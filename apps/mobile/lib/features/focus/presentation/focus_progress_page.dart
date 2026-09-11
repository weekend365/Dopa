import 'dart:async';

import 'package:dopa/app/theme/dopa_tokens.dart';
import 'package:dopa/features/focus/application/focus_session_controller.dart';
import 'package:dopa/features/focus/application/focus_setup_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class FocusProgressPage extends ConsumerStatefulWidget {
  const FocusProgressPage({super.key});

  @override
  ConsumerState<FocusProgressPage> createState() => _FocusProgressPageState();
}

class _FocusProgressPageState extends ConsumerState<FocusProgressPage> {
  Timer? _ticker;

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final setup = ref.watch(focusSetupControllerProvider);
    final sessionFlow = ref.watch(focusSessionControllerProvider);
    final session = sessionFlow.session;
    final remaining = session == null
        ? Duration(minutes: setup.durationMinutes)
        : _remainingFor(
            startedAtUtc: session.startedAtUtc,
            duration: session.plannedDuration,
          );
    final announcedMinutes = session?.preset.minutes ?? setup.durationMinutes;
    final plannedSeconds =
        session?.plannedDuration.inSeconds ?? setup.durationMinutes * 60;
    final elapsedFraction = plannedSeconds == 0
        ? 1.0
        : 1 - remaining.inMilliseconds / (plannedSeconds * 1000);
    final canComplete = session != null && remaining == Duration.zero;
    if (session != null && !canComplete) {
      _ensureTicker();
    } else {
      _ticker?.cancel();
      _ticker = null;
    }

    return Scaffold(
      key: const ValueKey('focus-progress-page'),
      appBar: AppBar(
        leading: IconButton(
          tooltip: '집중 종료',
          onPressed: sessionFlow.isBusy
              ? null
              : () => _confirmEarlyExit(context),
          icon: const Icon(Icons.close),
        ),
        title: const Text('집중 중'),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
      ),
      body: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: EdgeInsets.all(DopaSpacing.page(context)),
          child: Column(
            children: [
              const SizedBox(height: 32),
              Semantics(
                excludeSemantics: true,
                label: '$announcedMinutes분 중 남은 시간',
                value: _timerLabel(remaining),
                child: SizedBox.square(
                  dimension: 260,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      SizedBox.expand(
                        child: CircularProgressIndicator(
                          value: elapsedFraction.clamp(0.0, 1.0).toDouble(),
                          strokeWidth: 8,
                          strokeCap: StrokeCap.round,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            _timerLabel(remaining),
                            style: Theme.of(context).textTheme.displayMedium,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: DopaSpacing.xl),
              Text('원래 하려던 일', style: Theme.of(context).textTheme.labelLarge),
              const SizedBox(height: DopaSpacing.xs),
              Text(
                setup.intention.isEmpty ? '정한 일에 잠시 머물러 보세요.' : setup.intention,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 32),

              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: sessionFlow.isBusy || !canComplete
                      ? null
                      : () => _complete(context),
                  child: Text(
                    sessionFlow.isBusy
                        ? '기록 중…'
                        : canComplete
                        ? '세션 완료'
                        : '집중이 끝나면 완료할 수 있어요',
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _ensureTicker() {
    _ticker ??= Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() {});
    });
  }

  Duration _remainingFor({
    required DateTime startedAtUtc,
    required Duration duration,
  }) {
    final completesAt = startedAtUtc.add(duration);
    final remaining = completesAt.difference(
      ref.read(localNowProvider)().toUtc(),
    );
    return remaining.isNegative ? Duration.zero : remaining;
  }

  String _timerLabel(Duration remaining) {
    final totalSeconds = (remaining.inMilliseconds + 999) ~/ 1000;
    final minutes = totalSeconds ~/ 60;
    final seconds = totalSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:'
        '${seconds.toString().padLeft(2, '0')}';
  }

  Future<void> _complete(BuildContext context) async {
    try {
      final data = await ref
          .read(focusSessionControllerProvider.notifier)
          .complete();
      if (context.mounted) {
        context.go('/focus/completion/${data.kind.name}', extra: data);
      }
    } on FocusSessionNotElapsedException {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('집중 시간이 끝난 뒤 완료할 수 있어요.')));
      }
    } on Object {
      if (context.mounted) _showSaveError(context);
    }
  }

  Future<void> _confirmEarlyExit(BuildContext context) async {
    final leave = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('집중을 끝낼까요?'),
        content: const Text('지금까지의 시도는 기록으로 남아요. 준비되면 다시 시작할 수 있어요.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('계속 집중'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('종료'),
          ),
        ],
      ),
    );
    if (leave != true) return;
    try {
      await ref.read(focusSessionControllerProvider.notifier).endEarly();
      if (context.mounted) context.go('/today');
    } on Object {
      if (context.mounted) _showSaveError(context);
    }
  }

  void _showSaveError(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('세션 기록을 저장하지 못했어요. 다시 시도해 주세요.')),
    );
  }
}
