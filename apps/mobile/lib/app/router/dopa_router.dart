import 'package:dopa/features/auth/presentation/account_page.dart';
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
      GoRoute(path: '/today', builder: (context, state) => const TodayPage()),
      GoRoute(
        path: '/account',
        builder: (context, state) => const AccountPage(),
      ),
      GoRoute(
        path: '/focus',
        builder: (context, state) => const FocusSetupPage(),
        routes: [
          GoRoute(
            path: 'progress',
            builder: (context, state) => const FocusProgressPage(),
          ),
          GoRoute(
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
      GoRoute(
        path: '/insights/weekly',
        builder: (context, state) => const WeeklyReportPage(),
      ),
    ],
  );
  ref.onDispose(router.dispose);
  return router;
});
