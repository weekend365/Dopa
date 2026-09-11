import 'dart:async';

import 'package:dopa/core/persistence/dopa_database_providers.dart';
import 'package:dopa/features/insights/presentation/weekly_report_page.dart';
import 'package:dopa_domain/dopa_domain.dart';
import 'package:dopa_local_storage/dopa_local_storage.dart';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('timeline merges local dates, reacts to diary edits/deletes and preserves guide identity', () async {
    final db = DopaDatabase(NativeDatabase.memory());
    final container = ProviderContainer(
      overrides: [dopaDatabaseProvider.overrideWithValue(db)],
    );
    final subscription = container.listen(activityRecordsProvider, (_, _) {});
    final diaries = DriftDiaryRepository(db);
    try {
      await diaries.create(
        id: 'photo',
        day: '2026-09-11',
        photo: Uint8List.fromList([1]),
        body: '첫 장면',
        now: DateTime.utc(2026, 9, 12),
      );
      await db
          .into(db.focusSessions)
          .insert(
            FocusSessionsCompanion.insert(
              id: 'focus',
              startedAtUtcMicros: DateTime.utc(
                2026,
                9,
                13,
              ).microsecondsSinceEpoch,
              startedLocalDate: '2026-09-10',
              protectionMode: 'timerOnly',
              durationPresetMinutes: 10,
              plannedDurationSeconds: 600,
              protectedDurationSeconds: 30,
              status: 'endedEarly',
              endedAtUtcMicros: Value(
                DateTime.utc(2026, 9, 13, 0, 1).microsecondsSinceEpoch,
              ),
              usedFiveMinuteBypass: false,
            ),
          );
      final companions = DriftCompanionRepository(database: db);
      await companions.startOrResume(
        CompanionRun(
          id: 'reading',
          contentId: readingCompanionContent.id,
          contentVersion: 1,
          startedAtUtc: DateTime.utc(2026, 9, 11),
          startedLocalDate: LocalDate.parse('2026-09-11'),
          stepCount: 4,
        ),
      );
      Future<List<ActivityRecord>> matching(
        bool Function(List<ActivityRecord>) predicate,
      ) {
        final ready = Completer<List<ActivityRecord>>();
        final listener = container.listen(activityRecordsProvider, (_, value) {
          value.whenData((rows) {
            if (!ready.isCompleted && predicate(rows)) ready.complete(rows);
          });
        }, fireImmediately: true);
        return ready.future
            .timeout(const Duration(seconds: 5))
            .whenComplete(listener.close);
      }

      final initial = await matching((rows) => rows.length == 3);
      expect(initial.map((r) => r.id), ['photo', 'reading', 'focus']);
      expect(initial[1].title, '책 한 쪽 펼치기');
      expect(initial[1].route, '/companion');
      expect(initial.last.detail, '중간에 마쳤어요');
      expect(initial.first.route, '/diary/entry/photo');
      final edited = matching((rows) => rows.any((r) => r.detail == '수정한 장면'));
      await diaries.edit('photo', '수정한 장면');
      await edited;
      await companions.requestOutcome('reading');
      final completed = matching(
        (rows) => rows.any((r) => r.kind == 'companion' && r.route == null),
      );
      await companions.submitOutcome(
        runId: 'reading',
        outcome: CompanionOutcome.difficult,
        confirmedAtUtc: DateTime.utc(2026, 9, 12),
        confirmedLocalDate: LocalDate.parse('2026-09-12'),
      );
      expect(
        (await completed).firstWhere((r) => r.id == 'reading').date,
        '2026-09-11',
      );
      final deleted = matching((rows) => rows.length == 2);
      await diaries.delete('photo');
      expect((await deleted).any((r) => r.kind == 'diary'), isFalse);
    } finally {
      subscription.close();
      container.dispose();
      await db.close();
    }
  });
}
