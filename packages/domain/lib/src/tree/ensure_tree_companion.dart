import '../shared/validation.dart';
import 'focus_tree_repository.dart';
import 'tree_companion.dart';
import 'tree_growth_policy.dart';

/// Idempotently creates the device-local seed tree after login and consent.
///
/// Persistence adapters own tree ID generation. Their
/// [FocusTreeTransaction.getOrCreateTree] implementation must return the
/// existing companion on repeated calls.
final class EnsureTreeCompanion {
  const EnsureTreeCompanion({
    required FocusTreeRepository repository,
    this.policy = const TreeGrowthPolicy(),
  }) : _repository = repository;

  final FocusTreeRepository _repository;
  final TreeGrowthPolicy policy;

  Future<TreeCompanion> call({required DateTime createdAtUtc}) {
    policy.ensureSupported();
    requireUtc(createdAtUtc, 'createdAtUtc');
    return _repository.writeTransaction(
      (transaction) => transaction.getOrCreateTree(
        createdAtUtc: createdAtUtc,
        ruleVersion: policy.ruleVersion,
      ),
    );
  }
}
