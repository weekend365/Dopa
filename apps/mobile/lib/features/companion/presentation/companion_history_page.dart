import 'package:dopa/app/theme/dopa_tokens.dart';
import 'package:dopa/features/companion/application/companion_controller.dart';
import 'package:dopa/features/companion/presentation/companion_copy.dart';
import 'package:dopa_domain/dopa_domain.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class CompanionHistoryPage extends ConsumerStatefulWidget {
  const CompanionHistoryPage({super.key});

  @override
  ConsumerState<CompanionHistoryPage> createState() =>
      _CompanionHistoryPageState();
}

class _CompanionHistoryPageState extends ConsumerState<CompanionHistoryPage> {
  bool _deleting = false;
  bool _deleteFailed = false;

  Future<void> _delete(CompanionOutcomeRecord record) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('이 생활 행동 기록을 삭제할까요?'),
        content: const Text('삭제한 기록은 되돌릴 수 없어요.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('삭제'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    setState(() {
      _deleting = true;
      _deleteFailed = false;
    });
    try {
      await ref.read(companionRepositoryProvider).deleteRecord(record.run.id);
      if (mounted) ref.invalidate(companionHistoryProvider);
    } on Object {
      if (mounted) setState(() => _deleteFailed = true);
    } finally {
      if (mounted) setState(() => _deleting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!ref.watch(companionSampleEnabledProvider)) {
      return const Scaffold(body: Center(child: Text('아직 공개되지 않은 안내예요.')));
    }
    final history = ref.watch(companionHistoryProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text('생활 행동 기록'),
        leading: IconButton(
          tooltip: '오늘로 돌아가기',
          onPressed: () => context.go('/today'),
          icon: const Icon(Icons.arrow_back),
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(DopaSpacing.lg),
          children: [
            const Text('내가 직접 남긴 결과예요.\n개발용 텍스트 샘플 · 최근 50개'),
            const SizedBox(height: DopaSpacing.md),
            if (_deleteFailed)
              Semantics(
                liveRegion: true,
                child: const Text('삭제하지 못했어요. 다시 시도해주세요.'),
              ),
            ...history.when(
              loading: () => [const Center(child: CircularProgressIndicator())],
              error: (error, stack) => [
                const Text('기록을 불러오지 못했어요.'),
                OutlinedButton(
                  onPressed: () => ref.invalidate(companionHistoryProvider),
                  child: const Text('다시 불러오기'),
                ),
              ],
              data: (records) => records.isEmpty
                  ? [const Text('아직 직접 남긴 생활 행동 기록이 없어요.')]
                  : records
                        .expand(
                          (record) => [
                            Card(
                              child: Padding(
                                padding: const EdgeInsets.all(DopaSpacing.md),
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: [
                                    Text(
                                      record.run.contentId ==
                                              deskCompanionContent.id
                                          ? deskCompanionContent.title
                                          : '생활 안내',
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleMedium,
                                    ),
                                    const SizedBox(height: DopaSpacing.xs),
                                    Text(
                                      '${record.confirmedLocalDate} · 직접 확인',
                                    ),
                                    const SizedBox(height: DopaSpacing.sm),
                                    Text(
                                      companionOutcomeLabel(record.outcome),
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyLarge,
                                    ),
                                    TextButton(
                                      onPressed: _deleting
                                          ? null
                                          : () => _delete(record),
                                      child: const Text('기록 삭제'),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: DopaSpacing.md),
                          ],
                        )
                        .toList(),
            ),
          ],
        ),
      ),
    );
  }
}
