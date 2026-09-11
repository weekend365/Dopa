import 'package:drift/drift.dart';

import '../database/dopa_database.dart';

class DiarySummary {
  const DiarySummary(
    this.id,
    this.localDate,
    this.body,
    this.status,
    this.hasArtwork,
  );
  final String id, localDate, body, status;
  final bool hasArtwork;
}

/// Images live in the same private DB/transaction as the diary, so deletion
/// cannot leave orphaned photo files. No diary content is serialized for APIs.
class DriftDiaryRepository {
  DriftDiaryRepository(this.db);
  final DopaDatabase db;
  Future<List<String>> pendingIds() async {
    final rows = await db
        .customSelect(
          "SELECT id FROM photo_diaries WHERE status IN ('submitting','queued','processing')",
        )
        .get();
    return rows.map((row) => row.read<String>('id')).toList();
  }

  Future<void> markRemoteUse() async {
    await db
        .into(db.photoDiaryRemoteStates)
        .insert(
          const PhotoDiaryRemoteStatesCompanion(singleton: Value(1)),
          mode: InsertMode.insertOrIgnore,
        );
  }

  Future<bool> hasRemoteUse() async =>
      (await db.select(db.photoDiaryRemoteStates).get()).isNotEmpty;

  // The library never loads every full-resolution photo into memory at once.
  Stream<List<DiarySummary>> watchAll() => db
      .customSelect(
        'SELECT id,local_date,body,status,(artwork IS NOT NULL) AS has_artwork FROM photo_diaries ORDER BY local_date DESC',
        readsFrom: {db.photoDiaries},
      )
      .watch()
      .map(
        (rows) => rows
            .map(
              (r) => DiarySummary(
                r.read<String>('id'),
                r.read<String>('local_date'),
                r.read<String>('body'),
                r.read<String>('status'),
                r.read<int>('has_artwork') == 1,
              ),
            )
            .toList(),
      );
  Future<PhotoDiaryRow?> read(String id) => (db.select(
    db.photoDiaries,
  )..where((t) => t.id.equals(id))).getSingleOrNull();
  Future<PhotoDiaryRow?> forDay(String day) => (db.select(
    db.photoDiaries,
  )..where((t) => t.localDate.equals(day))).getSingleOrNull();
  Future<void> create({
    required String id,
    required String day,
    required Uint8List photo,
    required String body,
    required DateTime now,
  }) async {
    await db
        .into(db.photoDiaries)
        .insert(
          PhotoDiariesCompanion.insert(
            id: id,
            localDate: day,
            original: photo,
            body: Value(body),
            createdAtUtcMicros: now.toUtc().microsecondsSinceEpoch,
          ),
        );
  }

  Future<void> edit(String id, String body) async {
    await (db.update(db.photoDiaries)..where((t) => t.id.equals(id))).write(
      PhotoDiariesCompanion(body: Value(body)),
    );
  }

  Future<void> setJob(String id, String jobId, String status) async {
    await (db.update(db.photoDiaries)..where((t) => t.id.equals(id))).write(
      PhotoDiariesCompanion(jobId: Value(jobId), status: Value(status)),
    );
  }

  Future<void> updateJob(
    String id,
    String jobId,
    String status, {
    Uint8List? artwork,
  }) async {
    // Compare-and-set: a late result must never recreate deleted/replaced data.
    await (db.update(
      db.photoDiaries,
    )..where((t) => t.id.equals(id) & t.jobId.equals(jobId))).write(
      PhotoDiariesCompanion(
        status: Value(status),
        artwork: artwork == null ? const Value.absent() : Value(artwork),
      ),
    );
  }

  Future<void> delete(String id) async {
    await (db.delete(db.photoDiaries)..where((t) => t.id.equals(id))).go();
    await db.customStatement('PRAGMA wal_checkpoint(TRUNCATE)');
  }
}
