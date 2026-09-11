import 'package:dopa/app/presentation/dopa_destination_scaffold.dart';
import 'package:dopa/app/theme/dopa_tokens.dart';
import 'package:dopa/core/persistence/dopa_database_providers.dart';

import 'package:dopa/features/tree_companion/application/tree_companion_providers.dart';
import 'package:dopa/features/tree_companion/presentation/garden_artwork.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

final activeDestinationProvider = StreamProvider.autoDispose<String?>((ref) {
  final db = ref.watch(dopaDatabaseProvider);
  return db
      .customSelect(
        "SELECT '/focus' AS route, started_at_utc_micros AS stamp FROM focus_sessions WHERE status = 'active' "
        "UNION ALL SELECT '/companion', started_at_utc_micros FROM companion_runs WHERE active_slot = 1 ORDER BY stamp DESC LIMIT 1",
        readsFrom: {db.focusSessions, db.companionRuns},
      )
      .watch()
      .map((rows) => rows.isEmpty ? null : rows.first.read<String>('route'));
});

class TodayPage extends ConsumerWidget {
  const TodayPage({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final active = ref.watch(activeDestinationProvider);
    final destination = active.valueOrNull;
    return DopaDestinationScaffold(
      selectedIndex: 0,
      title: '틔움',
      actions: [
        IconButton(
          key: const ValueKey('today-account'),
          tooltip: '설정',
          onPressed: () => context.push('/account'),
          icon: const Icon(Icons.tune_rounded),
        ),
      ],
      body: ListView(
        padding: EdgeInsets.fromLTRB(
          DopaSpacing.page(context),
          8,
          DopaSpacing.page(context),
          32,
        ),
        children: [
          SizedBox(
            height: MediaQuery.textScalerOf(context).scale(16) > 24 ? 160 : 220,
            child: GardenArtwork(progress: ref.watch(treeProgressProvider)),
          ),
          const SizedBox(height: 24),
          Text(
            '잠깐 쉬어도,\n작게 시작해도 괜찮아요.',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            '지금 나에게 필요한 시간을 골라봐요.',
            style: Theme.of(context).textTheme.bodyMedium
                ?.copyWith(color: DopaSurfaces.of(context).muted),
          ),
          const SizedBox(height: 24),
          FilledButton.icon(
            key: const ValueKey('today-start'),
            onPressed: () => context.push(destination ?? '/companion'),
            icon: Icon(
              destination == null
                  ? Icons.wb_sunny_outlined
                  : Icons.play_arrow_rounded,
            ),
            label: Text(destination == null ? '같이 시작하기' : '이어서 하기'),
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            key: const ValueKey('today-rest'),
            onPressed: () => context.push('/rest'),
            icon: const Icon(Icons.spa_outlined),
            label: const Text('1분 쉬어가기'),
          ),
          const SizedBox(height: 8),
          TextButton(
            onPressed: () => context.push('/focus'),
            child: const Text('바로 집중하기'),
          ),
          if (active.hasError)
            TextButton(
              onPressed: () => ref.invalidate(activeDestinationProvider),
              child: const Text('이전 활동 다시 확인하기'),
            ),
          const SizedBox(height: 24),
          const Divider(),
          ListTile(
            key: const ValueKey('today-diary'),
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.photo_camera_outlined),
            title: const Text('오늘 기억하고 싶은 순간'),
            subtitle: const Text('사진과 한 줄로 하루를 돌아봐요.'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push('/diary/new'),
          ),
        ],
      ),
    );
  }
}
