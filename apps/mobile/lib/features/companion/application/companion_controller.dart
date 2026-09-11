import 'dart:async';

import 'package:dopa/core/app_environment.dart';
import 'package:dopa/core/persistence/dopa_database_providers.dart';
import 'package:dopa/features/focus/application/focus_session_controller.dart';
import 'package:dopa/features/tree_companion/application/tree_companion_providers.dart';
import 'package:dopa_domain/dopa_domain.dart';
import 'package:dopa_local_storage/dopa_local_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// The complete text guide is local and available in every flavor.
bool companionSampleAvailable(DopaEnvironment environment) => true;

final companionSampleEnabledProvider = Provider<bool>(
  (ref) => companionSampleAvailable(AppEnvironment.current),
);

final companionRepositoryProvider = Provider<CompanionRepository>(
  (ref) => DriftCompanionRepository(database: ref.watch(dopaDatabaseProvider)),
);

final companionHistoryProvider =
    FutureProvider.autoDispose<List<CompanionOutcomeRecord>>(
      (ref) => ref.watch(companionRepositoryProvider).readHistory(),
    );

final companionControllerProvider =
    StateNotifierProvider.autoDispose<CompanionController, CompanionState>(
      (ref) => CompanionController(
        repository: ref.watch(companionRepositoryProvider),
        now: ref.watch(localNowProvider),
        newId: ref.watch(sessionIdFactoryProvider),
        onSaved: () {
          if (ref.exists(companionHistoryProvider)) {
            ref.invalidate(companionHistoryProvider);
          }
          if (ref.exists(treeProgressControllerProvider)) {
            ref.invalidate(treeProgressControllerProvider);
          }
          if (ref.exists(weeklyGrowthDaysControllerProvider)) {
            ref.invalidate(weeklyGrowthDaysControllerProvider);
          }
        },
      ),
    );

enum CompanionFailure { dataUnavailable, contentUnavailable }

class CompanionState {
  const CompanionState({
    this.run,
    this.record,
    this.loading = false,
    this.busy = false,
    this.playing = false,
    this.automatic = false,
    this.failure,
  });

  final CompanionRun? run;
  final CompanionOutcomeRecord? record;
  final bool loading;
  final bool busy;
  final bool playing;
  final bool automatic;
  final CompanionFailure? failure;

  CompanionState copyWith({
    bool? busy,
    bool? playing,
    bool? automatic,
    CompanionFailure? failure,
  }) => CompanionState(
    run: run,
    record: record,
    loading: loading,
    busy: busy ?? this.busy,
    playing: playing ?? this.playing,
    automatic: automatic ?? this.automatic,
    failure: failure,
  );
}

class CompanionController extends StateNotifier<CompanionState> {
  CompanionController({
    required CompanionRepository repository,
    required DateTime Function() now,
    required String Function() newId,
    required void Function() onSaved,
  }) : _repository = repository,
       _now = now,
       _newId = newId,
       _onSaved = onSaved,
       super(const CompanionState(loading: true)) {
    unawaited(load());
  }

  final CompanionRepository _repository;
  final DateTime Function() _now;
  final String Function() _newId;
  final void Function() _onSaved;
  Timer? _timer;
  int _interruptionGeneration = 0;

  Future<bool> load() => _perform(() async {
    final run = await _repository.readActive();
    _checkContent(run);
    return CompanionState(run: run);
  });

  Future<bool> start({CompanionContent content = deskCompanionContent}) =>
      _perform(() async {
        final localNow = _now();
        final run = await _repository.startOrResume(
          CompanionRun(
            id: _newId(),
            contentId: content.id,
            contentVersion: content.version,
            startedAtUtc: localNow.toUtc(),
            startedLocalDate: LocalDate.fromLocal(localNow),
            stepCount: content.steps.length,
          ),
        );
        _checkContent(run);
        return CompanionState(
          run: run,
          playing: !run.awaitingOutcome,
          automatic: state.automatic,
        );
      });

  void play() {
    if (state.busy ||
        state.run == null ||
        state.run!.awaitingOutcome ||
        state.record != null ||
        state.failure != null) {
      return;
    }
    state = state.copyWith(playing: true);
    _armTimer();
  }

  /// Used for navigation, background, screen lock and any inactive lifecycle.
  void pause() {
    _interruptionGeneration++;
    _timer?.cancel();
    if (mounted) state = state.copyWith(playing: false, failure: state.failure);
  }

  void setAutomatic(bool automatic) {
    state = state.copyWith(automatic: automatic, failure: state.failure);
    _armTimer();
  }

  void replayGuide() {
    // The text stays available while paused; replay restarts only its wait.
    play();
  }

  Future<bool> next() => _perform(() async {
    final run = state.run;
    if (run == null || state.record != null) return state;
    final next = await _repository.advanceGuide(run.id);
    return CompanionState(
      run: next,
      playing: state.playing && !next.awaitingOutcome,
      automatic: state.automatic,
    );
  });

  Future<bool> finishGuide() {
    pause();
    return _perform(() async {
      final run = state.run;
      if (run == null || state.record != null) return state;
      return CompanionState(run: await _repository.requestOutcome(run.id));
    });
  }

  Future<bool> submit(CompanionOutcome outcome) => _perform(() async {
    if (state.record != null) return state;
    final run = state.run;
    if (run == null || !run.awaitingOutcome) return state;
    final localNow = _now();
    final record = await _repository.submitOutcome(
      runId: run.id,
      outcome: outcome,
      confirmedAtUtc: localNow.toUtc(),
      confirmedLocalDate: LocalDate.fromLocal(localNow),
    );
    if (mounted) _onSaved();
    return CompanionState(run: record.run, record: record);
  });

  Future<bool> _perform(Future<CompanionState> Function() action) async {
    if (state.busy) return false;
    _timer?.cancel();
    final generation = _interruptionGeneration;
    state = state.copyWith(busy: true);
    try {
      var next = await action();
      if (!mounted) return false;
      if (generation != _interruptionGeneration) {
        next = next.copyWith(playing: false);
      }
      state = next.copyWith(busy: false);
      _armTimer();
      return true;
    } on Object catch (error) {
      if (mounted) {
        state = CompanionState(
          run: state.run,
          record: state.record,
          automatic: state.automatic,
          failure: error is _ContentUnavailable
              ? CompanionFailure.contentUnavailable
              : CompanionFailure.dataUnavailable,
        );
      }
      return false;
    }
  }

  void _checkContent(CompanionRun? run) {
    if (run == null) return;
    final content = companionContentFor(run.contentId, run.contentVersion);
    if (content == null || run.stepCount != content.steps.length) {
      throw const _ContentUnavailable();
    }
  }

  void _armTimer() {
    _timer?.cancel();
    if (state.playing &&
        state.automatic &&
        !state.busy &&
        state.failure == null &&
        state.run != null &&
        !state.run!.awaitingOutcome &&
        state.record == null) {
      // Foreground guide pacing only; never a measurement of task performance.
      _timer = Timer(const Duration(seconds: 30), () => unawaited(next()));
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}

class _ContentUnavailable implements Exception {
  const _ContentUnavailable();
}
