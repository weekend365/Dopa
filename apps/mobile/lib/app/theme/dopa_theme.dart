import 'package:dopa/app/theme/dopa_tokens.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

abstract final class DopaTheme {
  static ThemeData get light => _build(false);
  static ThemeData get dark => _build(true);
  static ThemeData _build(bool dark) {
    final ink = dark ? DopaColors.moonInk : DopaColors.ink;
    final muted = dark ? DopaColors.moonMuted : DopaColors.inkMuted;
    final background = dark ? DopaColors.night : DopaColors.cream;
    final raised = dark ? DopaColors.nightRaised : DopaColors.creamRaised;
    final primary = dark ? DopaColors.nightSage : DopaColors.sageDeep;
    final soft = dark ? DopaColors.nightSageSoft : DopaColors.sageSoft;
    final scheme =
        ColorScheme.fromSeed(
          seedColor: primary,
          brightness: dark ? Brightness.dark : Brightness.light,
        ).copyWith(
          surface: background,
          onSurface: ink,
          onSurfaceVariant: muted,
          surfaceContainerLow: raised,
          surfaceContainer: raised,
          surfaceContainerHighest: soft,
          primary: primary,
          onPrimary: dark ? background : Colors.white,
          primaryContainer: soft,
          onPrimaryContainer: ink,
          secondary: primary,
          secondaryContainer: soft,
          onSecondaryContainer: ink,
          outline: Color(dark ? 0xFF829482 : 0xFF849287),
          outlineVariant: Color(dark ? 0xFF394A3E : 0xFFE3E8DF),
          error: Color(dark ? 0xFFF2AAA2 : 0xFFA23F3F),
        );
    TextStyle type(double size, double line, FontWeight weight) => TextStyle(
      fontFamily: 'Pretendard',
      fontSize: size,
      height: line / size,
      fontWeight: weight,
      color: ink,
    );
    final common = ButtonStyle(
      minimumSize: const WidgetStatePropertyAll(Size(48, 56)),
      padding: const WidgetStatePropertyAll(
        EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      ),
      shape: WidgetStatePropertyAll(
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      textStyle: WidgetStatePropertyAll(type(16, 22, FontWeight.w600)),
      animationDuration: DopaMotion.quick,
    );
    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      fontFamily: 'Pretendard',
      scaffoldBackgroundColor: background,
      visualDensity: VisualDensity.standard,
      materialTapTargetSize: MaterialTapTargetSize.padded,
      extensions: [
        DopaSurfaces(
          soft: soft,
          sunlight: Color(dark ? 0xFF4B422B : 0xFFF6E6B5),
          apricot: Color(dark ? 0xFF49362E : 0xFFF7E1D3),
          muted: muted,
        ),
      ],
      textTheme: TextTheme(
        displaySmall: type(30, 40, FontWeight.w600),
        displayMedium: type(
          48,
          56,
          FontWeight.w500,
        ).copyWith(fontFeatures: [const FontFeature.tabularFigures()]),
        headlineSmall: type(24, 34, FontWeight.w600),
        headlineMedium: type(30, 40, FontWeight.w600),
        titleLarge: type(20, 28, FontWeight.w600),
        titleMedium: type(16, 26, FontWeight.w600),
        titleSmall: type(14, 22, FontWeight.w600),
        bodyLarge: type(16, 26, FontWeight.w400),
        bodyMedium: type(16, 26, FontWeight.w400),
        bodySmall: type(14, 22, FontWeight.w400),
        labelLarge: type(16, 22, FontWeight.w600),
        labelMedium: type(14, 22, FontWeight.w500),
        labelSmall: type(12, 18, FontWeight.w500),
      ),
      appBarTheme: AppBarTheme(
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: dark ? Brightness.light : Brightness.dark,
          statusBarBrightness: dark ? Brightness.dark : Brightness.light,
          systemNavigationBarColor: background,
          systemNavigationBarIconBrightness: dark
              ? Brightness.light
              : Brightness.dark,
        ),
        backgroundColor: background,
        foregroundColor: ink,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: type(20, 28, FontWeight.w600),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: raised,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      ),
      filledButtonTheme: FilledButtonThemeData(style: common),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: common.copyWith(
          side: WidgetStateProperty.resolveWith(
            (s) => BorderSide(
              color: s.contains(WidgetState.disabled)
                  ? scheme.outlineVariant
                  : scheme.outline,
            ),
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: common.copyWith(
          minimumSize: const WidgetStatePropertyAll(Size(48, 48)),
        ),
      ),
      iconButtonTheme: const IconButtonThemeData(
        style: ButtonStyle(minimumSize: WidgetStatePropertyAll(Size(48, 48))),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: raised,
        contentPadding: const EdgeInsets.all(16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: scheme.outline),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: scheme.outline),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: primary, width: 2),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: raised,
        selectedColor: soft,
        side: BorderSide(color: scheme.outline),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: background,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        height: 72,
        indicatorColor: soft,
        labelTextStyle: WidgetStatePropertyAll(type(12, 18, FontWeight.w500)),
      ),
      dividerTheme: DividerThemeData(
        color: scheme.outlineVariant,
        thickness: 1,
      ),
    );
  }
}
