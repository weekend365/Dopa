import 'package:dopa_domain/dopa_domain.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:video_player/video_player.dart';

import '../application/companion_controller.dart';
import '../application/companion_media.dart';
import '../application/companion_media_controller.dart';
import 'companion_copy.dart';
import 'companion_page.dart';

final _activeCompanionProvider = FutureProvider.autoDispose(
  (ref) => ref.watch(companionRepositoryProvider).readActive(),
);

class CompanionExperiencePage extends ConsumerWidget {
  const CompanionExperiencePage({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final active = ref.watch(_activeCompanionProvider);
    final media = ref.watch(companionMediaProvider);
    if (active.isLoading || media.isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (active.hasError) return const CompanionPage();
    final run = active.valueOrNull;
    if (run?.contentVersion == 1 ||
        (run == null && media.valueOrNull == null)) {
      return const CompanionPage();
    }
    return _MediaPage(media: media.valueOrNull, existing: run != null);
  }
}

class _MediaPage extends ConsumerStatefulWidget {
  const _MediaPage({required this.media, required this.existing});
  final CompanionMedia? media;
  final bool existing;
  @override
  ConsumerState<_MediaPage> createState() => _MediaPageState();
}

class _MediaPageState extends ConsumerState<_MediaPage> {
  bool captions = true;
  bool leaving = false;
  @override
  void initState() {
    super.initState();
    Future.microtask(
      () => ref
          .read(companionMediaControllerProvider.notifier)
          .open(widget.media),
    );
  }

  Future<void> leave() async {
    if (leaving) return;
    leaving = true;
    await ref.read(companionMediaControllerProvider.notifier).pause(stop: true);
    if (!mounted) return;
    if (ref.read(companionMediaControllerProvider).error) {
      leaving = false;
      return;
    }
    context.go('/today');
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(companionMediaControllerProvider);
    final controller = ref.read(companionMediaControllerProvider.notifier);
    final run = state.run;
    final fallback = run?.guidanceMode == CompanionGuidanceMode.textFallback;
    final step = fallback
        ? run!.stepIndex
        : widget.media?.stepAt(state.snapshot.position.inMilliseconds) ?? 0;
    final video = controller.video;
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) leave();
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('같이 시작하기'),
          leading: IconButton(
            onPressed: state.busy ? null : leave,
            tooltip: '나중에 이어하기',
            icon: const Icon(Icons.arrow_back),
          ),
        ),
        body: SafeArea(
          child: ListView(
            padding: const EdgeInsets.all(24),
            children: [
              Text(
                deskCompanionContent.title,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              if (run == null) ...[
                if (widget.media != null && !widget.existing)
                  Image.asset(
                    widget.media!.poster,
                    semanticLabel: '책상과 손 동작 안내 미리보기',
                    errorBuilder: (context, error, stack) =>
                        const Text('책상에 작은 자리 만들기'),
                  ),
                Text(deskCompanionContent.preparation),
                const Text('손 동작과 한국어 목소리로 함께해요. 화면을 잠가도 음성이 이어집니다.'),
                FilledButton(
                  onPressed: state.busy
                      ? null
                      : () => controller.open(widget.media, start: true),
                  child: const Text('안내 준비하기'),
                ),
              ] else if (state.record != null) ...[
                Text(companionOutcomeLabel(state.record!.outcome)),
                const Text('직접 선택한 결과를 기록했어요.'),
                FilledButton(
                  onPressed: () => context.go('/today'),
                  child: const Text('오늘로 돌아가기'),
                ),
              ] else if (run.awaitingOutcome) ...[
                const Text('안내가 끝났어요. 해낸 만큼 직접 골라주세요.'),
                for (final outcome in CompanionOutcome.values)
                  FilledButton(
                    onPressed: state.busy
                        ? null
                        : () => controller.submit(outcome),
                    child: Text(companionOutcomeLabel(outcome)),
                  ),
              ] else ...[
                if (!fallback && video != null && video.value.isInitialized)
                  AspectRatio(
                    aspectRatio: video.value.aspectRatio,
                    child: ExcludeSemantics(child: VideoPlayer(video)),
                  ),
                if (state.snapshot.loading && !fallback && !state.error)
                  const LinearProgressIndicator(semanticsLabel: '안내 준비 중'),
                Text('${step + 1} / 4 단계'),
                Text(deskCompanionContent.steps[step]),
                if (captions && !fallback)
                  Semantics(
                    liveRegion: true,
                    child: Text(
                      widget.media?.captionAt(
                            state.snapshot.position.inMilliseconds,
                          ) ??
                          '',
                    ),
                  ),
                if (!fallback)
                  SwitchListTile(
                    title: const Text('한국어 자막 표시'),
                    value: captions,
                    onChanged: (value) => setState(() => captions = value),
                  ),
                if (state.error) ...[
                  const Text('안내를 재생하거나 저장하지 못했어요.'),
                  OutlinedButton(
                    onPressed: state.busy ? null : controller.retry,
                    child: const Text('다시 시도'),
                  ),
                  OutlinedButton(
                    onPressed: state.busy ? null : controller.fallback,
                    child: const Text('텍스트 안내로 계속'),
                  ),
                  TextButton(
                    onPressed: state.busy ? null : controller.finish,
                    child: const Text('안내 종료'),
                  ),
                ] else if (fallback)
                  FilledButton(
                    onPressed: state.busy ? null : controller.nextText,
                    child: const Text('다음 단계'),
                  )
                else ...[
                  FilledButton(
                    onPressed: state.busy
                        ? null
                        : state.snapshot.playing
                        ? controller.pause
                        : controller.play,
                    child: Text(state.snapshot.playing ? '일시 정지' : '재생'),
                  ),
                  OutlinedButton(
                    onPressed: state.busy
                        ? null
                        : () => controller.seekStep(step),
                    child: const Text('현재 단계 다시 듣기'),
                  ),
                  OutlinedButton(
                    onPressed: state.busy
                        ? null
                        : step == 3
                        ? controller.finish
                        : () => controller.seekStep(step + 1),
                    child: Text(step == 3 ? '결과 선택하기' : '다음 단계'),
                  ),
                ],
                TextButton(
                  onPressed: state.busy ? null : controller.finish,
                  child: const Text('여기까지 하고 결과 선택'),
                ),
              ],
              if (run != null && state.record == null)
                TextButton(
                  onPressed: state.busy ? null : leave,
                  child: const Text('나중에 이어하기'),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
