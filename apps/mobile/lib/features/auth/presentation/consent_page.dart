import 'package:dopa/features/auth/application/auth_providers.dart';
import 'package:dopa/features/auth/presentation/auth_chrome.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ConsentPage extends ConsumerStatefulWidget {
  const ConsentPage({super.key});
  @override
  ConsumerState<ConsentPage> createState() => _ConsentPageState();
}

class _ConsentPageState extends ConsumerState<ConsentPage> {
  bool busy = false;
  String? error;
  Future<void> accept() async {
    setState(() => busy = true);
    try {
      await ref.read(authControllerProvider.notifier).acceptConsent();
      if (mounted && ref.read(authControllerProvider).error != null) {
        setState(() => error = '기록 공간을 준비하지 못했어요. 다시 시도해 주세요.');
      }
    } on Object {
      if (mounted) setState(() => error = '저장하지 못했어요. 다시 시도해 주세요.');
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  @override
  Widget build(BuildContext context) => AuthScaffold(
    title: '내 기록은 내 기기에',
    body: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 24),
        Text(
          '편안하게 시작할 수 있도록',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: 24),
        const Text('집중, 생활 행동, 체크인과 정원 기록을 이 기기에 저장해요. 계정 가입은 필요하지 않아요.'),
        const SizedBox(height: 16),
        const Text(
          '기록을 서버로 보내지 않아요. 설정에서 모두 삭제할 수 있어요. 앱을 삭제하거나 기기를 바꾸면 복원할 수 없어요.',
        ),
        const SizedBox(height: 16),
        const Text('기존 기록이 있다면 그대로 이어가요.'),
        const SizedBox(height: 32),
        if (error != null)
          Semantics(
            liveRegion: true,
            child: Text(
              error!,
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ),
        FilledButton(
          key: const ValueKey('consent-accept'),
          onPressed: busy ? null : accept,
          child: Text(busy ? '정원을 준비하고 있어요…' : '동의하고 시작하기'),
        ),
      ],
    ),
  );
}
