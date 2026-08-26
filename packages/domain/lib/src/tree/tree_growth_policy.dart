import 'tree_companion.dart';

/// Versioned, deterministic policy for deriving visuals from ledger row count.
///
/// Stages are never persisted. A client can rebuild [TreeProgress] from the
/// number of credits and the policy version recorded with the tree and credits.
final class TreeGrowthPolicy {
  const TreeGrowthPolicy({this.ruleVersion = 1}) : assert(ruleVersion > 0);

  static const currentRuleVersion = 1;

  static const List<int> revealMilestones = <int>[
    1,
    3,
    7,
    14,
    30,
    60,
    90,
  ];

  final int ruleVersion;

  void ensureSupported() => _validateRuleVersion();

  TreeGrowthStage stageFor(int totalGrowthDays) {
    _validateRuleVersion();
    _validateTotal(totalGrowthDays);
    if (totalGrowthDays >= 90) {
      return TreeGrowthStage.mature;
    }
    if (totalGrowthDays >= 60) {
      return TreeGrowthStage.broadCanopy;
    }
    if (totalGrowthDays >= 30) {
      return TreeGrowthStage.spreadingBranches;
    }
    if (totalGrowthDays >= 14) {
      return TreeGrowthStage.youngZelkova;
    }
    if (totalGrowthDays >= 7) {
      return TreeGrowthStage.smallTree;
    }
    if (totalGrowthDays >= 3) {
      return TreeGrowthStage.sapling;
    }
    if (totalGrowthDays >= 1) {
      return TreeGrowthStage.sprout;
    }
    return TreeGrowthStage.seed;
  }

  TreeProgress progressFor(int totalGrowthDays) {
    final stage = stageFor(totalGrowthDays);
    return TreeProgress(
      totalGrowthDays: totalGrowthDays,
      stage: stage,
      nextThreshold: _nextThresholdFor(stage),
      postMatureRingCount:
          totalGrowthDays < 120 ? 0 : (totalGrowthDays - 90) ~/ 30,
    );
  }

  bool isRevealMilestone(int totalGrowthDays) {
    _validateRuleVersion();
    _validateTotal(totalGrowthDays);
    return revealMilestones.contains(totalGrowthDays);
  }

  bool isPostMatureRingMilestone(int totalGrowthDays) {
    _validateRuleVersion();
    _validateTotal(totalGrowthDays);
    return totalGrowthDays >= 120 && (totalGrowthDays - 90) % 30 == 0;
  }

  static int? _nextThresholdFor(TreeGrowthStage stage) => switch (stage) {
        TreeGrowthStage.seed => 1,
        TreeGrowthStage.sprout => 3,
        TreeGrowthStage.sapling => 7,
        TreeGrowthStage.smallTree => 14,
        TreeGrowthStage.youngZelkova => 30,
        TreeGrowthStage.spreadingBranches => 60,
        TreeGrowthStage.broadCanopy => 90,
        TreeGrowthStage.mature => null,
      };

  static void _validateTotal(int totalGrowthDays) {
    if (totalGrowthDays < 0) {
      throw ArgumentError.value(
        totalGrowthDays,
        'totalGrowthDays',
        'Must not be negative.',
      );
    }
  }

  void _validateRuleVersion() {
    if (ruleVersion != currentRuleVersion) {
      throw UnsupportedError(
        'Unsupported tree growth rule version: $ruleVersion',
      );
    }
  }
}
