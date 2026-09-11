import 'package:dopa/core/persistence/local_account_data_lifecycle.dart';
import 'package:dopa_domain/dopa_domain.dart';
import 'package:dopa_local_storage/dopa_local_storage.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test(
    'consent initialization creates one seed and account deletion clears it',
    () async {
      final database = DopaDatabase(NativeDatabase.memory());
      addTearDown(database.close);
      final lifecycle = LocalAccountDataLifecycle(
        repository: DriftFocusTreeRepository(
          database: database,
          treeIdFactory: () => 'tree-after-consent',
        ),
      );

      final progress = await lifecycle.initializeAfterConsent(
        createdAtUtc: DateTime.utc(2026, 8, 27),
      );

      expect(progress, const TreeGrowthPolicy().progressFor(0));
      expect(
        await database.select(database.treeCompanions).get(),
        hasLength(1),
      );
      expect(
        await database.select(database.sevenDayExperiments).get(),
        hasLength(1),
      );

      final companion = DriftCompanionRepository(database: database);
      await companion.startOrResume(
        CompanionRun(
          id: 'life-action',
          contentId: deskCompanionContent.id,
          contentVersion: 1,
          startedAtUtc: DateTime.utc(2026, 9, 10),
          startedLocalDate: LocalDate(2026, 9, 10),
          stepCount: 4,
        ),
      );
      await companion.requestOutcome('life-action');
      await companion.submitOutcome(
        runId: 'life-action',
        outcome: CompanionOutcome.started,
        confirmedAtUtc: DateTime.utc(2026, 9, 10, 0, 2),
        confirmedLocalDate: LocalDate(2026, 9, 10),
      );
      await lifecycle.deleteForLogoutOrAccountDeletion();

      expect(await database.select(database.treeCompanions).get(), isEmpty);
      expect(await database.select(database.treeGrowthCredits).get(), isEmpty);
      expect(await database.select(database.focusSessions).get(), isEmpty);
      expect(
        await database.select(database.sevenDayExperiments).get(),
        isEmpty,
      );
      expect(await database.select(database.dailyCheckIns).get(), isEmpty);
      expect(await database.select(database.companionRuns).get(), isEmpty);
      expect(await database.select(database.companionOutcomes).get(), isEmpty);
    },
  );

  test('existing trees without an experiment get the 7-day window', () async {
    final database = DopaDatabase(NativeDatabase.memory());
    addTearDown(database.close);
    final repository = DriftFocusTreeRepository(
      database: database,
      treeIdFactory: () => 'tree-legacy',
    );
    final lifecycle = LocalAccountDataLifecycle(repository: repository);

    await EnsureTreeCompanion(repository: repository)(
      createdAtUtc: DateTime.utc(2026, 8, 20, 12),
    );
    expect(await database.select(database.sevenDayExperiments).get(), isEmpty);

    await lifecycle.ensureExperimentForExistingTree();

    expect(
      await database.select(database.sevenDayExperiments).get(),
      hasLength(1),
    );
    expect(
      (await repository.readExperiment())!.startedOn,
      LocalDate.fromLocal(DateTime.utc(2026, 8, 20, 12).toLocal()),
    );
  });
}
