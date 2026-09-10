import 'dart:async';

import 'package:dopa/features/companion/application/companion_media.dart';
import 'package:dopa/features/companion/application/companion_media_controller.dart';
import 'package:dopa/features/companion/application/companion_playback_port.dart';
import 'package:dopa_domain/dopa_domain.dart';
import 'package:flutter_test/flutter_test.dart';

import 'fake_companion_repository.dart';

class MediaRepository extends FakeCompanionRepository
    implements CompanionMediaRepository {
  Completer<void>? saveGate;
  int writes = 0;
  @override
  Future<CompanionRun> savePlayback({
    required String runId,
    required int positionMs,
    required int revision,
    required int stepIndex,
    required CompanionGuidanceMode mode,
    bool completed = false,
  }) async {
    await saveGate?.future;
    writes++;
    if (active!.awaitingOutcome || revision <= active!.playbackRevision) {
      return active!;
    }
    return active = active!.withPlayback(
      positionMs: positionMs,
      revision: revision,
      stepIndex: stepIndex,
      mode: mode,
      completed: completed,
    );
  }
}

class FakePlayback implements CompanionPlaybackPort {
  final events = StreamController<CompanionPlaybackSnapshot>.broadcast(
    sync: true,
  );
  final control = StreamController<CompanionPlaybackCommand>.broadcast(
    sync: true,
  );
  bool disposed = false;
  bool fail = false;
  @override
  CompanionPlaybackSnapshot current = const CompanionPlaybackSnapshot(
    duration: Duration(seconds: 120),
  );
  @override
  Stream<CompanionPlaybackSnapshot> get snapshots => events.stream;
  @override
  Stream<CompanionPlaybackCommand> get commands => control.stream;
  void tick(int ms, {bool completed = false}) {
    current = CompanionPlaybackSnapshot(
      position: Duration(milliseconds: ms),
      duration: const Duration(seconds: 120),
      playing: !completed && current.playing,
      completed: completed,
    );
    events.add(current);
  }

  @override
  Future<void> prepare(String asset, String captions, Duration position) async {
    if (fail) throw StateError('fixture failure');
    tick(position.inMilliseconds);
  }

  @override
  Future<void> pause() async {
    current = CompanionPlaybackSnapshot(
      position: current.position,
      duration: current.duration,
      completed: current.completed,
    );
  }

  @override
  Future<void> play() async {
    current = CompanionPlaybackSnapshot(
      position: current.position,
      duration: current.duration,
      playing: true,
    );
  }

  @override
  Future<void> seek(Duration position) async => tick(position.inMilliseconds);
  @override
  Future<void> stop() => pause();
  @override
  Future<void> dispose() async {
    await pause();
    disposed = true;
  }
}

const media = CompanionMedia(
  video: 'test.mp4',
  poster: 'test.jpg',
  captions: 'WEBVTT\n',
  durationMs: 120000,
  stepStarts: [0, 30000, 60000, 90000],
);

void main() {
  late MediaRepository repo;
  late CompanionMediaController controller;
  late List<FakePlayback> ports;
  var fail = false;
  setUp(() {
    fail = false;
    repo = MediaRepository();
    ports = [];
    controller = CompanionMediaController(
      repository: repo,
      createPlayback: () {
        final port = FakePlayback()..fail = fail;
        ports.add(port);
        return port;
      },
      now: () => DateTime(2026, 9, 10),
      newId: () => 'media',
      onSaved: () {},
    );
  });
  tearDown(() async {
    await controller.shutdown();
    controller.dispose();
    for (final port in ports) {
      await port.events.close();
      await port.control.close();
    }
  });
  test(
    'start and restart prepare at saved position paused; seeks can go backward',
    () async {
      await controller.open(media, start: true);
      expect(controller.state.snapshot.playing, false);
      await controller.play();
      ports.last.tick(67321);
      await controller.pause();
      expect(repo.active!.positionMs, 67321);
      await controller.open(media);
      expect(ports.last.current.position.inMilliseconds, 67321);
      expect(ports.last.current.playing, false);
      await controller.seekStep(0);
      expect(repo.active!.positionMs, 0);
      await controller.seekStep(3);
      expect(repo.active!.stepIndex, 3);
      ports.first.tick(120000, completed: true);
      await controller.pause();
      expect(repo.active!.awaitingOutcome, false);
    },
  );
  test(
    'end waits for explicit result and duplicate commands keep one outcome',
    () async {
      await controller.open(media, start: true);
      await controller.play();
      ports.last.tick(120000, completed: true);
      await controller.pause();
      expect(repo.active!.awaitingOutcome, true);
      expect(repo.records, isEmpty);
      await Future.wait([
        controller.submit(CompanionOutcome.started),
        controller.submit(CompanionOutcome.difficult),
      ]);
      expect(repo.records.single.outcome, CompanionOutcome.started);
      expect(repo.submissions, 1);
    },
  );
  test(
    'loading failure retry and explicit fallback preserve distinct mode',
    () async {
      fail = true;
      await controller.open(media, start: true);
      expect(controller.state.error, true);
      expect(repo.active!.guidanceMode, CompanionGuidanceMode.humanMedia);
      fail = false;
      await controller.retry();
      expect(controller.state.error, false);
      await controller.fallback();
      expect(repo.active!.guidanceMode, CompanionGuidanceMode.textFallback);
      await controller.nextText();
      expect(repo.active!.stepIndex, 1);
      await controller.play();
      expect(ports.last.current.playing, false);
    },
  );
  test('system interruption pauses and persists without auto resume', () async {
    await controller.open(media, start: true);
    await controller.play();
    ports.last.tick(5213);
    ports.last.control.add(CompanionPlaybackCommand.pause);
    await controller.pause();
    expect(repo.active!.positionMs, 5213);
    expect(ports.last.current.playing, false);
  });
  test('shutdown drains pending save, rejects queued play and stops before deletion', () async {
    await controller.open(media, start: true);
    await controller.play();
    ports.last.tick(9123);
    repo.saveGate = Completer<void>();
    final paused = controller.pause();
    await Future<void>.delayed(Duration.zero);
    final queued = controller.play();
    var stopped = false;
    final shutdown = controller.shutdown().then((_) => stopped = true);
    await Future<void>.delayed(Duration.zero);
    expect(stopped, false);
    repo.saveGate!.complete();
    await Future.wait([paused, queued, shutdown]);
    expect(repo.active!.positionMs, 9123);
    expect(ports.last.disposed, true);
    repo.active = null;
    final writes = repo.writes;
    ports.last.tick(20000);
    await controller.play();
    expect(repo.writes, writes);
  });
  test(
    'five second checkpoint stores engine position rather than elapsed time',
    () async {
      await controller.open(media, start: true);
      await controller.play();
      ports.last.tick(2341);
      await Future<void>.delayed(const Duration(milliseconds: 5200));
      expect(repo.active!.positionMs, 2341);
      ports.last.tick(4932);
      await Future<void>.delayed(const Duration(milliseconds: 100));
      expect(repo.active!.positionMs, 2341);
    },
  );
}
