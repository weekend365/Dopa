import 'package:dopa/core/persistence/dopa_database_providers.dart';
import 'package:dopa/features/diary/application/diary_controller.dart';
import 'package:dopa/features/diary/presentation/diary_page.dart';
import 'package:dopa/features/diary/presentation/diary_library_page.dart';
import 'package:dopa_local_storage/dopa_local_storage.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../test_app.dart';
import 'diary_fakes.dart';

void main() {
  testWidgets(
    'personal library loads summaries and visible photos at large text',
    (t) async {
      await t.pumpWidget(
        ProviderScope(
          overrides: [
            diariesProvider.overrideWith(
              (ref) => Stream.value(const [
                DiarySummary(
                  'a',
                  '2026-09-11',
                  '창가에서 잠깐 쉬었어요.',
                  'local',
                  false,
                ),
              ]),
            ),
            diaryPreviewProvider('a')
                .overrideWith((ref) async => samplePhoto()),
          ],
          child: const TestApp(
            textScale: 2,
            brightness: Brightness.dark,
            home: DiaryLibraryPage(),
          ),
        ),
      );
      await t.pumpAndSettle();
      await t.scrollUntilVisible(
        find.text('창가에서 잠깐 쉬었어요.'),
        150,
        scrollable: find.byType(Scrollable).first,
      );
      await t.pumpAndSettle();
      expect(find.text('2026-09-11'), findsOneWidget);
      expect(find.byType(Image), findsOneWidget);
      expect(t.takeException(), isNull);
      await t.pumpWidget(const SizedBox());
      await t.pump();
    },
  );
  for (final width in [320.0, 390.0, 430.0]) {
    for (final brightness in Brightness.values) {
      for (final scale in [1.0, 2.0]) {
        testWidgets(
          'diary $width $brightness $scale photo and optional text save offline',
          (t) async {
            t.view.physicalSize = Size(width, 844);
            t.view.devicePixelRatio = 1;
            addTearDown(t.view.resetPhysicalSize);
            addTearDown(t.view.resetDevicePixelRatio);
            final db = DopaDatabase(NativeDatabase.memory());
            final api = FakeDiaryApi()..online = false;
            await t.pumpWidget(
              ProviderScope(
                overrides: [
                  dopaDatabaseProvider.overrideWithValue(db),
                  diaryApiProvider.overrideWithValue(api),
                  diaryPickerProvider.overrideWithValue(FakeDiaryPicker()),
                  diaryNowProvider.overrideWithValue(
                    () => DateTime(2026, 9, 11),
                  ),
                ],
                child: TestApp(
                  brightness: brightness,
                  textScale: scale,
                  home: const DiaryPage(),
                ),
              ),
            );
            await t.pumpAndSettle();
            await t.scrollUntilVisible(
              find.byKey(const ValueKey('diary-pick')),
              150,
              scrollable: find.byType(Scrollable).first,
            );
            await t.pumpAndSettle();
            await t.tap(find.byKey(const ValueKey('diary-pick')));
            await t.pumpAndSettle();
            await t.ensureVisible(find.byKey(const ValueKey('diary-body')));
            await t.pumpAndSettle();
            await t.enterText(
              find.byKey(const ValueKey('diary-body')),
              '오늘 창가의 햇빛이 따뜻했어요.',
            );
            await t.ensureVisible(find.byKey(const ValueKey('diary-save')));
            await t.pumpAndSettle();
            await t.tap(find.byKey(const ValueKey('diary-save')));
            await t.pumpAndSettle();
            expect(
              (await db.select(db.photoDiaries).getSingle()).body,
              '오늘 창가의 햇빛이 따뜻했어요.',
            );
            expect(api.requests, 0);
            expect(api.consents, 0);
            expect(t.takeException(), isNull);
            await t.pumpWidget(const SizedBox());
            await t.pump();
            await db.close();
          },
        );
      }
    }
  }
  testWidgets(
    'conversion sends nothing before explicit photo consent and preserves original',
    (t) async {
      final db = DopaDatabase(NativeDatabase.memory());
      final api = FakeDiaryApi();
      await t.pumpWidget(
        ProviderScope(
          overrides: [
            dopaDatabaseProvider.overrideWithValue(db),
            diaryApiProvider.overrideWithValue(api),
            diaryPickerProvider.overrideWithValue(FakeDiaryPicker()),
          ],
          child: const TestApp(home: DiaryPage()),
        ),
      );
      await t.pumpAndSettle();
      Future<void> tap(String key) async {
        final target = find.byKey(ValueKey(key));
        if (target.evaluate().isEmpty) {
          await t.scrollUntilVisible(
            target,
            150,
            scrollable: find.byType(Scrollable).first,
          );
        }
        await t.ensureVisible(target);
        await t.pumpAndSettle();
        await t.tap(target);
        await t.pumpAndSettle();
      }

      await tap('diary-pick');
      await tap('diary-save');
      await tap('diary-convert');
      expect(api.requests, 0);
      expect(api.consents, 0);
      await tap('diary-consent');
      expect(api.requests, 1);
      final entry = await db.select(db.photoDiaries).getSingle();
      api.jobs[entry.jobId!] = 'succeeded';
      await t.pump(const Duration(seconds: 5));
      await t.pumpAndSettle();
      expect((await db.select(db.photoDiaries).getSingle()).artwork, isNotNull);
      expect(find.text('원본 사진 보기'), findsOneWidget);
      expect(t.takeException(), isNull);
      await t.pumpWidget(const SizedBox());
      await t.pump();
      await db.close();
    },
  );
}
