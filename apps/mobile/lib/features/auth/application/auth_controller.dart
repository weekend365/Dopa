import 'package:dopa/core/persistence/dopa_database_providers.dart';
import 'package:dopa/features/auth/application/auth_session_store.dart';
import 'package:dopa/features/auth/application/sign_in_port.dart';
import 'package:dopa/features/experiment/application/daily_check_in_controller.dart';
import 'package:dopa/features/tree_companion/application/tree_companion_providers.dart';
import 'package:dopa_domain/dopa_domain.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

enum AuthPhase {
  loading,
  needsAge,
  blockedUnder14,
  needsSignIn,
  needsConsent,
  ready,
}

final class AuthState {
  const AuthState({required this.phase, this.session, this.error});

  final AuthPhase phase;
  final AccountSession? session;
  final String? error;
}

class AuthController extends StateNotifier<AuthState> {
  AuthController({
    required Ref ref,
    required AuthSessionStore store,
    required SignInPort signInPort,
    DateTime Function()? clock,
  }) : _ref = ref,
       _store = store,
       _signInPort = signInPort,
       _clock = clock ?? DateTime.now,
       super(const AuthState(phase: AuthPhase.loading)) {
    initialized = _restore();
  }

  final Ref _ref;
  final AuthSessionStore _store;
  final SignInPort _signInPort;
  final DateTime Function() _clock;
  late final Future<void> initialized;

  Future<void> _restore() async {
    try {
      final session = await _store.read();
      state = AuthState(phase: _phaseFor(session, _clock()), session: session);
    } on Object {
      await _store.clear();
      state = const AuthState(phase: AuthPhase.needsAge);
    }
  }

  Future<void> attestAge(LocalDate dateOfBirth) async {
    final now = _clock();
    final today = LocalDate.fromLocal(now);
    final band = ageBandOn(dateOfBirth: dateOfBirth, today: today);
    if (band == AgeBand.under14) {
      state = const AuthState(phase: AuthPhase.blockedUnder14);
      return;
    }

    final previous = state.session;
    final session = AccountSession(
      ageBand: band,
      ageAttestedAtUtc: now.toUtc(),
      provider: previous?.provider,
      consentVersion: previous?.consentVersion,
    );
    await _store.save(session);
    state = AuthState(phase: _phaseFor(session, now), session: session);
  }

  void retryAgeGate() {
    state = const AuthState(phase: AuthPhase.needsAge);
  }

  Future<void> signIn(SignInProvider requested) async {
    final current = state.session;
    if (current == null) {
      state = const AuthState(phase: AuthPhase.needsAge);
      return;
    }
    try {
      final provider = switch (requested) {
        SignInProvider.apple => await _signInPort.signInWithApple(),
        SignInProvider.google => await _signInPort.signInWithGoogle(),
      };
      final session = AccountSession(
        ageBand: current.ageBand,
        ageAttestedAtUtc: current.ageAttestedAtUtc,
        provider: provider,
        consentVersion: current.consentVersion,
      );
      await _store.save(session);
      state = AuthState(phase: _phaseFor(session, _clock()), session: session);
    } on SignInCancelledException {
      state = AuthState(
        phase: AuthPhase.needsSignIn,
        session: current,
        error: 'cancelled',
      );
    } on SignInFailedException catch (error) {
      state = AuthState(
        phase: AuthPhase.needsSignIn,
        session: current,
        error: error.code,
      );
    }
  }

  Future<void> acceptConsent() async {
    final current = state.session;
    if (current == null || !current.isSignedIn) {
      state = AuthState(phase: _phaseFor(current, _clock()), session: current);
      return;
    }

    try {
      await _ref
          .read(localAccountDataLifecycleProvider)
          .initializeAfterLoginAndConsent(createdAtUtc: _clock().toUtc());
    } on Object {
      state = AuthState(
        phase: AuthPhase.needsConsent,
        session: current,
        error: 'seed_failed',
      );
      return;
    }

    final session = AccountSession(
      ageBand: current.ageBand,
      ageAttestedAtUtc: current.ageAttestedAtUtc,
      provider: current.provider,
      consentVersion: AccountSession.currentConsentVersion,
    );
    await _store.save(session);
    state = AuthState(phase: AuthPhase.ready, session: session);
  }

  Future<void> logOut() async {
    await _wipeWellbeingAndInvalidate();
    final current = state.session;
    if (current == null) {
      state = const AuthState(phase: AuthPhase.needsAge);
      return;
    }
    final session = AccountSession(
      ageBand: current.ageBand,
      ageAttestedAtUtc: current.ageAttestedAtUtc,
    );
    await _store.save(session);
    state = AuthState(phase: AuthPhase.needsSignIn, session: session);
  }

  Future<void> deleteAccount() async {
    await _wipeWellbeingAndInvalidate();
    await _store.clear();
    state = const AuthState(phase: AuthPhase.needsAge);
  }

  Future<void> _wipeWellbeingAndInvalidate() async {
    await _ref
        .read(localAccountDataLifecycleProvider)
        .deleteForLogoutOrAccountDeletion();
    _ref.invalidate(dopaDatabaseProvider);
    _ref.invalidate(focusTreeRepositoryProvider);
    _ref.invalidate(localAccountDataLifecycleProvider);
    _ref.invalidate(treeProgressControllerProvider);
    _ref.invalidate(weeklyGrowthDaysControllerProvider);
    _ref.invalidate(experimentAttemptDaysControllerProvider);
    _ref.invalidate(dailyCheckInControllerProvider);
  }

  AuthPhase _phaseFor(AccountSession? session, DateTime now) {
    if (session == null) {
      return AuthPhase.needsAge;
    }
    final today = LocalDate.fromLocal(now);
    final attestedOn = LocalDate.fromLocal(session.ageAttestedAtUtc.toLocal());
    if (needsAgeReattestation(
      ageBand: session.ageBand,
      ageAttestedOn: attestedOn,
      today: today,
    )) {
      return AuthPhase.needsAge;
    }
    if (!session.isSignedIn) {
      return AuthPhase.needsSignIn;
    }
    if (!session.hasConsent) {
      return AuthPhase.needsConsent;
    }
    return AuthPhase.ready;
  }
}
