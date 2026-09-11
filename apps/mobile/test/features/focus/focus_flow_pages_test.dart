import 'package:dopa/features/focus/application/focus_session_controller.dart';
import 'package:dopa/features/focus/presentation/focus_completion_page.dart';
import 'package:dopa/features/focus/presentation/focus_progress_page.dart';
import 'package:dopa/features/tree_companion/application/tree_companion_providers.dart';
import 'package:dopa/features/tree_companion/presentation/garden_artwork.dart';
import 'package:dopa_domain/dopa_domain.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../test_app.dart';

void main() {
  test('completion route tokens retain recovery compatibility', () {
    for (final kind in TreeCompletionKind.values) {
      expect(TreeCompletionViewData.forRoute(kind.name).kind, kind);
    }
  });
  testWidgets('completion enables only after the captured session expires', (
    t,
  ) async {
    final start = DateTime.utc(2026, 9, 11);
    var now = start.add(const Duration(minutes: 4, seconds: 59));
    final session = FocusSession(
      id: 'timer',
      startedAtUtc: start,
      startedLocalDate: LocalDate(2026, 9, 11),
      protectionMode: ProtectionMode.timerOnly,
      preset: SessionDurationPreset.fiveMinutes,
    );
    await t.pumpWidget(
      ProviderScope(
        overrides: [
          localNowProvider.overrideWithValue(() => now),
          focusSessionControllerProvider.overrideWith(
            (ref) => Seeded(ref, session),
          ),
        ],
        child: const TestApp(home: FocusProgressPage()),
      ),
    );
    expect(t.widget<FilledButton>(find.byType(FilledButton)).onPressed, isNull);
    expect(find.text('5분만 허용'), findsNothing);
    now = start.add(const Duration(minutes: 5));
    await t.pump(const Duration(seconds: 1));
    expect(
      t.widget<FilledButton>(find.byType(FilledButton)).onPressed,
      isNotNull,
    );
    expect(find.byType(GardenArtwork), findsNothing);
    await t.pumpWidget(const SizedBox());
  });
  for (final width in [320.0, 390.0, 430.0]) {
    for (final brightness in Brightness.values) {
      testWidgets('focus progress and result $width $brightness at 200%', (
        t,
      ) async {
        t.view.physicalSize = Size(width, 800);
        t.view.devicePixelRatio = 1;
        addTearDown(t.view.resetPhysicalSize);
        addTearDown(t.view.resetDevicePixelRatio);
        await t.pumpWidget(
          ProviderScope(
            child: TestApp(
              textScale: 2,
              brightness: brightness,
              home: const FocusProgressPage(),
            ),
          ),
        );
        await t.ensureVisible(find.byType(FilledButton));
        expect(t.takeException(), isNull);
        await t.pumpWidget(
          ProviderScope(
            child: TestApp(
              textScale: 2,
              brightness: brightness,
              disableAnimations: true,
              home: FocusCompletionPage(
                data: TreeCompletionViewData.forRoute('alreadyCredited'),
              ),
            ),
          ),
        );
        await t.pumpAndSettle();
        await t.ensureVisible(find.text('여기서 마치기'));
        expect(find.textContaining('하루에 한 번'), findsOneWidget);
        expect(find.text('맞았어요'), findsNothing);
        expect(t.hasRunningAnimations, false);
        expect(t.takeException(), isNull);
      });
    }
  }
}

class Seeded extends FocusSessionController {
  Seeded(super.ref, FocusSession session) {
    state = FocusSessionFlowState(session: session);
  }
}
