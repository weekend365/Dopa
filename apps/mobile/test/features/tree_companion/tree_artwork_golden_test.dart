import 'package:dopa/features/tree_companion/presentation/garden_artwork.dart';
import 'package:dopa_domain/dopa_domain.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../test_app.dart';

void main() {
  for (final brightness in Brightness.values) {
    for (var stage = 0; stage < 8; stage++) {
      testWidgets('garden ${brightness.name} stage $stage', (tester) async {
        tester.view.physicalSize = const Size(360, 240);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        await tester.pumpWidget(
          TestApp(
            brightness: brightness,
            disableAnimations: true,
            home: Scaffold(
              body: SizedBox(
                width: 360,
                height: 240,
                child: GardenArtwork(
                  progress: const TreeGrowthPolicy().progressFor(
                    [0, 1, 3, 7, 14, 30, 60, 90][stage],
                  ),
                ),
              ),
            ),
          ),
        );
        await tester.runAsync(() async {
          await precacheImage(
            AssetImage('assets/garden/${brightness.name}_$stage.webp'),
            tester.element(find.byType(GardenArtwork)),
          );
        });
        await tester.pumpAndSettle();
        await expectLater(
          find.byType(GardenArtwork),
          matchesGoldenFile('goldens/garden_${brightness.name}_$stage.png'),
        );
      });
    }
  }
}
