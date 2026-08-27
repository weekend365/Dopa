import 'package:dopa_domain/dopa_domain.dart';

/// Pluggable Apple/Google sign-in. Network SDKs replace [ImmediateSignInPort].
abstract class SignInPort {
  Future<SignInProvider> signInWithApple();

  Future<SignInProvider> signInWithGoogle();
}

final class SignInCancelledException implements Exception {
  const SignInCancelledException();
}

final class SignInFailedException implements Exception {
  const SignInFailedException(this.code);

  /// Stable, non-PII failure code for UI copy. Never includes tokens.
  final String code;
}

/// Temporary adapter until Apple/Google SDKs are wired. A tap means success.
final class ImmediateSignInPort implements SignInPort {
  const ImmediateSignInPort();

  @override
  Future<SignInProvider> signInWithApple() async => SignInProvider.apple;

  @override
  Future<SignInProvider> signInWithGoogle() async => SignInProvider.google;
}
