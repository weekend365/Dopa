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
        child: Padding(
          padding: const EdgeInsets.all(DopaSpacing.lg),
          child: Column(
            children: [
              const Spacer(),
              Semantics(
                label: '$announcedMinutes분 중 남은 시간',
                value: _timerLabel(remaining),
                child: SizedBox.square(
                  dimension: 220,
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
                      Text(
                        _timerLabel(remaining),
                        style: Theme.of(context).textTheme.displaySmall,
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
              const Spacer(),
              OutlinedButton.icon(
                onPressed: sessionFlow.isBusy || session == null
                    ? null
                    : () => _allowBypass(context),
                icon: const Icon(Icons.lock_open_outlined),
                label: const Text('5분만 허용'),
              ),
              const SizedBox(height: DopaSpacing.sm),
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

  Future<void> _allowBypass(BuildContext context) async {
    try {
      await ref
          .read(focusSessionControllerProvider.notifier)
          .allowFiveMinuteBypass();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('5분 우회를 허용했어요. 세션을 완료하면 시도는 남아요.')),
        );
      }
    } on Object {
      if (context.mounted) _showSaveError(context);
    }
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
        content: const Text('일찍 끝낸 세션은 나무의 성장일로 기록되지 않아요.'),
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
