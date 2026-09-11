import 'package:dopa/app/theme/dopa_tokens.dart';
import 'package:dopa/app/presentation/dopa_components.dart';
import 'package:dopa/app/presentation/dopa_destination_scaffold.dart';
import 'package:dopa/core/persistence/dopa_database_providers.dart';
import 'package:dopa/features/companion/application/companion_controller.dart';
import 'package:dopa/features/experiment/application/daily_check_in_controller.dart';
import 'package:dopa/features/tree_companion/application/tree_companion_providers.dart';
import 'package:dopa/features/tree_companion/presentation/garden_artwork.dart';
import 'package:dopa_domain/dopa_domain.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class ActivityRecord {
  const ActivityRecord(this.id, this.kind, this.date, this.title, this.detail);
  final String id, kind, date, title, detail;
}

final activityRecordsProvider =
    StreamProvider.autoDispose<List<ActivityRecord>>((ref) {
      final db = ref.watch(dopaDatabaseProvider);
      return db
          .customSelect(
            """
    SELECT id, 'focus' AS kind, started_local_date AS day,
      intention AS title, status AS detail, duration_preset_minutes AS minutes,
      started_at_utc_micros AS timestamp FROM focus_sessions
    UNION ALL
    SELECT r.id, 'companion', r.started_local_date, '책상 한 칸 비우기',
      o.outcome, 0, r.started_at_utc_micros
    FROM companion_runs r INNER JOIN companion_outcomes o ON o.run_id = r.id
    ORDER BY timestamp DESC, id DESC
  """,
            readsFrom: {
              db.focusSessions,
              db.companionRuns,
              db.companionOutcomes,
            },
          )
          .watch()
          .map(
            (rows) => rows.map((r) {
              final kind = r.read<String>('kind'),
                  detail = r.read<String>('detail');
              final minutes = r.read<int>('minutes');
              return ActivityRecord(
                r.read<String>('id'),
                kind,
                r.read<String>('day'),
                r.read<String>('title').isEmpty
                    ? '나를 위한 집중'
                    : r.read<String>('title'),
                kind == 'companion'
                    ? switch (detail) {
                        'asPlanned' => '하려던 만큼 했어요',
                        'started' => '조금 시작했어요',
                        _ => '오늘은 어려웠어요',
                      }
                    : switch (detail) {
                        'completed' => '$minutes분 집중했어요',
                        'active' => '$minutes분 집중 · 진행 중',
                        'endedEarly' => '중간에 마쳤어요',
                        'cancelled' => '시작을 취소했어요',
                        _ => '이전 집중을 마쳤어요',
                      },
              );
            }).toList(),
          );
    });

class WeeklyReportPage extends ConsumerWidget {
  const WeeklyReportPage({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final records = ref.watch(activityRecordsProvider);
    final growth = ref.watch(treeProgressProvider);
    final checkIn = ref.watch(todaysCheckInProvider);
    final weekly = ref.watch(weeklyGrowthDaysProvider);
    return DopaDestinationScaffold(
      selectedIndex: 2,
      title: '나의 기록',
      body: ListView(
        padding: EdgeInsets.fromLTRB(
          DopaSpacing.page(context),
          8,
          DopaSpacing.page(context),
          32,
        ),
        children: [
          Row(
            children: [
              SizedBox(
                width: 88,
                height: 72,
                child: GardenArtwork(progress: growth),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '작은 시작이 쌓이는 곳',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    Text('함께 자란 ${growth.totalGrowthDays}일 · 이번 주 $weekly일'),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.auto_stories_outlined),
            title: const Text('나의 그림일기'),
            subtitle: const Text('사진과 짧은 글로 모아둔 일상'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push('/diary'),
          ),
          const SizedBox(height: 24),
          records.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, s) => DopaNotice(
              message: '기록을 불러오지 못했어요.',
              isError: true,
              onRetry: () => ref.invalidate(activityRecordsProvider),
            ),
            data: (items) => items.isEmpty
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const DopaNotice(message: '아직 기록이 없어요.\n작은 시작부터 남겨봐요.'),
                      TextButton(
                        onPressed: () => context.go('/companion'),
                        child: const Text('같이 시작하기'),
                      ),
                    ],
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      for (var i = 0; i < items.length; i++) ...[
                        if (i == 0 || items[i].date != items[i - 1].date)
                          Padding(
                            padding: const EdgeInsets.only(top: 16, bottom: 8),
                            child: Text(
                              items[i].date,
                              style: Theme.of(context).textTheme.titleSmall,
                            ),
                          ),
                        DopaRecordRow(
                          title: items[i].title,
                          subtitle: items[i].detail,
                          icon: items[i].kind == 'focus'
                              ? Icons.timer_outlined
                              : Icons.spa_outlined,
                          onDelete: items[i].kind == 'companion'
                              ? () => delete(context, ref, items[i].id)
                              : null,
                        ),
                        const Divider(height: 1),
                      ],
                    ],
                  ),
          ),
          const SizedBox(height: 32),
          Text(
            checkIn == null ? '오늘 사용은 내 의도와 맞았나요?' : '오늘의 체크인을 남겨두었어요.',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          if (checkIn == null) ...[
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final entry in const {
                  IntentionAlignment.yes: '맞았어요',
                  IntentionAlignment.no: '아니었어요',
                  IntentionAlignment.skipped: '건너뛰기',
                }.entries)
                  OutlinedButton(
                    onPressed: () async {
                      try {
                        await ref
                            .read(dailyCheckInControllerProvider.notifier)
                            .record(entry.key);
                      } on Object {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('체크인을 저장하지 못했어요.')),
                          );
                        }
                      }
                    },
                    child: Text(entry.value),
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Future<void> delete(BuildContext context, WidgetRef ref, String id) async {
    final yes = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('생활 기록을 삭제할까요?'),
        content: const Text('상세 행동 기록은 삭제돼요. 이미 쌓인 성장일은 내용 없는 정원 기록으로 남아요.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('취소'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('삭제'),
          ),
        ],
      ),
    );
    if (yes != true) return;
    try {
      await ref.read(companionRepositoryProvider).deleteRecord(id);
      ref.invalidate(companionHistoryProvider);
    } on Object {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('삭제하지 못했어요. 다시 시도해 주세요.')));
      }
    }
  }
}
