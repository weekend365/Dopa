import 'package:dopa/core/persistence/dopa_database_providers.dart';
import 'package:dopa/features/experiment/application/daily_check_in_controller.dart';
import 'package:dopa/features/focus/application/focus_session_controller.dart';
import 'package:dopa/features/focus/application/focus_setup_controller.dart';
import 'package:dopa/features/tree_companion/application/tree_companion_providers.dart';
import 'package:dopa_domain/dopa_domain.dart';
import 'package:dopa_local_storage/dopa_local_storage.dart';
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test(
    'check-in answers never change tree growth or experiment days',
    () async {
      final database = DopaDatabase(NativeDatabase.memory());
      addTearDown(database.close);
      final repository = DriftFocusTreeRepository(
        database: database,
        treeIdFactory: () => 'tree-check-in',
      );
      var now = DateTime.utc(2026, 8, 27, 12);
      final container = ProviderContainer(
        overrides: [
          focusTreeRepositoryProvider.overrideWithValue(repository),
          localNowProvider.overrideWithValue(() => now),
          sessionIdFactoryProvider.overrideWithValue(() => 'session-check-in'),
        ],
      );
      addTearDown(container.dispose);

      await EnsureTreeCompanion(repository: repository)(
        createdAtUtc: DateTime.utc(2026, 8, 27, 12),
      );
      await EnsureSevenDayExperiment(repository: repository)(
        startedOn: LocalDate(2026, 8, 27),
      );

      await container
          .read(dailyCheckInControllerProvider.notifier)
          .record(IntentionAlignment.no);
      expect((await repository.readTreeProgress()).totalGrowthDays, 0);
      expect(await repository.countExperimentAttemptDays(), 0);

      final controller = container.read(
        focusSessionControllerProvider.notifier,
      );
      await controller.start(const FocusSetupState(durationMinutes: 5));
      now = now.add(const Duration(minutes: 5));
      await controller.complete();

      expect((await repository.readTreeProgress()).totalGrowthDays, 1);
      expect(container.read(treeProgressProvider).totalGrowthDays, 1);
      expect(await repository.countExperimentAttemptDays(), 1);
      expect(
        (await repository.readCheckIn(LocalDate(2026, 8, 27)))!
            .intentionAlignment,
        IntentionAlignment.no,
      );
    },
  );
}
