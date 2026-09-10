import 'dart:async';

import 'package:dopa_domain/dopa_domain.dart';

/// Scriptable app boundary; SQLite durability is tested by local_storage.
class FakeCompanionRepository implements CompanionRepository {
  CompanionRun? active;
  final records = <CompanionOutcomeRecord>[];
  bool failRead = false;
  bool failStart = false;
  bool failNext = false;
  bool failSubmit = false;
  bool failHistory = false;
  bool failDelete = false;
  Completer<void>? nextGate;
  Completer<void>? submitGate;
  int submissions = 0;

  @override
  Future<CompanionRun?> readActive() async {
    if (failRead) throw StateError('test_read_failure');
    return active;
  }

  @override
  Future<CompanionRun> startOrResume(CompanionRun proposed) async {
    if (failStart) throw StateError('test_start_failure');
    return active ??= proposed;
  }

  @override
  Future<CompanionRun> advanceGuide(String runId) async {
    await nextGate?.future;
    if (failNext) throw StateError('test_progress_failure');
    return active = active!.advanceGuide();
  }

  @override
  Future<CompanionRun> requestOutcome(String runId) async =>
      active = active!.requestOutcome();

  @override
  Future<CompanionOutcomeRecord> submitOutcome({
    required String runId,
    required CompanionOutcome outcome,
    required DateTime confirmedAtUtc,
    required LocalDate confirmedLocalDate,
  }) async {
    submissions++;
    await submitGate?.future;
    if (failSubmit) throw StateError('test_write_failure');
    final existing = records.where((record) => record.run.id == runId);
    if (existing.isNotEmpty) return existing.first;
    final record = CompanionOutcomeRecord(
      run: active!,
      outcome: outcome,
      confirmedAtUtc: confirmedAtUtc,
      confirmedLocalDate: confirmedLocalDate,
    );
    records.insert(0, record);
    active = null;
    return record;
  }

  @override
  Future<List<CompanionOutcomeRecord>> readHistory({int limit = 50}) async {
    if (failHistory) throw StateError('test_history_failure');
    return records.take(limit).toList();
  }

  @override
  Future<void> deleteRecord(String runId) async {
    if (failDelete) throw StateError('test_delete_failure');
    records.removeWhere((record) => record.run.id == runId);
  }
}
