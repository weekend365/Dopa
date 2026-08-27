import 'package:dopa/features/auth/application/auth_controller.dart';
import 'package:dopa/features/auth/application/auth_session_store.dart';
import 'package:dopa/features/auth/application/sign_in_port.dart';
import 'package:dopa/features/auth/data/file_auth_session_store.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final authSessionStoreProvider = Provider<AuthSessionStore>(
  (ref) => FileAuthSessionStore(),
);

final signInPortProvider = Provider<SignInPort>(
  (ref) => const ImmediateSignInPort(),
);

final authNowProvider = Provider<DateTime Function()>((ref) => DateTime.now);

final authControllerProvider = StateNotifierProvider<AuthController, AuthState>(
  (ref) {
    return AuthController(
      ref: ref,
      store: ref.watch(authSessionStoreProvider),
      signInPort: ref.watch(signInPortProvider),
      clock: ref.watch(authNowProvider),
    );
  },
);
