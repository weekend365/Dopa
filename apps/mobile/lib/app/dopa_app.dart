import 'package:dopa/app/router/dopa_router.dart';
import 'package:dopa/app/theme/dopa_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final themeModeProvider = StateProvider<ThemeMode>((ref) => ThemeMode.system);

/// Authenticated app shell mounted by DopaRoot after login and consent.
///
/// Local wellbeing data is created only after those gates succeed.
class DopaApp extends ConsumerWidget {
  const DopaApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(dopaRouterProvider);
    final themeMode = ref.watch(themeModeProvider);

    return MaterialApp.router(
      title: 'Dopa',
      debugShowCheckedModeBanner: false,
      theme: DopaTheme.light,
      darkTheme: DopaTheme.dark,
      themeMode: themeMode,
      locale: const Locale('ko'),
      supportedLocales: const [Locale('ko'), Locale('en')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      routerConfig: router,
    );
  }
}
