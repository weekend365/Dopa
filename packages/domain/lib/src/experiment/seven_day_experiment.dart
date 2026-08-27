import '../shared/local_date.dart';

/// The single free 7-day observation window.
///
/// Attempt days are distinct local dates inside the window. Skipping a day
/// does not reset progress or past tree growth.
final class SevenDayExperiment {
  static const lengthDays = 7;

  SevenDayExperiment({required this.startedOn});

  final LocalDate startedOn;

  LocalDate get endExclusive => startedOn.addDays(lengthDays);

  bool contains(LocalDate date) =>
      date.compareTo(startedOn) >= 0 && date.compareTo(endExclusive) < 0;
}

/// Counts unique attempt dates that fall inside the experiment window.
int countExperimentAttemptDays({
  required SevenDayExperiment experiment,
  required Iterable<LocalDate> attemptDates,
}) {
  final unique = <LocalDate>{};
  for (final date in attemptDates) {
    if (experiment.contains(date)) {
      unique.add(date);
    }
  }
  return unique.length;
}
