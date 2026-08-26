import 'package:flutter_riverpod/flutter_riverpod.dart';

class TreeFeatureFlags {
  const TreeFeatureFlags({
    this.treeUiEnabled = true,
    this.treeRiveEnabled = false,
  });

  final bool treeUiEnabled;
  final bool treeRiveEnabled;
}

abstract final class TreeFeatureFlagKeys {
  static const treeUiEnabled = 'tree_ui_enabled';
  static const treeRiveEnabled = 'tree_rive_enabled';
}

/// Override this provider with Remote Config values at the application edge.
/// Growth crediting must never depend on either UI flag.
final treeFeatureFlagsProvider = Provider<TreeFeatureFlags>(
  (ref) => const TreeFeatureFlags(),
);
