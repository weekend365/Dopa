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
  var _busy = false;

  Future<void> _accept() async {
    setState(() => _busy = true);
    try {
      await ref.read(authControllerProvider.notifier).acceptConsent();
    } finally {
      if (mounted) {
        setState(() => _busy = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AuthScaffold(
      title: '로컬 저장 동의',
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            '집중 세션, 선택한 앱, 체크인, 나무는 이 기기 안에만 저장됩니다. 서버로 보내지 않으며, 로그아웃이나 계정 삭제 시 함께 지웁니다.',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: 24),
          FilledButton(
            key: const ValueKey('consent-accept'),
            onPressed: _busy ? null : _accept,
            child: Text(_busy ? '준비 중' : '동의하고 시작'),
          ),
        ],
      ),
    );
  }
}
