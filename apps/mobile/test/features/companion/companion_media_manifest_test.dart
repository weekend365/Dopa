import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:dopa/features/companion/application/companion_media.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

class MemoryBundle extends CachingAssetBundle {
  final files = <String, Uint8List>{};
  Map<String, Object?> manifest = {};
  @override
  Future<ByteData> load(String key) async {
    final bytes = key.endsWith('.json')
        ? Uint8List.fromList(utf8.encode(jsonEncode(manifest)))
        : files[key]!;
    return ByteData.sublistView(bytes);
  }

  void asset(String key, String path, String contents) {
    files[path] = Uint8List.fromList(utf8.encode(contents));
    manifest[key] = {
      'path': path,
      'sha256': sha256.convert(files[path]!).toString(),
    };
  }
}

void main() {
  MemoryBundle bundle() => MemoryBundle()
    ..manifest = {
      'ready': true,
      'rightsConfirmed': true,
      'evidenceReference': 'private-review-001',
      'contentId': 'desk_space',
      'version': 2,
      'durationMs': 120000,
      'stepStartsMs': [0, 30000, 60000, 90000],
    }
    ..asset(
      'video',
      'assets/companion/test.mp4',
      'test double, not produced media',
    )
    ..asset('poster', 'assets/companion/test.jpg', 'test poster')
    ..asset(
      'captions',
      'assets/companion/test.vtt',
      'WEBVTT\n\n00:00:01.000 --> 00:00:03.000\n한국어 안내\n\n00:00:30.000 --> 00:00:32.000\n종이를 모아요\n',
    );
  test(
    'unready content remains unavailable, even without any media assets',
    () async {
      expect(
        await CompanionMedia.load(MemoryBundle()..manifest = {'ready': false}),
        isNull,
      );
    },
  );
  test('verified bundle synchronizes stages and captions with silence and backwards seek', () async {
    final media = (await CompanionMedia.load(bundle()))!;
    expect(media.captionAt(1000), '한국어 안내');
    expect(media.captionAt(3000), '');
    expect(media.captionAt(31000), '종이를 모아요');
    expect(media.captionAt(1200), '한국어 안내');
    expect(media.stepAt(29999), 0);
    expect(media.stepAt(30000), 1);
  });
  test(
    'missing rights, changed bytes and unordered timestamps fail closed',
    () async {
      final unlicensed = bundle()..manifest['rightsConfirmed'] = false;
      await expectLater(CompanionMedia.load(unlicensed), throwsFormatException);
      final corrupt = bundle();
      corrupt.files['assets/companion/test.mp4'] = Uint8List.fromList([0]);
      await expectLater(CompanionMedia.load(corrupt), throwsFormatException);
      final unordered = bundle()
        ..manifest['stepStartsMs'] = [0, 60000, 30000, 90000];
      await expectLater(CompanionMedia.load(unordered), throwsFormatException);
    },
  );
  test('overlapping or absent captions fail the release gate', () async {
    final missing = bundle()
      ..asset('captions', 'assets/companion/test.vtt', 'WEBVTT\n');
    await expectLater(CompanionMedia.load(missing), throwsFormatException);
    final overlap = bundle()
      ..asset(
        'captions',
        'assets/companion/test.vtt',
        'WEBVTT\n\n00:00:01.000 --> 00:00:03.000\n첫 대사\n\n00:00:02.000 --> 00:00:04.000\n겹침\n',
      );
    await expectLater(CompanionMedia.load(overlap), throwsFormatException);
  });
}
