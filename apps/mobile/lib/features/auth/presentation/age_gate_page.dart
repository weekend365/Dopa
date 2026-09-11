import 'package:dopa/features/auth/application/auth_providers.dart';
import 'package:dopa/features/auth/presentation/auth_chrome.dart';
import 'package:dopa_domain/dopa_domain.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AgeGatePage extends ConsumerStatefulWidget {
  const AgeGatePage({super.key});

  @override
  ConsumerState<AgeGatePage> createState() => _AgeGatePageState();
}

class _AgeGatePageState extends ConsumerState<AgeGatePage> {
  final _controller = TextEditingController();
  String? _error;
  bool _busy = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_busy) return;
    try {
      final date = LocalDate.parse(_controller.text.trim());
      _controller.clear();
      setState(() {
        _error = null;
        _busy = true;
      });
      await ref.read(authControllerProvider.notifier).attestAge(date);
    } on FormatException {
      if (mounted) setState(() => _error = 'YYYY-MM-DD 형식으로 입력해 주세요.');
    } on ArgumentError {
      if (mounted) setState(() => _error = '유효한 날짜를 입력해 주세요.');
    } on Object {
      if (mounted) setState(() => _error = '저장하지 못했어요. 다시 시도해 주세요.');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AuthScaffold(
      title: '나이 확인',
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Dopa는 만 14세 이상만 사용할 수 있어요. 생년월일은 나이 확인 직후 기기에서 삭제되며 서버로 보내지 않습니다.',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: 24),
          TextField(
            key: const ValueKey('age-gate-birthdate'),
            controller: _controller,
            keyboardType: TextInputType.number,
            inputFormatters: [
              TextInputFormatter.withFunction((oldValue, newValue) {
                final digits = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');
                if (digits.length > 8) return oldValue;
                final text =
                    '${digits.substring(0, digits.length.clamp(0, 4))}'
                    '${digits.length > 4 ? '-${digits.substring(4, digits.length.clamp(4, 6))}' : ''}'
                    '${digits.length > 6 ? '-${digits.substring(6)}' : ''}';
                return TextEditingValue(
                  text: text,
                  selection: TextSelection.collapsed(offset: text.length),
                );
              }),
            ],
            decoration: InputDecoration(
              labelText: '생년월일',
              hintText: 'YYYY-MM-DD',
              helperText: '예: 2000-01-01',
              errorText: _error,
            ),
            onSubmitted: (_) => _submit(),
          ),
          const SizedBox(height: 24),
          FilledButton(
            key: const ValueKey('age-gate-continue'),
            onPressed: _busy ? null : _submit,
            child: const Text('나이 확인'),
          ),
        ],
      ),
    );
  }
}
