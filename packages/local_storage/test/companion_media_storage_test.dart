import 'dart:io';

import 'package:dopa_domain/dopa_domain.dart';
import 'package:dopa_local_storage/dopa_local_storage.dart';
import 'package:drift/native.dart';
import 'package:sqlite3/sqlite3.dart';
import 'package:test/test.dart';

void main() {
  test(
    'v2 playback position and mode persist across a database process reopen',
    () async {
      final directory = await Directory.systemTemp.createTemp(
        'dopa-media-test-',
      );
      final file = File('${directory.path}/media.sqlite');
      var db = DopaDatabase(NativeDatabase(file));
      var repo = DriftCompanionRepository(database: db);
      try {
        await repo.startOrResume(
          CompanionRun(
            id: 'resume',
            contentId: 'desk_space',
            contentVersion: 2,
            startedAtUtc: DateTime.utc(2026, 9, 10),
            startedLocalDate: LocalDate(2026, 9, 10),
            stepCount: 4,
            guidanceMode: CompanionGuidanceMode.humanMedia,
          ),
        );
        await repo.savePlayback(
          runId: 'resume',
          positionMs: 65432,
          revision: 7,
          stepIndex: 2,
          mode: CompanionGuidanceMode.humanMedia,
        );
        await db.close();
        db = DopaDatabase(NativeDatabase(file));
        repo = DriftCompanionRepository(database: db);
        final restored = (await repo.readActive())!;
        expect(restored.positionMs, 65432);
        expect(restored.playbackRevision, 7);
        expect(restored.guidanceMode, CompanionGuidanceMode.humanMedia);
        expect(restored.stepIndex, 2);
        expect(await repo.readHistory(), isEmpty);
      } finally {
        await db.close();
        await directory.delete(recursive: true);
      }
    },
  );
  test(
    'v4 active text guide and past outcome survive additive v5 migration',
    () async {
      final sqlite = sqlite3.openInMemory();
      sqlite.execute('''CREATE TABLE companion_runs (
      id TEXT NOT NULL PRIMARY KEY, content_id TEXT NOT NULL, content_version INTEGER NOT NULL,
      started_at_utc_micros INTEGER NOT NULL, started_local_date TEXT NOT NULL,
      step_count INTEGER NOT NULL, step_index INTEGER NOT NULL,
      guide_completed INTEGER NOT NULL, awaiting_outcome INTEGER NOT NULL,
      active_slot INTEGER UNIQUE CHECK(active_slot = 1))''');
      sqlite.execute('''CREATE TABLE companion_outcomes (
      run_id TEXT NOT NULL PRIMARY KEY REFERENCES companion_runs(id) ON DELETE CASCADE,
      outcome TEXT NOT NULL, confirmed_at_utc_micros INTEGER NOT NULL,
      confirmed_local_date TEXT NOT NULL)''');
      sqlite.execute(
        "INSERT INTO companion_runs VALUES ('active','desk_space',1,1000000,'2026-09-10',4,2,0,0,1),('past','desk_space',1,1000000,'2026-09-09',4,3,1,1,NULL)",
      );
      sqlite.execute(
        "INSERT INTO companion_outcomes VALUES ('past','started',2000000,'2026-09-09')",
      );
      sqlite.execute(
        'CREATE TABLE tree_growth_credits (tree_id TEXT, source_session_id TEXT, credited_local_date TEXT, credited_at_utc_micros INTEGER, rule_version INTEGER)',
      );
      sqlite.execute('PRAGMA user_version = 4');
      final db = DopaDatabase(NativeDatabase.opened(sqlite));
      addTearDown(db.close);
      final repo = DriftCompanionRepository(database: db);
      final active = (await repo.readActive())!;
      expect(active.stepIndex, 2);
      expect(active.positionMs, 0);
      expect(active.playbackRevision, 0);
      expect(active.guidanceMode, CompanionGuidanceMode.textSample);
      final record = (await repo.readHistory()).single;
      expect(record.outcome, CompanionOutcome.started);
      expect(record.run.contentVersion, 1);
      expect(record.run.guidanceMode, CompanionGuidanceMode.textSample);
      expect(sqlite.select('PRAGMA user_version').single.values.single, 6);
    },
  );
  test('backward saves reject stale revisions and cannot revert a confirmed result', () async {
    final db = DopaDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    final repo = DriftCompanionRepository(database: db);
    await EnsureTreeCompanion(
      repository: DriftFocusTreeRepository(database: db),
    )(createdAtUtc: DateTime.utc(2026, 9, 1));
    await repo.startOrResume(
      CompanionRun(
        id: 'media',
        contentId: 'desk_space',
        contentVersion: 2,
        startedAtUtc: DateTime.utc(2026, 9, 10),
        startedLocalDate: LocalDate(2026, 9, 10),
        stepCount: 4,
        guidanceMode: CompanionGuidanceMode.humanMedia,
      ),
    );
    Future<CompanionRun> save(
      int position,
      int revision, {
      bool completed = false,
    }) => repo.savePlayback(
      runId: 'media',
      positionMs: position,
      revision: revision,
      stepIndex: completed ? 3 : position ~/ 30000,
      mode: CompanionGuidanceMode.humanMedia,
      completed: completed,
    );
    await save(64000, 1);
    await save(1234, 3);
    await save(80000, 2);
    expect((await repo.readActive())!.positionMs, 1234);
    await save(120000, 4, completed: true);
    expect(await repo.readHistory(), isEmpty);
    await repo.submitOutcome(
      runId: 'media',
      outcome: CompanionOutcome.started,
      confirmedAtUtc: DateTime.utc(2026, 9, 10),
      confirmedLocalDate: LocalDate(2026, 9, 10),
    );
    await save(0, 99);
    expect(await repo.readActive(), isNull);
    final record = (await repo.readHistory()).single;
    expect(record.run.positionMs, 120000);
    expect(record.run.awaitingOutcome, true);
    expect(record.run.guidanceMode, CompanionGuidanceMode.humanMedia);
    expect(await db.select(db.focusSessions).get(), isEmpty);
    expect(await db.select(db.treeGrowthCredits).get(), hasLength(1));
    await repo.deleteRecord('media');
    await expectLater(save(1000, 100), throwsStateError);
    expect(await repo.readHistory(), isEmpty);
  });
}
