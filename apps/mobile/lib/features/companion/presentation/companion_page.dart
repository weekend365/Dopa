import 'package:dopa/app/theme/dopa_tokens.dart';
import 'package:dopa/app/presentation/dopa_components.dart';
import 'package:dopa/features/companion/application/companion_controller.dart';
import 'package:dopa/features/companion/presentation/companion_copy.dart';
import 'package:dopa/features/focus/application/focus_setup_controller.dart';
import 'package:dopa/features/tree_companion/presentation/garden_artwork.dart';
import 'package:dopa/features/tree_companion/application/tree_companion_providers.dart';
import 'package:dopa_domain/dopa_domain.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class CompanionPage extends ConsumerStatefulWidget {
  const CompanionPage({super.key});
  @override
  ConsumerState<CompanionPage> createState() => _CompanionPageState();
}

class _CompanionPageState extends ConsumerState<CompanionPage>
    with WidgetsBindingObserver {
  final scroll = ScrollController();
  CompanionContent selected = deskCompanionContent;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    scroll.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state != AppLifecycleState.resumed) {
      ref.read(companionControllerProvider.notifier).pause();
    }
  }

  void home() {
    ref.read(companionControllerProvider.notifier).pause();
    context.go('/today');
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(companionControllerProvider);
    final controller = ref.read(companionControllerProvider.notifier);
    final run = state.run;
    final record = state.record;
    final content = run == null
        ? selected
        : companionContentFor(run.contentId, run.contentVersion);
    final busy = state.busy || state.loading;
    ref.listen(companionControllerProvider, (before, after) {
      if (before?.run?.stepIndex != after.run?.stepIndex ||
          before?.record != after.record ||
          before?.run?.awaitingOutcome != after.run?.awaitingOutcome) {
        if (scroll.hasClients) scroll.jumpTo(0);
      }
    });
    return PopScope(
      canPop: !state.busy,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) controller.pause();
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('같이 시작하기'),
          leading: IconButton(
            tooltip: '나중에 이어하기',
            onPressed: busy ? null : home,
            icon: const Icon(Icons.arrow_back),
          ),
        ),
        body: SafeArea(
          child: ListView(
            controller: scroll,
            padding: EdgeInsets.all(DopaSpacing.page(context)),
            children: [
              if (state.loading)
                const Center(child: CircularProgressIndicator())
              else if (state.failure == CompanionFailure.contentUnavailable)
                DopaNotice(
                  message: '저장된 안내를 열 수 없어요. 기록은 그대로 보관하고 있어요.',
                  isError: true,
                  onRetry: controller.load,
                )
              else ...[
                if (state.failure != null)
                  DopaNotice(
                    message: '기록을 불러오거나 저장하지 못했어요. 같은 동작을 다시 시도해 주세요.',
                    isError: true,
                    onRetry: run == null ? controller.load : null,
                  ),
                if (record != null) ...[
                  SizedBox(
                    height: 160,
                    child: GardenArtwork(
                      progress: ref.watch(treeProgressProvider),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    record.outcome == CompanionOutcome.difficult
                        ? '오늘은 여기까지 해도 괜찮아요.'
                        : record.outcome == CompanionOutcome.asPlanned
                        ? switch (run!.contentId) {
                            'desk_space' => '책상 한 칸을 비웠어요.',
                            'open_book' => '책을 펼치고 읽어봤어요.',
                            _ => '미룬 일에 손을 대봤어요.',
                          }
                        : '작은 시작을 남겼어요.',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    '${companionContentTitle(record.run.contentId, record.run.contentVersion)} · ${companionOutcomeLabel(record.outcome)}',
                  ),
                  const SizedBox(height: 8),
                  Text(companionClosingCopy(record.outcome)),
                  const SizedBox(height: 32),
                  DopaActionButton(
                    label: '5분 더 집중하기',
                    onPressed: () {
                      ref
                          .read(focusSetupControllerProvider.notifier)
                          .selectDuration(5);
                      context.go('/focus');
                    },
                  ),
                  const SizedBox(height: 12),
                  TextButton(onPressed: home, child: const Text('여기서 마치기')),
                  TextButton(
                    onPressed: () => context.go('/insights/weekly'),
                    child: const Text('오늘의 기록 돌아보기'),
                  ),
                ] else if (run == null) ...[
                  Text(
                    '어디서부터 시작할까요?',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 8),
                  const Text('지금 필요한 작은 일 하나를 골라요.'),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (final option in companionContents)
                        ChoiceChip(
                          key: ValueKey('guide-${option.id}'),
                          label: Text(
                            companionContentTitle(option.id, option.version),
                          ),
                          selected: selected.id == option.id,
                          onSelected: busy
                              ? null
                              : (_) => setState(() => selected = option),
                        ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Text(content!.preparation),
                  const SizedBox(height: 16),
                  const Text(
                    '4단계 · 약 2분 분량의 글 안내\n시간제한 없이, 한 동작을 해본 뒤 다음을 눌러요.',
                  ),
                  const SizedBox(height: 32),
                  DopaActionButton(
                    key: const ValueKey('companion-start'),
                    label: '같이 시작하기',
                    busy: busy,
                    onPressed: state.failure == null
                        ? () => controller.start(content: selected)
                        : null,
                  ),
                ] else if (run.awaitingOutcome) ...[
                  Text(
                    '실제로 해본 만큼만',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 16),
                  const Text('조금 시작한 것도 충분해요.\n오늘의 결과를 직접 골라주세요.'),
                  const SizedBox(height: 32),
                  for (final outcome in CompanionOutcome.values) ...[
                    OutlinedButton(
                      key: ValueKey('companion-outcome-${outcome.name}'),
                      onPressed: busy ? null : () => controller.submit(outcome),
                      child: Text(companionOutcomeLabel(outcome)),
                    ),
                    const SizedBox(height: 12),
                  ],
                  TextButton(
                    onPressed: busy ? null : home,
                    child: const Text('결과는 나중에 남기기'),
                  ),
                ] else ...[
                  Text(
                    companionContentTitle(run.contentId, run.contentVersion),
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 24),
                  DopaStep(
                    key: const ValueKey('companion-step-text'),
                    index: run.stepIndex,
                    total: run.stepCount,
                    text: content!.steps[run.stepIndex],
                  ),
                  const SizedBox(height: 24),
                  const Text('서두르지 않아도 괜찮아요. 준비되면 다음으로 넘어가요.'),
                  const SizedBox(height: 32),
                  DopaActionButton(
                    key: const ValueKey('companion-next'),
                    label: run.stepIndex == run.stepCount - 1
                        ? '안내 마치고 결과 선택'
                        : '다음',
                    busy: busy,
                    onPressed: controller.next,
                  ),
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: busy ? null : controller.finishGuide,
                    child: const Text('여기서 마치고 결과 선택'),
                  ),
                  TextButton(
                    onPressed: busy ? null : home,
                    child: const Text('나중에 이어하기'),
                  ),
                ],
              ],
            ],
          ),
        ),
      ),
    );
  }
}
