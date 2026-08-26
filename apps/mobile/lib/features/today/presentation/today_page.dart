import 'package:dopa/app/presentation/dopa_destination_scaffold.dart';
import 'package:dopa/app/theme/dopa_tokens.dart';
import 'package:dopa/features/tree_companion/application/tree_companion_providers.dart';
import 'package:dopa/features/tree_companion/application/tree_feature_flags.dart';
import 'package:dopa/features/tree_companion/presentation/tree_hero_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class TodayPage extends ConsumerWidget {
  const TodayPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progress = ref.watch(treeProgressProvider);
    final attemptDays = ref.watch(experimentAttemptDaysProvider);
    final experimentLength = ref.watch(experimentLengthDaysProvider);
    final flags = ref.watch(treeFeatureFlagsProvider);

    final hero = flags.treeUiEnabled
        ? TreeHeroCard(
            progress: progress,
            experimentDays: attemptDays,
            experimentLength: experimentLength,
            onStartFocus: () => context.go('/focus'),
          )
        : ExperimentProgressCard(
            experimentDays: attemptDays,
            experimentLength: experimentLength,
            onStartFocus: () => context.go('/focus'),
          );

    return DopaDestinationScaffold(
      selectedIndex: 0,
      title: '오늘',
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          DopaSpacing.md,
          DopaSpacing.sm,
          DopaSpacing.md,
          DopaSpacing.xl,
        ),
        children: [
          hero,
          const SizedBox(height: DopaSpacing.md),
          Card(
            child: ListTile(
              contentPadding: const EdgeInsets.all(DopaSpacing.md),
              leading: const CircleAvatar(
                child: Icon(Icons.nightlight_outlined),
              ),
              title: const Text('다음 보호 시간'),
              subtitle: const Text('오늘 23:00 · 화면 밖 준비'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {},
            ),
          ),
        ],
      ),
    );
  }
}
