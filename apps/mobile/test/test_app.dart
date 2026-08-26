import 'package:dopa/app/theme/dopa_theme.dart';
import 'package:flutter/material.dart';

class TestApp extends StatelessWidget {
  const TestApp({
    required this.home,
    this.brightness = Brightness.light,
    this.textScale = 1,
    this.disableAnimations = false,
    super.key,
  });

  final Widget home;
  final Brightness brightness;
  final double textScale;
  final bool disableAnimations;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: DopaTheme.light,
      darkTheme: DopaTheme.dark,
      themeMode: brightness == Brightness.dark
          ? ThemeMode.dark
          : ThemeMode.light,
      builder: (context, child) {
        final media = MediaQuery.of(context);
        return MediaQuery(
          data: media.copyWith(
            textScaler: TextScaler.linear(textScale),
            disableAnimations: disableAnimations,
          ),
          child: child!,
        );
      },
      home: home,
    );
  }
}
