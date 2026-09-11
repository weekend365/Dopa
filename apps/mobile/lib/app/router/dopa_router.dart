import 'package:dopa/features/auth/presentation/account_page.dart';
import 'package:dopa/app/presentation/rest_page.dart';
import 'package:dopa/app/presentation/design_gallery_page.dart';
import 'package:dopa/core/app_environment.dart';
import 'package:dopa/features/companion/application/companion_controller.dart';
import 'package:dopa/features/companion/presentation/companion_page.dart';
import 'package:flutter/material.dart';
import 'package:dopa/features/focus/presentation/focus_completion_page.dart';
import 'package:dopa/features/focus/presentation/focus_progress_page.dart';
import 'package:dopa/features/focus/presentation/focus_setup_page.dart';
import 'package:dopa/features/insights/presentation/weekly_report_page.dart';
import 'package:dopa/features/today/presentation/today_page.dart';
import 'package:dopa/features/tree_companion/application/tree_companion_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

final dopaRouterProvider = Provider<GoRouter>((ref) {
  final router = GoRouter(
    initialLocation: '/today',
    routes: [
      _route(path: '/rest', builder: (context, state) => const RestPage()),
      _route(
        path: '/design',
        redirect: (context, state) =>
            AppEnvironment.isProduction ? '/today' : null,
        builder: (context, state) => const DesignGalleryPage(),
      ),
      _route(path: '/today', builder: (context, state) => const TodayPage()),
      _route(
        path: '/companion',
        redirect: (context, state) =>
            ref.read(companionSampleEnabledProvider) ? null : '/today',
        builder: (context, state) => const CompanionPage(),
        routes: [
          _route(
            path: 'history',
            redirect: (context, state) => '/insights/weekly',
          ),
        ],
      ),
      _route(
        path: '/account',
        builder: (context, state) => const AccountPage(),
      ),
      _route(
        path: '/focus',
        builder: (context, state) => const FocusSetupPage(),
        routes: [
          _route(
            path: 'progress',
            builder: (context, state) => const FocusProgressPage(),
          ),
          _route(
            path: 'completion/:kind',
            builder: (context, state) => FocusCompletionPage(
              data: state.extra is TreeCompletionViewData
                  ? state.extra! as TreeCompletionViewData
                  : TreeCompletionViewData.forRoute(
                      state.pathParameters['kind'] ?? 'milestone',
                    ),
            ),
          ),
        ],
      ),
      _route(
        path: '/insights/weekly',
        builder: (context, state) => const WeeklyReportPage(),
      ),
    ],
  );
  ref.onDispose(router.dispose);
  return router;
});

GoRoute _route({
  required String path,
  Widget Function(BuildContext, GoRouterState)? builder,
  String? Function(BuildContext, GoRouterState)? redirect,
  List<RouteBase> routes = const [],
}) => GoRoute(
  path: path,
  redirect: redirect,
  routes: routes,
  pageBuilder: builder == null
      ? null
      : (context, state) => CustomTransitionPage<void>(
          key: state.pageKey,
          transitionDuration: MediaQuery.disableAnimationsOf(context)
              ? Duration.zero
              : const Duration(milliseconds: 240),
          reverseTransitionDuration: MediaQuery.disableAnimationsOf(context)
              ? Duration.zero
              : const Duration(milliseconds: 240),
          child: builder(context, state),
          transitionsBuilder: (context, animation, secondary, child) =>
              FadeTransition(opacity: animation, child: child),
        ),
);
