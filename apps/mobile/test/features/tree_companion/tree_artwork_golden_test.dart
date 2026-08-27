import 'package:dopa/features/tree_companion/application/tree_season.dart';
import 'package:dopa/features/tree_companion/presentation/tree_artwork.dart';
import 'package:dopa/features/tree_companion/presentation/tree_renderer.dart';
import 'package:dopa_domain/dopa_domain.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/tolerant_golden_comparator.dart';
import '../../test_app.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    final current = goldenFileComparator;
    if (current is LocalFileComparator) {
      goldenFileComparator = TolerantGoldenComparator(
        current.basedir.resolve('tree_artwork_golden_test.dart'),
      );
    }
  });

  const policy = TreeGrowthPolicy();
  const stages = <(TreeGrowthStage, int)>[
    (TreeGrowthStage.seed, 0),
    (TreeGrowthStage.sprout, 1),
    (TreeGrowthStage.sapling, 3),
    (TreeGrowthStage.smallTree, 7),
    (TreeGrowthStage.youngZelkova, 14),
    (TreeGrowthStage.spreadingBranches, 30),
    (TreeGrowthStage.broadCanopy, 60),
    (TreeGrowthStage.mature, 90),
  ];

  for (final brightness in Brightness.values) {
    for (final stage in stages) {
      testWidgets(
        '${stage.$1.name} ${brightness.name} matches the static golden',
        (tester) async {
          await _pumpTree(
            tester,
            progress: policy.progressFor(stage.$2),
            brightness: brightness,
          );
          await expectLater(
            find.byType(TreeArtwork),
            matchesGoldenFile(
              'goldens/tree_${brightness.name}_${stage.$1.name}.png',
            ),
          );
        },
      );
    }
  }

  for (final season in TreeSeason.values) {
    testWidgets('${season.name} environment layer matches golden', (
      tester,
    ) async {
      await _pumpTree(
        tester,
        progress: policy.progressFor(7),
        brightness: Brightness.light,
        season: season,
      );
      await expectLater(
        find.byType(TreeArtwork),
        matchesGoldenFile('goldens/tree_light_smallTree_${season.name}.png'),
      );
    });
  }

  testWidgets('reduce motion reveal matches the static milestone frame', (
    tester,
  ) async {
    await _pumpTree(
      tester,
      progress: policy.progressFor(7),
      brightness: Brightness.light,
      animationCue: TreeAnimationCue.reveal,
      reduceMotion: true,
    );
    await expectLater(
      find.byType(TreeArtwork),
      matchesGoldenFile('goldens/tree_light_smallTree.png'),
    );
  });
}

Future<void> _pumpTree(
  WidgetTester tester, {
  required TreeProgress progress,
  required Brightness brightness,
  TreeSeason season = TreeSeason.summer,
  TreeAnimationCue animationCue = TreeAnimationCue.none,
  bool reduceMotion = true,
}) async {
  tester.view.physicalSize = const Size(240, 320);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  await tester.pumpWidget(
    ProviderScope(
      child: TestApp(
        brightness: brightness,
        disableAnimations: true,
        home: Scaffold(
          body: SizedBox(
            width: 240,
            height: 320,
            child: TreeArtwork(
              progress: progress,
              season: season,
              animationCue: animationCue,
              reduceMotion: reduceMotion,
            ),
          ),
        ),
      ),
    ),
  );

  final context = tester.element(find.byType(TreeArtwork));
  await tester.runAsync(() async {
    await precacheImage(
      const AssetImage(TreeStaticAssetContract.lightSprite),
      context,
    );
    await precacheImage(
      const AssetImage(TreeStaticAssetContract.darkSprite),
      context,
    );
  });
  await tester.pump();
}
