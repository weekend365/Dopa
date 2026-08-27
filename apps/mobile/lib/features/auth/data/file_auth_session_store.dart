import 'dart:convert';
import 'dart:io';

import 'package:dopa/features/auth/application/auth_session_store.dart';
import 'package:dopa_domain/dopa_domain.dart';
import 'package:path_provider/path_provider.dart';

final class FileAuthSessionStore implements AuthSessionStore {
  FileAuthSessionStore({Directory? directory}) : _directory = directory;

  static const _fileName = 'auth_session.json';

  final Directory? _directory;

  @override
  Future<AccountSession?> read() async {
    final file = await _file();
    if (!file.existsSync()) {
      return null;
    }
    final json = jsonDecode(await file.readAsString()) as Map<String, dynamic>;
    final band = AgeBand.values.byName(json['ageBand'] as String);
    final providerName = json['provider'] as String?;
    return AccountSession(
      ageBand: band,
      ageAttestedAtUtc: DateTime.parse(json['ageAttestedAtUtc'] as String),
      provider: providerName == null
          ? null
          : SignInProvider.values.byName(providerName),
      consentVersion: json['consentVersion'] as String?,
    );
  }

  @override
  Future<void> save(AccountSession session) async {
    final file = await _file();
    await file.parent.create(recursive: true);
    await file.writeAsString(
      jsonEncode({
        'ageBand': session.ageBand.name,
        'ageAttestedAtUtc': session.ageAttestedAtUtc.toIso8601String(),
        if (session.provider != null) 'provider': session.provider!.name,
        if (session.consentVersion != null)
          'consentVersion': session.consentVersion,
      }),
    );
  }

  @override
  Future<void> clear() async {
    final file = await _file();
    if (file.existsSync()) {
      await file.delete();
    }
  }

  Future<File> _file() async {
    final directory = _directory ?? await getApplicationSupportDirectory();
    return File('${directory.path}/$_fileName');
  }
}
