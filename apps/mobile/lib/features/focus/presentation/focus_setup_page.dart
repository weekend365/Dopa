import 'package:dopa/app/presentation/dopa_destination_scaffold.dart';
import 'package:dopa/app/theme/dopa_tokens.dart';
import 'package:dopa/features/focus/application/focus_session_controller.dart';
import 'package:dopa/features/focus/application/focus_setup_controller.dart';
import 'package:dopa_domain/dopa_domain.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class FocusSetupPage extends ConsumerWidget {
  const FocusSetupPage({super.key});

  static const durationOptions = [5, 10, 25, 50];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(focusSetupControllerProvider);
    final setupController = ref.read(focusSetupControllerProvider.notifier);
    final sessionFlow = ref.watch(focusSessionControllerProvider);
    final recovery = ref.watch(focusSessionRecoveryProvider);
    final activeSession =
        sessionFlow.session != null && !sessionFlow.session!.isTerminal;

    return DopaDestinationScaffold(
      selectedIndex: 1,
      title: '집중',
      body: ListView(
        key: const ValueKey('focus-setup-page'),
        padding: const EdgeInsets.fromLTRB(
          DopaSpacing.md,
          DopaSpacing.sm,
          DopaSpacing.md,
          DopaSpacing.xl,
        ),
        children: [
          Text('얼마나 집중할까요?', style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: DopaSpacing.sm),
          Text(
            '짧게 시작해도 충분해요. 완료한 시도는 하루 한 번 나무에 남아요.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: DopaSpacing.lg),
          if (sessionFlow.recoveryKind == ActiveFocusRecoveryKind.invalidate)
            Padding(
              padding: const EdgeInsets.only(bottom: DopaSpacing.lg),
              child: Text(
                '이전 집중은 너무 오래되어 종료했어요. 같은 일로 다시 시작할 수 있어요.',
                key: const ValueKey('focus-recovery-invalidated'),
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
          if (sessionFlow.recoveryKind == ActiveFocusRecoveryKind.complete)
            Padding(
              padding: const EdgeInsets.only(bottom: DopaSpacing.lg),
              child: Text(
                '집중 시간이 지나 있어요. 돌아가서 완료할 수 있어요.',
                key: const ValueKey('focus-recovery-elapsed'),
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
          Semantics(
            label: '집중 시간 선택',
            child: Wrap(
              spacing: DopaSpacing.xs,
              runSpacing: DopaSpacing.xs,
              children: [
                for (final minutes in durationOptions)
                  ChoiceChip(
                    label: Text('$minutes분'),
                    selected: state.durationMinutes == minutes,
                    onSelected: (_) => setupController.selectDuration(minutes),
                  ),
              ],
            ),
          ),
          const SizedBox(height: DopaSpacing.xl),
          Text('원래 하려던 일', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: DopaSpacing.xs),
          TextFormField(
            key: ValueKey('focus-intention-${state.intention}'),
            initialValue: state.intention,
            minLines: 1,
            maxLines: 3,
            maxLength: FocusSession.maxIntentionLength,
            textInputAction: TextInputAction.done,
            inputFormatters: [
              LengthLimitingTextInputFormatter(FocusSession.maxIntentionLength),
            ],
            decoration: const InputDecoration(
              hintText: '예: 보고서 첫 문단 쓰기',
              border: OutlineInputBorder(),
            ),
            onChanged: setupController.updateIntention,
          ),
          const SizedBox(height: DopaSpacing.xl),
          Text('보호 방식', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: DopaSpacing.xs),
          RadioGroup<ProtectionMode>(
            groupValue: state.protectionMode,
            onChanged: (mode) {
              if (mode != null) {
                setupController.selectProtectionMode(mode);
              }
            },
            child: const Column(
              children: [
                _ProtectionModeTile(
                  title: '타이머만 사용',
                  subtitle: '앱 차단 없이 시간을 지켜봐요.',
                  value: ProtectionMode.timerOnly,
                ),
                _ProtectionModeTile(
                  title: '집중 보호',
                  subtitle: '권한과 기기 지원 상태에 따라 사용할 수 있어요.',
                  value: ProtectionMode.shield,
                ),
              ],
            ),
          ),
          const SizedBox(height: DopaSpacing.xl),
          FilledButton.icon(
            onPressed: sessionFlow.isBusy || recovery.isLoading
                ? null
                : activeSession
                ? () => context.push('/focus/progress')
                : () => _startFocus(context, ref, state),
            icon: const Icon(Icons.play_arrow_rounded),
            label: Text(
              sessionFlow.isBusy || recovery.isLoading
                  ? '세션 준비 중…'
                  : activeSession
                  ? '진행 중인 집중으로 돌아가기'
                  : '${state.durationMinutes}분 집중 시작',
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _startFocus(
    BuildContext context,
    WidgetRef ref,
    FocusSetupState setup,
  ) async {
    try {
      await ref.read(focusSessionControllerProvider.notifier).start(setup);
      if (context.mounted) {
        context.push('/focus/progress');
      }
    } on Object {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('세션을 저장하지 못했어요. 다시 시도해 주세요.')),
        );
      }
    }
  }
}

class _ProtectionModeTile extends StatelessWidget {
  const _ProtectionModeTile({
    required this.title,
    required this.subtitle,
    required this.value,
  });

  final String title;
  final String subtitle;
  final ProtectionMode value;

  @override
  Widget build(BuildContext context) {
    return RadioListTile<ProtectionMode>(
      contentPadding: EdgeInsets.zero,
      title: Text(title),
      subtitle: Text(subtitle),
      value: value,
    );
  }
}
