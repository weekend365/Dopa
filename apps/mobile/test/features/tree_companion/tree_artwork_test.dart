import 'package:dopa/features/tree_companion/presentation/garden_artwork.dart';
import 'package:dopa_domain/dopa_domain.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../test_app.dart';

void main() {
  testWidgets('garden has one image description and no recurring motion', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();
    await tester.pumpWidget(
      TestApp(
        disableAnimations: true,
        home: Scaffold(
          body: SizedBox(
            height: 220,
            child: GardenArtwork(
              progress: const TreeGrowthPolicy().progressFor(14),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.bySemanticsLabel('가지가 뻗는 정원'), findsOneWidget);
    expect(tester.getSemantics(find.byType(GardenArtwork)).childrenCount, 0);
    expect(tester.hasRunningAnimations, false);
    semantics.dispose();
  });
  testWidgets('missing artwork gives a quiet plant fallback', (tester) async {
    await tester.pumpWidget(
      const TestApp(
        home: Scaffold(
          body: SizedBox(
            height: 220,
            child: GardenArtwork(assetOverride: 'missing.webp'),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.byIcon(Icons.spa_outlined), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
  test('all legacy thresholds map to garden stages without rewriting data', () {
    const days = [0, 1, 3, 7, 14, 30, 60, 90];
    for (var i = 0; i < days.length; i++) {
      expect(
        GardenProgress(const TreeGrowthPolicy().progressFor(days[i])).stage,
        i,
      );
    }
    expect(GardenProgress(const TreeGrowthPolicy().progressFor(200)).stage, 7);
  });
}
