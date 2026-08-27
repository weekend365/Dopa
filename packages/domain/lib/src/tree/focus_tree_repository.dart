import '../experiment/daily_check_in.dart';
import '../experiment/seven_day_experiment.dart';
import '../focus/focus_session.dart';
import '../shared/local_date.dart';
import 'tree_companion.dart';

/// Result of a conflict-safe ledger insert.
enum TreeGrowthCreditInsertOutcome {
  inserted,
  duplicateSourceSession,
  duplicateLocalDate,
}

/// Device-local persistence boundary for focus completion and tree growth.
///
/// Implementations must keep all writes and reads in [writeTransaction] atomic.
/// No implementation of this contract should synchronize tree data to a server.
abstract interface class FocusTreeRepository {
  Future<T> writeTransaction<T>(
    Future<T> Function(FocusTreeTransaction transaction) operation,
  );
}

/// Operations available inside one focus/tree write transaction.
abstract interface class FocusTreeTransaction {
  Future<FocusSession?> findSessionById(String sessionId);

  Future<void> saveSession(FocusSession session);

  /// Returns the device-local tree when consent has already created it.
  Future<TreeCompanion?> findTree();

  /// Returns the one device-local tree, creating it atomically when absent.
  Future<TreeCompanion> getOrCreateTree({
    required DateTime createdAtUtc,
    required int ruleVersion,
  });

  Future<TreeGrowthCredit?> findGrowthCreditBySourceSessionId(
    String sourceSessionId,
  );

  /// Inserts a credit while enforcing unique constraints on source session ID
  /// and on `(treeId, creditedLocalDate)`.
  Future<TreeGrowthCreditInsertOutcome> tryInsertGrowthCredit(
    TreeGrowthCredit credit,
  );

  Future<int> countGrowthCredits(String treeId);

  Future<SevenDayExperiment> getOrCreateExperiment({
    required LocalDate startedOn,
  });

  /// Persists the first answer for [DailyCheckIn.localDate]. Later writes
  /// return the stored row instead of replacing it.
  Future<DailyCheckIn> saveCheckIn(DailyCheckIn checkIn);

  Future<DailyCheckIn?> findCheckIn(LocalDate localDate);
}
