import 'dart:async';

import 'package:dopa_domain/dopa_domain.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:video_player/video_player.dart';

import '../../focus/application/focus_session_controller.dart';
import 'companion_controller.dart';
import 'companion_media.dart';
import 'companion_playback_port.dart';
import 'native_companion_playback.dart';

final companionPlaybackFactoryProvider =
    Provider<CompanionPlaybackPort Function()>(
      (ref) => NativeCompanionPlayback.new,
    );
// Deliberately account-scoped. Leaving the route does not dispose the engine.
final companionMediaControllerProvider =
    StateNotifierProvider<CompanionMediaController, CompanionMediaState>((ref) {
      final controller = CompanionMediaController(
        repository: ref.watch(companionRepositoryProvider),
        createPlayback: ref.watch(companionPlaybackFactoryProvider),
        now: ref.watch(localNowProvider),
        newId: ref.watch(sessionIdFactoryProvider),
        onSaved: () => ref.invalidate(companionHistoryProvider),
      );
      ref.onDispose(controller.closeWithoutSaving);
      return controller;
    });

class CompanionMediaState {
  const CompanionMediaState({
    this.run,
    this.snapshot = const CompanionPlaybackSnapshot(),
    this.busy = false,
    this.error = false,
    this.record,
  });
  final CompanionRun? run;
  final CompanionPlaybackSnapshot snapshot;
  final bool busy;
  final bool error;
  final CompanionOutcomeRecord? record;
}

class CompanionMediaController extends StateNotifier<CompanionMediaState> {
  CompanionMediaController({
    required CompanionRepository repository,
    required CompanionPlaybackPort Function() createPlayback,
    required DateTime Function() now,
    required String Function() newId,
    required void Function() onSaved,
  }) : _repository = repository,
       _createPlayback = createPlayback,
       _now = now,
       _newId = newId,
       _onSaved = onSaved,
       super(const CompanionMediaState());
  final CompanionRepository _repository;
  final CompanionPlaybackPort Function() _createPlayback;
  final DateTime Function() _now;
  final String Function() _newId;
  final void Function() _onSaved;
  CompanionPlaybackPort? _port;
  CompanionMedia? _media;
  StreamSubscription<CompanionPlaybackSnapshot>? _subscription;
  StreamSubscription<CompanionPlaybackCommand>? _commands;
  Timer? _checkpoint;
  Future<void> _tail = Future.value();
  bool _closed = false;
  bool _prepared = false;
  bool _terminalPending = false;
  int _epoch = 0;
  VideoPlayerController? get video => _port is NativeCompanionPlayback
      ? (_port! as NativeCompanionPlayback).video
      : null;

  void _emit({
    CompanionRun? run,
    CompanionPlaybackSnapshot? snapshot,
    bool? busy,
    bool? error,
    CompanionOutcomeRecord? record,
  }) {
    if (!mounted || _closed) return;
    state = CompanionMediaState(
      run: run ?? state.run,
      snapshot: snapshot ?? state.snapshot,
      busy: busy ?? state.busy,
      error: error ?? state.error,
      record: record ?? state.record,
    );
  }

  Future<void> _enqueue(Future<void> Function() action) {
    if (_closed) return Future.value();
    final next = _tail.then((_) async {
      if (_closed) return;
      _emit(busy: true);
      try {
        await action();
      } on Object {
        try {
          await _port?.pause();
        } on Object {
          /* Preserve the actionable error. */
        }
        _emit(error: true);
      }
      _emit(busy: false);
    });
    _tail = next;
    return next;
  }

  /// Restores at the recorded engine position, always paused. No engine is
  /// constructed until the user enters/starts the media guide.
  Future<void> open(CompanionMedia? media, {bool start = false}) =>
      _enqueue(() async {
        _media = media;
        var run = await _repository.readActive();
        if (run == null && start && media != null) {
          final now = _now();
          run = await _repository.startOrResume(
            CompanionRun(
              id: _newId(),
              contentId: 'desk_space',
              contentVersion: 2,
              startedAtUtc: now.toUtc(),
              startedLocalDate: LocalDate.fromLocal(now),
              stepCount: 4,
              guidanceMode: CompanionGuidanceMode.humanMedia,
            ),
          );
        }
        if (run == null) {
          if (mounted && !_closed) state = const CompanionMediaState();
          return;
        }
        if (run.contentVersion != 2 ||
            run.contentId != 'desk_space' ||
            run.stepCount != 4) {
          throw StateError('Incompatible content.');
        }
        if (mounted && !_closed) {
          state = CompanionMediaState(run: run, busy: true);
        }
        if (run.awaitingOutcome ||
            run.guidanceMode == CompanionGuidanceMode.textFallback) {
          return;
        }
        await _prepare();
      });

  Future<void> _prepare() async {
    if (state.run == null ||
        state.run!.awaitingOutcome ||
        state.run!.guidanceMode == CompanionGuidanceMode.textFallback) {
      return;
    }
    _prepared = false;
    final media = _media;
    if (media == null) throw StateError('Media unavailable.');
    final epoch = ++_epoch;
    await _subscription?.cancel();
    await _commands?.cancel();
    await _port?.dispose();
    final port = _createPlayback();
    _port = port;
    _commands = port.commands.listen((command) {
      if (epoch != _epoch || _closed) return;
      switch (command) {
        case CompanionPlaybackCommand.play:
          unawaited(play());
        case CompanionPlaybackCommand.pause:
          unawaited(pause());
        case CompanionPlaybackCommand.stop:
          unawaited(pause(stop: true));
      }
    });
    await port.prepare(
      media.video,
      media.captions,
      Duration(milliseconds: state.run!.positionMs),
    );
    if ((port.current.duration.inMilliseconds - media.durationMs).abs() > 500) {
      throw StateError('Media duration mismatch.');
    }
    _prepared = true;
    _emit(snapshot: port.current, error: false);
    _subscription = port.snapshots.listen((snapshot) {
      if (_closed ||
          epoch != _epoch ||
          !_prepared ||
          state.run?.awaitingOutcome == true) {
        return;
      }
      _emit(snapshot: snapshot, error: snapshot.error ? true : null);
      if ((snapshot.completed || snapshot.error) && !_terminalPending) {
        _terminalPending = true;
        unawaited(
          _enqueue(() async {
            try {
              if (epoch != _epoch || !_prepared || state.run!.awaitingOutcome) {
                return;
              }
              final completed = port.current.completed;
              if (!completed && !port.current.error) return;
              await port.pause();
              await _save(completed: completed);
              if (completed) await port.stop();
            } finally {
              _terminalPending = false;
            }
          }),
        );
      }
    });
    _checkpoint?.cancel();
    _checkpoint = Timer.periodic(const Duration(seconds: 5), (_) {
      if (port.current.playing) unawaited(_enqueue(() => _save()));
    });
  }

  Future<void> retry() => _enqueue(_prepare);
  Future<void> play() => _enqueue(() async {
    if (!_prepared ||
        state.run!.awaitingOutcome ||
        state.record != null ||
        state.run!.guidanceMode != CompanionGuidanceMode.humanMedia) {
      return;
    }
    await _port!.play();
    _emit(snapshot: _port!.current, error: false);
  });
  Future<void> pause({bool stop = false}) => _enqueue(() async {
    if (_port == null) {
      _emit(error: false);
      return;
    }
    await _port!.pause();
    await _save();
    if (stop) await _port!.stop();
    _emit(snapshot: _port!.current, error: false);
  });
  Future<void> seekStep(int step) => _enqueue(() async {
    if (!_prepared ||
        state.run!.awaitingOutcome ||
        state.run!.guidanceMode != CompanionGuidanceMode.humanMedia) {
      return;
    }
    final index = step.clamp(0, 3);
    await _port!.seek(Duration(milliseconds: _media!.stepStarts[index]));
    await _save();
    _emit(snapshot: _port!.current);
  });
  Future<void> _save({
    bool completed = false,
    CompanionGuidanceMode? mode,
  }) async {
    final run = state.run;
    if (run == null ||
        run.awaitingOutcome ||
        state.record != null ||
        (!_prepared && mode == null)) {
      return;
    }
    final position = _prepared
        ? _port!.current.position.inMilliseconds.clamp(0, _media!.durationMs)
        : run.positionMs;
    final next = await (_repository as CompanionMediaRepository).savePlayback(
      runId: run.id,
      positionMs: position,
      revision: run.playbackRevision + 1,
      stepIndex: completed ? 3 : (_media?.stepAt(position) ?? run.stepIndex),
      mode: mode ?? run.guidanceMode,
      completed: completed,
    );
    _emit(run: next);
  }

  Future<void> fallback() => _enqueue(() async {
    await _port?.pause();
    await _save(mode: CompanionGuidanceMode.textFallback);
    _prepared = false;
    _epoch++;
    _checkpoint?.cancel();
    await _port?.stop();
    _emit(snapshot: const CompanionPlaybackSnapshot(), error: false);
  });
  Future<void> nextText() => _enqueue(() async {
    if (state.run?.guidanceMode != CompanionGuidanceMode.textFallback) return;
    _emit(run: await _repository.advanceGuide(state.run!.id));
  });
  Future<void> finish() => _enqueue(() async {
    if (state.run == null) return;
    await _port?.pause();
    await _save();
    _emit(run: await _repository.requestOutcome(state.run!.id), error: false);
    await _port?.stop();
  });
  Future<void> submit(CompanionOutcome outcome) => _enqueue(() async {
    if (state.record != null || state.run?.awaitingOutcome != true) return;
    await _port?.stop();
    final now = _now();
    final record = await _repository.submitOutcome(
      runId: state.run!.id,
      outcome: outcome,
      confirmedAtUtc: now.toUtc(),
      confirmedLocalDate: LocalDate.fromLocal(now),
    );
    _emit(run: record.run, record: record);
    _onSaved();
  });
  Future<void> shutdown() async {
    _closed = true;
    _epoch++;
    _checkpoint?.cancel();
    await _tail;
    await _subscription?.cancel();
    await _commands?.cancel();
    await _port?.dispose();
    _port = null;
  }

  void closeWithoutSaving() {
    unawaited(shutdown());
  }
}
