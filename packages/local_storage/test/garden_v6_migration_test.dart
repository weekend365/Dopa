import 'dart:io';

import 'package:dopa_domain/dopa_domain.dart';
import 'package:dopa_local_storage/dopa_local_storage.dart';
import 'package:drift/native.dart';
import 'package:test/test.dart';

void main() {
  test('v5 to v6 preserves focus, outcomes, active run, tree ID and dates without retroactive growth', () async {
    final dir = await Directory.systemTemp.createTemp('dopa-v5-');
    final file = File('${dir.path}/migration.sqlite');
    var db = DopaDatabase(NativeDatabase(file));
    try {
      final focus = DriftFocusTreeRepository(
        database: db,
        treeIdFactory: () => 'legacy-tree',
      );
      await focus.writeTransaction(
        (tx) => tx.saveSession(
          FocusSession(
            id: 'legacy-focus',
            startedAtUtc: DateTime.utc(2026, 9, 9),
            startedLocalDate: LocalDate(2026, 9, 9),
            protectionMode: ProtectionMode.timerOnly,
            preset: SessionDurationPreset.fiveMinutes,
            intention: 'keep this',
          ),
        ),
      );
      await CompleteFocusSession(repository: focus)(
        sessionId: 'legacy-focus',
        terminalStatus: FocusSessionStatus.completed,
        endedAtUtc: DateTime.utc(2026, 9, 9, 0, 5),
        protectedDuration: const Duration(minutes: 5),
      );
      final repo = DriftCompanionRepository(database: db);
      CompanionRun run(String id) => CompanionRun(
        id: id,
        contentId: deskCompanionContent.id,
        contentVersion: 1,
        startedAtUtc: DateTime.utc(2026, 9, 10),
        startedLocalDate: LocalDate(2026, 9, 10),
        stepCount: 4,
      );
      await repo.startOrResume(run('old-result'));
      await repo.requestOutcome('old-result');
      await repo.submitOutcome(
        runId: 'old-result',
        outcome: CompanionOutcome.started,
        confirmedAtUtc: DateTime.utc(2026, 9, 10, 0, 2),
        confirmedLocalDate: LocalDate(2026, 9, 10),
      );
      await repo.startOrResume(run('pending'));
      await repo.advanceGuide('pending');
      // Reconstruct the actual v5 ledger contract. v5 never paid life outcomes.
      await db.customStatement(
        'ALTER TABLE tree_growth_credits RENAME TO new_credits',
      );
      await db.customStatement("""CREATE TABLE tree_growth_credits (
    tree_id TEXT NOT NULL REFERENCES tree_companions(id) ON DELETE CASCADE,
    source_session_id TEXT NOT NULL REFERENCES focus_sessions(id) ON DELETE RESTRICT,
    credited_local_date TEXT NOT NULL, credited_at_utc_micros INTEGER NOT NULL,
    rule_version INTEGER NOT NULL CHECK(rule_version > 0),
    PRIMARY KEY(source_session_id), UNIQUE(tree_id,credited_local_date))""");
      await db.customStatement(
        """INSERT INTO tree_growth_credits SELECT tree_id,source_session_id,
    credited_local_date,credited_at_utc_micros,rule_version FROM new_credits WHERE source_kind='focus'""",
      );
      await db.customStatement('DROP TABLE new_credits');
      await db.customStatement('PRAGMA user_version = 5');
      await db.customStatement('DROP TABLE photo_diaries');
      await db.customStatement('DROP TABLE photo_diary_remote_states');
      await db.close();
      db = DopaDatabase(NativeDatabase(file));
      final restored = DriftCompanionRepository(database: db);
      expect(
        (await db.select(db.focusSessions).getSingle()).intention,
        'keep this',
      );
      expect(
        (await db.select(db.treeCompanions).getSingle()).id,
        'legacy-tree',
      );
      expect((await restored.readActive())!.stepIndex, 1);
      expect(
        (await restored.readHistory()).single.outcome,
        CompanionOutcome.started,
      );
      await restored.submitOutcome(
        runId: 'old-result',
        outcome: CompanionOutcome.asPlanned,
        confirmedAtUtc: DateTime.utc(2026, 9, 11),
        confirmedLocalDate: LocalDate(2026, 9, 11),
      );
      final credits = await db.select(db.treeGrowthCredits).get();
      expect(credits, hasLength(1));
      expect(credits.single.sourceKind, 'focus');
      expect(credits.single.creditedLocalDate, '2026-09-09');
      expect(
        (await db.customSelect('PRAGMA user_version').getSingle()).read<int>(
          'user_version',
        ),
        7,
      );
    } finally {
      await db.close();
      for (final name in [
        'migration.sqlite',
        'migration.sqlite-wal',
        'migration.sqlite-shm',
      ]) {
        final f = File('${dir.path}/$name');
        if (await f.exists()) await f.delete();
      }
      await dir.delete();
    }
  });
}
