import 'package:dopa/app/theme/dopa_tokens.dart';
import 'package:dopa/app/presentation/dopa_components.dart';
import 'package:dopa/app/presentation/dopa_destination_scaffold.dart';
import 'package:dopa/core/persistence/dopa_database_providers.dart';
import 'package:dopa/features/companion/application/companion_controller.dart';
import 'package:dopa/features/diary/application/diary_controller.dart';
import 'package:dopa/features/experiment/application/daily_check_in_controller.dart';
import 'package:dopa/features/tree_companion/application/tree_companion_providers.dart';
import 'package:dopa/features/tree_companion/presentation/garden_artwork.dart';
import 'package:dopa_domain/dopa_domain.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class ActivityRecord {
  const ActivityRecord(
    this.id,
    this.kind,
    this.date,
    this.title,
    this.detail, {
    this.route,
  });
  final String id, kind, date, title, detail;
  final String? route;
}

final activityRecordsProvider =
    StreamProvider.autoDispose<List<ActivityRecord>>((ref) {
      final db = ref.watch(dopaDatabaseProvider);
      return db
          .customSelect(
            """
    SELECT id, 'focus' AS kind, started_local_date AS day,
      intention AS title, status AS detail, duration_preset_minutes AS minutes,
      started_at_utc_micros AS timestamp, 0 AS version FROM focus_sessions
    UNION ALL
    SELECT r.id, 'companion', r.started_local_date, r.content_id,
      COALESCE(o.outcome, 'pending'), 0, r.started_at_utc_micros, r.content_version
    FROM companion_runs r LEFT JOIN companion_outcomes o ON o.run_id = r.id
    UNION ALL
    SELECT id, 'diary', local_date, '기억하고 싶은 순간', body, 0, created_at_utc_micros, 0
    FROM photo_diaries
    ORDER BY day DESC, timestamp DESC, id DESC, kind DESC
  """,
            readsFrom: {
              db.focusSessions,
              db.companionRuns,
              db.companionOutcomes,
              db.photoDiaries,
            },
          )
          .watch()
          .map(
            (rows) => rows.map((r) {
              final kind = r.read<String>('kind'),
                  detail = r.read<String>('detail');
              final minutes = r.read<int>('minutes');
              final title = r.read<String>('title');
              return ActivityRecord(
                r.read<String>('id'),
                kind,
                r.read<String>('day'),
                kind == 'companion'
                    ? companionContentTitle(title, r.read<int>('version'))
                    : title.isEmpty
                    ? '나를 위한 집중'
                    : title,
                kind == 'diary'
                    ? detail.isEmpty
                          ? '사진 한 장으로 남긴 하루'
                          : detail
                    : kind == 'companion'
                    ? switch (detail) {
                        'asPlanned' => '하려던 만큼 했어요',
                        'started' => '조금 시작했어요',
                        'pending' => '결과를 아직 남기지 않았어요 · 이어하기',
                        _ => '오늘은 어려웠어요',
                      }
                    : switch (detail) {
                        'completed' => '$minutes분 집중했어요',
                        'active' => '$minutes분 집중 · 진행 중',
                        'endedEarly' => '중간에 마쳤어요',
                        'cancelled' => '시작을 취소했어요',
                        _ => '이전 집중을 마쳤어요',
                      },
                route: kind == 'diary'
                    ? '/diary/entry/${r.read<String>('id')}'
                    : kind == 'companion' && detail == 'pending'
                    ? '/companion'
                    : kind == 'focus' && detail == 'active'
                    ? '/focus'
                    : null,
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
      body: CustomScrollView(
        slivers: [
          SliverPadding(
            padding: EdgeInsets.fromLTRB(
              DopaSpacing.page(context),
              8,
              DopaSpacing.page(context),
              8,
            ),
            sliver: SliverList.list(
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
                            '하루를 돌아봐요',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const Text('해본 일과 남겨둔 순간들'),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                TextButton.icon(
                  key: const ValueKey('records-diary'),
                  onPressed: () => context.push('/diary/new'),
                  icon: const Icon(Icons.add_photo_alternate_outlined),
                  label: const Text('오늘 기억하고 싶은 순간 남기기'),
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
          SliverPadding(
            padding: EdgeInsets.symmetric(
              horizontal: DopaSpacing.page(context),
            ),
            sliver: records.when(
              loading: () => const SliverToBoxAdapter(
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (e, s) => SliverToBoxAdapter(
                child: DopaNotice(
                  message: '기록을 불러오지 못했어요.',
                  isError: true,
                  onRetry: () => ref.invalidate(activityRecordsProvider),
                ),
              ),
              data: (items) => items.isEmpty
                  ? SliverToBoxAdapter(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const DopaNotice(
                            message: '아직 남긴 기록이 없어요.\n작은 일을 시작하거나, 기억하고 싶은 장면 하나를 남겨봐요.',
                          ),
                          TextButton(
                            onPressed: () => context.go('/companion'),
                            child: const Text('같이 시작하기'),
                          ),
                        ],
                      ),
                    )
                  : SliverList.builder(
                      itemCount: items.length,
                      itemBuilder: (context, i) => Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          if (i == 0 || items[i].date != items[i - 1].date)
                            Padding(
                              padding: const EdgeInsets.only(
                                top: 16,
                                bottom: 8,
                              ),
                              child: Text(
                                items[i].date,
                                style: Theme.of(context).textTheme.titleSmall,
                              ),
                            ),
                          if (items[i].kind == 'diary')
                            _DiaryRecord(record: items[i])
                          else if (items[i].route != null)
                            ListTile(
                              contentPadding: EdgeInsets.zero,
                              leading: Icon(
                                items[i].kind == 'focus'
                                    ? Icons.timer_outlined
                                    : Icons.spa_outlined,
                              ),
                              title: Text(items[i].title),
                              subtitle: Text(items[i].detail),
                              trailing: const Icon(Icons.chevron_right),
                              onTap: () => context.push(items[i].route!),
                            )
                          else
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
                      ),
                    ),
            ),
          ),
          SliverPadding(
            padding: EdgeInsets.all(DopaSpacing.page(context)),
            sliver: SliverList.list(
              children: [
                const SizedBox(height: 32),
                Text(
                  '이번 주 작은 시작 $weekly일 · 정원과 함께한 ${growth.totalGrowthDays}일',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: 24),
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
                                  const SnackBar(
                                    content: Text('체크인을 저장하지 못했어요.'),
                                  ),
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
          ),
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

class _DiaryRecord extends ConsumerWidget {
  const _DiaryRecord({required this.record});
  final ActivityRecord record;

  @override
  Widget build(BuildContext context, WidgetRef ref) => InkWell(
    key: ValueKey('record-diary-${record.id}'),
    onTap: () => context.push(record.route!),
    child: Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: SizedBox(
              height: 160,
              child: ref
                  .watch(diaryPreviewProvider(record.id))
                  .when(
                    loading: () =>
                        const Center(child: Icon(Icons.photo_outlined)),
                    error: (e, s) =>
                        const Center(child: Text('사진은 일기에서 다시 확인해요.')),
                    data: (bytes) => bytes == null
                        ? const Center(child: Icon(Icons.photo_outlined))
                        : Image.memory(
                            bytes,
                            fit: BoxFit.cover,
                            cacheWidth: 640,
                            semanticLabel: '${record.date} 기억하고 싶은 순간',
                            errorBuilder: (_, e, s) =>
                                const Center(child: Icon(Icons.photo_outlined)),
                          ),
                  ),
            ),
          ),
          const SizedBox(height: 12),
          Text(record.title, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 4),
          Text(record.detail, maxLines: 3, overflow: TextOverflow.ellipsis),
          const SizedBox(height: 8),
          const Text('일기 열기'),
        ],
      ),
    ),
  );
}
