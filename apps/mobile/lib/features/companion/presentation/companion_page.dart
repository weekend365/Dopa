import 'package:dopa/app/theme/dopa_tokens.dart';
import 'package:dopa/features/companion/application/companion_controller.dart';
import 'package:dopa/features/companion/presentation/companion_copy.dart';
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
  final _scroll = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state != AppLifecycleState.resumed &&
        ref.read(companionSampleEnabledProvider)) {
      ref.read(companionControllerProvider.notifier).pause();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _scroll.dispose();
    super.dispose();
  }

  void _home() {
    ref.read(companionControllerProvider.notifier).pause();
    context.go('/today');
  }

  @override
  Widget build(BuildContext context) {
    if (!ref.watch(companionSampleEnabledProvider)) {
      return const Scaffold(body: Center(child: Text('아직 공개되지 않은 안내예요.')));
    }
    final state = ref.watch(companionControllerProvider);
    final controller = ref.read(companionControllerProvider.notifier);
    ref.listen(companionControllerProvider, (before, after) {
      if (before?.run?.stepIndex != after.run?.stepIndex ||
          before?.run?.awaitingOutcome != after.run?.awaitingOutcome ||
          before?.record != after.record) {
        if (_scroll.hasClients) _scroll.jumpTo(0);
      }
    });
    final run = state.run;
    final record = state.record;
    final blocked = state.busy || state.loading;
    return PopScope(
      canPop: !state.busy,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) controller.pause();
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('같이 시작하기'),
          leading: IconButton(
            tooltip: '오늘로 돌아가기',
            onPressed: blocked ? null : _home,
            icon: const Icon(Icons.arrow_back),
          ),
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            controller: _scroll,
            padding: const EdgeInsets.all(DopaSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text('무료 · 개발용 텍스트 안내 샘플'),
                const SizedBox(height: DopaSpacing.md),
                if (state.loading)
                  const Center(child: CircularProgressIndicator())
                else if (state.failure ==
                    CompanionFailure.contentUnavailable) ...[
                  const Text('저장된 버전의 안내를 열 수 없어요. 기록은 그대로 보관하고 있어요.'),
                  TextButton(onPressed: _home, child: const Text('오늘로 돌아가기')),
                ] else ...[
                  if (state.failure != null) ...[
                    Semantics(
                      liveRegion: true,
                      child: const Text(
                        '기록을 불러오거나 저장하지 못했어요. 아래 동작을 다시 시도해주세요.',
                      ),
                    ),
                    if (run == null)
                      OutlinedButton(
                        onPressed: blocked ? null : controller.load,
                        child: const Text('다시 불러오기'),
                      ),
                    const SizedBox(height: DopaSpacing.md),
                  ],
                  if (record != null) ...[
                    Semantics(
                      header: true,
                      liveRegion: true,
                      child: Text(
                        '생활 행동 기록을 남겼어요',
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                    ),
                    const SizedBox(height: DopaSpacing.lg),
                    Text(companionOutcomeLabel(record.outcome)),
                    const SizedBox(height: DopaSpacing.md),
                    Text(
                      companionClosingCopy(record.outcome),
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                    const SizedBox(height: DopaSpacing.lg),
                    FilledButton(
                      onPressed: _home,
                      child: const Text('오늘은 여기까지'),
                    ),
                    TextButton(
                      onPressed: () => context.go('/companion/history'),
                      child: const Text('생활 행동 기록 보기'),
                    ),
                  ] else if (run == null) ...[
                    Semantics(
                      header: true,
                      child: Text(
                        deskCompanionContent.title,
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                    ),
                    const SizedBox(height: DopaSpacing.md),
                    const Text('약 2분 · 안내 분량이며 일을 끝내야 하는 제한시간은 아니에요.'),
                    const SizedBox(height: DopaSpacing.md),
                    Text(
                      deskCompanionContent.preparation,
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                    const SizedBox(height: DopaSpacing.md),
                    const Text('글을 읽으며 따라가는 샘플이에요. 영상과 음성은 아직 제공하지 않아요.'),
                    const SizedBox(height: DopaSpacing.lg),
                    FilledButton(
                      key: const ValueKey('companion-start'),
                      onPressed: blocked || state.failure != null
                          ? null
                          : controller.start,
                      child: const Text('같이 시작하기'),
                    ),
                  ] else if (run.awaitingOutcome) ...[
                    Semantics(
                      header: true,
                      liveRegion: true,
                      child: Text(
                        run.guideCompleted ? '안내가 끝났어요' : '오늘은 여기까지 해도 괜찮아요',
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                    ),
                    const SizedBox(height: DopaSpacing.md),
                    const Text('실제로 해본 만큼 골라주세요. 안내를 끝까지 보지 않아도 괜찮아요.'),
                    const SizedBox(height: DopaSpacing.lg),
                    for (final outcome in CompanionOutcome.values) ...[
                      OutlinedButton(
                        key: ValueKey('companion-outcome-${outcome.name}'),
                        style: OutlinedButton.styleFrom(
                          minimumSize: const Size(48, 52),
                        ),
                        onPressed: blocked
                            ? null
                            : () => controller.submit(outcome),
                        child: Text(companionOutcomeLabel(outcome)),
                      ),
                      const SizedBox(height: DopaSpacing.sm),
                    ],
                    TextButton(
                      onPressed: blocked ? null : _home,
                      child: const Text('결과는 나중에 남기기'),
                    ),
                  ] else ...[
                    Text(
                      deskCompanionContent.title,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: DopaSpacing.md),
                    Semantics(
                      liveRegion: true,
                      header: true,
                      child: Text(
                        '${run.stepIndex + 1} / ${run.stepCount} 안내',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                    ),
                    const SizedBox(height: DopaSpacing.lg),
                    Text(
                      deskCompanionContent.steps[run.stepIndex],
                      key: const ValueKey('companion-step-text'),
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: DopaSpacing.lg),
                    Text(
                      state.playing
                          ? '천천히 해봐요. 지금 다 하지 않아도 괜찮아요.'
                          : '잠시 멈췄어요. 준비되면 이어가세요.',
                    ),
                    const SizedBox(height: DopaSpacing.md),
                    FilledButton(
                      key: const ValueKey('companion-play-pause'),
                      onPressed: blocked
                          ? null
                          : state.playing
                          ? controller.pause
                          : controller.play,
                      child: Text(state.playing ? '일시정지' : '이어하기'),
                    ),
                    const SizedBox(height: DopaSpacing.xs),
                    OutlinedButton(
                      key: const ValueKey('companion-next'),
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size(48, 52),
                      ),
                      onPressed: blocked ? null : controller.next,
                      child: Text(
                        run.stepIndex == run.stepCount - 1
                            ? '안내 마치고 결과 선택'
                            : '다음 안내',
                      ),
                    ),
                    TextButton(
                      onPressed: blocked
                          ? null
                          : () {
                              controller.replayGuide();
                              _scroll.jumpTo(0);
                            },
                      child: const Text('이 안내 다시 보기'),
                    ),
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('안내 자동 넘김'),
                      subtitle: const Text(
                        '켜면 각 안내를 30초 동안 보여줘요. 행동 완료는 직접 확인해요.',
                      ),
                      value: state.automatic,
                      onChanged: blocked ? null : controller.setAutomatic,
                    ),
                    TextButton(
                      onPressed: blocked ? null : controller.finishGuide,
                      child: const Text('여기서 마치고 결과 선택'),
                    ),
                    TextButton(
                      onPressed: blocked ? null : _home,
                      child: const Text('나중에 이어하기'),
                    ),
                  ],
                  if (state.busy)
                    Padding(
                      padding: const EdgeInsets.all(DopaSpacing.md),
                      child: Semantics(
                        liveRegion: true,
                        child: const Text('기록을 저장하고 있어요.'),
                      ),
                    ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
