import 'package:dopa/app/theme/dopa_tokens.dart';
import 'package:dopa/features/auth/application/auth_providers.dart';
import 'package:dopa_domain/dopa_domain.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AccountPage extends ConsumerWidget {
  const AccountPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(authControllerProvider).session;
    final providerLabel = switch (session?.provider) {
      SignInProvider.apple => 'Apple',
      SignInProvider.google => 'Google',
      null => '없음',
    };

    return Scaffold(
      appBar: AppBar(
        title: const Text('계정'),
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(DopaSpacing.lg),
          children: [
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('로그인'),
              subtitle: Text(providerLabel),
            ),
            const SizedBox(height: DopaSpacing.md),
            OutlinedButton(
              key: const ValueKey('account-logout'),
              onPressed: () =>
                  ref.read(authControllerProvider.notifier).logOut(),
              child: const Text('로그아웃'),
            ),
            const SizedBox(height: DopaSpacing.sm),
            TextButton(
              key: const ValueKey('account-delete'),
              onPressed: () => _confirmDelete(context, ref),
              child: const Text('계정 삭제'),
            ),
            const SizedBox(height: DopaSpacing.sm),
            Text(
              '로그아웃과 계정 삭제는 이 기기의 나무, 집중 세션, 성장 원장을 지웁니다.',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('계정을 삭제할까요?'),
        content: const Text('이 기기의 나무와 집중 기록이 삭제되고 처음 나이 확인부터 다시 시작됩니다.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('취소'),
          ),
          FilledButton(
            key: const ValueKey('account-delete-confirm'),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('삭제'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await ref.read(authControllerProvider.notifier).deleteAccount();
    }
  }
}
