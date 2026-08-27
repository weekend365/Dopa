import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';

/// Allows tiny Skia/OS raster differences so goldens can run on macOS and CI.
final class TolerantGoldenComparator extends LocalFileComparator {
  TolerantGoldenComparator(super.testFile, {this.maxDiffPercent = 0.015});

  final double maxDiffPercent;

  @override
  Future<bool> compare(Uint8List imageBytes, Uri golden) async {
    final result = await GoldenFileComparator.compareLists(
      imageBytes,
      await getGoldenBytes(golden),
    );
    if (result.passed || result.diffPercent <= maxDiffPercent) {
      return true;
    }
    final error = await generateFailureOutput(result, golden, basedir);
    throw FlutterError(error);
  }
}
