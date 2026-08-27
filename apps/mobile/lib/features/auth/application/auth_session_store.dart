import 'package:dopa_domain/dopa_domain.dart';

abstract class AuthSessionStore {
  Future<AccountSession?> read();

  Future<void> save(AccountSession session);

  Future<void> clear();
}

final class InMemoryAuthSessionStore implements AuthSessionStore {
  InMemoryAuthSessionStore([this._session]);

  AccountSession? _session;

  @override
  Future<AccountSession?> read() async => _session;

  @override
  Future<void> save(AccountSession session) async {
    _session = session;
  }

  @override
  Future<void> clear() async {
    _session = null;
  }
}
