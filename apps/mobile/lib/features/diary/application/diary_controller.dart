import 'dart:math';
import 'dart:typed_data';

import 'package:dopa/core/app_environment.dart';
import 'package:dopa/core/persistence/dopa_database_providers.dart';
import 'package:dopa_local_storage/dopa_local_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/diary_api.dart';
import '../data/diary_photo_picker.dart';

final diaryNowProvider = Provider<DateTime Function()>((ref) => DateTime.now);
final diaryRepositoryProvider = Provider(
  (ref) => DriftDiaryRepository(ref.watch(dopaDatabaseProvider)),
);
final diariesProvider = StreamProvider.autoDispose(
  (ref) => ref.watch(diaryRepositoryProvider).watchAll(),
);
final diaryPreviewProvider = FutureProvider.autoDispose
    .family<Uint8List?, String>((ref, id) async {
      ref.watch(diariesProvider);
      final entry = await ref.watch(diaryRepositoryProvider).read(id);
      return entry?.artwork ?? entry?.original;
    });
final diaryPickerProvider = Provider<DiaryPhotoPicker>(
  (ref) => NativeDiaryPhotoPicker(),
);
final diaryApiProvider = Provider<DiaryApi>((ref) {
  const url = String.fromEnvironment(
    'DOPA_DIARY_API_URL',
    defaultValue: AppEnvironment.isProduction ? '' : 'http://127.0.0.1:8787',
  );
  final uri = Uri.tryParse(url);
  final safe =
      uri != null &&
      (uri.scheme == 'https' ||
          (!AppEnvironment.isProduction &&
              uri.scheme == 'http' &&
              uri.host == '127.0.0.1'));
  return HttpDiaryApi(safe ? url.replaceFirst(RegExp(r'/$'), '') : '');
});
final diaryControllerProvider = Provider(
  (ref) => DiaryController(
    ref.watch(diaryRepositoryProvider),
    ref.watch(diaryApiProvider),
    ref.watch(diaryPickerProvider),
    ref.watch(diaryNowProvider),
  ),
);

String diaryDay(DateTime now) =>
    '${now.year.toString().padLeft(4, '0')}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
String diaryId() {
  final random = Random.secure();
  return List.generate(
    16,
    (_) => random.nextInt(256).toRadixString(16).padLeft(2, '0'),
  ).join();
}

class DiaryController {
  DiaryController(this.repository, this.api, this.picker, this.now);
  final DriftDiaryRepository repository;
  final DiaryApi api;
  final DiaryPhotoPicker picker;
  final DateTime Function() now;
  final Set<String> _refreshing = {};
  final Set<String> _converting = {};
  final Set<String> _acknowledged = {};

  Future<String> save({
    String? id,
    required Uint8List photo,
    required String body,
    required String day,
  }) async {
    if (body.runes.length > 2000) throw const DiaryFailure('body_too_long');
    if (id != null) {
      await repository.edit(id, body);
      return id;
    }
    final existing = await repository.forDay(day);
    if (existing != null) throw const DiaryFailure('day_exists');
    final newId = diaryId();
    await repository.create(
      id: newId,
      day: day,
      photo: photo,
      body: body,
      now: now(),
    );
    return newId;
  }

  Future<void> convert(String id) async {
    if (!_converting.add(id)) return;
    try {
      await _convert(id);
    } finally {
      _converting.remove(id);
    }
  }

  Future<void> _convert(String id) async {
    var entry = await repository.read(id);
    if (entry == null) return;
    if (entry.status == 'succeeded' || entry.status == 'uncertain') return;
    if (entry.jobId != null && !['failed', 'expired'].contains(entry.status)) {
      await refresh(id);
      return;
    }
    // Persist the request identity before any network call, including registration.
    final job = diaryId();
    await repository.setJob(id, job, 'submitting');
    await repository.markRemoteUse();
    try {
      await api.consent();
      if (await repository.read(id) == null) return;
      final status = await api.submit(job, entry.original);
      await repository.updateJob(id, job, status);
    } on DiaryFailure catch (e) {
      // Unknown delivery keeps the SAME job ID. Retry first queries, then PUTs it.
      if (e.code != 'network') await repository.updateJob(id, job, 'failed');
      rethrow;
    }
  }

  Future<void> refresh(String id) async {
    if (!_refreshing.add(id)) return;
    try {
      final entry = await repository.read(id);
      if (entry == null || entry.jobId == null) return;
      final job = entry.jobId!;
      if (entry.status == 'succeeded' && entry.artwork != null) {
        if (_acknowledged.add(job)) {
          try {
            await api.acknowledge(job);
          } on Object {
            _acknowledged.remove(job);
            rethrow;
          }
        }
        return;
      }
      if (!['submitting', 'queued', 'processing'].contains(entry.status)) {
        return;
      }
      String status;
      try {
        status = await api.status(job);
      } on DiaryFailure catch (e) {
        if (e.code == 'not_found' && entry.status == 'submitting') {
          await api.consent();
          status = await api.submit(job, entry.original);
        } else if (e.code == 'not_found' || e.code == 'unauthorized') {
          await repository.updateJob(id, job, 'expired');
          return;
        } else {
          rethrow;
        }
      }
      if (status == 'succeeded') {
        try {
          final art = await api.image(job);
          await repository.updateJob(id, job, status, artwork: art);
          await api.acknowledge(job);
          _acknowledged.add(job);
        } on DiaryFailure catch (e) {
          if (e.code == 'result_expired') {
            await repository.updateJob(id, job, 'expired');
          } else {
            rethrow;
          }
        }
      } else {
        await repository.updateJob(
          id,
          job,
          [
                'queued',
                'processing',
                'failed',
                'uncertain',
                'expired',
              ].contains(status)
              ? status
              : 'expired',
        );
      }
    } finally {
      _refreshing.remove(id);
    }
  }

  Future<void> delete(String id) async {
    final entry = await repository.read(id);
    if (entry?.jobId != null) {
      try {
        await api.delete(entry!.jobId!);
      } on DiaryFailure catch (e) {
        if (!['unauthorized', 'not_found'].contains(e.code)) rethrow;
      }
    }
    await repository.delete(id);
  }
}

String diaryError(Object error) => switch (error) {
  DiaryFailure(code: 'daily_limit') => '오늘의 그림은 이미 남겼어요. 글은 계속 수정할 수 있어요.',
  DiaryFailure(code: 'day_exists') => '이 날짜의 일기가 이미 있어요. 기록함에서 열어 주세요.',
  DiaryFailure(code: 'not_configured') =>
    '그림 변환을 준비 중이에요. 사진 일기는 그대로 남길 수 있어요.',
  DiaryFailure(code: 'photo_unavailable') =>
    '사진을 열지 못했어요. 사진 접근 설정을 확인하거나 다른 사진을 골라 주세요.',
  DiaryFailure(code: 'too_large') => '사진 크기가 너무 커요. 더 작은 사진을 골라 주세요.',
  DiaryFailure(code: 'retry_limit' || 'service_limit') =>
    '오늘은 그림 변환을 잠시 쉬고 있어요. 일기는 안전하게 저장되어 있어요.',
  _ => '연결을 확인한 뒤 다시 시도해 주세요. 저장한 일기는 그대로 있어요.',
};
