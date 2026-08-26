import 'package:dopa/app/theme/dopa_tokens.dart';
import 'package:dopa/features/tree_companion/presentation/tree_artwork.dart';
import 'package:dopa/features/tree_companion/presentation/tree_copy.dart';
import 'package:dopa_domain/dopa_domain.dart';
import 'package:flutter/material.dart';

class TreeHeroCard extends StatelessWidget {
  const TreeHeroCard({
    required this.progress,
    required this.experimentDays,
    required this.experimentLength,
    required this.onStartFocus,
    super.key,
  });

  final TreeProgress progress;
  final int experimentDays;
  final int experimentLength;
  final VoidCallback onStartFocus;

  @override
  Widget build(BuildContext context) {
    return Card(
      key: const ValueKey('today-tree-hero'),
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.all(DopaSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(height: 236, child: TreeArtwork(progress: progress)),
            const SizedBox(height: DopaSpacing.sm),
            ExcludeSemantics(
              child: Text(
                treeStatusTitle(progress),
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
            ),
            const SizedBox(height: DopaSpacing.xs),
            Text(
              '쉬는 날에도 지금까지의 성장은 그대로 남아요.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: DopaSpacing.lg),
            _ExperimentProgress(
              attemptedDays: experimentDays,
              totalDays: experimentLength,
            ),
            const SizedBox(height: DopaSpacing.md),
            FilledButton.icon(
              onPressed: onStartFocus,
              icon: const Icon(Icons.play_arrow_rounded),
              label: const Text('10분 집중 시작'),
            ),
          ],
        ),
      ),
    );
  }
}

class ExperimentProgressCard extends StatelessWidget {
  const ExperimentProgressCard({
    required this.experimentDays,
    required this.experimentLength,
    required this.onStartFocus,
    super.key,
  });

  final int experimentDays;
  final int experimentLength;
  final VoidCallback onStartFocus;

  @override
  Widget build(BuildContext context) {
    return Card(
      key: const ValueKey('today-progress-fallback'),
      child: Padding(
        padding: const EdgeInsets.all(DopaSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('오늘의 실험', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: DopaSpacing.md),
            _ExperimentProgress(
              attemptedDays: experimentDays,
              totalDays: experimentLength,
            ),
            const SizedBox(height: DopaSpacing.lg),
            FilledButton.icon(
              onPressed: onStartFocus,
              icon: const Icon(Icons.play_arrow_rounded),
              label: const Text('10분 집중 시작'),
            ),
          ],
        ),
      ),
    );
  }
}

class _ExperimentProgress extends StatelessWidget {
  const _ExperimentProgress({
    required this.attemptedDays,
    required this.totalDays,
  });

  final int attemptedDays;
  final int totalDays;

  @override
  Widget build(BuildContext context) {
    final safeTotal = totalDays <= 0 ? 1 : totalDays;
    final value = (attemptedDays / safeTotal).clamp(0.0, 1.0).toDouble();
    return Semantics(
      label: '현재 실험 $attemptedDays/$totalDays일',
      value: '${(value * 100).round()}%',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  '현재 실험',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              Text(
                '$attemptedDays/$totalDays일',
                style: Theme.of(context).textTheme.titleMedium
                    ?.copyWith(fontWeight: FontWeight.w700),
              ),
            ],
          ),
          const SizedBox(height: DopaSpacing.xs),
          LinearProgressIndicator(
            value: value,
            minHeight: 8,
            borderRadius: BorderRadius.circular(DopaRadii.pill),
          ),
        ],
      ),
    );
  }
}
