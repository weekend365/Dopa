import '../shared/local_date.dart';
import '../tree/focus_tree_repository.dart';
import 'seven_day_experiment.dart';

/// Idempotently starts the free 7-day experiment after login and consent.
final class EnsureSevenDayExperiment {
  const EnsureSevenDayExperiment({required FocusTreeRepository repository})
    : _repository = repository;

  final FocusTreeRepository _repository;

  Future<SevenDayExperiment> call({required LocalDate startedOn}) {
    return _repository.writeTransaction(
      (transaction) => transaction.getOrCreateExperiment(startedOn: startedOn),
    );
  }

  /// Starts the window from the existing tree when the experiment row is
  /// missing. Returns `null` before consent, so no check-in store is created.
  Future<SevenDayExperiment?> fromExistingTree() {
    return _repository.writeTransaction((transaction) async {
      final tree = await transaction.findTree();
      if (tree == null) {
        return null;
      }
      return transaction.getOrCreateExperiment(
        startedOn: LocalDate.fromLocal(tree.createdAtUtc.toLocal()),
      );
    });
  }
}
