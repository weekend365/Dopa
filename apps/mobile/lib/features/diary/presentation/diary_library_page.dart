import 'package:dopa/app/theme/dopa_tokens.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../application/diary_controller.dart';

class DiaryLibraryPage extends ConsumerWidget {
  const DiaryLibraryPage({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) => Scaffold(
    appBar: AppBar(title: const Text('남겨둔 순간들')),
    body: SafeArea(
      child: ref
          .watch(diariesProvider)
          .when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, s) => Center(
              child: TextButton(
                onPressed: () => ref.invalidate(diariesProvider),
                child: const Text('기록 다시 불러오기'),
              ),
            ),
            data: (items) => ListView.builder(
              padding: EdgeInsets.all(DopaSpacing.page(context)),
              itemCount: items.length + 1,
              itemBuilder: (context, index) {
                if (index == 0) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        '사진과 한 줄로\n돌아보는 내 하루',
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 12),
                      const Text('특별하지 않아도 괜찮아요. 기억하고 싶은 순간을 모아봐요.'),
                      const SizedBox(height: 24),
                      FilledButton.icon(
                        onPressed: () => context.push('/diary/new'),
                        icon: const Icon(Icons.add_photo_alternate_outlined),
                        label: const Text('오늘의 한 장 남기기'),
                      ),
                      if (items.isEmpty)
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 32),
                          child: Text('아직 남긴 일기가 없어요.\n사진 한 장으로 시작해도 좋아요.'),
                        ),
                      const SizedBox(height: 24),
                    ],
                  );
                }
                final entry = items[index - 1];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 24),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(24),
                    onTap: () => context.push('/diary/entry/${entry.id}'),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(24),
                          child: SizedBox(
                            height: 220,
                            child: Consumer(
                              builder: (context, previewRef, child) => previewRef
                                  .watch(diaryPreviewProvider(entry.id))
                                  .when(
                                    loading: () => const Center(
                                      child: Icon(Icons.photo_outlined),
                                    ),
                                    error: (e, s) => const Center(
                                      child: Icon(Icons.photo_outlined),
                                    ),
                                    data: (bytes) => bytes == null
                                        ? const SizedBox()
                                        : Image.memory(
                                            bytes,
                                            fit: BoxFit.cover,
                                            cacheWidth: 640,
                                            semanticLabel:
                                                '${entry.localDate}의 ${entry.hasArtwork ? 'Dopa 그림' : '사진'}',
                                            errorBuilder: (_, e, s) =>
                                                const Center(
                                                  child: Icon(
                                                    Icons.photo_outlined,
                                                    size: 40,
                                                  ),
                                                ),
                                          ),
                                  ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          entry.localDate,
                          style: Theme.of(context).textTheme.labelLarge,
                        ),
                        if (entry.body.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(
                              entry.body,
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        if ([
                          'submitting',
                          'queued',
                          'processing',
                        ].contains(entry.status))
                          const Text('그림을 준비하고 있어요 · 열어서 확인'),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
    ),
  );
}
