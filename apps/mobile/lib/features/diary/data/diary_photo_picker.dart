import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:image_picker/image_picker.dart';

import 'diary_api.dart';

abstract class DiaryPhotoPicker {
  Future<Uint8List?> pick();
  Future<Uint8List?> recover();
}

class NativeDiaryPhotoPicker implements DiaryPhotoPicker {
  final _picker = ImagePicker();
  @override
  Future<Uint8List?> pick() async {
    try {
      final file = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1536,
        maxHeight: 1536,
        requestFullMetadata: false,
      );
      return file == null
          ? null
          : await normalizePhoto(await file.readAsBytes());
    } on DiaryFailure {
      rethrow;
    } on Object {
      throw const DiaryFailure('photo_unavailable');
    }
  }

  @override
  Future<Uint8List?> recover() async {
    if (!Platform.isAndroid) return null;
    final data = await _picker.retrieveLostData();
    if (data.exception != null) throw const DiaryFailure('photo_unavailable');
    final files = data.files;
    return files == null || files.isEmpty
        ? null
        : normalizePhoto(await files.first.readAsBytes());
  }
}

/// Decode/encode in memory, applying the platform decoder's orientation and
/// dropping EXIF/GPS before a photo can enter any network request.
Future<Uint8List> normalizePhoto(Uint8List input) async {
  if (input.length > 30 * 1024 * 1024) throw const DiaryFailure('too_large');
  final buffer = await ui.ImmutableBuffer.fromUint8List(input);
  final descriptor = await ui.ImageDescriptor.encoded(buffer);
  try {
    if (descriptor.width * descriptor.height > 40_000_000) {
      throw const DiaryFailure('too_large');
    }
    final scale =
        1536 /
        (descriptor.width > descriptor.height
            ? descriptor.width
            : descriptor.height);
    final codec = await descriptor.instantiateCodec(
      targetWidth: scale < 1
          ? (descriptor.width * scale).round()
          : descriptor.width,
      targetHeight: scale < 1
          ? (descriptor.height * scale).round()
          : descriptor.height,
    );
    try {
      final frame = await codec.getNextFrame();
      try {
        final bytes = (await frame.image.toByteData(
          format: ui.ImageByteFormat.png,
        ))!.buffer.asUint8List();
        if (bytes.length > 10 * 1024 * 1024) {
          throw const DiaryFailure('too_large');
        }
        return bytes;
      } finally {
        frame.image.dispose();
      }
    } finally {
      codec.dispose();
    }
  } finally {
    descriptor.dispose();
    buffer.dispose();
  }
}
