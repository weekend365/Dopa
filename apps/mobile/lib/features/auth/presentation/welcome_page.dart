import 'package:dopa/features/auth/presentation/age_gate_page.dart';
import 'package:dopa/features/auth/presentation/auth_chrome.dart';
import 'package:dopa/features/tree_companion/presentation/garden_artwork.dart';
import 'package:flutter/material.dart';

class WelcomePage extends StatefulWidget {
  const WelcomePage({super.key});
  @override
  State<WelcomePage> createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage> {
  bool started = false;
  @override
  Widget build(BuildContext context) {
    if (started) return const AgeGatePage();
    return AuthScaffold(
      title: 'Dopa',
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 24),
          const SizedBox(height: 220, child: GardenArtwork()),
          const SizedBox(height: 32),
          Text(
            '조금 쉬고,\n다시 나의 하루로.',
            style: Theme.of(context).textTheme.displaySmall,
          ),
          const SizedBox(height: 16),
          const Text('잠깐 폰을 내려놓는 시간.\n미뤄둔 일을 함께 시작하는 작은 안내.'),
          const SizedBox(height: 32),
          FilledButton(
            key: const ValueKey('welcome-start'),
            onPressed: () => setState(() => started = true),
            child: const Text('나를 위한 시간 시작하기'),
          ),
          const SizedBox(height: 12),
          const Text(
            '가입 없이 시작해요. 기록은 이 기기에만 남아요.',
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
