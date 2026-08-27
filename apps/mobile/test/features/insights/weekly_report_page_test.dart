import 'package:dopa/features/insights/presentation/weekly_report_page.dart';
import 'package:dopa/features/tree_companion/application/tree_companion_providers.dart';
import 'package:dopa_domain/dopa_domain.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../test_app.dart';

void main() {
  testWidgets('weekly report summarizes tree growth without streak language', (
    tester,
  ) async {
    const policy = TreeGrowthPolicy();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          treeProgressProvider.overrideWithValue(policy.progressFor(30)),
          weeklyGrowthDaysProvider.overrideWithValue(3),
          experimentAttemptDaysProvider.overrideWithValue(4),
        ],
        child: const TestApp(home: WeeklyReportPage()),
      ),
    );

    expect(find.text('함께 자란 30일 · 가지를 펴는 나무'), findsOneWidget);
    expect(find.text('이번 주 3일'), findsOneWidget);
    expect(find.text('4/7일'), findsOneWidget);
    expect(find.textContaining('스트릭'), findsNothing);
    expect(find.byKey(const ValueKey('weekly-tree-summary')), findsOneWidget);
  });
}
