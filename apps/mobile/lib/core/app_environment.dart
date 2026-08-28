import 'package:flutter/services.dart' show appFlavor;

/// Build-time environment selected by Flutter's native app flavor.
enum DopaEnvironment { dev, prod }

abstract final class AppEnvironment {
  static const name = appFlavor ?? 'dev';

  static const current = name == 'prod'
      ? DopaEnvironment.prod
      : DopaEnvironment.dev;

  static const isProduction = current == DopaEnvironment.prod;

  static String get displayName => isProduction ? 'Dopa' : 'Dopa Dev';
}
