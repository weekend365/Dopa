import '../shared/local_date.dart';

enum AgeBand { under14, age14To17, adult18Plus }

/// Calendar age-band used before any auth SDK is enabled.
///
/// The 14th and 18th birthdays are inclusive: the user may continue on the
/// birthday itself. February 29 births use February 28 in non-leap years.
AgeBand ageBandOn({required LocalDate dateOfBirth, required LocalDate today}) {
  final fourteenth = _anniversary(dateOfBirth, 14);
  if (today.compareTo(fourteenth) < 0) {
    return AgeBand.under14;
  }
  final eighteenth = _anniversary(dateOfBirth, 18);
  if (today.compareTo(eighteenth) < 0) {
    return AgeBand.age14To17;
  }
  return AgeBand.adult18Plus;
}

/// 14–17 users re-enter a local age check 12 months after [ageAttestedOn].
bool needsAgeReattestation({
  required AgeBand ageBand,
  required LocalDate ageAttestedOn,
  required LocalDate today,
}) {
  if (ageBand != AgeBand.age14To17) {
    return false;
  }
  return today.compareTo(_anniversary(ageAttestedOn, 1)) >= 0;
}

LocalDate _anniversary(LocalDate birth, int yearsLater) {
  final year = birth.year + yearsLater;
  try {
    return LocalDate(year, birth.month, birth.day);
  } on ArgumentError {
    return LocalDate(year, 2, 28);
  }
}
