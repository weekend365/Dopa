import 'package:dopa/app/dopa_root.dart';
import 'package:dopa/app/dopa_app.dart';
import 'package:dopa/core/persistence/dopa_database_providers.dart';
import 'package:dopa/features/auth/application/auth_providers.dart';
import 'package:dopa/features/auth/application/auth_session_store.dart';
import 'package:dopa/features/focus/application/focus_session_controller.dart';
import 'package:dopa_local_storage/dopa_local_storage.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  testWidgets(
    'Android first use → silent rest → desk guide → focus → records; guest deletion',
    (t) async {
      final db = DopaDatabase(NativeDatabase.memory());
      final store = InMemoryAuthSessionStore();
      var now = DateTime(2026, 9, 11, 12), dbOpened = false;
      final container = ProviderContainer(
        overrides: [
          dopaDatabaseProvider.overrideWith((ref) {
            dbOpened = true;
            return db;
          }),
          authSessionStoreProvider.overrideWithValue(store),
          authNowProvider.overrideWithValue(() => now),
          localNowProvider.overrideWithValue(() => now),
        ],
      );
      Future<void> tap(Finder f) async {
        if (f.evaluate().isEmpty) await t.scrollUntilVisible(f, 150);
        await t.ensureVisible(f);
        await t.pumpAndSettle();
        await t.tap(f);
        await t.pumpAndSettle();
      }

      try {
        await t.pumpWidget(
          UncontrolledProviderScope(
            container: container,
            child: const DopaRoot(),
          ),
        );
        await t.pumpAndSettle();
        expect(dbOpened, false);
        await tap(find.byKey(const ValueKey('welcome-start')));
        await t.enterText(
          find.byKey(const ValueKey('age-gate-birthdate')),
          '20000101',
        );
        await tap(find.byKey(const ValueKey('age-gate-continue')));
        expect(dbOpened, false);
        await tap(find.byKey(const ValueKey('consent-accept')));
        expect(dbOpened, true);
        expect((await store.read())!.provider, isNull);
        await tap(find.byKey(const ValueKey('today-rest')));
        await tap(find.text('1분 쉬기 시작'));
        expect(find.text('01:00'), findsNothing);
        await tap(find.text('마치기'));
        expect(await db.select(db.treeGrowthCredits).get(), isEmpty);
        await tap(find.byKey(const ValueKey('today-start')));
        await tap(find.byKey(const ValueKey('companion-start')));
        for (var i = 0; i < 4; i++) {
          await tap(find.byKey(const ValueKey('companion-next')));
        }
        expect(await db.select(db.companionOutcomes).get(), isEmpty);
        await tap(find.text('조금 시작했어요'));
        expect(await db.select(db.treeGrowthCredits).get(), hasLength(1));
        await tap(find.text('5분 더 집중하기'));
        await tap(find.text('5분 집중 시작'));
        now = now.add(const Duration(minutes: 5));
        await t.pump(const Duration(seconds: 1));
        await tap(find.text('세션 완료'));
        await tap(find.text('내 기록 보기'));
        expect(find.text('5분 집중했어요'), findsOneWidget);
        expect(find.text('조금 시작했어요'), findsOneWidget);
        expect(await db.select(db.treeGrowthCredits).get(), hasLength(1));
        container.read(themeModeProvider.notifier).state = ThemeMode.dark;
        await t.pumpAndSettle();
        expect(t.takeException(), isNull);
        await tap(find.text('오늘'));
        await tap(find.byKey(const ValueKey('today-account')));
        await tap(find.byKey(const ValueKey('account-delete')));
        await tap(find.byKey(const ValueKey('account-delete-confirm')));
        expect(await store.read(), isNull);
        expect(await db.select(db.treeGrowthCredits).get(), isEmpty);
        expect(find.byKey(const ValueKey('welcome-start')), findsOneWidget);
      } finally {
        await t.pumpWidget(const SizedBox());
        await t.pump(const Duration(milliseconds: 10));
        container.dispose();
        await db.close();
      }
    },
  );
}
