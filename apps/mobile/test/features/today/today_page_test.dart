import 'package:dopa/features/today/presentation/today_page.dart';
import 'package:dopa/features/tree_companion/application/tree_companion_providers.dart';
import 'package:dopa_domain/dopa_domain.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../test_app.dart';

void main() {
  for (final width in [320.0, 390.0, 430.0]) {
    for (final brightness in Brightness.values) {
      for (final scale in [1.0, 2.0]) {
        testWidgets('today $width $brightness text $scale', (tester) async {
          tester.view.physicalSize = Size(width, 844);
          tester.view.devicePixelRatio = 1;
          addTearDown(tester.view.resetPhysicalSize);
          addTearDown(tester.view.resetDevicePixelRatio);
          await tester.pumpWidget(
            ProviderScope(
              overrides: [
                treeProgressProvider.overrideWithValue(
                  const TreeGrowthPolicy().progressFor(7),
                ),
                activeDestinationProvider.overrideWith(
                  (ref) => Stream.value(null),
                ),
              ],
              child: TestApp(
                brightness: brightness,
                textScale: scale,
                home: const TodayPage(),
              ),
            ),
          );
          await tester.pumpAndSettle();
          await tester.scrollUntilVisible(find.text('같이 시작하기'), 150);
          expect(find.text('같이 시작하기'), findsOneWidget);
          await tester.scrollUntilVisible(find.text('1분 쉬어가기'), 100);
          expect(find.text('오늘'), findsOneWidget);
          expect(find.text('기록'), findsOneWidget);
          expect(find.text('오늘 사용은 내 의도와 맞았나요?'), findsNothing);
          expect(tester.takeException(), isNull);
        });
      }
    }
  }
  testWidgets('unfinished activity changes primary action to resume', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          treeProgressProvider.overrideWithValue(
            const TreeGrowthPolicy().progressFor(0),
          ),
          activeDestinationProvider.overrideWith(
            (ref) => Stream.value('/companion'),
          ),
        ],
        child: const TestApp(home: TodayPage()),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('이어서 하기'), findsOneWidget);
  });
}
