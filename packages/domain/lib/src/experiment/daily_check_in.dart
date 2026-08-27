import '../shared/local_date.dart';

enum IntentionAlignment { yes, no, skipped }

/// One optional local check-in per calendar date.
///
/// Answers never affect tree growth and must not leave the device.
final class DailyCheckIn {
  DailyCheckIn({required this.localDate, required this.intentionAlignment});

  final LocalDate localDate;
  final IntentionAlignment intentionAlignment;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DailyCheckIn &&
          localDate == other.localDate &&
          intentionAlignment == other.intentionAlignment;

  @override
  int get hashCode => Object.hash(localDate, intentionAlignment);
}
