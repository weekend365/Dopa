import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  testWidgets(
    '16 independent WebP landscapes are 1152x768 and below 6MiB combined',
    (tester) async {
      await tester.runAsync(() async {
        var total = 0;
        for (final theme in ['light', 'dark']) {
          for (var stage = 0; stage < 8; stage++) {
            final file = File('assets/garden/${theme}_$stage.webp');
            final bytes = await file.readAsBytes();
            total += bytes.length;
            expect(String.fromCharCodes(bytes.sublist(0, 4)), 'RIFF');
            expect(String.fromCharCodes(bytes.sublist(8, 12)), 'WEBP');
            final codec = await ui.instantiateImageCodec(bytes);
            final frame = await codec.getNextFrame();
            expect(frame.image.width, 1152);
            expect(frame.image.height, 768);
            frame.image.dispose();
            codec.dispose();
          }
        }
        expect(total, lessThanOrEqualTo(6 * 1024 * 1024));
        expect(
          Directory('assets/garden')
              .listSync()
              .where((f) => f.path.endsWith('.webp')),
          hasLength(16),
        );
      });
    },
  );
}
