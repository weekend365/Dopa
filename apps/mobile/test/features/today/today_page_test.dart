import 'package:dopa/features/today/presentation/today_page.dart';
import 'package:dopa/features/tree_companion/application/tree_companion_providers.dart';
import 'package:dopa/features/tree_companion/application/tree_feature_flags.dart';
import 'package:dopa_domain/dopa_domain.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../test_app.dart';

void main() {
  const policy = TreeGrowthPolicy();

  testWidgets('Today combines tree, experiment progress, and focus CTA', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          treeProgressProvider.overrideWithValue(policy.progressFor(7)),
          experimentAttemptDaysProvider.overrideWithValue(3),
        ],
        child: const TestApp(home: TodayPage()),
      ),
    );

    expect(find.text('함께 자란 7일 · 작은 나무'), findsOneWidget);
    expect(find.text('3/7일'), findsOneWidget);
    expect(find.text('10분 집중 시작'), findsOneWidget);
    expect(find.byKey(const ValueKey('today-tree-hero')), findsOneWidget);
  });

  testWidgets('tree UI kill switch preserves focus and experiment actions', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          treeFeatureFlagsProvider.overrideWithValue(
            const TreeFeatureFlags(treeUiEnabled: false),
          ),
          experimentAttemptDaysProvider.overrideWithValue(3),
        ],
        child: const TestApp(home: TodayPage()),
      ),
    );

    expect(find.byKey(const ValueKey('today-tree-hero')), findsNothing);
    expect(
      find.byKey(const ValueKey('today-progress-fallback')),
      findsOneWidget,
    );
    expect(find.text('3/7일'), findsOneWidget);
    expect(find.text('10분 집중 시작'), findsOneWidget);
  });

  testWidgets('Today remains operable at 200 percent text scale', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          treeProgressProvider.overrideWithValue(policy.progressFor(14)),
        ],
        child: const TestApp(textScale: 2, home: TodayPage()),
      ),
    );

    await tester.drag(find.byType(ListView).first, const Offset(0, -500));
    await tester.pump();
    expect(tester.takeException(), isNull);
    expect(find.text('10분 집중 시작'), findsOneWidget);
  });
}
