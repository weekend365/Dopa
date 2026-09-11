import 'package:dopa/app/theme/dopa_tokens.dart';

import 'dart:async';

import 'package:dopa/app/presentation/dopa_components.dart';
import 'package:dopa/features/tree_companion/presentation/garden_artwork.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class RestPage extends StatefulWidget {
  const RestPage({this.clock, super.key});
  final DateTime Function()? clock;
  @override
  State<RestPage> createState() => _RestPageState();
}

class _RestPageState extends State<RestPage> with WidgetsBindingObserver {
  DateTime? started;
  Timer? timer;
  bool finished = false;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  void start() {
    setState(() => started = (widget.clock ?? DateTime.now)());
    timer = Timer(const Duration(minutes: 1), check);
  }

  void check() {
    if (mounted &&
        started != null &&
        (widget.clock ?? DateTime.now)().difference(started!) >=
            const Duration(minutes: 1)) {
      setState(() => finished = true);
      timer?.cancel();
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) check();
  }

  @override
  void dispose() {
    timer?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('1분 쉬어가기')),
    body: SafeArea(
      child: ListView(
        padding: EdgeInsets.all(DopaSpacing.page(context)),
        children: [
          const SizedBox(height: 180, child: GardenArtwork()),
          const SizedBox(height: 32),
          Text(
            finished
                ? '조금 더 쉬어도 괜찮아요.'
                : started == null
                ? '잠깐, 나에게 돌아오는 시간.'
                : '폰을 내려놓고\n잠깐 주변을 바라봐요.',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 16),
          Text(
            finished
                ? '준비가 되면 작은 일 하나를 함께 시작해봐요.'
                : '지금 무엇을 해내지 않아도 괜찮아요.\n알림이나 소리 없이 조용히 기다릴게요.',
          ),
          const SizedBox(height: 32),
          if (started == null)
            DopaActionButton(label: '1분 쉬기 시작', onPressed: start)
          else if (finished)
            DopaActionButton(
              label: '같이 시작하기',
              onPressed: () => context.go('/companion'),
            ),
          const SizedBox(height: 12),
          TextButton(
            onPressed: () => context.go('/today'),
            child: Text(started == null ? '오늘로 돌아가기' : '마치기'),
          ),
        ],
      ),
    ),
  );
}
