import 'dart:typed_data';

import 'package:dopa_local_storage/dopa_local_storage.dart';
import 'package:drift/native.dart';
import 'package:sqlite3/sqlite3.dart';
import 'package:test/test.dart';

void main() {
  late DopaDatabase db;
  late DriftDiaryRepository repo;
  setUp(() {
    db = DopaDatabase(NativeDatabase.memory());
    repo = DriftDiaryRepository(db);
  });
  tearDown(() => db.close());
  Future<void> create(String id, String day) => repo.create(
    id: id,
    day: day,
    photo: Uint8List.fromList([1, 2, 3]),
    body: '사진 일기',
    now: DateTime.utc(2026, 9, 11),
  );

  test(
    'one entry per local day, text edits keep original and artwork',
    () async {
      await create('a', '2026-09-11');
      await expectLater(
        create('b', '2026-09-11'),
        throwsA(isA<SqliteException>()),
      );
      await repo.setJob('a', 'job', 'processing');
      await repo.updateJob(
        'a',
        'job',
        'succeeded',
        artwork: Uint8List.fromList([9]),
      );
      await repo.edit('a', '수정한 글');
      final entry = (await repo.read('a'))!;
      expect(entry.body, '수정한 글');
      expect(entry.original, [1, 2, 3]);
      expect(entry.artwork, [9]);
      final summary = (await repo.watchAll().first).single;
      expect(summary.body, '수정한 글');
      expect(summary.hasArtwork, true);
      expect(await db.select(db.treeGrowthCredits).get(), isEmpty);
    },
  );
  test('delete and stale callbacks cannot recreate images; remote marker survives individual deletion', () async {
    await create('a', '2026-09-11');
    await repo.markRemoteUse();
    await repo.setJob('a', 'job', 'processing');
    await repo.delete('a');
    await repo.updateJob(
      'a',
      'job',
      'succeeded',
      artwork: Uint8List.fromList([9]),
    );
    expect(await repo.read('a'), isNull);
    expect(await repo.hasRemoteUse(), isTrue);
    await db.deleteAllLocalData();
    expect(await repo.hasRemoteUse(), isFalse);
    expect(await db.select(db.photoDiaries).get(), isEmpty);
  });
  test(
    'v6 migration adds empty diary storage and preserves existing values',
    () async {
      final schema = await db
          .customSelect(
            "SELECT sql FROM sqlite_master WHERE type='table' AND name NOT LIKE 'sqlite_%' AND name NOT LIKE 'photo_%'",
          )
          .get();
      final legacy = sqlite3.openInMemory();
      for (final row in schema) {
        legacy.execute(row.read<String>('sql'));
      }
      legacy.execute("INSERT INTO daily_check_ins VALUES ('2026-09-10','yes')");
      legacy.execute('PRAGMA user_version=6');
      final migrated = DopaDatabase(NativeDatabase.opened(legacy));
      try {
        expect(await migrated.select(migrated.photoDiaries).get(), isEmpty);
        expect(
          (await migrated.select(migrated.dailyCheckIns).getSingle()).localDate,
          '2026-09-10',
        );
        expect(legacy.select('PRAGMA user_version').single.values.single, 7);
      } finally {
        await migrated.close();
      }
    },
  );
}
