import 'package:dopa/app/theme/dopa_tokens.dart';
import 'package:dopa/core/app_environment.dart';
import 'package:dopa/features/auth/application/auth_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class AccountPage extends ConsumerStatefulWidget {
  const AccountPage({super.key});
  @override
  ConsumerState<AccountPage> createState() => _AccountPageState();
}

class _AccountPageState extends ConsumerState<AccountPage> {
  bool busy = false;
  String? error;
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('설정')),
    body: SafeArea(
      child: ListView(
        padding: EdgeInsets.all(DopaSpacing.page(context)),
        children: [
          Text('나의 작은 공간', style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 16),
          const Text(
            '가입 없이 사용 중이에요.\n활동·정원·일기는 이 기기에 저장돼요. 그림 변환에 동의한 사진만 외부 AI 서비스로 전송해요.',
          ),
          const SizedBox(height: 24),
          const Divider(),
          const SizedBox(height: 16),
          const Text(
            '휴식에는 점수도, 따라잡아야 할 목표도 없어요.\n집중하거나 생활 행동을 시작한 날에는 하루 한 번 정원이 자라요.',
          ),
          const SizedBox(height: 24),
          if (AppEnvironment.current == DopaEnvironment.dev)
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('디자인 시스템'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => context.push('/design'),
            ),
          TextButton(
            key: const ValueKey('account-delete'),
            onPressed: busy ? null : confirm,
            child: Text(busy ? '삭제 중…' : '이 기기의 기록 모두 삭제'),
          ),
          if (error != null) Semantics(liveRegion: true, child: Text(error!)),
          const Text('앱 삭제·기기 변경 후에는 기록을 복원할 수 없어요.'),
        ],
      ),
    ),
  );
  Future<void> confirm() async {
    final yes = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('모든 기록을 삭제할까요?'),
        content: const Text(
          '집중, 생활 행동, 체크인, 정원과 사진 일기를 모두 삭제해요. 그림 변환을 사용했다면 서버의 임시 사진도 삭제하며 연결이 필요해요. 이 작업은 되돌릴 수 없어요.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('취소'),
          ),
          FilledButton(
            key: const ValueKey('account-delete-confirm'),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('모두 삭제'),
          ),
        ],
      ),
    );
    if (yes != true || !mounted) return;
    setState(() => busy = true);
    try {
      await ref.read(authControllerProvider.notifier).deleteAccount();
    } on Object {
      if (mounted) setState(() => error = '삭제하지 못했어요. 다시 시도해 주세요.');
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }
}
