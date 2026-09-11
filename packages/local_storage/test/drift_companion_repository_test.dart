import 'dart:io';

import 'package:dopa_domain/dopa_domain.dart';
import 'package:dopa_local_storage/dopa_local_storage.dart';
import 'package:drift/native.dart';
import 'package:test/test.dart';

CompanionRun proposed([String id = 'run']) => CompanionRun(
  id: id,
  contentId: deskCompanionContent.id,
  contentVersion: 1,
  startedAtUtc: DateTime.utc(2026, 9, 10, 14, 59),
  startedLocalDate: LocalDate(2026, 9, 10),
  stepCount: 4,
);

Future<CompanionOutcomeRecord> submit(
  CompanionRepository repo, [
  CompanionOutcome outcome = CompanionOutcome.started,
]) => repo.submitOutcome(
  runId: 'run',
  outcome: outcome,
  confirmedAtUtc: DateTime.utc(2026, 9, 10, 15, 2),
  confirmedLocalDate: LocalDate(2026, 9, 11),
);

void main() {
  late DopaDatabase db;
  var dbOpen = false;
  late DriftCompanionRepository repo;
  setUp(() async {
    db = DopaDatabase(NativeDatabase.memory());
    dbOpen = true;
    repo = DriftCompanionRepository(database: db);
    await EnsureTreeCompanion(
      repository: DriftFocusTreeRepository(database: db),
    )(createdAtUtc: DateTime.utc(2026, 9, 1));
  });
  tearDown(() async {
    if (dbOpen) await db.close();
  });

  test(
    'focus and companion completing concurrently share one start-date credit',
    () async {
      final focus = DriftFocusTreeRepository(database: db);
      await focus.writeTransaction(
        (tx) => tx.saveSession(
          FocusSession(
            id: 'same-day-focus',
            startedAtUtc: DateTime.utc(2026, 9, 10, 14, 55),
            startedLocalDate: LocalDate(2026, 9, 10),
            protectionMode: ProtectionMode.timerOnly,
            preset: SessionDurationPreset.fiveMinutes,
          ),
        ),
      );
      await repo.startOrResume(proposed());
      await repo.requestOutcome('run');
      await Future.wait<Object>([
        submit(repo),
        CompleteFocusSession(repository: focus)(
          sessionId: 'same-day-focus',
          terminalStatus: FocusSessionStatus.completed,
          endedAtUtc: DateTime.utc(2026, 9, 10, 15, 2),
          protectedDuration: const Duration(minutes: 5),
        ),
      ]);
      final credits = await db.select(db.treeGrowthCredits).get();
      expect(credits, hasLength(1));
      expect(credits.single.creditedLocalDate, '2026-09-10');
      expect(await repo.readHistory(), hasLength(1));
      expect(
        (await db.select(db.focusSessions).getSingle()).status,
        'completed',
      );
    },
  );

  test('growth write failure rolls back outcome and allows retry', () async {
    await repo.startOrResume(proposed());
    await repo.requestOutcome('run');
    await db.customStatement(
      "CREATE TRIGGER fail_growth BEFORE INSERT ON tree_growth_credits BEGIN SELECT RAISE(ABORT, 'growth_failure'); END",
    );
    await expectLater(submit(repo), throwsA(isA<Exception>()));
    expect(await repo.readHistory(), isEmpty);
    expect((await repo.readActive())!.awaitingOutcome, isTrue);
    expect(await db.select(db.treeGrowthCredits).get(), isEmpty);
    await db.customStatement('DROP TRIGGER fail_growth');
    await submit(repo);
    expect(await db.select(db.treeGrowthCredits).get(), hasLength(1));
  });

  test(
    'a new free guide and full guide end do not create a result or growth',
    () async {
      expect(await repo.readActive(), isNull);
      await repo.startOrResume(proposed());
      for (var i = 0; i < 4; i++) {
        await repo.advanceGuide('run');
      }
      expect((await repo.readActive())!.guideCompleted, isTrue);
      expect(await repo.readHistory(), isEmpty);
      expect(await db.select(db.focusSessions).get(), isEmpty);
      expect(await db.select(db.treeGrowthCredits).get(), isEmpty);
      expect(await db.select(db.dailyCheckIns).get(), isEmpty);
    },
  );

  test('existing focus minutes, intention, tree and check-in survive a life action', () async {
    final focus = DriftFocusTreeRepository(
      database: db,
      treeIdFactory: () => 'existing-tree',
    );
    final original = FocusSession(
      id: 'focus',
      startedAtUtc: DateTime.utc(2026, 9, 9, 1),
      startedLocalDate: LocalDate(2026, 9, 9),
      protectionMode: ProtectionMode.timerOnly,
      preset: SessionDurationPreset.fiveMinutes,
      intention: '기존 할 일',
    );
    await focus.writeTransaction(
      (transaction) => transaction.saveSession(original),
    );
    await CompleteFocusSession(repository: focus)(
      sessionId: 'focus',
      terminalStatus: FocusSessionStatus.completed,
      endedAtUtc: DateTime.utc(2026, 9, 9, 1, 5),
      protectedDuration: const Duration(minutes: 5),
    );
    await db.customStatement(
      "INSERT INTO daily_check_ins VALUES ('2026-09-09', 'no')",
    );
    final beforeSession = await db.select(db.focusSessions).getSingle();
    final beforeTree = await db.select(db.treeCompanions).getSingle();
    final beforeCredit = await db.select(db.treeGrowthCredits).getSingle();
    await repo.startOrResume(proposed());
    await repo.requestOutcome('run');
    await submit(repo);
    await submit(repo);
    expect(await db.select(db.focusSessions).getSingle(), beforeSession);
    expect(await db.select(db.treeCompanions).getSingle(), beforeTree);
    expect(await db.select(db.treeGrowthCredits).get(), contains(beforeCredit));
    expect(
      (await db.select(db.dailyCheckIns).getSingle()).intentionAlignment,
      'no',
    );
    expect((await focus.readTreeProgress()).totalGrowthDays, 2);
  });

  for (final outcome in CompanionOutcome.values) {
    test(
      'explicit $outcome persists separately, preserving local dates',
      () async {
        await repo.startOrResume(proposed());
        await repo.requestOutcome('run');
        final result = await submit(repo, outcome);
        expect(result.outcome, outcome);
        expect(result.run.guideCompleted, isFalse);
        expect(result.run.startedLocalDate, LocalDate(2026, 9, 10));
        expect(result.confirmedLocalDate, LocalDate(2026, 9, 11));
        expect(await repo.readActive(), isNull);
        expect((await repo.readHistory()).single.outcome, outcome);
        final credits = await db.select(db.treeGrowthCredits).get();
        expect(
          credits,
          hasLength(outcome == CompanionOutcome.difficult ? 0 : 1),
        );
        if (credits.isNotEmpty) {
          expect(credits.single.creditedLocalDate, '2026-09-10');
          expect(credits.single.sourceKind, 'companion');
        }
      },
    );
  }

  test(
    'repeated start resumes and a second active DB slot is rejected',
    () async {
      await repo.startOrResume(proposed());
      await repo.advanceGuide('run');
      final restored = await repo.startOrResume(proposed('other'));
      expect(restored.id, 'run');
      expect(restored.stepIndex, 1);
      expect(await db.select(db.companionRuns).get(), hasLength(1));
      await expectLater(
        db.customStatement('''
      INSERT INTO companion_runs (id, content_id, content_version,
      started_at_utc_micros, started_local_date, step_count, step_index,
      guide_completed, awaiting_outcome, active_slot) SELECT 'other', content_id, content_version,
      started_at_utc_micros, started_local_date, step_count, step_index,
      guide_completed, awaiting_outcome, active_slot FROM companion_runs
    '''),
        throwsA(isA<Exception>()),
      );
    },
  );

  test('submission requires user result screen; duplicate submissions keep first choice', () async {
    await repo.startOrResume(proposed());
    await expectLater(submit(repo), throwsStateError);
    await repo.requestOutcome('run');
    final results = await Future.wait([
      submit(repo),
      submit(repo, CompanionOutcome.asPlanned),
    ]);
    expect(results.map((r) => r.outcome).toSet(), hasLength(1));
    expect((await repo.readHistory()), hasLength(1));
    final first = results.first;
    expect(
      (await submit(repo, CompanionOutcome.difficult)).outcome,
      first.outcome,
    );
    expect(await db.select(db.treeGrowthCredits).get(), hasLength(1));
    expect((await repo.startOrResume(proposed('second'))).id, 'second');
  });

  test(
    'failure after result insertion rolls back and same run can retry',
    () async {
      await repo.startOrResume(proposed());
      await repo.requestOutcome('run');
      await db.customStatement(
        '''CREATE TRIGGER fail_finish BEFORE UPDATE OF active_slot
      ON companion_runs BEGIN SELECT RAISE(ABORT, 'test_write_failure'); END''',
      );
      await expectLater(submit(repo), throwsA(isA<Exception>()));
      expect(await repo.readHistory(), isEmpty);
      expect((await repo.readActive())!.id, 'run');
      await db.customStatement('DROP TRIGGER fail_finish');
      await submit(repo);
      expect(await repo.readHistory(), hasLength(1));
    },
  );

  test(
    'record deletion cascades its run and does not discard a pending run',
    () async {
      await repo.startOrResume(proposed());
      await repo.requestOutcome('run');
      await submit(repo);
      await repo.startOrResume(proposed('pending'));
      await repo.deleteRecord('pending');
      expect((await repo.readActive())!.id, 'pending');
      await repo.deleteRecord('run');
      expect(await repo.readHistory(), isEmpty);
      expect((await db.select(db.companionRuns).get()).single.id, 'pending');
      expect(await db.select(db.treeGrowthCredits).get(), hasLength(1));
      await repo.requestOutcome('pending');
      await repo.submitOutcome(
        runId: 'pending',
        outcome: CompanionOutcome.asPlanned,
        confirmedAtUtc: DateTime.utc(2026, 9, 11),
        confirmedLocalDate: LocalDate(2026, 9, 11),
      );
      expect(await db.select(db.treeGrowthCredits).get(), hasLength(1));
      await db.deleteAllLocalData();
      expect(await db.select(db.companionRuns).get(), isEmpty);
      expect(await db.select(db.companionOutcomes).get(), isEmpty);
    },
  );

  test('on-disk reopen restores progress and separately committed self-report', () async {
    await db.close();
    dbOpen = false;
    final directory = await Directory.systemTemp.createTemp('dopa_companion_');
    final file = File('${directory.path}/test.sqlite');
    var disk = DopaDatabase(NativeDatabase(file));
    try {
      var repository = DriftCompanionRepository(database: disk);
      await EnsureTreeCompanion(
        repository: DriftFocusTreeRepository(database: disk),
      )(createdAtUtc: DateTime.utc(2026, 9, 1));
      await repository.startOrResume(proposed());
      await repository.advanceGuide('run');
      await disk.close();
      disk = DopaDatabase(NativeDatabase(file));
      repository = DriftCompanionRepository(database: disk);
      expect((await repository.readActive())!.stepIndex, 1);
      expect(await repository.readHistory(), isEmpty);
      await repository.requestOutcome('run');
      await submit(repository);
      await disk.close();
      disk = DopaDatabase(NativeDatabase(file));
      repository = DriftCompanionRepository(database: disk);
      expect(await repository.readActive(), isNull);
      expect(
        (await repository.readHistory()).single.outcome,
        CompanionOutcome.started,
      );
    } finally {
      await disk.close();
      // The sole named test file is deleted; no recursive directory operation.
      for (final name in [
        'test.sqlite',
        'test.sqlite-wal',
        'test.sqlite-shm',
      ]) {
        final testFile = File('${directory.path}/$name');
        if (await testFile.exists()) await testFile.delete();
      }
      await directory.delete();
    }
  });
}
