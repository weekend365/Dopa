import 'dart:async';

import 'package:dopa/core/persistence/dopa_database_providers.dart';
import 'package:dopa/features/companion/application/companion_controller.dart';
import 'package:dopa/features/focus/application/focus_session_controller.dart';
import 'package:dopa/features/focus/application/focus_setup_controller.dart';
import 'package:dopa_domain/dopa_domain.dart';
import 'package:dopa_local_storage/dopa_local_storage.dart';
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('a life guide preserves a running focus session, its settings and bypass state', () async {
    final db = DopaDatabase(NativeDatabase.memory());
    var id = 0;
    await EnsureTreeCompanion(
      repository: DriftFocusTreeRepository(database: db),
    )(createdAtUtc: DateTime.utc(2026, 9, 1));
    final container = ProviderContainer(
      overrides: [
        dopaDatabaseProvider.overrideWithValue(db),
        localNowProvider.overrideWithValue(() => DateTime(2026, 9, 10, 12)),
        sessionIdFactoryProvider.overrideWithValue(() => 'isolation-${id++}'),
      ],
    );
    final setup = container.read(focusSetupControllerProvider.notifier);
    setup.selectDuration(25);
    setup.selectProtectionMode(ProtectionMode.timerOnly);
    setup.updateIntention('  기존에 읽던 문서  ');
    final originalSetup = container.read(focusSetupControllerProvider);
    final focus = container.read(focusSessionControllerProvider.notifier);
    await focus.start(originalSetup);
    await focus.allowFiveMinuteBypass();
    final originalFocus = container
        .read(focusSessionControllerProvider)
        .session;
    final loaded = Completer<void>();
    final subscription = container.listen(companionControllerProvider, (
      _,
      next,
    ) {
      if (!next.loading && !loaded.isCompleted) loaded.complete();
    }, fireImmediately: true);
    try {
      await loaded.future;
      final companion = container.read(companionControllerProvider.notifier);
      await companion.start();
      await companion.next();
      companion.pause();
      companion.replayGuide();
      await companion.finishGuide();
      await companion.submit(CompanionOutcome.started);
      expect(container.read(focusSetupControllerProvider), originalSetup);
      expect(
        container.read(focusSessionControllerProvider).session,
        originalFocus,
      );
      final persisted = await db.select(db.focusSessions).getSingle();
      expect(persisted.intention, '기존에 읽던 문서');
      expect(persisted.status, 'active');
      expect(persisted.durationPresetMinutes, 25);
      expect(persisted.usedFiveMinuteBypass, isTrue);
      expect(persisted.protectedDurationSeconds, 0);
      expect(await db.select(db.treeGrowthCredits).get(), hasLength(1));
      expect(
        await container.read(companionHistoryProvider.future),
        hasLength(1),
      );
    } finally {
      subscription.close();
      container.dispose();
      await db.close();
    }
  });
}
