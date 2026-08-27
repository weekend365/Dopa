import '../shared/local_date.dart';
import '../shared/validation.dart';

enum TreeSpecies { zelkovaV1 }

enum TreeGrowthStage {
  seed,
  sprout,
  sapling,
  smallTree,
  youngZelkova,
  spreadingBranches,
  broadCanopy,
  mature,
}

final class TreeCompanion {
  factory TreeCompanion({
    required String id,
    TreeSpecies species = TreeSpecies.zelkovaV1,
    required DateTime createdAtUtc,
    required int ruleVersion,
  }) => TreeCompanion._(
    id: requireNonBlank(id, 'id'),
    species: species,
    createdAtUtc: requireUtc(createdAtUtc, 'createdAtUtc'),
    ruleVersion: requirePositive(ruleVersion, 'ruleVersion'),
  );

  const TreeCompanion._({
    required this.id,
    required this.species,
    required this.createdAtUtc,
    required this.ruleVersion,
  });

  final String id;
  final TreeSpecies species;
  final DateTime createdAtUtc;
  final int ruleVersion;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TreeCompanion &&
          id == other.id &&
          species == other.species &&
          createdAtUtc == other.createdAtUtc &&
          ruleVersion == other.ruleVersion;

  @override
  int get hashCode => Object.hash(id, species, createdAtUtc, ruleVersion);
}

/// One immutable row in the device-local tree growth ledger.
final class TreeGrowthCredit {
  factory TreeGrowthCredit({
    required String treeId,
    required String sourceSessionId,
    required LocalDate creditedLocalDate,
    required DateTime creditedAtUtc,
    required int ruleVersion,
  }) => TreeGrowthCredit._(
    treeId: requireNonBlank(treeId, 'treeId'),
    sourceSessionId: requireNonBlank(sourceSessionId, 'sourceSessionId'),
    creditedLocalDate: creditedLocalDate,
    creditedAtUtc: requireUtc(creditedAtUtc, 'creditedAtUtc'),
    ruleVersion: requirePositive(ruleVersion, 'ruleVersion'),
  );

  const TreeGrowthCredit._({
    required this.treeId,
    required this.sourceSessionId,
    required this.creditedLocalDate,
    required this.creditedAtUtc,
    required this.ruleVersion,
  });

  final String treeId;
  final String sourceSessionId;
  final LocalDate creditedLocalDate;
  final DateTime creditedAtUtc;
  final int ruleVersion;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TreeGrowthCredit &&
          treeId == other.treeId &&
          sourceSessionId == other.sourceSessionId &&
          creditedLocalDate == other.creditedLocalDate &&
          creditedAtUtc == other.creditedAtUtc &&
          ruleVersion == other.ruleVersion;

  @override
  int get hashCode => Object.hash(
    treeId,
    sourceSessionId,
    creditedLocalDate,
    creditedAtUtc,
    ruleVersion,
  );
}

final class TreeProgress {
  TreeProgress({
    required this.totalGrowthDays,
    required this.stage,
    required this.nextThreshold,
    required this.postMatureRingCount,
  }) {
    if (totalGrowthDays < 0) {
      throw ArgumentError.value(
        totalGrowthDays,
        'totalGrowthDays',
        'Must not be negative.',
      );
    }
    if (postMatureRingCount < 0) {
      throw ArgumentError.value(
        postMatureRingCount,
        'postMatureRingCount',
        'Must not be negative.',
      );
    }
  }

  final int totalGrowthDays;
  final TreeGrowthStage stage;

  /// The next visual-stage threshold, or `null` after reaching mature at 90.
  final int? nextThreshold;
  final int postMatureRingCount;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TreeProgress &&
          totalGrowthDays == other.totalGrowthDays &&
          stage == other.stage &&
          nextThreshold == other.nextThreshold &&
          postMatureRingCount == other.postMatureRingCount;

  @override
  int get hashCode =>
      Object.hash(totalGrowthDays, stage, nextThreshold, postMatureRingCount);
}
