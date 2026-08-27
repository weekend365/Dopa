import 'package:dopa/features/auth/application/auth_providers.dart';
import 'package:dopa/features/auth/presentation/auth_chrome.dart';
import 'package:dopa_domain/dopa_domain.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SignInPage extends ConsumerWidget {
  const SignInPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authControllerProvider);
    final error = switch (auth.error) {
      'cancelled' => '로그인을 취소했어요. 계정 없이 사용 기록은 만들지 않습니다.',
      'offline' => '오프라인에서는 로그인할 수 없어요. 연결 후 다시 시도해 주세요.',
      String code => '로그인에 실패했어요 ($code). 사용 기록은 저장되지 않았습니다.',
      null => null,
    };

    return AuthScaffold(
      title: '로그인',
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Apple 또는 Google 계정으로 로그인한 뒤에만 나무와 집중 기록을 이 기기에 만들어요.',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          if (error != null) ...[
            const SizedBox(height: 16),
            Text(
              error,
              key: const ValueKey('sign-in-error'),
              style: Theme.of(context).textTheme.bodyMedium
                  ?.copyWith(color: Theme.of(context).colorScheme.error),
            ),
          ],
          const SizedBox(height: 24),
          FilledButton(
            key: const ValueKey('sign-in-apple'),
            onPressed: () => ref
                .read(authControllerProvider.notifier)
                .signIn(SignInProvider.apple),
            child: const Text('Apple로 계속'),
          ),
          const SizedBox(height: 12),
          OutlinedButton(
            key: const ValueKey('sign-in-google'),
            onPressed: () => ref
                .read(authControllerProvider.notifier)
                .signIn(SignInProvider.google),
            child: const Text('Google로 계속'),
          ),
        ],
      ),
    );
  }
}
