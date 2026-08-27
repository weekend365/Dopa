import '../shared/validation.dart';
import 'age_band.dart';

enum SignInProvider { apple, google }

/// Device-local account gate. Does not include wellbeing records.
///
/// Date of birth is never stored. [ageBand] is [AgeBand.age14To17] or
/// [AgeBand.adult18Plus] only.
final class AccountSession {
  static const currentConsentVersion = 'local-wellbeing-v1';

  AccountSession({
    required this.ageBand,
    required this.ageAttestedAtUtc,
    this.provider,
    this.consentVersion,
  }) {
    if (ageBand == AgeBand.under14) {
      throw ArgumentError.value(
        ageBand,
        'ageBand',
        'under14 sessions must not be persisted.',
      );
    }
    requireUtc(ageAttestedAtUtc, 'ageAttestedAtUtc');
    if (consentVersion != null) {
      requireNonBlank(consentVersion!, 'consentVersion');
    }
  }

  final AgeBand ageBand;
  final DateTime ageAttestedAtUtc;
  final SignInProvider? provider;
  final String? consentVersion;

  bool get isSignedIn => provider != null;

  bool get hasConsent =>
      consentVersion != null && consentVersion == currentConsentVersion;

  bool get canCreateLocalWellbeingData => isSignedIn && hasConsent;
}
