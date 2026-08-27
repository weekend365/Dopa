import 'package:dopa/app/theme/dopa_tokens.dart';
import 'package:dopa/features/tree_companion/application/tree_companion_providers.dart';
import 'package:dopa/features/tree_companion/application/tree_feature_flags.dart';
import 'package:dopa/features/tree_companion/presentation/tree_artwork.dart';
import 'package:dopa/features/tree_companion/presentation/tree_copy.dart';
import 'package:dopa/features/tree_companion/presentation/tree_renderer.dart';
import 'package:dopa_domain/dopa_domain.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class FocusCompletionPage extends ConsumerWidget {
  const FocusCompletionPage({required this.data, super.key});

  final TreeCompletionViewData data;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cue = switch (data.kind) {
      TreeCompletionKind.milestone => TreeAnimationCue.reveal,
      TreeCompletionKind.growthPulse => TreeAnimationCue.pulse,
      TreeCompletionKind.postMatureRing => TreeAnimationCue.ring,
      TreeCompletionKind.alreadyCredited => TreeAnimationCue.none,
    };
    final treeUiEnabled = ref.watch(treeFeatureFlagsProvider).treeUiEnabled;
    final isMilestone = data.kind == TreeCompletionKind.milestone;
    final content = <Widget>[
      if (treeUiEnabled)
        SizedBox(
          height: isMilestone ? 360 : 280,
          child: TreeArtwork(progress: data.progress, animationCue: cue),
        )
      else
        const Padding(
          padding: EdgeInsets.symmetric(vertical: DopaSpacing.xxl),
          child: Icon(
            Icons.check_circle_outline_rounded,
            key: ValueKey('completion-generic-icon'),
            size: 72,
          ),
        ),
      const SizedBox(height: DopaSpacing.md),
      Semantics(
        liveRegion: true,
        child: Text(
          treeUiEnabled ? _title : '집중을 마쳤어요',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.headlineSmall,
        ),
      ),
      const SizedBox(height: DopaSpacing.xs),
      if (treeUiEnabled) ...[
        ExcludeSemantics(
          child: Text(
            treeStatusTitle(data.progress),
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ),
        const SizedBox(height: DopaSpacing.sm),
      ],
      Text(
        treeUiEnabled ? _description : '오늘의 집중 시도를 완료로 기록했어요.',
        textAlign: TextAlign.center,
        style: Theme.of(context).textTheme.bodyMedium,
      ),
      const SizedBox(height: DopaSpacing.md),
    ];
    final actions = _CompletionActions(onFinish: _finish(context));
    final largeText = MediaQuery.textScalerOf(context).scale(1) >= 1.5;

    return Scaffold(
      key: ValueKey('completion-${data.kind.name}'),
      body: SafeArea(
        child: largeText
            ? SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(
                  DopaSpacing.lg,
                  DopaSpacing.xl,
                  DopaSpacing.lg,
                  DopaSpacing.lg,
                ),
                child: Column(children: [...content, actions]),
              )
            : Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(
                        DopaSpacing.lg,
                        DopaSpacing.xl,
                        DopaSpacing.lg,
                        0,
                      ),
                      child: Column(children: content),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(
                      DopaSpacing.lg,
                      DopaSpacing.xs,
                      DopaSpacing.lg,
                      DopaSpacing.lg,
                    ),
                    child: actions,
                  ),
                ],
              ),
      ),
    );
  }

  VoidCallback _finish(BuildContext context) =>
      () => context.go('/today');

  String get _title => switch (data.kind) {
    TreeCompletionKind.milestone => _milestoneTitle,
    TreeCompletionKind.growthPulse => '오늘의 성장이 남았어요',
    TreeCompletionKind.postMatureRing => '나이테가 하나 더 새겨졌어요',
    TreeCompletionKind.alreadyCredited => '오늘의 성장은 이미 남겨졌어요',
  };

  String get _description => switch (data.kind) {
    TreeCompletionKind.milestone => _milestoneDescription,
    TreeCompletionKind.growthPulse => '완료한 시간의 길이와 관계없이 오늘의 시도를 한 번 기록했어요.',
    TreeCompletionKind.postMatureRing => '성목이 된 뒤의 시도도 나무 곁에 조용히 계속 쌓여요.',
    TreeCompletionKind.alreadyCredited => '세션 완료는 그대로 인정돼요. 나무는 하루에 한 번만 자라요.',
  };

  String get _milestoneTitle => switch (data.progress.stage) {
    TreeGrowthStage.seed => '씨앗과 함께 시작해요',
    TreeGrowthStage.sprout => '첫 새싹이 올라왔어요',
    TreeGrowthStage.sapling => '묘목으로 자랐어요',
    TreeGrowthStage.smallTree => '작은 나무가 되었어요',
    TreeGrowthStage.youngZelkova => '어린 느티나무가 되었어요',
    TreeGrowthStage.spreadingBranches => '가지가 한층 넓어졌어요',
    TreeGrowthStage.broadCanopy => '넓은 수관이 펼쳐졌어요',
    TreeGrowthStage.mature => '느티나무가 성목이 되었어요',
  };

  String get _milestoneDescription =>
      data.progress.stage == TreeGrowthStage.sprout
      ? '완료한 오늘의 시도 하나가 나무의 첫 성장일이 되었어요.'
      : '오늘의 시도 한 번이 쌓여 새로운 성장 단계에 도착했어요.';
}

class _CompletionActions extends StatelessWidget {
  const _CompletionActions({required this.onFinish});

  final VoidCallback onFinish;

  @override
  Widget build(BuildContext context) {
    return Column(
      key: const ValueKey('completion-immediate-actions'),
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          '오늘 사용은 내 의도와 맞았나요?',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: DopaSpacing.md),
        Wrap(
          alignment: WrapAlignment.center,
          spacing: DopaSpacing.xs,
          runSpacing: DopaSpacing.xs,
          children: [
            _CheckInButton(label: '맞았어요', onPressed: onFinish),
            _CheckInButton(label: '아니었어요', onPressed: onFinish),
            _CheckInButton(label: '건너뛰기', onPressed: onFinish),
          ],
        ),
        const SizedBox(height: DopaSpacing.md),
        SizedBox(
          width: double.infinity,
          child: FilledButton(
            onPressed: onFinish,
            child: const Text('오늘로 돌아가기'),
          ),
        ),
      ],
    );
  }
}

class _CheckInButton extends StatelessWidget {
  const _CheckInButton({required this.label, required this.onPressed});

  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(onPressed: onPressed, child: Text(label));
  }
}
