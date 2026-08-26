import 'package:dopa/features/tree_companion/application/tree_season.dart';
import 'package:dopa_domain/dopa_domain.dart';
import 'package:flutter/material.dart';

/// Data-binding names expected from the production Rive state machine.
/// The runtime adapter is injected from the app edge so the static experience
/// stays shippable when Rive is disabled or cannot initialize.
abstract final class TreeRiveContract {
  static const assetPath = 'assets/tree/dopa_zelkova_v1.riv';
  static const stateMachine = 'TreeCompanion';
  static const stage = 'stage';
  static const theme = 'theme';
  static const season = 'season';
  static const playReveal = 'playReveal';
  static const playPulse = 'playPulse';
  static const reduceMotion = 'reduceMotion';
}

abstract final class TreeStaticAssetContract {
  static const lightSprite = 'assets/tree/zelkova_growth_sprite_light.png';
  static const darkSprite = 'assets/tree/zelkova_growth_sprite_dark.png';
  static const columns = 4;
  static const rows = 2;
}

enum TreeAnimationCue { none, reveal, pulse, ring }

class TreeRenderRequest {
  const TreeRenderRequest({
    required this.stage,
    required this.brightness,
    required this.season,
    required this.animationCue,
    required this.reduceMotion,
  });

  final TreeGrowthStage stage;
  final Brightness brightness;
  final TreeSeason season;
  final TreeAnimationCue animationCue;
  final bool reduceMotion;
}

abstract interface class TreeRenderer {
  String get rendererName;

  Widget render(TreeRenderRequest request);
}

/// Implement this contract in the Rive integration package. It is deliberately
/// absent from the default dependency graph while `tree_rive_enabled` is off.
///
/// Rive asset and state-machine initialization finish after this method
/// returns. Implementations must keep [fallback] available and replace their
/// subtree with it on any asynchronous load/runtime failure. Every such
/// transition must call [onFailure] with allowlisted operational metadata only.
abstract interface class RiveTreeRenderer {
  String get rendererName;

  Widget renderWithFallback(
    TreeRenderRequest request, {
    required Widget fallback,
    required TreeRenderFailureReporter onFailure,
  });
}

class TreeRenderFailure {
  const TreeRenderFailure({
    required this.renderer,
    required this.platform,
    required this.errorCode,
  });

  final String renderer;
  final String platform;
  final String errorCode;

  static const eventName = 'tree_render_failed';
}

typedef TreeRenderFailureReporter = void Function(TreeRenderFailure failure);
