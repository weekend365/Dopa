/// A calendar date without a time or timezone.
///
/// A focus session captures this value at start time. It must not be recomputed
/// when the session ends or when the device timezone changes.
final class LocalDate implements Comparable<LocalDate> {
  factory LocalDate(int year, int month, int day) {
    if (year < 1 || year > 9999) {
      throw ArgumentError.value(year, 'year', 'Must be between 1 and 9999.');
    }

    final normalized = DateTime.utc(year, month, day);
    if (normalized.year != year ||
        normalized.month != month ||
        normalized.day != day) {
      throw ArgumentError.value(
        '$year-$month-$day',
        'date',
        'Must be a valid calendar date.',
      );
    }

    return LocalDate._(year, month, day);
  }

  const LocalDate._(this.year, this.month, this.day);

  factory LocalDate.fromLocal(DateTime localDateTime) => LocalDate(
        localDateTime.year,
        localDateTime.month,
        localDateTime.day,
      );

  factory LocalDate.parse(String value) {
    final match = RegExp(r'^(\d{4})-(\d{2})-(\d{2})$').firstMatch(value);
    if (match == null) {
      throw FormatException('Expected a date in YYYY-MM-DD format.', value);
    }

    try {
      return LocalDate(
        int.parse(match.group(1)!),
        int.parse(match.group(2)!),
        int.parse(match.group(3)!),
      );
    } on ArgumentError {
      throw FormatException('Expected a valid calendar date.', value);
    }
  }

  final int year;
  final int month;
  final int day;

  LocalDate addDays(int days) {
    final value = DateTime.utc(year, month, day).add(Duration(days: days));
    return LocalDate(value.year, value.month, value.day);
  }

  String toIso8601String() => '${year.toString().padLeft(4, '0')}-'
      '${month.toString().padLeft(2, '0')}-'
      '${day.toString().padLeft(2, '0')}';

  @override
  int compareTo(LocalDate other) {
    final yearComparison = year.compareTo(other.year);
    if (yearComparison != 0) {
      return yearComparison;
    }
    final monthComparison = month.compareTo(other.month);
    if (monthComparison != 0) {
      return monthComparison;
    }
    return day.compareTo(other.day);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LocalDate &&
          year == other.year &&
          month == other.month &&
          day == other.day;

  @override
  int get hashCode => Object.hash(year, month, day);

  @override
  String toString() => toIso8601String();
}
