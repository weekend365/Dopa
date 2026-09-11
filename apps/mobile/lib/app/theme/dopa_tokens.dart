import 'package:flutter/material.dart';

// Primitive palette. Screens consume ColorScheme or DopaSurfaces.
abstract final class DopaColors {
  static const cream = Color(0xFFFAF9F5);
  static const creamRaised = Color(0xFFFFFFFF);
  static const ink = Color(0xFF25362F);
  static const inkMuted = Color(0xFF657268);
  static const sage = Color(0xFF728B72);
  static const sageDeep = Color(0xFF356448);
  static const sageSoft = Color(0xFFEDF3E8);
  static const newLeaf = Color(0xFFF6E6B5);
  static const bark = Color(0xFF7A604A);
  static const soil = Color(0xFFCAB397);
  static const treeCanvasLight = cream;
  static const night = Color(0xFF18231D);
  static const nightRaised = Color(0xFF223027);
  static const moonInk = Color(0xFFEDF3EA);
  static const moonMuted = Color(0xFFB0BDB0);
  static const nightSage = Color(0xFFB5D5AE);
  static const nightSageSoft = Color(0xFF2C3D31);
  static const treeCanvasDark = night;
}

abstract final class DopaSpacing {
  static const xxs = 4.0,
      xs = 8.0,
      sm = 12.0,
      md = 16.0,
      pageCompact = 20.0,
      lg = 24.0,
      xl = 32.0,
      xxl = 48.0,
      xxxl = 64.0;
  static double page(BuildContext context) =>
      MediaQuery.sizeOf(context).width < 360 ? pageCompact : lg;
}

abstract final class DopaRadii {
  static const sm = 12.0, md = 16.0, lg = 24.0, pill = 999.0;
}

abstract final class DopaMotion {
  static const quick = Duration(milliseconds: 120);
  static const standard = Duration(milliseconds: 240);
  static const treePulse = Duration(milliseconds: 280);
  static const milestoneReveal = Duration(milliseconds: 600);
}

@immutable
class DopaSurfaces extends ThemeExtension<DopaSurfaces> {
  const DopaSurfaces({
    required this.soft,
    required this.sunlight,
    required this.apricot,
    required this.muted,
  });
  final Color soft, sunlight, apricot, muted;
  static DopaSurfaces of(BuildContext context) =>
      Theme.of(context).extension<DopaSurfaces>()!;
  @override
  DopaSurfaces copyWith({
    Color? soft,
    Color? sunlight,
    Color? apricot,
    Color? muted,
  }) => DopaSurfaces(
    soft: soft ?? this.soft,
    sunlight: sunlight ?? this.sunlight,
    apricot: apricot ?? this.apricot,
    muted: muted ?? this.muted,
  );
  @override
  DopaSurfaces lerp(DopaSurfaces? other, double t) => other == null
      ? this
      : DopaSurfaces(
          soft: Color.lerp(soft, other.soft, t)!,
          sunlight: Color.lerp(sunlight, other.sunlight, t)!,
          apricot: Color.lerp(apricot, other.apricot, t)!,
          muted: Color.lerp(muted, other.muted, t)!,
        );
}
