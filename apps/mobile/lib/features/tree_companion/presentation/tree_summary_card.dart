import 'package:dopa/app/theme/dopa_tokens.dart';
import 'package:dopa/features/tree_companion/presentation/tree_artwork.dart';
import 'package:dopa/features/tree_companion/presentation/tree_copy.dart';
import 'package:dopa_domain/dopa_domain.dart';
import 'package:flutter/material.dart';

class TreeSummaryCard extends StatelessWidget {
  const TreeSummaryCard({
    required this.progress,
    required this.weeklyGrowthDays,
    super.key,
  });

  final TreeProgress progress;
  final int weeklyGrowthDays;

  @override
  Widget build(BuildContext context) {
    return Card(
      key: const ValueKey('weekly-tree-summary'),
      child: Padding(
        padding: const EdgeInsets.all(DopaSpacing.lg),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final compact = constraints.maxWidth < 360;
            final artwork = SizedBox(
              width: compact ? double.infinity : 150,
              height: 150,
              child: TreeArtwork(progress: progress),
            );
            final copy = Column(
              crossAxisAlignment: compact
                  ? CrossAxisAlignment.center
                  : CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ExcludeSemantics(
                  child: Text(
                    treeStatusTitle(progress),
                    textAlign: compact ? TextAlign.center : TextAlign.start,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
                const SizedBox(height: DopaSpacing.xs),
                Text(
                  '이번 주 $weeklyGrowthDays일',
                  style: Theme.of(context).textTheme.bodyLarge
                      ?.copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: DopaSpacing.xs),
                Text(
                  '하루 한 번의 시도가 나무에 남았어요.',
                  textAlign: compact ? TextAlign.center : TextAlign.start,
                ),
              ],
            );

            if (compact) {
              return Column(children: [artwork, copy]);
            }
            return Row(
              children: [
                artwork,
                const SizedBox(width: DopaSpacing.md),
                Expanded(child: copy),
              ],
            );
          },
        ),
      ),
    );
  }
}
