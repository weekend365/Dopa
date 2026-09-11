import 'package:dopa/app/dopa_root.dart';

import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:dopa/app/router/dopa_router.dart';
import 'package:dopa/core/persistence/dopa_database_providers.dart';
import 'package:dopa/features/auth/application/auth_providers.dart';
import 'package:dopa/features/auth/application/auth_session_store.dart';
import 'package:dopa/features/diary/application/diary_controller.dart';
import 'package:dopa/features/diary/data/diary_api.dart';
import 'package:dopa/features/diary/data/diary_photo_picker.dart';
import 'package:dopa_local_storage/dopa_local_storage.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

class FixturePicker implements DiaryPhotoPicker {
  @override
  Future<Uint8List?> pick() async {
    if (const bool.fromEnvironment('DOPA_NATIVE_PICKER_TEST')) {
      return NativeDiaryPhotoPicker().pick();
    }
    return normalizePhoto(
      (await rootBundle.load('assets/garden/light_0.webp')).buffer
          .asUint8List(),
    );
  }

  @override
  Future<Uint8List?> recover() async => null;
}

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  testWidgets(
    'Android diary local save → explicit consent → real local HTTP queue → download → edit → delete',
    (t) async {
      // Prevent the native IME from replaying stale text over injected test input.
      // HTTP, SQLite and secure storage remain real; input is a test fixture.
      t.testTextInput.register();
      final db = DopaDatabase(NativeDatabase.memory());
      final api = HttpDiaryApi('http://127.0.0.1:8788');
      final container = ProviderContainer(
        overrides: [
          dopaDatabaseProvider.overrideWithValue(db),
          authSessionStoreProvider.overrideWithValue(
            InMemoryAuthSessionStore(),
          ),
          diaryApiProvider.overrideWithValue(api),
          diaryPickerProvider.overrideWithValue(FixturePicker()),
        ],
      );
      Future<void> tap(Finder target) async {
        if (target.evaluate().isEmpty) {
          await t.scrollUntilVisible(
            target,
            180,
            scrollable: find.byType(Scrollable).first,
          );
        }
        await t.ensureVisible(target);
        await t.pumpAndSettle();
        await t.tap(target);
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
        await tap(find.byKey(const ValueKey('welcome-start')));
        await t.enterText(
          find.byKey(const ValueKey('age-gate-birthdate')),
          '20000101',
        );
        await tap(find.byKey(const ValueKey('age-gate-continue')));
        await tap(find.byKey(const ValueKey('consent-accept')));
        await tap(find.byKey(const ValueKey('today-diary')));
        await tap(find.byKey(const ValueKey('diary-pick')));
        if (const bool.fromEnvironment('DOPA_NATIVE_PICKER_TEST')) {
          for (
            var i = 0;
            i < 360 && find.text('다른 사진 고르기').evaluate().isEmpty;
            i++
          ) {
            await t.pump(const Duration(milliseconds: 500));
          }
          expect(find.text('다른 사진 고르기'), findsOneWidget);
        }
        await t.ensureVisible(find.byKey(const ValueKey('diary-body')));
        await t.pumpAndSettle();
        await t.enterText(
          find.byKey(const ValueKey('diary-body')),
          '테스트: 창가에서 잠깐 쉬었어요.',
        );
        await tap(find.byKey(const ValueKey('diary-save')));
        final initial = await db.select(db.photoDiaries).getSingle();
        expect(initial.jobId, isNull);
        expect(await db.select(db.treeGrowthCredits).get(), isEmpty);
        await tap(find.byKey(const ValueKey('diary-convert')));
        await tap(find.byKey(const ValueKey('diary-consent')));
        for (var i = 0; i < 20; i++) {
          if ((await db.select(db.photoDiaries).getSingle()).artwork != null) {
            break;
          }
          await t.pump(const Duration(seconds: 1));
        }
        final completed = await db.select(db.photoDiaries).getSingle();
        expect(completed.status, 'succeeded');
        expect(completed.artwork, isNotNull);
        expect(completed.original, initial.original);
        expect(completed.body, initial.body);
        await t.pumpAndSettle();
        await tap(find.text('원본 사진 보기'));
        expect(find.text('틔움 그림 보기'), findsOneWidget);
        await t.ensureVisible(find.byKey(const ValueKey('diary-body')));
        await t.pumpAndSettle();
        await t.enterText(
          find.byKey(const ValueKey('diary-body')),
          '테스트: 수정한 기억',
        );
        await t.pumpAndSettle();
        FocusManager.instance.primaryFocus?.unfocus();
        await t.pumpAndSettle();
        expect(
          t
              .widget<TextField>(find.byKey(const ValueKey('diary-body')))
              .controller!
              .text,
          '테스트: 수정한 기억',
        );
        expect(find.text('글 수정 저장'), findsOneWidget);
        await t.ensureVisible(find.byKey(const ValueKey('diary-save')));
        await t.pumpAndSettle();
        expect(
          t
              .widget<FilledButton>(find.byKey(const ValueKey('diary-save')))
              .onPressed,
          isNotNull,
        );
        await tap(find.byKey(const ValueKey('diary-save')));
        for (var i = 0; i < 50; i++) {
          if ((await db.select(db.photoDiaries).getSingle()).body ==
              '테스트: 수정한 기억') {
            break;
          }
          await t.pump(const Duration(milliseconds: 100));
        }
        expect(
          (await db.select(db.photoDiaries).getSingle()).jobId,
          completed.jobId,
        );
        expect(
          (await db.select(db.photoDiaries).getSingle()).body,
          '테스트: 수정한 기억',
        );
        expect(
          (await container.read(diariesProvider.future)).single.body,
          '테스트: 수정한 기억',
        );
        container.read(dopaRouterProvider).go('/diary');
        await t.pumpAndSettle();
        expect(find.text('남겨둔 순간들'), findsOneWidget);
        await t.scrollUntilVisible(
          find.text('테스트: 수정한 기억'),
          160,
          scrollable: find.byType(Scrollable).first,
        );
        expect(find.text('테스트: 수정한 기억'), findsOneWidget);
        if (const bool.fromEnvironment('DOPA_NATIVE_PICKER_TEST')) {
          await binding.convertFlutterSurfaceToImage();
          await t.pumpAndSettle();
          final bytes = await binding.takeScreenshot('diary-native-preview');
          final folder = await getApplicationSupportDirectory();
          await File('${folder.path}/diary-native-preview.png')
              .writeAsBytes(bytes);
        }
        container.read(dopaRouterProvider).push('/diary/entry/${completed.id}');
        await t.pumpAndSettle();
        await tap(find.byTooltip('일기 삭제'));
        await tap(find.text('삭제'));
        expect(await db.select(db.photoDiaries).get(), isEmpty);
        expect(await db.select(db.treeGrowthCredits).get(), isEmpty);
        container.read(dopaRouterProvider).go('/account');
        await t.pumpAndSettle();
        await tap(find.byKey(const ValueKey('account-delete')));
        await tap(find.byKey(const ValueKey('account-delete-confirm')));
        expect(await db.select(db.photoDiaryRemoteStates).get(), isEmpty);
        expect(find.byKey(const ValueKey('welcome-start')), findsOneWidget);
        expect(t.takeException(), isNull);
      } finally {
        t.testTextInput.unregister();
        await api.deleteSession();
        await t.pumpWidget(const SizedBox());
        await t.pump();
        container.dispose();
        await db.close();
      }
    },
  );
}
