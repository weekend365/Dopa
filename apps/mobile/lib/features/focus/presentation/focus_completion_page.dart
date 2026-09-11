import 'package:dopa/app/theme/dopa_tokens.dart';
import 'package:dopa/app/presentation/dopa_components.dart';
import 'package:dopa/features/tree_companion/application/tree_companion_providers.dart';
import 'package:dopa/features/tree_companion/presentation/garden_artwork.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class FocusCompletionPage extends ConsumerWidget {
  const FocusCompletionPage({required this.data, super.key});
  final TreeCompletionViewData data;
  @override
  Widget build(BuildContext context, WidgetRef ref) => Scaffold(
    appBar: AppBar(title: const Text('집중을 마쳤어요')),
    body: SafeArea(
      child: ListView(
        padding: EdgeInsets.all(DopaSpacing.page(context)),
        children: [
          SizedBox(height: 220, child: GardenArtwork(progress: data.progress)),
          const SizedBox(height: 32),
          Text(
            '나를 위한 시간을 남겼어요.',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 16),
          Text(
            data.kind == TreeCompletionKind.alreadyCredited
                ? '집중한 기록을 남겼어요. 정원은 하루에 한 번 자라요.'
                : '오늘의 작은 시도 하나가 정원에 남았어요.',
          ),
          const SizedBox(height: 32),
          DopaActionButton(
            label: '여기서 마치기',
            onPressed: () => context.go('/today'),
          ),
          const SizedBox(height: 8),
          TextButton(
            onPressed: () => context.go('/insights/weekly'),
            child: const Text('내 기록 보기'),
          ),
        ],
      ),
    ),
  );
}
