import '../focus/focus_session.dart';
import '../shared/validation.dart';
import 'focus_tree_repository.dart';
import 'tree_companion.dart';
import 'tree_growth_policy.dart';

enum GrowthAwardStatus {
  awarded,
  alreadyAwardedForSession,
  alreadyAwardedForLocalDate,
  ineligibleSession,
}

final class CompleteFocusSessionResult {
  const CompleteFocusSessionResult({
    required this.session,
    required this.awardStatus,
    required this.tree,
    required this.credit,
    required this.progress,
  });

  final FocusSession session;
  final GrowthAwardStatus awardStatus;
  final TreeCompanion? tree;
  final TreeGrowthCredit? credit;
  final TreeProgress? progress;

  bool get didAwardGrowth => awardStatus == GrowthAwardStatus.awarded;
}

final class FocusSessionNotFoundException implements Exception {
  const FocusSessionNotFoundException(this.sessionId);

  final String sessionId;

  @override
  String toString() => 'FocusSessionNotFoundException($sessionId)';
}

final class FocusSessionFinalizationConflict implements Exception {
  const FocusSessionFinalizationConflict({
    required this.sessionId,
    required this.persistedStatus,
    required this.requestedStatus,
  });

  final String sessionId;
  final FocusSessionStatus persistedStatus;
  final FocusSessionStatus requestedStatus;

  @override
  String toString() =>
      'FocusSessionFinalizationConflict('
      'sessionId: $sessionId, persisted: $persistedStatus, '
      'requested: $requestedStatus)';
}

final class TreeRuleVersionConflict implements Exception {
  const TreeRuleVersionConflict({
    required this.treeId,
    required this.persistedRuleVersion,
    required this.requestedRuleVersion,
  });

  final String treeId;
  final int persistedRuleVersion;
  final int requestedRuleVersion;

  @override
  String toString() =>
      'TreeRuleVersionConflict('
      'treeId: $treeId, persisted: $persistedRuleVersion, '
      'requested: $requestedRuleVersion)';
}

/// Atomically finalizes a focus session and, when eligible, awards one growth
/// credit for the local date captured at session start.
///
/// Repeating the same command is safe. Conflicting attempts to change an
/// already-terminal status fail instead of rewriting session history.
final class CompleteFocusSession {
  const CompleteFocusSession({
    required FocusTreeRepository repository,
    this.policy = const TreeGrowthPolicy(),
  }) : _repository = repository;

  final FocusTreeRepository _repository;
  final TreeGrowthPolicy policy;

  Future<CompleteFocusSessionResult> call({
    required String sessionId,
    required FocusSessionStatus terminalStatus,
    required DateTime endedAtUtc,
    Duration? protectedDuration,
  }) {
    policy.ensureSupported();
    requireNonBlank(sessionId, 'sessionId');
    requireUtc(endedAtUtc, 'endedAtUtc');
    if (protectedDuration != null && protectedDuration.isNegative) {
      throw ArgumentError.value(
        protectedDuration,
        'protectedDuration',
        'Must not be negative.',
      );
    }
    if (!terminalStatus.isTerminal) {
      throw ArgumentError.value(
        terminalStatus,
        'terminalStatus',
        'Must be a terminal focus session status.',
      );
    }

    return _repository.writeTransaction((transaction) async {
      var session = await transaction.findSessionById(sessionId);
      if (session == null) {
        throw FocusSessionNotFoundException(sessionId);
      }
      if (endedAtUtc.isBefore(session.startedAtUtc)) {
        throw ArgumentError.value(
          endedAtUtc,
          'endedAtUtc',
          'Must not be before the persisted session start.',
        );
      }

      if (session.isTerminal) {
        if (session.status != terminalStatus) {
          throw FocusSessionFinalizationConflict(
            sessionId: session.id,
            persistedStatus: session.status,
            requestedStatus: terminalStatus,
          );
        }
      } else {
        session = session.finish(
          status: terminalStatus,
          endedAtUtc: endedAtUtc,
          protectedDuration: protectedDuration,
        );
        await transaction.saveSession(session);
      }

      if (!session.qualifiesForTreeGrowth) {
        return CompleteFocusSessionResult(
          session: session,
          awardStatus: GrowthAwardStatus.ineligibleSession,
          tree: null,
          credit: null,
          progress: null,
        );
      }

      final tree = await transaction.getOrCreateTree(
        createdAtUtc: session.startedAtUtc,
        ruleVersion: policy.ruleVersion,
      );
      if (tree.ruleVersion != policy.ruleVersion) {
        throw TreeRuleVersionConflict(
          treeId: tree.id,
          persistedRuleVersion: tree.ruleVersion,
          requestedRuleVersion: policy.ruleVersion,
        );
      }
      final existingCredit = await transaction
          .findGrowthCreditBySourceSessionId(session.id);
      if (existingCredit != null) {
        return _resultWithCurrentProgress(
          transaction: transaction,
          session: session,
          tree: tree,
          awardStatus: GrowthAwardStatus.alreadyAwardedForSession,
          credit: existingCredit,
        );
      }

      final candidate = TreeGrowthCredit(
        treeId: tree.id,
        sourceSessionId: session.id,
        creditedLocalDate: session.startedLocalDate,
        creditedAtUtc: session.endedAtUtc!,
        ruleVersion: policy.ruleVersion,
      );
      final insertOutcome = await transaction.tryInsertGrowthCredit(candidate);

      switch (insertOutcome) {
        case TreeGrowthCreditInsertOutcome.inserted:
          return _resultWithCurrentProgress(
            transaction: transaction,
            session: session,
            tree: tree,
            awardStatus: GrowthAwardStatus.awarded,
            credit: candidate,
          );
        case TreeGrowthCreditInsertOutcome.duplicateSourceSession:
          final persistedCredit = await transaction
              .findGrowthCreditBySourceSessionId(session.id);
          return _resultWithCurrentProgress(
            transaction: transaction,
            session: session,
            tree: tree,
            awardStatus: GrowthAwardStatus.alreadyAwardedForSession,
            credit: persistedCredit,
          );
        case TreeGrowthCreditInsertOutcome.duplicateLocalDate:
          return _resultWithCurrentProgress(
            transaction: transaction,
            session: session,
            tree: tree,
            awardStatus: GrowthAwardStatus.alreadyAwardedForLocalDate,
            credit: null,
          );
      }
    });
  }

  Future<CompleteFocusSessionResult> _resultWithCurrentProgress({
    required FocusTreeTransaction transaction,
    required FocusSession session,
    required TreeCompanion tree,
    required GrowthAwardStatus awardStatus,
    required TreeGrowthCredit? credit,
  }) async {
    final totalGrowthDays = await transaction.countGrowthCredits(tree.id);
    return CompleteFocusSessionResult(
      session: session,
      awardStatus: awardStatus,
      tree: tree,
      credit: credit,
      progress: policy.progressFor(totalGrowthDays),
    );
  }
}
