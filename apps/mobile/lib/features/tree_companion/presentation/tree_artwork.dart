import 'package:dopa/features/tree_companion/presentation/garden_artwork.dart';

import 'package:dopa/features/tree_companion/application/tree_feature_flags.dart';
import 'package:dopa/features/tree_companion/application/tree_season.dart';
import 'package:dopa/features/tree_companion/presentation/tree_copy.dart';
import 'package:dopa/features/tree_companion/presentation/tree_renderer.dart';
import 'package:dopa_domain/dopa_domain.dart';
import 'package:flutter/foundation.dart' show defaultTargetPlatform;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final riveTreeRendererProvider = Provider<RiveTreeRenderer?>((ref) => null);

/// Override with the allowlisted `tree_render_failed` operational event sink.
/// The callback receives no asset path, exception text, or user/session data.
final treeRenderFailureReporterProvider = Provider<TreeRenderFailureReporter>(
  (ref) => (failure) {},
);

final treeRenderDiagnosticsProvider = Provider<TreeRenderDiagnostics>(
  (ref) => TreeRenderDiagnostics(),
);

final localTreeRendererProvider = Provider<TreeRenderer>(
  (ref) => LocalSpriteTreeRenderer(
    onFailure: (failure) => ref
        .read(treeRenderDiagnosticsProvider)
        .reportOnce(
          failure: failure,
          reporter: ref.read(treeRenderFailureReporterProvider),
        ),
  ),
);

class TreeArtwork extends ConsumerWidget {
  const TreeArtwork({
    required this.progress,
    this.season,
    this.animationCue = TreeAnimationCue.none,
    this.reduceMotion,
    super.key,
  });

  final TreeProgress progress;
  final TreeSeason? season;
  final TreeAnimationCue animationCue;
  final bool? reduceMotion;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final flags = ref.watch(treeFeatureFlagsProvider);
    if (!flags.treeUiEnabled) {
      return const SizedBox.shrink();
    }

    final media = MediaQuery.maybeOf(context);
    final motionIsReduced = reduceMotion ?? media?.disableAnimations ?? false;
    final request = TreeRenderRequest(
      stage: progress.stage,
      brightness: Theme.of(context).brightness,
      season: season ?? ref.watch(treeSeasonProvider),
      animationCue: animationCue,
      reduceMotion: motionIsReduced,
    );
    final localRenderer = ref.watch(localTreeRendererProvider);
    final riveRenderer = ref.watch(riveTreeRendererProvider);
    var rendererName = localRenderer.rendererName;
    var renderedTree = localRenderer.render(request);
    if (flags.treeRiveEnabled && riveRenderer == null) {
      ref
          .read(treeRenderDiagnosticsProvider)
          .reportOnce(
            failure: TreeRenderFailure(
              renderer: 'rive',
              platform: defaultTargetPlatform.name,
              errorCode: 'adapter_missing',
            ),
            reporter: ref.read(treeRenderFailureReporterProvider),
          );
    } else if (flags.treeRiveEnabled && riveRenderer != null) {
      try {
        rendererName = riveRenderer.rendererName;
        renderedTree = riveRenderer.renderWithFallback(
          request,
          fallback: renderedTree,
          onFailure: (failure) => ref
              .read(treeRenderDiagnosticsProvider)
              .reportOnce(
                failure: failure,
                reporter: ref.read(treeRenderFailureReporterProvider),
              ),
        );
      } on Object {
        ref
            .read(treeRenderDiagnosticsProvider)
            .reportOnce(
              failure: TreeRenderFailure(
                renderer: riveRenderer.rendererName,
                platform: defaultTargetPlatform.name,
                errorCode: 'renderer_build_failed',
              ),
              reporter: ref.read(treeRenderFailureReporterProvider),
            );
        rendererName = localRenderer.rendererName;
        renderedTree = localRenderer.render(request);
      }
    }

    return Semantics(
      label: treeStatusLabel(progress),
      image: true,
      container: true,
      child: ExcludeSemantics(
        child: KeyedSubtree(
          key: ValueKey('tree-renderer-$rendererName'),
          child: renderedTree,
        ),
      ),
    );
  }
}

class TreeRenderDiagnostics {
  static const _allowedRenderers = <String>{'rive', 'local-static'};
  static const _allowedPlatforms = <String>{
    'android',
    'fuchsia',
    'iOS',
    'linux',
    'macOS',
    'windows',
  };
  static const _allowedErrorCodes = <String>{
    'adapter_missing',
    'asset_load_failed',
    'data_binding_failed',
    'playback_failed',
    'renderer_build_failed',
    'rive_asset_load_failed',
    'state_machine_missing',
    'unknown_runtime_failure',
  };

  final Set<String> _reported = <String>{};

  void reportOnce({
    required TreeRenderFailure failure,
    required TreeRenderFailureReporter reporter,
  }) {
    final safeFailure = TreeRenderFailure(
      renderer: _allowedRenderers.contains(failure.renderer)
          ? failure.renderer
          : 'rive',
      platform: _allowedPlatforms.contains(failure.platform)
          ? failure.platform
          : defaultTargetPlatform.name,
      errorCode: _allowedErrorCodes.contains(failure.errorCode)
          ? failure.errorCode
          : 'unknown_runtime_failure',
    );
    final fingerprint =
        '${safeFailure.renderer}:${safeFailure.platform}:${safeFailure.errorCode}';
    if (_reported.add(fingerprint)) {
      reporter(safeFailure);
    }
  }
}

class LocalSpriteTreeRenderer implements TreeRenderer {
  const LocalSpriteTreeRenderer({
    this.onFailure,
    this.spriteAssetForBrightness,
  });
  final TreeRenderFailureReporter? onFailure;
  final String Function(Brightness)? spriteAssetForBrightness;
  @override
  String get rendererName => 'local-static';
  @override
  Widget render(TreeRenderRequest request) => GardenArtwork(
    progress: const TreeGrowthPolicy().progressFor(
      const [0, 1, 3, 7, 14, 30, 60, 90][request.stage.index],
    ),
    assetOverride: spriteAssetForBrightness?.call(request.brightness),
  );
}
