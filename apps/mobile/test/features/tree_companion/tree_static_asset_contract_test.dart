import 'package:dopa/features/tree_companion/presentation/tree_renderer.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const expectedWidth = 1536;
  const expectedHeight = 1024;
  const maxCombinedBytes = 6 * 1024 * 1024;
  const pngSignature = <int>[137, 80, 78, 71, 13, 10, 26, 10];

  test('sprite sheets are opaque 1536x1024 RGB and stay under 6MiB', () async {
    var combinedBytes = 0;
    for (final asset in [
      TreeStaticAssetContract.lightSprite,
      TreeStaticAssetContract.darkSprite,
    ]) {
      final data = await rootBundle.load(asset);
      final bytes = data.buffer.asUint8List();
      combinedBytes += bytes.length;
      expect(bytes.length, greaterThanOrEqualTo(26));
      expect(bytes.sublist(0, 8), pngSignature);
      expect(_readBigEndian(bytes, 16), expectedWidth);
      expect(_readBigEndian(bytes, 20), expectedHeight);
      expect(
        bytes[25],
        2,
        reason: '$asset must be PNG color type 2 (opaque RGB)',
      );
    }
    expect(combinedBytes, lessThanOrEqualTo(maxCombinedBytes));
  });
}

int _readBigEndian(Uint8List bytes, int offset) =>
    (bytes[offset] << 24) |
    (bytes[offset + 1] << 16) |
    (bytes[offset + 2] << 8) |
    bytes[offset + 3];
