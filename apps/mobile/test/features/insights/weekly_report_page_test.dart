import 'package:dopa/features/insights/presentation/weekly_report_page.dart';
import 'package:dopa/features/experiment/application/daily_check_in_controller.dart';
import 'package:dopa/features/tree_companion/application/tree_companion_providers.dart';
import 'package:dopa/features/diary/application/diary_controller.dart';
import 'package:dopa_domain/dopa_domain.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../test_app.dart';

void main() {
  for (final width in [320.0, 390.0, 430.0]) {
    for (final brightness in Brightness.values) {
      for (final scale in [1.0, 2.0]) {
        testWidgets('combined history $width $brightness at $scale text', (
          t,
        ) async {
          t.view.physicalSize = Size(width, 800);
          t.view.devicePixelRatio = 1;
          addTearDown(t.view.resetPhysicalSize);
          addTearDown(t.view.resetDevicePixelRatio);
          await t.pumpWidget(
            ProviderScope(
              overrides: [
                treeProgressProvider.overrideWithValue(
                  const TreeGrowthPolicy().progressFor(3),
                ),
                weeklyGrowthDaysProvider.overrideWithValue(1),
                todaysCheckInProvider.overrideWithValue(null),
                diaryPreviewProvider('d').overrideWith((ref) async => null),
                activityRecordsProvider.overrideWith(
                  (ref) => Stream.value(const [
                    ActivityRecord(
                      'c',
                      'companion',
                      '2026-09-11',
                      '책상 한 칸 비우기',
                      '조금 시작했어요',
                    ),
                    ActivityRecord(
                      'f',
                      'focus',
                      '2026-09-11',
                      '책 읽기',
                      '5분 집중했어요',
                    ),
                    ActivityRecord(
                      'd',
                      'diary',
                      '2026-09-11',
                      '기억하고 싶은 순간',
                      '책 한 쪽을 읽었어요.',
                      route: '/diary/entry/d',
                    ),
                    ActivityRecord(
                      'e',
                      'focus',
                      '2026-09-10',
                      '나를 위한 집중',
                      '중간에 마쳤어요',
                    ),
                  ]),
                ),
              ],
              child: TestApp(
                brightness: brightness,
                textScale: scale,
                home: const WeeklyReportPage(),
              ),
            ),
          );
          await t.pumpAndSettle();
          await t.scrollUntilVisible(find.text('2026-09-11'), 150);
          expect(find.text('2026-09-11'), findsOneWidget);
          expect(find.text('조금 시작했어요'), findsOneWidget);
          await t.scrollUntilVisible(find.text('책 한 쪽을 읽었어요.'), 100);
          expect(find.byKey(const ValueKey('record-diary-d')), findsOneWidget);
          await t.scrollUntilVisible(find.text('중간에 마쳤어요'), 150);
          await t.scrollUntilVisible(find.text('오늘 사용은 내 의도와 맞았나요?'), 150);
          expect(t.takeException(), isNull);
        });
      }
    }
  }
  testWidgets('empty history invites first action', (t) async {
    await t.pumpWidget(
      ProviderScope(
        overrides: [
          treeProgressProvider.overrideWithValue(
            const TreeGrowthPolicy().progressFor(0),
          ),
          weeklyGrowthDaysProvider.overrideWithValue(0),
          todaysCheckInProvider.overrideWithValue(null),
          activityRecordsProvider.overrideWith((ref) => Stream.value([])),
        ],
        child: const TestApp(home: WeeklyReportPage()),
      ),
    );
    await t.pumpAndSettle();
    expect(find.text('같이 시작하기'), findsOneWidget);
  });
}
