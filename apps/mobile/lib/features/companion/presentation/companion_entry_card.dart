import 'package:dopa/app/theme/dopa_tokens.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class CompanionEntryCard extends StatelessWidget {
  const CompanionEntryCard({super.key});

  @override
  Widget build(BuildContext context) => Card(
    key: const ValueKey('companion-entry'),
    child: Padding(
      padding: const EdgeInsets.all(DopaSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('같이 시작하기', style: Theme.of(context).textTheme.labelLarge),
          const SizedBox(height: DopaSpacing.xs),
          Text(
            '해야 할 일이 있는데 시작이 어렵나요?',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: DopaSpacing.xs),
          const Text('작은 것 하나만 같이 해봐요.\n책상에 시작할 자리 만들기 · 무료'),
          const SizedBox(height: DopaSpacing.md),
          FilledButton(
            key: const ValueKey('companion-entry-start'),
            onPressed: () => context.push('/companion'),
            child: const Text('2분만 시작하기'),
          ),
          const SizedBox(height: DopaSpacing.xs),
          const Text('개발용 텍스트 안내 샘플', textAlign: TextAlign.center),
        ],
      ),
    ),
  );
}
