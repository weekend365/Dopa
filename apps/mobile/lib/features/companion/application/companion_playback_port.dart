import 'dart:async';

class CompanionPlaybackSnapshot {
  const CompanionPlaybackSnapshot({
    this.position = Duration.zero,
    this.duration = Duration.zero,
    this.playing = false,
    this.loading = false,
    this.completed = false,
    this.error = false,
  });
  final Duration position;
  final Duration duration;
  final bool playing;
  final bool loading;
  final bool completed;
  final bool error;
}

enum CompanionPlaybackCommand { play, pause, stop }

abstract interface class CompanionPlaybackPort {
  Stream<CompanionPlaybackSnapshot> get snapshots;
  Stream<CompanionPlaybackCommand> get commands;
  CompanionPlaybackSnapshot get current;
  Future<void> prepare(String asset, String captions, Duration position);
  Future<void> play();
  Future<void> pause();
  Future<void> seek(Duration position);
  Future<void> stop();
  Future<void> dispose();
}
