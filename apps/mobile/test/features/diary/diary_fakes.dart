import 'dart:io';
import 'dart:typed_data';

import 'package:dopa/features/diary/data/diary_api.dart';
import 'package:dopa/features/diary/data/diary_photo_picker.dart';

Uint8List samplePhoto() => File('assets/garden/light_0.webp').readAsBytesSync();

class FakeDiaryPicker implements DiaryPhotoPicker {
  Uint8List? result = samplePhoto();
  @override
  Future<Uint8List?> pick() async => result;
  @override
  Future<Uint8List?> recover() async => null;
}

class FakeDiaryApi implements DiaryApi {
  String? submitError, statusError, imageError;
  bool failAcknowledgement = false;
  Future<void> Function()? beforeConsent;
  int requests = 0, consents = 0, acknowledgements = 0, deletions = 0;
  bool online = true, timeoutAfterSubmit = false, sessionDeleted = false;
  final jobs = <String, String>{};
  @override
  bool get configured => true;
  @override
  Future<bool> available() async => online;
  @override
  Future<void> consent() async {
    consents++;
    await beforeConsent?.call();
  }

  @override
  Future<String> submit(String id, Uint8List photo) async {
    if (submitError != null) throw DiaryFailure(submitError!);
    jobs.putIfAbsent(id, () {
      requests++;
      return 'queued';
    });
    if (timeoutAfterSubmit) throw const DiaryFailure('network');
    return jobs[id]!;
  }

  @override
  Future<String> status(String id) async {
    if (statusError != null) throw DiaryFailure(statusError!);
    return jobs[id] ?? (throw const DiaryFailure('not_found'));
  }

  @override
  Future<Uint8List> image(String id) async {
    if (imageError != null) throw DiaryFailure(imageError!);
    return samplePhoto();
  }

  @override
  Future<void> acknowledge(String id) async {
    acknowledgements++;
    if (failAcknowledgement) throw const DiaryFailure('network');
  }

  @override
  Future<void> delete(String id) async {
    if (!online) throw const DiaryFailure('network');
    deletions++;
    jobs.remove(id);
  }

  @override
  Future<void> deleteSession() async {
    sessionDeleted = true;
    jobs.clear();
  }
}
