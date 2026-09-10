import 'dart:async';

import 'package:audio_service/audio_service.dart';
import 'package:audio_session/audio_session.dart';
import 'package:video_player/video_player.dart';

import 'companion_playback_port.dart';

/// One video engine owns both picture and audio. The handler only exposes controls.
class NativeCompanionPlayback implements CompanionPlaybackPort {
  static Future<_CompanionAudioHandler>? _handlerFuture;
  final _snapshots = StreamController<CompanionPlaybackSnapshot>.broadcast();
  final _commands = StreamController<CompanionPlaybackCommand>.broadcast();
  VideoPlayerController? video;
  AudioSession? _session;
  _CompanionAudioHandler? _handler;
  StreamSubscription<AudioInterruptionEvent>? _interruptions;
  StreamSubscription<void>? _noisy;
  @override
  Stream<CompanionPlaybackSnapshot> get snapshots => _snapshots.stream;
  @override
  Stream<CompanionPlaybackCommand> get commands => _commands.stream;
  @override
  CompanionPlaybackSnapshot get current {
    final value = video?.value;
    return CompanionPlaybackSnapshot(
      position: value?.position ?? Duration.zero,
      duration: value?.duration ?? Duration.zero,
      playing: value?.isPlaying ?? false,
      loading: value == null || !value.isInitialized || value.isBuffering,
      completed: value?.isCompleted ?? false,
      error: value?.hasError ?? false,
    );
  }

  void _changed() {
    final snapshot = current;
    _snapshots.add(snapshot);
    _handler?.playbackState.add(
      PlaybackState(
        controls: [
          snapshot.playing ? MediaControl.pause : MediaControl.play,
          MediaControl.stop,
        ],
        androidCompactActionIndices: const [0, 1],
        processingState: snapshot.error
            ? AudioProcessingState.error
            : snapshot.completed
            ? AudioProcessingState.completed
            : snapshot.loading
            ? AudioProcessingState.loading
            : AudioProcessingState.ready,
        playing: snapshot.playing,
        updatePosition: snapshot.position,
      ),
    );
  }

  @override
  Future<void> prepare(String asset, String captions, Duration position) async {
    final previous = video;
    video = null;
    previous?.removeListener(_changed);
    await previous?.dispose();
    try {
      _handler = await (_handlerFuture ??= AudioService.init(
        builder: _CompanionAudioHandler.new,
        config: const AudioServiceConfig(
          androidNotificationChannelId: 'com.devnamu.dopa.companion',
          androidNotificationChannelName: '같이 시작하기',
          androidNotificationOngoing: true,
        ),
      ));
    } on Object {
      _handlerFuture = null;
      rethrow;
    }
    _handler!.owner = this;
    final next = VideoPlayerController.asset(
      asset,
      closedCaptionFile: Future.value(WebVTTCaptionFile(captions)),
      videoPlayerOptions: VideoPlayerOptions(
        allowBackgroundPlayback: true,
        mixWithOthers: true,
      ),
    );
    video = next;
    next.addListener(_changed);
    await next.initialize();
    await next.setLooping(false);
    await next.seekTo(position);
    await next.pause();
    _session = await AudioSession.instance;
    await _session!.configure(const AudioSessionConfiguration.speech());
    await _interruptions?.cancel();
    await _noisy?.cancel();
    _interruptions = _session!.interruptionEventStream.listen((event) {
      if (event.begin) _commands.add(CompanionPlaybackCommand.pause);
    });
    _noisy = _session!.becomingNoisyEventStream.listen(
      (_) => _commands.add(CompanionPlaybackCommand.pause),
    );
    _handler!.mediaItem.add(
      MediaItem(
        id: 'desk_space_v2',
        title: '책상에 작은 자리 만들기',
        artist: '같이 시작하기',
        duration: next.value.duration,
      ),
    );
    _changed();
  }

  @override
  Future<void> play() async {
    if (await _session?.setActive(true) != true) {
      throw StateError('Audio focus unavailable.');
    }
    await video?.play();
  }

  @override
  Future<void> pause() async {
    await video?.pause();
    await _session?.setActive(false);
  }

  @override
  Future<void> seek(Duration position) async => video?.seekTo(position);
  @override
  Future<void> stop() async {
    await pause();
    _handler?.playbackState.add(
      PlaybackState(processingState: AudioProcessingState.idle),
    );
  }

  @override
  Future<void> dispose() async {
    await stop();
    await _interruptions?.cancel();
    await _noisy?.cancel();
    if (_handler?.owner == this) _handler?.owner = null;
    video?.removeListener(_changed);
    await video?.dispose();
    video = null;
    await _snapshots.close();
    await _commands.close();
  }
}

class _CompanionAudioHandler extends BaseAudioHandler {
  NativeCompanionPlayback? owner;
  @override
  Future<void> play() async =>
      owner?._commands.add(CompanionPlaybackCommand.play);
  @override
  Future<void> pause() async =>
      owner?._commands.add(CompanionPlaybackCommand.pause);
  @override
  Future<void> stop() async =>
      owner?._commands.add(CompanionPlaybackCommand.stop);
  @override
  Future<void> onTaskRemoved() async =>
      owner?._commands.add(CompanionPlaybackCommand.stop);
}
