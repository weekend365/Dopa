import 'package:dopa/app/presentation/dopa_destination_scaffold.dart';
import 'package:dopa/app/theme/dopa_tokens.dart';
import 'package:dopa/features/experiment/application/daily_check_in_controller.dart';
import 'package:dopa/features/tree_companion/application/tree_companion_providers.dart';
import 'package:dopa/features/tree_companion/application/tree_feature_flags.dart';
import 'package:dopa/features/tree_companion/presentation/tree_hero_card.dart';
import 'package:dopa_domain/dopa_domain.dart';
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
    final todaysCheckIn = ref.watch(todaysCheckInProvider);

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
      actions: [
        IconButton(
          key: const ValueKey('today-account'),
          tooltip: '계정',
          icon: const Icon(Icons.person_outline),
          onPressed: () => context.push('/account'),
        ),
      ],
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
          _TodayCheckInCard(checkIn: todaysCheckIn),
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

class _TodayCheckInCard extends ConsumerWidget {
  const _TodayCheckInCard({required this.checkIn});

  final DailyCheckIn? checkIn;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final answered = checkIn != null;
    return Card(
      key: const ValueKey('today-check-in'),
      child: Padding(
        padding: const EdgeInsets.all(DopaSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              answered ? '오늘의 체크인을 남겨 두었어요.' : '오늘 사용은 내 의도와 맞았나요?',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            if (!answered) ...[
              const SizedBox(height: DopaSpacing.md),
              Wrap(
                spacing: DopaSpacing.xs,
                runSpacing: DopaSpacing.xs,
                children: [
                  OutlinedButton(
                    key: const ValueKey('today-check-in-yes'),
                    onPressed: () => ref
                        .read(dailyCheckInControllerProvider.notifier)
                        .record(IntentionAlignment.yes),
                    child: const Text('맞았어요'),
                  ),
                  OutlinedButton(
                    key: const ValueKey('today-check-in-no'),
                    onPressed: () => ref
                        .read(dailyCheckInControllerProvider.notifier)
                        .record(IntentionAlignment.no),
                    child: const Text('아니었어요'),
                  ),
                  OutlinedButton(
                    key: const ValueKey('today-check-in-skipped'),
                    onPressed: () => ref
                        .read(dailyCheckInControllerProvider.notifier)
                        .record(IntentionAlignment.skipped),
                    child: const Text('건너뛰기'),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
