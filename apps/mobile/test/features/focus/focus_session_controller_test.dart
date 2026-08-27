import 'package:dopa/core/persistence/dopa_database_providers.dart';
import 'package:dopa/features/focus/application/focus_session_controller.dart';
import 'package:dopa/features/focus/application/focus_setup_controller.dart';
import 'package:dopa/features/tree_companion/application/tree_companion_providers.dart';
import 'package:dopa_domain/dopa_domain.dart';
import 'package:dopa_local_storage/dopa_local_storage.dart';
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('active local session is restored before a new focus attempt', () async {
    final database = DopaDatabase(NativeDatabase.memory());
    addTearDown(database.close);
    final repository = DriftFocusTreeRepository(database: database);
    const intention = '읽던 문서 한 단락 마치기';
    final startedAtUtc = DateTime.utc(2026, 8, 27, 3);
    final active = FocusSession(
      id: 'recover-session',
      startedAtUtc: startedAtUtc,
      startedLocalDate: LocalDate(2026, 8, 27),
      protectionMode: ProtectionMode.shield,
      preset: SessionDurationPreset.tenMinutes,
      intention: intention,
    );
    await repository.writeTransaction(
      (transaction) => transaction.saveSession(active),
    );
    final container = ProviderContainer(
      overrides: [
        focusTreeRepositoryProvider.overrideWithValue(repository),
        localNowProvider.overrideWithValue(
          () => startedAtUtc.add(const Duration(minutes: 4)),
        ),
      ],
    );
    addTearDown(container.dispose);

    await container.read(focusSessionRecoveryProvider.future);

    expect(container.read(focusSessionControllerProvider).session, active);
    expect(
      container.read(focusSessionControllerProvider).recoveryKind,
      ActiveFocusRecoveryKind.resume,
    );
    expect(container.read(focusSetupControllerProvider).intention, intention);
    expect(container.read(focusSetupControllerProvider).durationMinutes, 10);
  });

  test(
    'elapsed recovery keeps the session completable without auto-award',
    () async {
      final database = DopaDatabase(NativeDatabase.memory());
      addTearDown(database.close);
      final repository = DriftFocusTreeRepository(
        database: database,
        treeIdFactory: () => 'tree-elapsed-recovery',
      );
      final startedAtUtc = DateTime.utc(2026, 8, 27, 3);
      var now = startedAtUtc.add(const Duration(minutes: 12));
      final active = FocusSession(
        id: 'elapsed-session',
        startedAtUtc: startedAtUtc,
        startedLocalDate: LocalDate(2026, 8, 27),
        protectionMode: ProtectionMode.timerOnly,
        preset: SessionDurationPreset.tenMinutes,
        intention: '보고서 첫 문단',
      );
      await repository.writeTransaction(
        (transaction) => transaction.saveSession(active),
      );
      final container = ProviderContainer(
        overrides: [
          focusTreeRepositoryProvider.overrideWithValue(repository),
          localNowProvider.overrideWithValue(() => now),
        ],
      );
      addTearDown(container.dispose);

      await container.read(focusSessionRecoveryProvider.future);

      expect(
        container.read(focusSessionControllerProvider).recoveryKind,
        ActiveFocusRecoveryKind.complete,
      );
      expect((await repository.readTreeProgress()).totalGrowthDays, 0);

      final viewData = await container
          .read(focusSessionControllerProvider.notifier)
          .complete();
      expect(viewData.progress.totalGrowthDays, 1);
      expect((await repository.readTreeProgress()).totalGrowthDays, 1);
    },
  );

  test(
    'stale recovery invalidates without growth and keeps the intention',
    () async {
      final database = DopaDatabase(NativeDatabase.memory());
      addTearDown(database.close);
      final repository = DriftFocusTreeRepository(
        database: database,
        treeIdFactory: () => 'tree-stale-recovery',
      );
      const intention = '읽던 문서 한 단락 마치기';
      final startedAtUtc = DateTime.utc(2026, 8, 26, 3);
      var now = startedAtUtc.add(const Duration(hours: 8));
      final active = FocusSession(
        id: 'stale-session',
        startedAtUtc: startedAtUtc,
        startedLocalDate: LocalDate(2026, 8, 26),
        protectionMode: ProtectionMode.timerOnly,
        preset: SessionDurationPreset.tenMinutes,
        intention: intention,
      );
      await repository.writeTransaction(
        (transaction) => transaction.saveSession(active),
      );
      final container = ProviderContainer(
        overrides: [
          focusTreeRepositoryProvider.overrideWithValue(repository),
          localNowProvider.overrideWithValue(() => now),
          sessionIdFactoryProvider.overrideWithValue(() => 'fresh-session'),
        ],
      );
      addTearDown(container.dispose);

      final controller = container.read(
        focusSessionControllerProvider.notifier,
      );
      await controller.restoreActive();
      await controller.restoreActive();

      final recovered = container.read(focusSessionControllerProvider);
      expect(recovered.recoveryKind, ActiveFocusRecoveryKind.invalidate);
      expect(recovered.session!.status, FocusSessionStatus.invalidRecovery);
      expect(container.read(focusSetupControllerProvider).intention, intention);
      expect(await repository.readActiveFocusSession(), isNull);
      expect((await repository.readTreeProgress()).totalGrowthDays, 0);

      now = DateTime.utc(2026, 8, 27, 12);
      final started = await container
          .read(focusSessionControllerProvider.notifier)
          .start(container.read(focusSetupControllerProvider));
      expect(started.id, 'fresh-session');
      expect(started.intention, intention);
      expect(started.status, FocusSessionStatus.active);
    },
  );

  test('clock rollback invalidates without rewriting startedAtUtc', () async {
    final database = DopaDatabase(NativeDatabase.memory());
    addTearDown(database.close);
    final repository = DriftFocusTreeRepository(database: database);
    final startedAtUtc = DateTime.utc(2026, 8, 27, 3);
    final active = FocusSession(
      id: 'clock-rollback',
      startedAtUtc: startedAtUtc,
      startedLocalDate: LocalDate(2026, 8, 27),
      protectionMode: ProtectionMode.timerOnly,
    );
    await repository.writeTransaction(
      (transaction) => transaction.saveSession(active),
    );
    final container = ProviderContainer(
      overrides: [
        focusTreeRepositoryProvider.overrideWithValue(repository),
        localNowProvider.overrideWithValue(
          () => startedAtUtc.subtract(const Duration(minutes: 20)),
        ),
      ],
    );
    addTearDown(container.dispose);

    await container.read(focusSessionRecoveryProvider.future);

    final recovered = container.read(focusSessionControllerProvider).session!;
    expect(recovered.status, FocusSessionStatus.invalidRecovery);
    expect(recovered.endedAtUtc, startedAtUtc);
    expect((await repository.readTreeProgress()).totalGrowthDays, 0);
  });

  test(
    'elapsed session is completed and awarded through the Drift transaction',
    () async {
      final database = DopaDatabase(NativeDatabase.memory());
      addTearDown(database.close);
      final repository = DriftFocusTreeRepository(
        database: database,
        treeIdFactory: () => 'tree-device-one',
      );
      var now = DateTime(2026, 8, 26, 12);
      final container = ProviderContainer(
        overrides: [
          focusTreeRepositoryProvider.overrideWithValue(repository),
          localNowProvider.overrideWithValue(() => now),
          sessionIdFactoryProvider.overrideWithValue(() => 'session-one'),
        ],
      );
      addTearDown(container.dispose);

      const setup = FocusSetupState(durationMinutes: 5);
      final controller = container.read(
        focusSessionControllerProvider.notifier,
      );
      await controller.start(setup);

      await expectLater(
        controller.complete(),
        throwsA(isA<FocusSessionNotElapsedException>()),
      );
      expect((await repository.readTreeProgress()).totalGrowthDays, 0);

      now = now.add(const Duration(minutes: 5));
      final viewData = await controller.complete();

      expect(viewData.kind, TreeCompletionKind.milestone);
      expect(viewData.progress.totalGrowthDays, 1);
      expect(container.read(treeProgressProvider).totalGrowthDays, 1);
      expect((await repository.readTreeProgress()).totalGrowthDays, 1);
    },
  );

  test(
    'concurrent completion callbacks share one controller operation',
    () async {
      final database = DopaDatabase(NativeDatabase.memory());
      addTearDown(database.close);
      final repository = DriftFocusTreeRepository(
        database: database,
        treeIdFactory: () => 'tree-controller-deduplication',
      );
      var now = DateTime(2026, 8, 27, 12);
      final container = ProviderContainer(
        overrides: [
          focusTreeRepositoryProvider.overrideWithValue(repository),
          localNowProvider.overrideWithValue(() => now),
          sessionIdFactoryProvider.overrideWithValue(
            () => 'session-controller-deduplication',
          ),
        ],
      );
      addTearDown(container.dispose);

      final controller = container.read(
        focusSessionControllerProvider.notifier,
      );
      await controller.start(const FocusSetupState(durationMinutes: 5));
      now = now.add(const Duration(minutes: 5));

      final results = await Future.wait([
        controller.complete(),
        controller.complete(),
      ]);

      expect(results, hasLength(2));
      expect(
        results.every((result) => result.progress.totalGrowthDays == 1),
        isTrue,
      );
      expect((await repository.readTreeProgress()).totalGrowthDays, 1);
    },
  );
}
