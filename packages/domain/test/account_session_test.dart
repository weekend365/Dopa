import 'package:dopa_domain/dopa_domain.dart';
import 'package:test/test.dart';

void main() {
  test('under14 sessions cannot be constructed', () {
    expect(
      () => AccountSession(
        ageBand: AgeBand.under14,
        ageAttestedAtUtc: DateTime.utc(2026, 8, 27),
      ),
      throwsArgumentError,
    );
  });

  test('wellbeing data is allowed only after login and current consent', () {
    final signedIn = AccountSession(
      ageBand: AgeBand.adult18Plus,
      ageAttestedAtUtc: DateTime.utc(2026, 8, 27),
      provider: SignInProvider.apple,
    );
    expect(signedIn.isSignedIn, isTrue);
    expect(signedIn.hasConsent, isFalse);
    expect(signedIn.canCreateLocalWellbeingData, isFalse);

    final ready = AccountSession(
      ageBand: AgeBand.age14To17,
      ageAttestedAtUtc: DateTime.utc(2026, 8, 27),
      provider: SignInProvider.google,
      consentVersion: AccountSession.currentConsentVersion,
    );
    expect(ready.canCreateLocalWellbeingData, isTrue);
  });
}
