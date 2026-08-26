import 'package:flutter/material.dart';

abstract final class DopaColors {
  static const cream = Color(0xFFF7F2E8);
  static const creamRaised = Color(0xFFFFFBF3);
  static const ink = Color(0xFF27302B);
  static const inkMuted = Color(0xFF66706A);
  static const sage = Color(0xFF728B72);
  static const sageDeep = Color(0xFF3F604A);
  static const sageSoft = Color(0xFFDCE6D8);
  static const newLeaf = Color(0xFFD5A84E);
  static const bark = Color(0xFF7A604A);
  static const soil = Color(0xFFCAB397);
  static const treeCanvasLight = Color(0xFFF8F4EF);

  static const night = Color(0xFF151B18);
  static const nightRaised = Color(0xFF202824);
  static const moonInk = Color(0xFFF1EEE5);
  static const moonMuted = Color(0xFFB8C2BA);
  static const nightSage = Color(0xFF91AD91);
  static const nightSageSoft = Color(0xFF2A3A30);
  static const treeCanvasDark = Color(0xFF151917);
}

abstract final class DopaSpacing {
  static const xxs = 4.0;
  static const xs = 8.0;
  static const sm = 12.0;
  static const md = 16.0;
  static const lg = 24.0;
  static const xl = 32.0;
  static const xxl = 48.0;
}

abstract final class DopaRadii {
  static const sm = 12.0;
  static const md = 20.0;
  static const lg = 28.0;
  static const pill = 999.0;
}

abstract final class DopaMotion {
  static const quick = Duration(milliseconds: 150);
  static const standard = Duration(milliseconds: 240);
  static const treePulse = Duration(milliseconds: 280);
  static const milestoneReveal = Duration(milliseconds: 1200);
}
