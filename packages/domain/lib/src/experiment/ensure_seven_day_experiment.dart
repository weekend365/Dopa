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
}
