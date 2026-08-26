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
    final active = FocusSession(
      id: 'recover-session',
      startedAtUtc: DateTime.utc(2026, 8, 26, 3),
      startedLocalDate: LocalDate(2026, 8, 26),
      protectionMode: ProtectionMode.shield,
      preset: SessionDurationPreset.tenMinutes,
    );
    await repository.writeTransaction(
      (transaction) => transaction.saveSession(active),
    );
    final container = ProviderContainer(
      overrides: [focusTreeRepositoryProvider.overrideWithValue(repository)],
    );
    addTearDown(container.dispose);

    await container.read(focusSessionRecoveryProvider.future);

    expect(container.read(focusSessionControllerProvider).session, active);
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
