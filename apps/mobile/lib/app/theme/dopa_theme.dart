import 'package:dopa/app/theme/dopa_tokens.dart';
import 'package:flutter/material.dart';

abstract final class DopaTheme {
  static ThemeData get light => _build(
    brightness: Brightness.light,
    surface: DopaColors.cream,
    surfaceRaised: DopaColors.creamRaised,
    foreground: DopaColors.ink,
    muted: DopaColors.inkMuted,
    primary: DopaColors.sageDeep,
    secondary: DopaColors.newLeaf,
  );

  static ThemeData get dark => _build(
    brightness: Brightness.dark,
    surface: DopaColors.night,
    surfaceRaised: DopaColors.nightRaised,
    foreground: DopaColors.moonInk,
    muted: DopaColors.moonMuted,
    primary: DopaColors.nightSage,
    secondary: DopaColors.newLeaf,
  );

  static ThemeData _build({
    required Brightness brightness,
    required Color surface,
    required Color surfaceRaised,
    required Color foreground,
    required Color muted,
    required Color primary,
    required Color secondary,
  }) {
    final scheme =
        ColorScheme.fromSeed(
          seedColor: primary,
          brightness: brightness,
          surface: surface,
        ).copyWith(
          primary: primary,
          secondary: secondary,
          onSurface: foreground,
          surfaceContainerLow: surfaceRaised,
          surfaceContainerHighest: surfaceRaised,
          outline: muted,
        );

    final base = ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: scheme,
      scaffoldBackgroundColor: surface,
    );

    return base.copyWith(
      textTheme: base.textTheme.copyWith(
        displaySmall: base.textTheme.displaySmall?.copyWith(
          color: foreground,
          fontWeight: FontWeight.w700,
          height: 1.1,
          letterSpacing: -0.8,
        ),
        headlineSmall: base.textTheme.headlineSmall?.copyWith(
          color: foreground,
          fontWeight: FontWeight.w700,
          height: 1.2,
          letterSpacing: -0.3,
        ),
        titleLarge: base.textTheme.titleLarge?.copyWith(
          color: foreground,
          fontWeight: FontWeight.w700,
        ),
        bodyLarge: base.textTheme.bodyLarge?.copyWith(
          color: foreground,
          height: 1.5,
        ),
        bodyMedium: base.textTheme.bodyMedium?.copyWith(
          color: muted,
          height: 1.45,
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: surfaceRaised,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(DopaRadii.lg),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size(48, 52),
          padding: const EdgeInsets.symmetric(
            horizontal: DopaSpacing.lg,
            vertical: DopaSpacing.md,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(DopaRadii.md),
          ),
          textStyle: const TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        elevation: 0,
        backgroundColor: surfaceRaised,
        indicatorColor: scheme.primaryContainer,
        height: 72,
      ),
      dividerTheme: DividerThemeData(color: scheme.outlineVariant),
    );
  }
}
