import 'dart:io';

import 'package:dopa/features/auth/data/file_auth_session_store.dart';
import 'package:dopa_domain/dopa_domain.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test(
    'round-trips a signed-in consented session without a date of birth',
    () async {
      final directory = await Directory.systemTemp.createTemp('dopa_auth');
      addTearDown(() => directory.delete(recursive: true));
      final store = FileAuthSessionStore(directory: directory);
      final session = AccountSession(
        ageBand: AgeBand.adult18Plus,
        ageAttestedAtUtc: DateTime.utc(2026, 8, 27, 3, 4, 5),
        provider: SignInProvider.apple,
        consentVersion: AccountSession.currentConsentVersion,
      );

      await store.save(session);
      final restored = await store.read();

      expect(restored!.ageBand, AgeBand.adult18Plus);
      expect(restored.ageAttestedAtUtc, DateTime.utc(2026, 8, 27, 3, 4, 5));
      expect(restored.provider, SignInProvider.apple);
      expect(restored.consentVersion, AccountSession.currentConsentVersion);
      expect(
        directory.listSync().map((file) => file.path).join(),
        isNot(contains('2012')),
      );

      await store.clear();
      expect(await store.read(), isNull);
    },
  );
}
