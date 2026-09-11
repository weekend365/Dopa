import 'dart:async';
import 'dart:typed_data';

import 'package:dopa/app/theme/dopa_tokens.dart';
import 'package:dopa_local_storage/dopa_local_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../application/diary_controller.dart';

class DiaryPage extends ConsumerStatefulWidget {
  const DiaryPage({this.id, this.recoveredPhoto, super.key});
  final String? id;
  final Uint8List? recoveredPhoto;
  @override
  ConsumerState<DiaryPage> createState() => _DiaryPageState();
}

class _DiaryPageState extends ConsumerState<DiaryPage>
    with WidgetsBindingObserver {
  final text = TextEditingController();
  PhotoDiaryRow? entry;
  Uint8List? photo;
  late String day;
  String? error;
  bool loading = true, busy = false, dirty = false, original = false;
  bool? available;
  Timer? timer;
  DiaryController get controller => ref.read(diaryControllerProvider);
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    day = diaryDay(ref.read(diaryNowProvider)());
    photo = widget.recoveredPhoto;
    dirty = photo != null;
    unawaited(load());
    unawaited(checkService());
    timer = Timer.periodic(
      const Duration(seconds: 5),
      (_) => unawaited(refresh()),
    );
  }

  Future<void> checkService() async {
    try {
      final ready = await controller.api.available();
      if (mounted) setState(() => available = ready);
    } on Object {
      if (mounted) setState(() => available = false);
    }
  }

  Future<void> load() async {
    try {
      final item = widget.id == null
          ? await controller.repository.forDay(day)
          : await controller.repository.read(widget.id!);
      if (!mounted) return;
      setState(() {
        entry = item;
        if (item != null) {
          photo = item.original;
          text.text = item.body;
          day = item.localDate;
          dirty = false;
        }
        loading = false;
      });
      await refresh();
    } on Object {
      if (mounted) {
        setState(() {
          loading = false;
          error = '일기를 불러오지 못했어요. 다시 열어 주세요.';
        });
      }
    }
  }

  Future<void> refresh() async {
    if (!mounted ||
        busy ||
        entry?.jobId == null ||
        WidgetsBinding.instance.lifecycleState == AppLifecycleState.paused) {
      return;
    }
    try {
      await controller.refresh(entry!.id);
      final updated = await controller.repository.read(entry!.id);
      if (mounted) setState(() => entry = updated);
    } on Object {
      // Background polling must not replace writing with error dialogs.
      // Manual refresh exposes a retry message through run().
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      unawaited(refresh());
      unawaited(checkService());
    }
  }

  @override
  void dispose() {
    timer?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    text.dispose();
    super.dispose();
  }

  Future<void> run(Future<void> Function() action) async {
    if (busy) return;
    setState(() {
      busy = true;
      error = null;
    });
    try {
      await action();
    } on Object catch (e) {
      if (mounted) setState(() => error = diaryError(e));
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  Future<void> save() async {
    final id = await controller.save(
      id: entry?.id,
      photo: photo!,
      body: text.text,
      day: day,
    );
    final saved = await controller.repository.read(id);
    if (mounted) {
      setState(() {
        entry = saved;
        dirty = false;
      });
    }
  }

  Future<void> convert() async {
    await save();
    if (!mounted) return;
    final yes = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('이 사진을 그림으로 남길까요?'),
        content: const SingleChildScrollView(
          child: Text(
            '선택한 사진을 틔움 서버와 OpenAI에 보내 그림으로 바꿔요. 위치 정보는 제거하고, 일기 글은 보내지 않아요.\n\n'
            '틔움 서버의 사진은 다운로드 확인 후 삭제하며, 미수신 사진도 24시간 후 정리해요. OpenAI는 기본적으로 API 데이터를 학습에 사용하지 않지만 보안 모니터링을 위해 최대 30일 보관할 수 있어요(예외 있음).\n\n'
            '그림은 원본과 다를 수 있어요. 원본은 기기에 남아요. 변환은 처음 이용한 시간대 기준 하루 한 장이며, 삭제해도 오늘 사용량은 유지돼요.',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('원본으로 남기기'),
          ),
          FilledButton(
            key: const ValueKey('diary-consent'),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('동의하고 변환'),
          ),
        ],
      ),
    );
    if (yes != true) return;
    try {
      await controller.convert(entry!.id);
    } finally {
      final updated = await controller.repository.read(entry!.id);
      if (mounted) setState(() => entry = updated);
    }
  }

  Future<void> remove() async {
    final yes = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('이 일기를 삭제할까요?'),
        content: Text(
          entry?.jobId == null
              ? '사진과 글이 기기에서 삭제돼요. 되돌릴 수 없어요.'
              : '사진과 글, 서버의 임시 사진을 삭제해요. 서버 삭제에는 연결이 필요해요. 오늘의 변환 사용량은 유지돼요.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('취소'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('삭제'),
          ),
        ],
      ),
    );
    if (yes != true) return;
    await controller.delete(entry!.id);
    if (mounted) {
      setState(() => dirty = false);
      context.go('/insights/weekly');
    }
  }

  @override
  Widget build(BuildContext context) {
    final status = entry?.status ?? 'local';
    final pending = ['submitting', 'queued', 'processing'].contains(status);
    final art = entry?.artwork;
    return PopScope(
      canPop: !dirty && !busy,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop || busy) return;
        final leave = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('저장하지 않고 나갈까요?'),
            content: const Text('이번에 작성한 내용은 저장되지 않아요.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('계속 쓰기'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('나가기'),
              ),
            ],
          ),
        );
        if (leave == true && context.mounted) {
          setState(() => dirty = false);
          await Future<void>.delayed(Duration.zero);
          if (context.mounted) context.pop();
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('오늘의 한 장'),
          actions: [
            if (entry != null)
              IconButton(
                tooltip: '일기 삭제',
                onPressed: busy ? null : () => run(remove),
                icon: const Icon(Icons.delete_outline),
              ),
          ],
        ),
        body: loading
            ? const Center(child: CircularProgressIndicator())
            : SafeArea(
                child: ListView(
                  padding: EdgeInsets.all(DopaSpacing.page(context)),
                  children: [
                    Text(day, style: Theme.of(context).textTheme.labelLarge),
                    const SizedBox(height: 8),
                    Text(
                      '오늘 기억하고 싶은\n순간이 있었나요?',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 24),
                    if (photo == null)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          vertical: 32,
                          horizontal: 16,
                        ),
                        decoration: BoxDecoration(
                          color: DopaSurfaces.of(context).soft,
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: Column(
                          children: [
                            const Icon(Icons.photo_camera_outlined, size: 40),
                            const SizedBox(height: 16),
                            const Text('오늘 기억하고 싶은 장면 하나'),
                            const SizedBox(height: 16),
                            OutlinedButton(
                              key: const ValueKey('diary-pick'),
                              onPressed: busy
                                  ? null
                                  : () => run(() async {
                                      final selected = await controller.picker
                                          .pick();
                                      if (selected != null && mounted) {
                                        setState(() {
                                          photo = selected;
                                          dirty = true;
                                        });
                                      }
                                    }),
                              child: const Text('사진 한 장 고르기'),
                            ),
                          ],
                        ),
                      )
                    else ...[
                      ClipRRect(
                        borderRadius: BorderRadius.circular(24),
                        child: AspectRatio(
                          aspectRatio: 1,
                          child: Image.memory(
                            !original && art != null ? art : photo!,
                            fit: BoxFit.contain,
                            semanticLabel: !original && art != null
                                ? '$day 일상의 장면을 그린 틔움 그림'
                                : '$day 내가 남긴 사진',
                            errorBuilder: (_, e, s) => const Center(
                              child: Text('사진을 표시하지 못했어요. 글은 보관되어 있어요.'),
                            ),
                          ),
                        ),
                      ),
                      if (art != null)
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton.icon(
                            onPressed: () =>
                                setState(() => original = !original),
                            icon: const Icon(Icons.compare_outlined),
                            label: Text(original ? '틔움 그림 보기' : '원본 사진 보기'),
                          ),
                        ),
                      if (entry == null)
                        TextButton(
                          onPressed: busy
                              ? null
                              : () => run(() async {
                                  final selected = await controller.picker
                                      .pick();
                                  if (selected != null && mounted) {
                                    setState(() {
                                      photo = selected;
                                      dirty = true;
                                    });
                                  }
                                }),
                          child: const Text('다른 사진 고르기'),
                        ),
                    ],
                    const SizedBox(height: 24),
                    TextField(
                      key: const ValueKey('diary-body'),
                      controller: text,
                      enabled: !busy,
                      minLines: 3,
                      maxLines: 8,
                      maxLength: 2000,
                      onChanged: (_) => setState(() => dirty = true),
                      decoration: const InputDecoration(
                        labelText: '이 순간에 남기고 싶은 말 (선택)',
                        hintText: '책을 한 쪽 읽고, 창가에서 잠깐 쉬었어요.',
                      ),
                    ),
                    const SizedBox(height: 16),
                    FilledButton(
                      key: const ValueKey('diary-save'),
                      onPressed: busy || photo == null ? null : () => run(save),
                      child: Text(
                        busy
                            ? '잠시만요…'
                            : entry == null
                            ? '일기 저장하기'
                            : dirty
                            ? '글 수정 저장'
                            : '기기에 저장했어요',
                      ),
                    ),
                    const SizedBox(height: 16),
                    if (entry != null && !dirty)
                      TextButton(
                        key: const ValueKey('diary-back-to-records'),
                        onPressed: busy
                            ? null
                            : () => context.go('/insights/weekly'),
                        child: const Text('하루 기록으로 돌아가기'),
                      ),
                    if (entry != null && art == null) ...[
                      Text(switch (status) {
                        'submitting' =>
                          '변환 요청을 확인하고 있어요. 다시 연결해도 중복으로 만들지 않아요.',
                        'queued' ||
                        'processing' => '오늘의 그림을 그리고 있어요. 앱을 나가도 괜찮아요.',
                        'uncertain' =>
                          '변환 완료 여부를 확인하지 못했어요. 중복 요청을 막기 위해 오늘은 원본으로 남겨요.',
                        'failed' => '이번에는 그림을 만들지 못했어요. 원본 일기는 안전하게 남아 있어요.',
                        'expired' => '그림을 받아올 수 있는 시간이 지났어요. 원본 일기는 남아 있어요.',
                        _ => '사진 그대로도 충분해요. 원한다면 틔움의 그림체로 바꿔 간직할 수 있어요.',
                      }),
                      const SizedBox(height: 12),
                      if (pending)
                        OutlinedButton(
                          onPressed: busy
                              ? null
                              : () => run(() async {
                                  await controller.refresh(entry!.id);
                                  final updated = await controller.repository
                                      .read(entry!.id);
                                  if (mounted) setState(() => entry = updated);
                                }),
                          child: const Text('변환 상태 다시 확인'),
                        )
                      else if (status != 'uncertain')
                        OutlinedButton.icon(
                          key: const ValueKey('diary-convert'),
                          onPressed: busy || available != true
                              ? null
                              : () => run(convert),
                          icon: const Icon(Icons.brush_outlined),
                          label: const Text('틔움 그림으로 남기기'),
                        ),
                    ],
                    if (entry != null && available == false && art == null) ...[
                      const SizedBox(height: 12),
                      const Text('지금은 그림 변환에 연결할 수 없어요. 사진 일기는 그대로 사용할 수 있어요.'),
                      TextButton(
                        onPressed: busy ? null : checkService,
                        child: const Text('연결 다시 확인'),
                      ),
                    ],
                    if (error != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 16),
                        child: Semantics(
                          liveRegion: true,
                          child: Text(
                            error!,
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.error,
                            ),
                          ),
                        ),
                      ),
                    const SizedBox(height: 24),
                    const Text('일기를 쓰지 않은 날도 괜찮아요.\n이 기록은 정원 성장과 연결되지 않아요.'),
                  ],
                ),
              ),
      ),
    );
  }
}
