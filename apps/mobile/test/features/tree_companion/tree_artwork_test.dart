import 'dart:async';

import 'package:dopa/app/theme/dopa_tokens.dart';
import 'package:dopa/features/tree_companion/application/tree_season.dart';
import 'package:dopa/features/tree_companion/application/tree_feature_flags.dart';
import 'package:dopa/features/tree_companion/presentation/tree_artwork.dart';
import 'package:dopa/features/tree_companion/presentation/tree_copy.dart';
import 'package:dopa/features/tree_companion/presentation/tree_renderer.dart';
import 'package:dopa_domain/dopa_domain.dart';
import 'package:flutter/foundation.dart' show defaultTargetPlatform;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../test_app.dart';

void main() {
  const policy = TreeGrowthPolicy();

  testWidgets('announces growth days and stage as one image', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        child: TestApp(
          home: Scaffold(
            body: SizedBox(
              width: 320,
              height: 320,
              child: TreeArtwork(progress: policy.progressFor(14)),
            ),
          ),
        ),
      ),
    );

    expect(find.bySemanticsLabel('함께 자란 14일, 어린 느티나무'), findsOneWidget);

    final semantics = tester.getSemantics(find.byType(TreeArtwork));
    expect(semantics.label, '함께 자란 14일, 어린 느티나무');
    expect(semantics.childrenCount, 0);
  });

  testWidgets('reduce motion renders the reveal final frame immediately', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        child: TestApp(
          disableAnimations: true,
          home: Scaffold(
            body: TreeArtwork(
              progress: policy.progressFor(7),
              animationCue: TreeAnimationCue.reveal,
            ),
          ),
        ),
      ),
    );

    final animation = tester.widget<TweenAnimationBuilder<double>>(
      find.byKey(const ValueKey('tree-one-shot-animation')),
    );
    expect(animation.duration, Duration.zero);
    expect(tester.hasRunningAnimations, isFalse);
  });

  testWidgets('non-milestone pulse remains within the 300ms motion budget', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        child: TestApp(
          home: Scaffold(
            body: TreeArtwork(
              progress: policy.progressFor(8),
              animationCue: TreeAnimationCue.pulse,
            ),
          ),
        ),
      ),
    );

    final animation = tester.widget<TweenAnimationBuilder<double>>(
      find.byKey(const ValueKey('tree-one-shot-animation')),
    );
    expect(animation.duration, DopaMotion.treePulse);
    expect(
      animation.duration,
      lessThanOrEqualTo(const Duration(milliseconds: 300)),
    );
    expect(find.byKey(const ValueKey('tree-leaf-light-pulse')), findsOneWidget);
    await tester.pumpAndSettle();
    final pulseOpacity = tester.widget<Opacity>(
      find.byKey(const ValueKey('tree-leaf-light-pulse')),
    );
    expect(pulseOpacity.opacity, closeTo(0, .001));
    expect(tester.hasRunningAnimations, isFalse);
  });

  testWidgets('post-mature ring expands and fades without scaling the tree', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        child: TestApp(
          home: Scaffold(
            body: TreeArtwork(
              progress: policy.progressFor(120),
              animationCue: TreeAnimationCue.ring,
            ),
          ),
        ),
      ),
    );

    final treeAnimation = tester.widget<TweenAnimationBuilder<double>>(
      find.byKey(const ValueKey('tree-one-shot-animation')),
    );
    final ringAnimation = tester.widget<TweenAnimationBuilder<double>>(
      find.byKey(const ValueKey('tree-ring-animation')),
    );
    expect(treeAnimation.duration, Duration.zero);
    expect(ringAnimation.duration, DopaMotion.standard);
    expect(
      ringAnimation.duration,
      lessThanOrEqualTo(const Duration(milliseconds: 300)),
    );

    await tester.pumpAndSettle();
    final ringOpacity = tester.widget<Opacity>(
      find.descendant(
        of: find.byKey(const ValueKey('tree-ring-animation')),
        matching: find.byType(Opacity),
      ),
    );
    expect(ringOpacity.opacity, 0);
    expect(tester.hasRunningAnimations, isFalse);
  });

  testWidgets('Rive flag safely falls back when no adapter is registered', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          treeFeatureFlagsProvider.overrideWithValue(
            const TreeFeatureFlags(treeRiveEnabled: true),
          ),
        ],
        child: TestApp(
          home: Scaffold(body: TreeArtwork(progress: policy.progressFor(3))),
        ),
      ),
    );

    expect(
      find.byKey(const ValueKey('tree-renderer-local-static')),
      findsOneWidget,
    );
  });

  testWidgets(
    'synchronous Rive failure reports an allowlisted code and falls back',
    (tester) async {
      final failures = <TreeRenderFailure>[];
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            treeFeatureFlagsProvider.overrideWithValue(
              const TreeFeatureFlags(treeRiveEnabled: true),
            ),
            riveTreeRendererProvider.overrideWithValue(
              const _ThrowingRiveRenderer(),
            ),
            treeRenderFailureReporterProvider.overrideWithValue(failures.add),
          ],
          child: TestApp(
            home: Scaffold(body: TreeArtwork(progress: policy.progressFor(7))),
          ),
        ),
      );

      expect(
        find.byKey(const ValueKey('tree-renderer-local-static')),
        findsOneWidget,
      );
      expect(failures, hasLength(1));
      expect(failures.single.errorCode, 'renderer_build_failed');
      expect(TreeRenderFailure.eventName, 'tree_render_failed');
    },
  );

  testWidgets(
    'asynchronous Rive load failure keeps the static fallback visible',
    (tester) async {
      final failures = <TreeRenderFailure>[];
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            treeFeatureFlagsProvider.overrideWithValue(
              const TreeFeatureFlags(treeRiveEnabled: true),
            ),
            riveTreeRendererProvider.overrideWithValue(
              const _AsyncFailingRiveRenderer(),
            ),
            treeRenderFailureReporterProvider.overrideWithValue(failures.add),
          ],
          child: TestApp(
            home: Scaffold(body: TreeArtwork(progress: policy.progressFor(7))),
          ),
        ),
      );
      await tester.pump();

      expect(
        find.byKey(const ValueKey('tree-stage-smallTree')),
        findsOneWidget,
      );
      expect(failures, hasLength(1));
      expect(failures.single.errorCode, 'rive_asset_load_failed');
    },
  );

  testWidgets(
    'missing local sprite reports asset_load_failed and keeps the painter',
    (tester) async {
      final failures = <TreeRenderFailure>[];
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            localTreeRendererProvider.overrideWithValue(
              LocalSpriteTreeRenderer(
                onFailure: failures.add,
                spriteAssetForBrightness: (_) =>
                    'assets/tree/missing_sprite.png',
              ),
            ),
          ],
          child: TestApp(
            home: Scaffold(body: TreeArtwork(progress: policy.progressFor(1))),
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));

      expect(find.byKey(const ValueKey('tree-stage-sprout')), findsOneWidget);
      expect(find.byKey(const ValueKey('tree-sprite-surface')), findsOneWidget);
      expect(
        failures.any((failure) => failure.errorCode == 'asset_load_failed'),
        isTrue,
      );
    },
  );

  test('render diagnostics redact adapter-controlled values', () {
    final failures = <TreeRenderFailure>[];
    final diagnostics = TreeRenderDiagnostics();

    diagnostics.reportOnce(
      failure: const TreeRenderFailure(
        renderer: 'user/session/path',
        platform: 'device-id',
        errorCode: 'exception text with private data',
      ),
      reporter: failures.add,
    );

    expect(failures, hasLength(1));
    expect(failures.single.renderer, 'rive');
    expect(failures.single.platform, defaultTargetPlatform.name);
    expect(failures.single.errorCode, 'unknown_runtime_failure');
  });

  testWidgets('dark theme selects the dark local sprite', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        child: TestApp(
          brightness: Brightness.dark,
          home: Scaffold(body: TreeArtwork(progress: policy.progressFor(90))),
        ),
      ),
    );

    final image = tester.widget<Image>(find.byType(Image));
    expect(
      (image.image as AssetImage).assetName,
      TreeStaticAssetContract.darkSprite,
    );
    final surface = tester.widget<DecoratedBox>(
      find.byKey(const ValueKey('tree-sprite-surface')),
    );
    expect(
      (surface.decoration as BoxDecoration).color,
      DopaColors.treeCanvasDark,
    );
  });

  testWidgets(
    'season accents render above the opaque sprite while glow stays behind',
    (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: TestApp(
            home: Scaffold(
              body: TreeArtwork(
                progress: policy.progressFor(120),
                season: TreeSeason.autumn,
                animationCue: TreeAnimationCue.ring,
                reduceMotion: true,
              ),
            ),
          ),
        ),
      );

      final scene = tester.widget<Stack>(
        find.byKey(const ValueKey('tree-scene')),
      );
      expect(scene.children.map((child) => child.key), [
        const ValueKey('tree-environment-background'),
        const ValueKey('tree-sprite-layer'),
        const ValueKey('tree-environment-overlay'),
      ]);
      final surface = tester.widget<DecoratedBox>(
        find.byKey(const ValueKey('tree-sprite-surface')),
      );
      expect(
        (surface.decoration as BoxDecoration).color,
        DopaColors.treeCanvasLight,
      );
    },
  );

  test('calendar month boundaries derive environment season only', () {
    expect(treeSeasonForMonth(2), TreeSeason.winter);
    expect(treeSeasonForMonth(3), TreeSeason.spring);
    expect(treeSeasonForMonth(5), TreeSeason.spring);
    expect(treeSeasonForMonth(6), TreeSeason.summer);
    expect(treeSeasonForMonth(8), TreeSeason.summer);
    expect(treeSeasonForMonth(9), TreeSeason.autumn);
    expect(treeSeasonForMonth(11), TreeSeason.autumn);
    expect(treeSeasonForMonth(12), TreeSeason.winter);
    expect(() => treeSeasonForMonth(13), throwsArgumentError);
  });

  test('season provider reads an injectable local clock', () {
    final container = ProviderContainer(
      overrides: [
        treeSeasonNowProvider.overrideWithValue(() => DateTime(2026, 3, 1)),
      ],
    );
    addTearDown(container.dispose);

    expect(container.read(treeSeasonProvider), TreeSeason.spring);
  });

  testWidgets('all eight visual stages select a sprite cell', (tester) async {
    for (final stage in TreeGrowthStage.values) {
      final days = switch (stage) {
        TreeGrowthStage.seed => 0,
        TreeGrowthStage.sprout => 1,
        TreeGrowthStage.sapling => 3,
        TreeGrowthStage.smallTree => 7,
        TreeGrowthStage.youngZelkova => 14,
        TreeGrowthStage.spreadingBranches => 30,
        TreeGrowthStage.broadCanopy => 60,
        TreeGrowthStage.mature => 90,
      };
      await tester.pumpWidget(
        ProviderScope(
          child: TestApp(
            home: Scaffold(
              body: TreeArtwork(progress: policy.progressFor(days)),
            ),
          ),
        ),
      );

      expect(find.byKey(ValueKey('tree-stage-${stage.name}')), findsOneWidget);
      expect(
        find.bySemanticsLabel('함께 자란 $days일, ${stage.koreanLabel}'),
        findsOneWidget,
      );
      expect(tester.takeException(), isNull);
    }
  });
}

class _AsyncFailingRiveRenderer implements RiveTreeRenderer {
  const _AsyncFailingRiveRenderer();

  @override
  String get rendererName => 'rive';

  @override
  Widget renderWithFallback(
    TreeRenderRequest request, {
    required Widget fallback,
    required TreeRenderFailureReporter onFailure,
  }) {
    return _DelayedRiveFallback(fallback: fallback, onFailure: onFailure);
  }
}

class _DelayedRiveFallback extends StatefulWidget {
  const _DelayedRiveFallback({required this.fallback, required this.onFailure});

  final Widget fallback;
  final TreeRenderFailureReporter onFailure;

  @override
  State<_DelayedRiveFallback> createState() => _DelayedRiveFallbackState();
}

class _DelayedRiveFallbackState extends State<_DelayedRiveFallback> {
  var _failed = false;

  @override
  void initState() {
    super.initState();
    scheduleMicrotask(() {
      widget.onFailure(
        TreeRenderFailure(
          renderer: 'rive',
          platform: defaultTargetPlatform.name,
          errorCode: 'rive_asset_load_failed',
        ),
      );
      if (mounted) {
        setState(() => _failed = true);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return _failed ? widget.fallback : const SizedBox.shrink();
  }
}

class _ThrowingRiveRenderer implements RiveTreeRenderer {
  const _ThrowingRiveRenderer();

  @override
  String get rendererName => 'rive';

  @override
  Widget renderWithFallback(
    TreeRenderRequest request, {
    required Widget fallback,
    required TreeRenderFailureReporter onFailure,
  }) {
    throw StateError('synthetic test failure');
  }
}
