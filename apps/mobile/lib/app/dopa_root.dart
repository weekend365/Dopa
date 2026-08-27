import 'package:dopa/app/dopa_app.dart';
import 'package:dopa/features/auth/application/auth_controller.dart';
import 'package:dopa/features/auth/application/auth_providers.dart';
import 'package:dopa/features/auth/presentation/age_gate_page.dart';
import 'package:dopa/features/auth/presentation/auth_chrome.dart';
import 'package:dopa/features/auth/presentation/consent_page.dart';
import 'package:dopa/features/auth/presentation/sign_in_page.dart';
import 'package:dopa/features/auth/presentation/under14_blocked_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Outer account gate. [DopaApp] is the authenticated shell.
class DopaRoot extends ConsumerWidget {
  const DopaRoot({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authControllerProvider);
    return switch (auth.phase) {
      AuthPhase.loading => const AuthMaterialApp(
        home: Scaffold(body: Center(child: CircularProgressIndicator())),
      ),
      AuthPhase.needsAge => const AuthMaterialApp(home: AgeGatePage()),
      AuthPhase.blockedUnder14 => const AuthMaterialApp(
        home: Under14BlockedPage(),
      ),
      AuthPhase.needsSignIn => const AuthMaterialApp(home: SignInPage()),
      AuthPhase.needsConsent => const AuthMaterialApp(home: ConsentPage()),
      AuthPhase.ready => const DopaApp(),
    };
  }
}
