import 'dart:async';

import 'package:dopa/features/diary/application/diary_controller.dart';
import 'package:dopa/features/diary/data/diary_api.dart';
import 'package:dopa_local_storage/dopa_local_storage.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'diary_fakes.dart';

void main() {
  late DopaDatabase db;
  late DriftDiaryRepository repo;
  late FakeDiaryApi api;
  late DiaryController controller;
  setUp(() {
    db = DopaDatabase(NativeDatabase.memory());
    repo = DriftDiaryRepository(db);
    api = FakeDiaryApi();
    controller = DiaryController(
      repo,
      api,
      FakeDiaryPicker(),
      () => DateTime(2026, 9, 12),
    );
  });
  tearDown(() => db.close());
  Future<String> save() =>
      controller.save(photo: samplePhoto(), body: '나만 보는 글', day: '2026-09-11');
  test('offline save uses captured day, never registers or uploads', () async {
    api.online = false;
    final id = await save();
    expect((await repo.read(id))!.localDate, '2026-09-11');
    expect(api.requests, 0);
    expect(api.consents, 0);
    expect(await repo.hasRemoteUse(), false);
    await expectLater(save(), throwsA(isA<DiaryFailure>()));
  });
  test(
    'delete while consent is in flight does not upload a deleted photo',
    () async {
      final id = await save();
      final entered = Completer<void>(), proceed = Completer<void>();
      api.beforeConsent = () {
        entered.complete();
        return proceed.future;
      };
      final conversion = controller.convert(id);
      await entered.future;
      await repo.delete(id);
      proceed.complete();
      await conversion;
      expect(api.requests, 0);
      expect(await repo.read(id), isNull);
    },
  );
  test('confirmed rejection preserves original and marks failure', () async {
    final id = await save();
    api.submitError = 'daily_limit';
    await expectLater(controller.convert(id), throwsA(isA<DiaryFailure>()));
    expect((await repo.read(id))!.status, 'failed');
    expect((await repo.read(id))!.original, samplePhoto());
  });
  test(
    'unreceived submission reuses its ID and expired result keeps original',
    () async {
      final id = await save();
      api.timeoutAfterSubmit = true;
      await expectLater(controller.convert(id), throwsA(isA<DiaryFailure>()));
      final job = (await repo.read(id))!.jobId!;
      api.jobs.clear();
      api.timeoutAfterSubmit = false;
      await controller.refresh(id);
      expect((await repo.read(id))!.jobId, job);
      api.jobs[job] = 'succeeded';
      api.imageError = 'result_expired';
      await controller.refresh(id);
      expect((await repo.read(id))!.status, 'expired');
      expect((await repo.read(id))!.original, samplePhoto());
    },
  );
  test('revoked session recovers to original', () async {
    final id = await save();
    await controller.convert(id);
    api.statusError = 'unauthorized';
    await controller.refresh(id);
    expect((await repo.read(id))!.status, 'expired');
    expect((await repo.read(id))!.artwork, isNull);
  });
  test('acknowledgement failure keeps downloaded art and can retry', () async {
    final id = await save();
    await controller.convert(id);
    final job = (await repo.read(id))!.jobId!;
    api.jobs[job] = 'succeeded';
    api.failAcknowledgement = true;
    await expectLater(controller.refresh(id), throwsA(isA<DiaryFailure>()));
    expect((await repo.read(id))!.artwork, isNotNull);
    await expectLater(controller.refresh(id), throwsA(isA<DiaryFailure>()));
    api.failAcknowledgement = false;
    await controller.refresh(id);
    await controller.refresh(id);
    expect(api.acknowledgements, 3);
    expect(api.requests, 1);
  });
  test(
    'response loss and restart recover same job without duplicate generation',
    () async {
      final id = await save();
      api.timeoutAfterSubmit = true;
      await expectLater(controller.convert(id), throwsA(isA<DiaryFailure>()));
      final job = (await repo.read(id))!.jobId!;
      api.jobs[job] = 'succeeded';
      final restored = DiaryController(
        repo,
        api,
        FakeDiaryPicker(),
        DateTime.now,
      );
      await restored.refresh(id);
      final entry = (await repo.read(id))!;
      expect(entry.artwork, isNotNull);
      expect(entry.original, samplePhoto());
      expect(entry.body, '나만 보는 글');
      expect(api.requests, 1);
      expect(api.acknowledgements, 1);
      await restored.refresh(id);
      expect(api.acknowledgements, 1);
    },
  );
  test(
    'concurrent taps generate once and text edit never regenerates',
    () async {
      final id = await save();
      await Future.wait([controller.convert(id), controller.convert(id)]);
      expect(api.requests, 1);
      await controller.save(
        id: id,
        photo: samplePhoto(),
        body: '수정',
        day: '2026-09-12',
      );
      expect(api.requests, 1);
      expect((await repo.read(id))!.localDate, '2026-09-11');
    },
  );
  test(
    'remote deletion failure retains local diary and retry completes deletion',
    () async {
      final id = await save();
      await controller.convert(id);
      api.online = false;
      await expectLater(controller.delete(id), throwsA(isA<DiaryFailure>()));
      expect(await repo.read(id), isNotNull);
      api.online = true;
      await controller.delete(id);
      expect(await repo.read(id), isNull);
      expect(api.deletions, 1);
    },
  );
  test(
    'uncertain results cannot be regenerated; confirmed failures can retry',
    () async {
      final id = await save();
      await controller.convert(id);
      final job = (await repo.read(id))!.jobId!;
      api.jobs[job] = 'failed';
      await controller.refresh(id);
      await controller.convert(id);
      expect(api.requests, 2);
      final retry = (await repo.read(id))!.jobId!;
      api.jobs[retry] = 'uncertain';
      await controller.refresh(id);
      await controller.convert(id);
      expect(api.requests, 2);
      expect((await repo.read(id))!.original, samplePhoto());
    },
  );
}
