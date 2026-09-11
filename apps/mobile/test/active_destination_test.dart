import 'dart:async';

import 'package:dopa/core/persistence/dopa_database_providers.dart';
import 'package:dopa/features/today/presentation/today_page.dart';
import 'package:dopa_domain/dopa_domain.dart';
import 'package:dopa_local_storage/dopa_local_storage.dart';
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test(
    'home observes most recently started unfinished activity across both kinds',
    () async {
      final db = DopaDatabase(NativeDatabase.memory());
      final c = ProviderContainer(
        overrides: [dopaDatabaseProvider.overrideWithValue(db)],
      );
      final events = StreamController<String?>();
      final sub = c.listen(activeDestinationProvider, (before, next) {
        if (next.hasValue) events.add(next.valueOrNull);
      });
      final queue = StreamIterator(events.stream);
      Future<void> expectNext(String? route) async {
        expect(
          await queue.moveNext().timeout(const Duration(seconds: 5)),
          true,
        );
        expect(queue.current, route);
      }

      try {
        await expectNext(null);
        final repo = DriftFocusTreeRepository(database: db);
        await repo.writeTransaction(
          (tx) => tx.saveSession(
            FocusSession(
              id: 'f',
              startedAtUtc: DateTime.utc(2026, 9, 11),
              startedLocalDate: LocalDate(2026, 9, 11),
              protectionMode: ProtectionMode.timerOnly,
              preset: SessionDurationPreset.tenMinutes,
            ),
          ),
        );
        await expectNext('/focus');
        final life = DriftCompanionRepository(database: db);
        await life.startOrResume(
          CompanionRun(
            id: 'c',
            contentId: deskCompanionContent.id,
            contentVersion: 1,
            startedAtUtc: DateTime.utc(2026, 9, 11, 0, 1),
            startedLocalDate: LocalDate(2026, 9, 11),
            stepCount: 4,
          ),
        );
        await expectNext('/companion');
      } finally {
        sub.close();
        c.dispose();
        await queue.cancel();
        await events.close();
        await db.close();
      }
    },
  );
}
