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
          authNowProvider.overrideWithValue(() => DateTime(2026, 9, 11, 12)),
        ],
        child: const DopaRoot(),
      ),
    );
    await tester.pumpAndSettle();
  }

  Future<void> tap(WidgetTester t, String key) async {
    final f = find.byKey(ValueKey(key));
    await t.ensureVisible(f);
    await t.tap(f);
    await t.pumpAndSettle();
  }

  testWidgets(
    'intro then age; under14 can correct age without entering activity',
    (t) async {
      await pumpRoot(t);
      await tap(t, 'welcome-start');
      await t.enterText(
        find.byKey(const ValueKey('age-gate-birthdate')),
        '2015-01-01',
      );
      await tap(t, 'age-gate-continue');
      expect(find.byKey(const ValueKey('age-blocked-retry')), findsOneWidget);
      expect((await store.read()), isNull);
      await tap(t, 'age-blocked-retry');
      expect(find.byKey(const ValueKey('age-gate-birthdate')), findsOneWidget);
    },
  );
  testWidgets(
    'guest consent initializes garden; relaunch preserves it; all delete resets',
    (t) async {
      await pumpRoot(t);
      await tap(t, 'welcome-start');
      await t.enterText(
        find.byKey(const ValueKey('age-gate-birthdate')),
        '20000101',
      );
      await tap(t, 'age-gate-continue');
      expect(find.text('Apple로 계속'), findsNothing);
      expect(find.text('내 기록은 내 기기에'), findsWidgets);
      expect(await database.select(database.treeCompanions).get(), isEmpty);
      await tap(t, 'consent-accept');
      expect(find.byKey(const ValueKey('today-start')), findsOneWidget);
      final original =
          (await database.select(database.treeCompanions).getSingle()).id;
      expect((await store.read())!.provider, isNull);
      await t.pumpWidget(const SizedBox());
      await pumpRoot(t);
      expect(
        (await database.select(database.treeCompanions).getSingle()).id,
        original,
      );
      await tap(t, 'today-account');
      await tap(t, 'account-delete');
      await tap(t, 'account-delete-confirm');
      expect(await store.read(), isNull);
      expect(await database.select(database.treeCompanions).get(), isEmpty);
      expect(find.byKey(const ValueKey('welcome-start')), findsOneWidget);
      await t.pumpWidget(const SizedBox());
      await t.pump(const Duration(milliseconds: 1));
    },
  );
  testWidgets(
    'existing consent requires one local-use update and preserves tree',
    (t) async {
      await EnsureTreeCompanion(
        repository: DriftFocusTreeRepository(
          database: database,
          treeIdFactory: () => 'legacy',
        ),
      )(createdAtUtc: DateTime.utc(2026, 8, 1));
      await store.save(
        AccountSession(
          ageBand: AgeBand.adult18Plus,
          ageAttestedAtUtc: DateTime.utc(2026, 9, 1),
          provider: SignInProvider.apple,
          consentVersion: 'v1',
        ),
      );
      await pumpRoot(t);
      expect(find.byKey(const ValueKey('consent-accept')), findsOneWidget);
      await tap(t, 'consent-accept');
      expect(
        (await database.select(database.treeCompanions).getSingle()).id,
        'legacy',
      );
      expect((await store.read())!.hasConsent, isTrue);
      await t.pumpWidget(const SizedBox());
      await t.pump(const Duration(milliseconds: 1));
    },
  );
}
