import '../shared/local_date.dart';
import 'companion_session.dart';

abstract interface class CompanionRepository {
  Future<CompanionRun?> readActive();

  /// Returns the existing unfinished run if one exists.
  Future<CompanionRun> startOrResume(CompanionRun proposed);
  Future<CompanionRun> advanceGuide(String runId);
  Future<CompanionRun> requestOutcome(String runId);

  /// First committed self-report wins. Repeated submissions return it unchanged.
  Future<CompanionOutcomeRecord> submitOutcome({
    required String runId,
    required CompanionOutcome outcome,
    required DateTime confirmedAtUtc,
    required LocalDate confirmedLocalDate,
  });

  Future<List<CompanionOutcomeRecord>> readHistory({int limit = 50});
  Future<void> deleteRecord(String runId);
}
