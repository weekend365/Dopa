import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:video_player/video_player.dart';

/// A release manifest is deliberately absent until the actual footage is reviewed.
final companionMediaProvider = FutureProvider<CompanionMedia?>(
  (ref) => CompanionMedia.load(rootBundle),
);

class CompanionMedia {
  const CompanionMedia({
    required this.video,
    required this.poster,
    required this.captions,
    required this.durationMs,
    required this.stepStarts,
  });
  final String video;
  final String poster;
  final String captions;
  final int durationMs;
  final List<int> stepStarts;

  String captionAt(int positionMs) {
    for (final caption in WebVTTCaptionFile(captions).captions) {
      if (positionMs >= caption.start.inMilliseconds &&
          positionMs < caption.end.inMilliseconds) {
        return caption.text;
      }
    }
    return '';
  }

  int stepAt(int position) => stepStarts
      .lastIndexWhere((start) => position >= start)
      .clamp(0, stepStarts.length - 1);

  static Future<CompanionMedia?> load(AssetBundle bundle) async {
    final json = jsonDecode(
      await bundle.loadString('assets/companion/desk_v2.json'),
    ) as Map<String, dynamic>;
    if (json['ready'] != true) return null;
    if (json['contentId'] != 'desk_space' ||
        json['version'] != 2 ||
        json['rightsConfirmed'] != true ||
        (json['evidenceReference'] as String? ?? '').isEmpty) {
      throw const FormatException('Media is not cleared.');
    }
    final duration = json['durationMs'] as int;
    final starts = (json['stepStartsMs'] as List).cast<int>();
    if (duration <= 0 ||
        starts.length != 4 ||
        starts.first != 0 ||
        starts.last >= duration) {
      throw const FormatException('Invalid timeline.');
    }
    for (var i = 1; i < starts.length; i++) {
      if (starts[i] <= starts[i - 1]) {
        throw const FormatException('Unordered timeline.');
      }
    }
    var total = 0;
    final paths = <String, String>{};
    for (final key in ['video', 'poster', 'captions']) {
      final entry = json[key] as Map<String, dynamic>;
      final path = entry['path'] as String;
      if ((key == 'video' && !path.endsWith('.mp4')) ||
          (key == 'captions' && !path.endsWith('.vtt')) ||
          (key == 'poster' &&
              !path.endsWith('.jpg') &&
              !path.endsWith('.png'))) {
        throw const FormatException('Incorrect asset type.');
      }
      if (!RegExp(r'^assets/companion/[a-zA-Z0-9_\-]+\.(mp4|jpg|png|vtt)$')
          .hasMatch(path)) {
        throw const FormatException('Invalid asset path.');
      }
      final bytes = await bundle.load(path);
      total += bytes.lengthInBytes;
      if (sha256
              .convert(
                bytes.buffer.asUint8List(
                  bytes.offsetInBytes,
                  bytes.lengthInBytes,
                ),
              )
              .toString() !=
          entry['sha256']) {
        throw const FormatException('Asset checksum mismatch.');
      }
      paths[key] = path;
    }
    if (total > 30000000) {
      throw const FormatException('Media exceeds 30 MB.');
    }
    final captions = await bundle.loadString(paths['captions']!);
    final cues = WebVTTCaptionFile(captions).captions;
    if (!captions.startsWith('WEBVTT') || cues.isEmpty) {
      throw const FormatException('Missing captions.');
    }
    var lastEnd = 0;
    for (final cue in cues) {
      if (cue.start.inMilliseconds < lastEnd ||
          cue.end <= cue.start ||
          cue.end.inMilliseconds > duration ||
          cue.text.trim().isEmpty) {
        throw const FormatException('Invalid caption timeline.');
      }
      lastEnd = cue.end.inMilliseconds;
    }
    return CompanionMedia(
      video: paths['video']!,
      poster: paths['poster']!,
      captions: captions,
      durationMs: duration,
      stepStarts: List.unmodifiable(starts),
    );
  }
}
