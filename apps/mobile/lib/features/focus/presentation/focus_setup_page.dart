import 'package:dopa/app/theme/dopa_tokens.dart';
import 'package:dopa/app/presentation/dopa_components.dart';
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
    final setup = ref.read(focusSetupControllerProvider.notifier);
    final flow = ref.watch(focusSessionControllerProvider);
    final recovery = ref.watch(focusSessionRecoveryProvider);
    final active = flow.session != null && !flow.session!.isTerminal;
    return Scaffold(
      appBar: AppBar(title: const Text('잠시 집중하기')),
      body: SafeArea(
        child: ListView(
          key: const ValueKey('focus-setup-page'),
          padding: EdgeInsets.all(DopaSpacing.page(context)),
          children: [
            const SizedBox(height: 16),
            Text(
              '얼마나 머물러볼까요?',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 12),
            const Text('짧게 시작해도 충분해요.\n앱 차단 없이 시간을 지켜보는 타이머예요.'),
            const SizedBox(height: 32),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final m in durationOptions)
                  ChoiceChip(
                    label: Text('$m분'),
                    selected: state.durationMinutes == m,
                    onSelected: active ? null : (_) => setup.selectDuration(m),
                  ),
              ],
            ),
            const SizedBox(height: 24),
            if (flow.recoveryKind == ActiveFocusRecoveryKind.invalidate)
              const DopaNotice(message: '이전 집중은 시간이 많이 지나 마쳤어요. 다시 시작할 수 있어요.'),
            if (recovery.hasError)
              DopaNotice(
                message: '이전 집중을 확인하지 못했어요.',
                isError: true,
                onRetry: () => ref.invalidate(focusSessionRecoveryProvider),
              ),
            DopaActionButton(
              label: active
                  ? '진행 중인 집중으로 돌아가기'
                  : '${state.durationMinutes}분 집중 시작',
              busy: flow.isBusy || recovery.isLoading,
              onPressed: recovery.hasError
                  ? null
                  : () async {
                      if (active) {
                        context.push('/focus/progress');
                        return;
                      }
                      setup.selectProtectionMode(ProtectionMode.timerOnly);
                      try {
                        await ref
                            .read(focusSessionControllerProvider.notifier)
                            .start(ref.read(focusSetupControllerProvider));
                        if (context.mounted) context.push('/focus/progress');
                      } on Object {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('세션을 저장하지 못했어요. 다시 시도해 주세요.'),
                            ),
                          );
                        }
                      }
                    },
            ),
            const SizedBox(height: 32),
            TextFormField(
              key: ValueKey('focus-intention-${flow.session?.id ?? 'new'}'),
              initialValue: state.intention,
              minLines: 1,
              maxLines: 3,
              maxLength: FocusSession.maxIntentionLength,
              textInputAction: TextInputAction.done,
              inputFormatters: [
                LengthLimitingTextInputFormatter(
                  FocusSession.maxIntentionLength,
                ),
              ],
              decoration: const InputDecoration(
                labelText: '원래 하려던 일 · 선택',
                hintText: '예: 보고서 첫 문단 쓰기',
              ),
              onChanged: setup.updateIntention,
            ),
          ],
        ),
      ),
    );
  }
}
