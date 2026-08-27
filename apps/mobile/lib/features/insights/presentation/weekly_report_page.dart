import 'package:dopa/app/presentation/dopa_destination_scaffold.dart';
import 'package:dopa/app/theme/dopa_tokens.dart';
import 'package:dopa/features/tree_companion/application/tree_companion_providers.dart';
import 'package:dopa/features/tree_companion/application/tree_feature_flags.dart';
import 'package:dopa/features/tree_companion/presentation/tree_summary_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class WeeklyReportPage extends ConsumerWidget {
  const WeeklyReportPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progress = ref.watch(treeProgressProvider);
    final weeklyDays = ref.watch(weeklyGrowthDaysProvider);
    final attemptDays = ref.watch(experimentAttemptDaysProvider);
    final experimentLength = ref.watch(experimentLengthDaysProvider);
    final flags = ref.watch(treeFeatureFlagsProvider);

    return DopaDestinationScaffold(
      selectedIndex: 2,
      title: '주간 리포트',
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          DopaSpacing.md,
          DopaSpacing.sm,
          DopaSpacing.md,
          DopaSpacing.xl,
        ),
        children: [
          if (flags.treeUiEnabled) ...[
            TreeSummaryCard(progress: progress, weeklyGrowthDays: weeklyDays),
            const SizedBox(height: DopaSpacing.md),
          ],
          Card(
            child: Padding(
              padding: const EdgeInsets.all(DopaSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '이번 주의 흐름',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: DopaSpacing.md),
                  _ReportRow(
                    label: '시도한 날',
                    value: '$attemptDays/$experimentLength일',
                  ),
                  const SizedBox(height: DopaSpacing.md),
                  Text(
                    '쉬었던 날은 실패로 계산하지 않아요. 다음 시도를 가볍게 골라보세요.',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ReportRow extends StatelessWidget {
  const _ReportRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: Text(label)),
        Text(value, style: const TextStyle(fontWeight: FontWeight.w700)),
      ],
    );
  }
}
