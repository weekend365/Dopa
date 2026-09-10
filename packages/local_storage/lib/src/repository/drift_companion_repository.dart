import 'package:dopa_domain/dopa_domain.dart';
import 'package:drift/drift.dart';

import '../database/dopa_database.dart';

final class DriftCompanionRepository
    implements CompanionRepository, CompanionMediaRepository {
  const DriftCompanionRepository({required DopaDatabase database})
    : _db = database;

  final DopaDatabase _db;

  @override
  Future<CompanionRun?> readActive() async {
    final row = await (_db.select(
      _db.companionRuns,
    )..where((table) => table.activeSlot.equals(1))).getSingleOrNull();
    return row == null ? null : _run(row);
  }

  @override
  Future<CompanionRun> startOrResume(CompanionRun proposed) => _db.transaction(
    () async {
      final active = await readActive();
      if (active != null) return active;
      if (proposed.stepIndex != 0 || proposed.awaitingOutcome) {
        throw StateError('A new guide must begin at its first step.');
      }
      await _db
          .into(_db.companionRuns)
          .insert(
            CompanionRunsCompanion.insert(
              id: proposed.id,
              contentId: proposed.contentId,
              contentVersion: proposed.contentVersion,
              startedAtUtcMicros: proposed.startedAtUtc.microsecondsSinceEpoch,
              startedLocalDate: proposed.startedLocalDate.toIso8601String(),
              stepCount: proposed.stepCount,
              stepIndex: 0,
              guideCompleted: false,
              awaitingOutcome: false,
              activeSlot: const Value(1),
              guidanceMode: Value(proposed.guidanceMode.name),
            ),
          );
      return proposed;
    },
  );

  @override
  Future<CompanionRun> advanceGuide(String runId) =>
      _updateRun(runId, (run) => run.advanceGuide());

  @override
  Future<CompanionRun> savePlayback({
    required String runId,
    required int positionMs,
    required int revision,
    required int stepIndex,
    required CompanionGuidanceMode mode,
    bool completed = false,
  }) => _db.transaction(() async {
    final row = await _findRun(runId);
    final run = _run(row);
    if (row.activeSlot == null ||
        run.awaitingOutcome ||
        revision <= run.playbackRevision) {
      return run;
    }
    if (run.contentVersion != 2 ||
        mode == CompanionGuidanceMode.textSample ||
        (run.guidanceMode == CompanionGuidanceMode.textFallback &&
            mode == CompanionGuidanceMode.humanMedia)) {
      throw StateError('Invalid media mode transition.');
    }
    final next = run.withPlayback(
      positionMs: positionMs,
      revision: revision,
      stepIndex: stepIndex,
      mode: mode,
      completed: completed,
    );
    await (_db.update(
      _db.companionRuns,
    )..where((t) => t.id.equals(runId))).write(
      CompanionRunsCompanion(
        positionMs: Value(next.positionMs),
        playbackRevision: Value(next.playbackRevision),
        guidanceMode: Value(next.guidanceMode.name),
        stepIndex: Value(next.stepIndex),
        guideCompleted: Value(next.guideCompleted),
        awaitingOutcome: Value(next.awaitingOutcome),
      ),
    );
    return next;
  });

  @override
  Future<CompanionRun> requestOutcome(String runId) =>
      _updateRun(runId, (run) => run.requestOutcome());

  Future<CompanionRun> _updateRun(
    String id,
    CompanionRun Function(CompanionRun) update,
  ) => _db.transaction(() async {
    final row = await _findRun(id);
    if (row.activeSlot == null) return _run(row);
    final next = update(_run(row));
    await (_db.update(
      _db.companionRuns,
    )..where((table) => table.id.equals(id))).write(
      CompanionRunsCompanion(
        stepIndex: Value(next.stepIndex),
        guideCompleted: Value(next.guideCompleted),
        awaitingOutcome: Value(next.awaitingOutcome),
      ),
    );
    return next;
  });

  @override
  Future<CompanionOutcomeRecord> submitOutcome({
    required String runId,
    required CompanionOutcome outcome,
    required DateTime confirmedAtUtc,
    required LocalDate confirmedLocalDate,
  }) => _db.transaction(() async {
    final row = await _findRun(runId);
    final existing = await (_db.select(
      _db.companionOutcomes,
    )..where((table) => table.runId.equals(runId))).getSingleOrNull();
    if (existing != null) return _record(row, existing);
    if (!row.awaitingOutcome ||
        row.activeSlot == null ||
        !confirmedAtUtc.isUtc) {
      throw StateError('Request a self-report before saving an outcome.');
    }
    final inserted = await _db
        .into(_db.companionOutcomes)
        .insertReturning(
          CompanionOutcomesCompanion.insert(
            runId: runId,
            outcome: outcome.name,
            confirmedAtUtcMicros: confirmedAtUtc.microsecondsSinceEpoch,
            confirmedLocalDate: confirmedLocalDate.toIso8601String(),
          ),
        );
    await (_db.update(_db.companionRuns)
          ..where((table) => table.id.equals(runId)))
        .write(const CompanionRunsCompanion(activeSlot: Value(null)));
    return _record(row, inserted);
  });

  @override
  Future<List<CompanionOutcomeRecord>> readHistory({int limit = 50}) async {
    if (limit < 1 || limit > 100) throw ArgumentError.value(limit, 'limit');
    final query =
        _db.select(_db.companionOutcomes).join([
            innerJoin(
              _db.companionRuns,
              _db.companionRuns.id.equalsExp(_db.companionOutcomes.runId),
            ),
          ])
          ..orderBy([
            OrderingTerm.desc(_db.companionOutcomes.confirmedAtUtcMicros),
            OrderingTerm.desc(_db.companionOutcomes.runId),
          ])
          ..limit(limit);
    return (await query.get())
        .map(
          (row) => _record(
            row.readTable(_db.companionRuns),
            row.readTable(_db.companionOutcomes),
          ),
        )
        .toList(growable: false);
  }

  @override
  Future<void> deleteRecord(String runId) => _db.transaction(() async {
    // Unconfirmed runs are retained for resume. Account deletion removes both.
    await (_db.delete(
          _db.companionRuns,
        )..where((table) => table.id.equals(runId) & table.activeSlot.isNull()))
        .go();
  });

  Future<CompanionRunRow> _findRun(String id) => (_db.select(
    _db.companionRuns,
  )..where((table) => table.id.equals(id))).getSingle();

  CompanionRun _run(CompanionRunRow row) => CompanionRun(
    id: row.id,
    contentId: row.contentId,
    contentVersion: row.contentVersion,
    startedAtUtc: DateTime.fromMicrosecondsSinceEpoch(
      row.startedAtUtcMicros,
      isUtc: true,
    ),
    startedLocalDate: LocalDate.parse(row.startedLocalDate),
    stepCount: row.stepCount,
    stepIndex: row.stepIndex,
    guideCompleted: row.guideCompleted,
    awaitingOutcome: row.awaitingOutcome,
    positionMs: row.positionMs,
    playbackRevision: row.playbackRevision,
    guidanceMode: CompanionGuidanceMode.values.byName(row.guidanceMode),
  );

  CompanionOutcomeRecord _record(
    CompanionRunRow run,
    CompanionOutcomeRow outcome,
  ) => CompanionOutcomeRecord(
    run: _run(run),
    outcome: CompanionOutcome.values.byName(outcome.outcome),
    confirmedAtUtc: DateTime.fromMicrosecondsSinceEpoch(
      outcome.confirmedAtUtcMicros,
      isUtc: true,
    ),
    confirmedLocalDate: LocalDate.parse(outcome.confirmedLocalDate),
  );
}
