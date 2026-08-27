import 'package:dopa/app/dopa_root.dart';
import 'package:dopa/core/persistence/dopa_database_providers.dart';
import 'package:dopa/features/auth/application/auth_providers.dart';
import 'package:dopa/features/auth/application/auth_session_store.dart';
import 'package:dopa_domain/dopa_domain.dart';
import 'package:dopa_local_storage/dopa_local_storage.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late DopaDatabase database;
  late InMemoryAuthSessionStore store;

  setUp(() {
    database = DopaDatabase(NativeDatabase.memory());
    store = InMemoryAuthSessionStore();
  });

  tearDown(() async {
    await database.close();
  });

  Future<void> pumpRoot(WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authSessionStoreProvider.overrideWithValue(store),
          dopaDatabaseProvider.overrideWithValue(database),
          authNowProvider.overrideWithValue(() => DateTime(2026, 8, 27, 12)),
        ],
        child: const DopaRoot(),
      ),
    );
    await tester.pump();
    await tester.pump();
  }

  testWidgets('age gate blocks under14 then allows retry', (tester) async {
    await pumpRoot(tester);

    expect(find.text('나이 확인'), findsWidgets);
    await tester.enterText(
      find.byKey(const ValueKey('age-gate-birthdate')),
      '2012-08-28',
    );
    await tester.tap(find.byKey(const ValueKey('age-gate-continue')));
    await tester.pump();
    await tester.pump();

    expect(find.text('지금은 가입할 수 없어요'), findsOneWidget);
    expect(await database.select(database.treeCompanions).get(), isEmpty);

    await tester.tap(find.byKey(const ValueKey('age-blocked-retry')));
    await tester.pump();
    await tester.pump();
    expect(find.byKey(const ValueKey('age-gate-birthdate')), findsOneWidget);
  });

  testWidgets('login and consent mount the authenticated shell with a seed', (
    tester,
  ) async {
    await pumpRoot(tester);

    await tester.enterText(
      find.byKey(const ValueKey('age-gate-birthdate')),
      '2000-01-01',
    );
    await tester.tap(find.byKey(const ValueKey('age-gate-continue')));
    await tester.pump();
    await tester.pump();

    expect(find.text('Apple로 계속'), findsOneWidget);
    expect(await database.select(database.treeCompanions).get(), isEmpty);

    await tester.tap(find.byKey(const ValueKey('sign-in-apple')));
    await tester.pump();
    await tester.pump();
    expect(find.text('로컬 저장 동의'), findsWidgets);
    expect(await database.select(database.treeCompanions).get(), isEmpty);

    await tester.tap(find.byKey(const ValueKey('consent-accept')));
    await tester.pump();
    await tester.pump();

    expect(find.byKey(const ValueKey('today-account')), findsOneWidget);
    expect(await database.select(database.treeCompanions).get(), hasLength(1));
    expect(
      await database.select(database.sevenDayExperiments).get(),
      hasLength(1),
    );
  });

  testWidgets('logout from account returns to sign-in without a tree', (
    tester,
  ) async {
    await store.save(
      AccountSession(
        ageBand: AgeBand.adult18Plus,
        ageAttestedAtUtc: DateTime.utc(2026, 8, 27),
        provider: SignInProvider.apple,
        consentVersion: AccountSession.currentConsentVersion,
      ),
    );
    await pumpRoot(tester);

    await tester.tap(find.byKey(const ValueKey('today-account')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    await tester.tap(find.byKey(const ValueKey('account-logout')));
    await tester.pump();
    await tester.pump();

    expect(find.text('Apple로 계속'), findsOneWidget);
    expect(await database.select(database.treeCompanions).get(), isEmpty);
  });
}
