import 'dart:math' as math;

import 'package:dopa/app/theme/dopa_tokens.dart';
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
  const LocalSpriteTreeRenderer({this.onFailure});

  final TreeRenderFailureReporter? onFailure;

  @override
  String get rendererName => 'local-static';

  @override
  Widget render(TreeRenderRequest request) {
    final duration = request.reduceMotion
        ? Duration.zero
        : switch (request.animationCue) {
            TreeAnimationCue.reveal => DopaMotion.milestoneReveal,
            TreeAnimationCue.pulse => DopaMotion.treePulse,
            TreeAnimationCue.ring => Duration.zero,
            TreeAnimationCue.none => Duration.zero,
          };

    return TweenAnimationBuilder<double>(
      key: const ValueKey('tree-one-shot-animation'),
      duration: duration,
      curve: Curves.easeOutCubic,
      tween: Tween<double>(begin: _beginValue(request), end: 1),
      builder: (context, value, child) {
        if (request.animationCue == TreeAnimationCue.pulse &&
            !request.reduceMotion) {
          return Stack(
            fit: StackFit.expand,
            children: [
              child!,
              ExcludeSemantics(
                child: IgnorePointer(
                  child: Opacity(
                    key: const ValueKey('tree-leaf-light-pulse'),
                    opacity: math.sin(math.pi * value).clamp(0, 1).toDouble(),
                    child: CustomPaint(
                      painter: _GrowthPulsePainter(
                        brightness: request.brightness,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        }
        if (request.animationCue == TreeAnimationCue.reveal &&
            !request.reduceMotion) {
          return Transform.scale(
            scale: value,
            alignment: Alignment.bottomCenter,
            child: child,
          );
        }
        return child!;
      },
      child: _TreeScene(request: request, onFailure: onFailure),
    );
  }

  double _beginValue(TreeRenderRequest request) => request.reduceMotion
      ? 1
      : switch (request.animationCue) {
          TreeAnimationCue.pulse => 0,
          TreeAnimationCue.reveal => 0.86,
          TreeAnimationCue.ring || TreeAnimationCue.none => 1,
        };
}

class _GrowthPulsePainter extends CustomPainter {
  const _GrowthPulsePainter({required this.brightness});

  final Brightness brightness;

  @override
  void paint(Canvas canvas, Size size) {
    final glowCenter = Offset(size.width * .5, size.height * .42);
    final glowRadius = size.shortestSide * .34;
    final glow = Paint()
      ..shader = RadialGradient(
        colors: [
          DopaColors.newLeaf.withAlpha(brightness == Brightness.dark ? 72 : 92),
          DopaColors.newLeaf.withAlpha(0),
        ],
      ).createShader(Rect.fromCircle(center: glowCenter, radius: glowRadius));
    canvas.drawCircle(glowCenter, glowRadius, glow);

    final leaf = Paint()
      ..color = brightness == Brightness.dark
          ? DopaColors.nightSage.withAlpha(150)
          : DopaColors.sage.withAlpha(135);
    for (var index = 0; index < 5; index++) {
      final angle = index * math.pi * .4;
      final center =
          glowCenter +
          Offset(
            math.cos(angle) * size.width * .2,
            math.sin(angle) * size.height * .12,
          );
      canvas.save();
      canvas.translate(center.dx, center.dy);
      canvas.rotate(angle + .35);
      canvas.drawOval(const Rect.fromLTWH(-4, -2, 8, 4), leaf);
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant _GrowthPulsePainter oldDelegate) =>
      oldDelegate.brightness != brightness;
}

class _TreeScene extends StatelessWidget {
  const _TreeScene({required this.request, required this.onFailure});

  final TreeRenderRequest request;
  final TreeRenderFailureReporter? onFailure;

  @override
  Widget build(BuildContext context) {
    return Stack(
      key: const ValueKey('tree-scene'),
      fit: StackFit.expand,
      children: [
        ExcludeSemantics(
          key: const ValueKey('tree-environment-background'),
          child: CustomPaint(
            painter: _EnvironmentPainter(
              season: request.season,
              brightness: request.brightness,
              showRing: false,
              layer: _EnvironmentLayer.glow,
            ),
          ),
        ),
        Padding(
          key: const ValueKey('tree-sprite-layer'),
          padding: const EdgeInsets.all(DopaSpacing.xs),
          child: _TreeSpriteCell(request: request, onFailure: onFailure),
        ),
        ExcludeSemantics(
          key: const ValueKey('tree-environment-overlay'),
          child: IgnorePointer(
            child: Stack(
              fit: StackFit.expand,
              children: [
                CustomPaint(
                  painter: _EnvironmentPainter(
                    season: request.season,
                    brightness: request.brightness,
                    showRing: false,
                    layer: _EnvironmentLayer.accents,
                  ),
                ),
                if (request.animationCue == TreeAnimationCue.ring)
                  _TreeRingPulse(request: request),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _TreeRingPulse extends StatelessWidget {
  const _TreeRingPulse({required this.request});

  final TreeRenderRequest request;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      key: const ValueKey('tree-ring-animation'),
      duration: request.reduceMotion ? Duration.zero : DopaMotion.standard,
      curve: Curves.easeOutCubic,
      tween: Tween<double>(begin: request.reduceMotion ? 1 : 0, end: 1),
      builder: (context, value, child) => Opacity(
        opacity: 1 - value,
        child: Transform.scale(
          scale: .72 + value * .5,
          alignment: Alignment.bottomCenter,
          child: child,
        ),
      ),
      child: CustomPaint(
        painter: _EnvironmentPainter(
          season: request.season,
          brightness: request.brightness,
          showRing: true,
          layer: _EnvironmentLayer.ring,
        ),
      ),
    );
  }
}

class _TreeSpriteCell extends StatelessWidget {
  const _TreeSpriteCell({required this.request, required this.onFailure});

  final TreeRenderRequest request;
  final TreeRenderFailureReporter? onFailure;

  @override
  Widget build(BuildContext context) {
    final stageIndex = request.stage.index;
    final column = stageIndex % TreeStaticAssetContract.columns;
    final row = stageIndex ~/ TreeStaticAssetContract.columns;
    final asset = request.brightness == Brightness.dark
        ? TreeStaticAssetContract.darkSprite
        : TreeStaticAssetContract.lightSprite;

    return Center(
      child: AspectRatio(
        key: ValueKey('tree-stage-${request.stage.name}'),
        aspectRatio: 0.75,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(DopaRadii.md),
          child: DecoratedBox(
            key: const ValueKey('tree-sprite-surface'),
            decoration: BoxDecoration(
              color: request.brightness == Brightness.dark
                  ? DopaColors.treeCanvasDark
                  : DopaColors.treeCanvasLight,
            ),
            child: Stack(
              fit: StackFit.expand,
              children: [
                CustomPaint(
                  painter: _FallbackTreePainter(
                    stage: request.stage,
                    brightness: request.brightness,
                  ),
                ),
                LayoutBuilder(
                  builder: (context, constraints) {
                    final width = constraints.maxWidth;
                    final height = constraints.maxHeight;
                    return ClipRect(
                      child: Stack(
                        clipBehavior: Clip.hardEdge,
                        children: [
                          Positioned(
                            left: -column * width,
                            top: -row * height,
                            width: width * TreeStaticAssetContract.columns,
                            height: height * TreeStaticAssetContract.rows,
                            child: Image.asset(
                              asset,
                              fit: BoxFit.fill,
                              filterQuality: FilterQuality.high,
                              excludeFromSemantics: true,
                              errorBuilder: (context, error, stackTrace) {
                                onFailure?.call(
                                  TreeRenderFailure(
                                    renderer: 'local-static',
                                    platform: defaultTargetPlatform.name,
                                    errorCode: 'asset_load_failed',
                                  ),
                                );
                                return const SizedBox.shrink();
                              },
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

enum _EnvironmentLayer { glow, accents, ring }

class _EnvironmentPainter extends CustomPainter {
  const _EnvironmentPainter({
    required this.season,
    required this.brightness,
    required this.showRing,
    required this.layer,
  });

  final TreeSeason season;
  final Brightness brightness;
  final bool showRing;
  final _EnvironmentLayer layer;

  @override
  void paint(Canvas canvas, Size size) {
    final isDark = brightness == Brightness.dark;
    final glowColor = switch (season) {
      TreeSeason.spring => const Color(0xFFF2CFC0),
      TreeSeason.summer => const Color(0xFFE5D6A2),
      TreeSeason.autumn => const Color(0xFFDCA76A),
      TreeSeason.winter => const Color(0xFFCEDBE0),
    };

    if (layer == _EnvironmentLayer.ring) {
      _paintRing(canvas, size, glowColor);
      return;
    }
    if (layer == _EnvironmentLayer.accents) {
      _paintAccents(canvas, size, glowColor, isDark);
      return;
    }

    final glow = Paint()
      ..shader =
          RadialGradient(
            colors: [
              glowColor.withAlpha(isDark ? 36 : 76),
              glowColor.withAlpha(0),
            ],
          ).createShader(
            Rect.fromCircle(
              center: Offset(size.width * .5, size.height * .45),
              radius: size.shortestSide * .56,
            ),
          );
    canvas.drawCircle(
      Offset(size.width * .5, size.height * .45),
      size.shortestSide * .56,
      glow,
    );
  }

  void _paintAccents(Canvas canvas, Size size, Color glowColor, bool isDark) {
    final accent = Paint()..color = glowColor.withAlpha(isDark ? 95 : 130);
    if (season == TreeSeason.winter) {
      for (var i = 0; i < 7; i++) {
        final x = size.width * (.12 + i * .125);
        final y = size.height * (.12 + (i % 3) * .12);
        canvas.drawCircle(Offset(x, y), 1.8, accent);
      }
    } else if (season == TreeSeason.spring || season == TreeSeason.autumn) {
      for (var i = 0; i < 5; i++) {
        final x = size.width * (.16 + i * .16);
        final y = size.height * (.18 + (i % 2) * .14);
        canvas.save();
        canvas.translate(x, y);
        canvas.rotate(i * .35);
        canvas.drawOval(const Rect.fromLTWH(-3, -1.5, 6, 3), accent);
        canvas.restore();
      }
    }
  }

  void _paintRing(Canvas canvas, Size size, Color glowColor) {
    if (!showRing) return;
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(size.width * .5, size.height * .86),
        width: size.width * .45,
        height: size.height * .08,
      ),
      Paint()
        ..color = glowColor.withAlpha(105)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    );
  }

  @override
  bool shouldRepaint(covariant _EnvironmentPainter oldDelegate) =>
      oldDelegate.season != season ||
      oldDelegate.brightness != brightness ||
      oldDelegate.showRing != showRing ||
      oldDelegate.layer != layer;
}

class _FallbackTreePainter extends CustomPainter {
  const _FallbackTreePainter({required this.stage, required this.brightness});

  final TreeGrowthStage stage;
  final Brightness brightness;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height * .82);
    final soilPaint = Paint()
      ..color = brightness == Brightness.dark
          ? const Color(0xFF665849)
          : DopaColors.soil;
    canvas.drawOval(
      Rect.fromCenter(
        center: center,
        width: size.width * .7,
        height: size.height * .11,
      ),
      soilPaint,
    );

    if (stage == TreeGrowthStage.seed) {
      canvas.save();
      canvas.translate(center.dx, center.dy - size.height * .04);
      canvas.rotate(-.35);
      canvas.drawOval(
        Rect.fromCenter(
          center: Offset.zero,
          width: size.width * .12,
          height: size.height * .04,
        ),
        Paint()..color = const Color(0xFF88764A),
      );
      canvas.restore();
      return;
    }

    final maturity = math.max(1, stage.index) / 7;
    final trunkTop = Offset(
      center.dx,
      center.dy - size.height * (.22 + maturity * .42),
    );
    final trunk = Paint()
      ..color = DopaColors.bark
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 3 + maturity * 12;
    canvas.drawLine(center, trunkTop, trunk);

    final leafPaint = Paint()
      ..color = brightness == Brightness.dark
          ? DopaColors.nightSage
          : DopaColors.sage;
    final canopyWidth = size.width * (.18 + maturity * .6);
    final canopyHeight = size.height * (.08 + maturity * .28);
    for (var i = 0; i < 7; i++) {
      final angle = i / 7 * math.pi * 2;
      final offset = Offset(
        math.cos(angle) * canopyWidth * .27,
        math.sin(angle) * canopyHeight * .26,
      );
      canvas.drawCircle(
        trunkTop + Offset(0, canopyHeight * .12) + offset,
        canopyWidth * (.13 + (i % 2) * .018),
        leafPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _FallbackTreePainter oldDelegate) =>
      oldDelegate.stage != stage || oldDelegate.brightness != brightness;
}
