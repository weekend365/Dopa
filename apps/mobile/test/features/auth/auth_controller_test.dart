import 'package:dopa/core/persistence/dopa_database_providers.dart';
import 'package:dopa/features/auth/application/auth_controller.dart';
import 'package:dopa/features/auth/application/auth_providers.dart';
import 'package:dopa/features/auth/application/auth_session_store.dart';
import 'package:dopa/features/auth/application/sign_in_port.dart';
import 'package:dopa_domain/dopa_domain.dart';
import 'package:dopa_local_storage/dopa_local_storage.dart';
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

class _ScriptedSignInPort implements SignInPort {
  Future<SignInProvider> Function() result = () async => SignInProvider.apple;

  @override
  Future<SignInProvider> signInWithApple() => result();

  @override
  Future<SignInProvider> signInWithGoogle() => result();
}

void main() {
  late DopaDatabase database;
  late InMemoryAuthSessionStore store;
  late _ScriptedSignInPort signInPort;
  late ProviderContainer container;

  setUp(() {
    database = DopaDatabase(NativeDatabase.memory());
    store = InMemoryAuthSessionStore();
    signInPort = _ScriptedSignInPort();
    container = ProviderContainer(
      overrides: [
        authSessionStoreProvider.overrideWithValue(store),
        signInPortProvider.overrideWithValue(signInPort),
        dopaDatabaseProvider.overrideWithValue(database),
        authNowProvider.overrideWithValue(() => DateTime(2026, 8, 27, 12)),
      ],
    );
  });

  tearDown(() async {
    container.dispose();
    await database.close();
  });

  Future<AuthController> controller() async {
    final auth = container.read(authControllerProvider.notifier);
    await auth.initialized;
    return auth;
  }

  test('login cancel and failure never create a wellbeing tree', () async {
    final auth = await controller();
    await auth.attestAge(LocalDate(2000, 1, 1));

    signInPort.result = () async => throw const SignInCancelledException();
    await auth.signIn(SignInProvider.apple);
    expect(container.read(authControllerProvider).phase, AuthPhase.needsSignIn);
    expect(container.read(authControllerProvider).error, 'cancelled');
    expect(await database.select(database.treeCompanions).get(), isEmpty);

    signInPort.result = () async =>
        throw const SignInFailedException('offline');
    await auth.signIn(SignInProvider.google);
    expect(container.read(authControllerProvider).error, 'offline');
    expect(await database.select(database.treeCompanions).get(), isEmpty);
  });

  test('seed is created only after login and consent', () async {
    final auth = await controller();
    await auth.attestAge(LocalDate(2000, 1, 1));
    expect(await database.select(database.treeCompanions).get(), isEmpty);

    await auth.signIn(SignInProvider.apple);
    expect(await database.select(database.treeCompanions).get(), isEmpty);

    await auth.acceptConsent();
    expect(container.read(authControllerProvider).phase, AuthPhase.ready);
    expect(await database.select(database.treeCompanions).get(), hasLength(1));
    expect(
      await database.select(database.sevenDayExperiments).get(),
      hasLength(1),
    );
  });

  test('logout deletes the tree ledger and returns to sign-in', () async {
    final auth = await controller();
    await auth.attestAge(LocalDate(2000, 1, 1));
    await auth.signIn(SignInProvider.google);
    await auth.acceptConsent();
    await auth.logOut();

    expect(container.read(authControllerProvider).phase, AuthPhase.needsSignIn);
    expect((await store.read())?.provider, isNull);
    expect(await database.select(database.treeCompanions).get(), isEmpty);
    expect(await database.select(database.focusSessions).get(), isEmpty);
    expect(await database.select(database.treeGrowthCredits).get(), isEmpty);
    expect(await database.select(database.sevenDayExperiments).get(), isEmpty);
    expect(await database.select(database.dailyCheckIns).get(), isEmpty);
  });

  test('account deletion clears the age session', () async {
    final auth = await controller();
    await auth.attestAge(LocalDate(2000, 1, 1));
    await auth.signIn(SignInProvider.apple);
    await auth.acceptConsent();
    await auth.deleteAccount();

    expect(container.read(authControllerProvider).phase, AuthPhase.needsAge);
    expect(await store.read(), isNull);
    expect(await database.select(database.treeCompanions).get(), isEmpty);
  });

  test('under14 is not persisted and creates no tree', () async {
    final auth = await controller();
    await auth.attestAge(LocalDate(2012, 8, 28));

    expect(
      container.read(authControllerProvider).phase,
      AuthPhase.blockedUnder14,
    );
    expect(await store.read(), isNull);
    expect(await database.select(database.treeCompanions).get(), isEmpty);
  });

  test(
    'restoring a consented session backfills a missing experiment',
    () async {
      await EnsureTreeCompanion(
        repository: DriftFocusTreeRepository(
          database: database,
          treeIdFactory: () => 'tree-legacy',
        ),
      )(createdAtUtc: DateTime.utc(2026, 8, 20, 12));
      expect(
        await database.select(database.sevenDayExperiments).get(),
        isEmpty,
      );

      await store.save(
        AccountSession(
          ageBand: AgeBand.adult18Plus,
          ageAttestedAtUtc: DateTime.utc(2026, 8, 20),
          provider: SignInProvider.apple,
          consentVersion: AccountSession.currentConsentVersion,
        ),
      );

      await controller();
      expect(container.read(authControllerProvider).phase, AuthPhase.ready);
      expect(
        await database.select(database.sevenDayExperiments).get(),
        hasLength(1),
      );
    },
  );
}
