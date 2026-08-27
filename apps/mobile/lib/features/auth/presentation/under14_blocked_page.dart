import 'package:dopa/features/auth/application/auth_providers.dart';
import 'package:dopa/features/auth/presentation/auth_chrome.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class Under14BlockedPage extends ConsumerWidget {
  const Under14BlockedPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AuthScaffold(
      title: '지금은 가입할 수 없어요',
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            '만 14세가 되면 다시 나이를 확인할 수 있어요. 계정을 만들지 않았고 사용 기록도 저장하지 않았습니다.',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: 24),
          FilledButton(
            key: const ValueKey('age-blocked-retry'),
            onPressed: () {
              ref.read(authControllerProvider.notifier).retryAgeGate();
            },
            child: const Text('다시 확인'),
          ),
        ],
      ),
    );
  }
}
