import 'package:dopa/features/focus/application/focus_session_controller.dart';
import 'package:dopa/features/focus/presentation/focus_completion_page.dart';
import 'package:dopa/features/focus/presentation/focus_progress_page.dart';
import 'package:dopa/features/tree_companion/application/tree_companion_providers.dart';
import 'package:dopa/features/tree_companion/application/tree_feature_flags.dart';
import 'package:dopa/features/tree_companion/presentation/tree_artwork.dart';
import 'package:dopa_domain/dopa_domain.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../test_app.dart';

void main() {
  test('completion route tokens round-trip without route extras', () {
    expect(
      TreeCompletionViewData.forRoute(TreeCompletionKind.growthPulse.name).kind,
      TreeCompletionKind.growthPulse,
    );
    expect(
      TreeCompletionViewData.forRoute(TreeCompletionKind.alreadyCredited.name)
          .kind,
      TreeCompletionKind.alreadyCredited,
    );
    expect(
      TreeCompletionViewData.forRoute(TreeCompletionKind.postMatureRing.name)
          .kind,
      TreeCompletionKind.postMatureRing,
    );
  });

  testWidgets('focus progress deliberately contains no tree', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(child: TestApp(home: FocusProgressPage())),
    );

    expect(find.byKey(const ValueKey('focus-progress-page')), findsOneWidget);
    expect(find.byType(TreeArtwork), findsNothing);
    expect(find.text('원래 하려던 일'), findsOneWidget);
    expect(find.text('5분만 허용'), findsOneWidget);
  });

  testWidgets('completion stays disabled until the captured session expires', (
    tester,
  ) async {
    final startedAt = DateTime.utc(2026, 8, 26, 3);
    var now = startedAt.add(const Duration(minutes: 4, seconds: 59));
    final session = FocusSession(
      id: 'session-countdown',
      startedAtUtc: startedAt,
      startedLocalDate: LocalDate(2026, 8, 26),
      protectionMode: ProtectionMode.timerOnly,
      preset: SessionDurationPreset.fiveMinutes,
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          localNowProvider.overrideWithValue(() => now),
          focusSessionControllerProvider.overrideWith(
            (ref) => _SeededFocusSessionController(ref, session),
          ),
        ],
        child: const TestApp(home: FocusProgressPage()),
      ),
    );

    var completeButton = tester.widget<FilledButton>(find.byType(FilledButton));
    expect(completeButton.onPressed, isNull);
    expect(find.text('집중이 끝나면 완료할 수 있어요'), findsOneWidget);

    now = startedAt.add(const Duration(minutes: 5));
    await tester.pump(const Duration(seconds: 1));
    completeButton = tester.widget<FilledButton>(find.byType(FilledButton));
    expect(completeButton.onPressed, isNotNull);
    expect(find.text('세션 완료'), findsOneWidget);

    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets(
    'milestone completion is a full-page reveal with immediate actions',
    (tester) async {
      final data = TreeCompletionViewData.forRoute('milestone');
      await tester.pumpWidget(
        ProviderScope(
          child: TestApp(
            disableAnimations: true,
            home: FocusCompletionPage(data: data),
          ),
        ),
      );

      expect(find.text('첫 새싹이 올라왔어요'), findsOneWidget);
      expect(find.text('맞았어요'), findsOneWidget);
      expect(find.text('건너뛰기'), findsOneWidget);
      expect(find.text('오늘로 돌아가기'), findsOneWidget);
      expect(tester.hasRunningAnimations, isFalse);
    },
  );

  testWidgets('90-day milestone uses mature-stage reveal copy', (tester) async {
    const policy = TreeGrowthPolicy();
    await tester.pumpWidget(
      ProviderScope(
        child: TestApp(
          disableAnimations: true,
          home: FocusCompletionPage(
            data: TreeCompletionViewData(
              kind: TreeCompletionKind.milestone,
              progress: policy.progressFor(90),
            ),
          ),
        ),
      ),
    );

    expect(find.text('느티나무가 성목이 되었어요'), findsOneWidget);
    expect(find.text('첫 새싹이 올라왔어요'), findsNothing);
    expect(find.text('함께 자란 90일 · 성목'), findsOneWidget);
  });

  testWidgets('tree UI kill switch removes tree visuals and growth copy', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          treeFeatureFlagsProvider.overrideWithValue(
            const TreeFeatureFlags(treeUiEnabled: false),
          ),
        ],
        child: TestApp(
          home: FocusCompletionPage(
            data: TreeCompletionViewData.forRoute('milestone'),
          ),
        ),
      ),
    );

    expect(find.byType(TreeArtwork), findsNothing);
    expect(
      find.byKey(const ValueKey('completion-generic-icon')),
      findsOneWidget,
    );
    expect(find.text('집중을 마쳤어요'), findsOneWidget);
    expect(find.textContaining('새싹'), findsNothing);
    expect(find.textContaining('함께 자란'), findsNothing);
  });

  testWidgets('completion actions remain on screen on a small phone', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 568);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      ProviderScope(
        child: TestApp(
          disableAnimations: true,
          home: FocusCompletionPage(
            data: TreeCompletionViewData.forRoute('milestone'),
          ),
        ),
      ),
    );

    final actionsRect = tester.getRect(
      find.byKey(const ValueKey('completion-immediate-actions')),
    );
    expect(actionsRect.top, greaterThanOrEqualTo(0));
    expect(actionsRect.bottom, lessThanOrEqualTo(568));
    expect(find.text('오늘로 돌아가기'), findsOneWidget);
  });

  testWidgets(
    'completion actions remain scroll-accessible at 200 percent text',
    (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: TestApp(
            textScale: 2,
            disableAnimations: true,
            home: FocusCompletionPage(
              data: TreeCompletionViewData.forRoute('milestone'),
            ),
          ),
        ),
      );

      expect(tester.takeException(), isNull);
      expect(find.byType(ListView), findsOneWidget);
      await tester.ensureVisible(find.text('오늘로 돌아가기'));
      await tester.pump();
      expect(find.text('오늘로 돌아가기').hitTestable(), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'duplicate-day completion keeps completion credit and explains cap',
    (tester) async {
      final data = TreeCompletionViewData.forRoute('duplicate');
      await tester.pumpWidget(
        ProviderScope(
          child: TestApp(home: FocusCompletionPage(data: data)),
        ),
      );

      expect(find.text('오늘의 성장은 이미 남겨졌어요'), findsOneWidget);
      expect(find.text('세션 완료는 그대로 인정돼요. 나무는 하루에 한 번만 자라요.'), findsOneWidget);
    },
  );

  testWidgets('120-day completion uses the non-destructive ring state', (
    tester,
  ) async {
    final data = TreeCompletionViewData.forRoute('ring');
    await tester.pumpWidget(
      ProviderScope(
        child: TestApp(home: FocusCompletionPage(data: data)),
      ),
    );

    expect(find.text('나이테가 하나 더 새겨졌어요'), findsOneWidget);
    expect(find.text('함께 자란 120일 · 성목'), findsOneWidget);
  });
}

class _SeededFocusSessionController extends FocusSessionController {
  _SeededFocusSessionController(Ref ref, FocusSession session) : super(ref) {
    state = FocusSessionFlowState(session: session);
  }
}
