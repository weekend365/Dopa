import 'package:dopa_domain/dopa_domain.dart';
import 'package:test/test.dart';

void main() {
  final experiment = SevenDayExperiment(startedOn: LocalDate(2026, 8, 27));

  test('counts unique dates inside the 7-day window', () {
    expect(
      countExperimentAttemptDays(
        experiment: experiment,
        attemptDates: [
          LocalDate(2026, 8, 27),
          LocalDate(2026, 8, 27),
          LocalDate(2026, 8, 29),
          LocalDate(2026, 9, 2),
          LocalDate(2026, 8, 26),
          LocalDate(2026, 9, 3),
        ],
      ),
      3,
    );
  });

  test('keeps skipped days from resetting the window', () {
    expect(experiment.contains(LocalDate(2026, 8, 28)), isTrue);
    expect(experiment.endExclusive, LocalDate(2026, 9, 3));
    expect(
      countExperimentAttemptDays(
        experiment: experiment,
        attemptDates: const [],
      ),
      0,
    );
  });
}
