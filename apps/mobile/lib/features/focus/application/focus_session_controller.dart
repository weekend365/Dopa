import 'dart:math';

import 'package:dopa/core/persistence/dopa_database_providers.dart';
import 'package:dopa/features/focus/application/focus_setup_controller.dart';
import 'package:dopa/features/tree_companion/application/tree_companion_providers.dart';
import 'package:dopa_domain/dopa_domain.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

typedef SessionIdFactory = String Function();
typedef LocalNow = DateTime Function();

final class FocusSessionNotElapsedException implements Exception {
  const FocusSessionNotElapsedException(this.remaining);

  final Duration remaining;

  @override
  String toString() => 'FocusSessionNotElapsedException($remaining)';
}

final localNowProvider = Provider<LocalNow>((ref) => DateTime.now);
final sessionIdFactoryProvider = Provider<SessionIdFactory>(
  (ref) => _newSessionId,
);

class FocusSessionFlowState {
  const FocusSessionFlowState({this.session, this.isBusy = false, this.error});

  final FocusSession? session;
  final bool isBusy;
  final Object? error;

  FocusSessionFlowState copyWith({
    FocusSession? session,
    bool? isBusy,
    Object? error,
    bool clearError = false,
  }) {
    return FocusSessionFlowState(
      session: session ?? this.session,
      isBusy: isBusy ?? this.isBusy,
      error: clearError ? null : error ?? this.error,
    );
  }
}

final focusSessionControllerProvider =
    StateNotifierProvider<FocusSessionController, FocusSessionFlowState>(
      (ref) => FocusSessionController(ref),
    );

/// Restores an unfinished local session when the user next enters focus setup.
final focusSessionRecoveryProvider = FutureProvider<void>(
  (ref) => ref.read(focusSessionControllerProvider.notifier).restoreActive(),
);

/// Coordinates the UI with the domain transaction without making growth
/// dependent on any tree feature flag.
class FocusSessionController extends StateNotifier<FocusSessionFlowState> {
  FocusSessionController(this._ref) : super(const FocusSessionFlowState());

  final Ref _ref;
  Future<TreeCompletionViewData>? _pendingCompletion;

  Future<void> restoreActive() async {
    if (state.session case final session? when !session.isTerminal) return;
    try {
      final session = await _ref
          .read(focusTreeRepositoryProvider)
          .readActiveFocusSession();
      if (session != null && mounted) {
        state = FocusSessionFlowState(session: session);
      }
    } on Object catch (error) {
      if (mounted) {
        state = state.copyWith(error: error);
      }
      rethrow;
    }
  }

  Future<FocusSession> start(FocusSetupState setup) async {
    if (state.isBusy) {
      throw StateError('A focus session operation is already running.');
    }
    final existing = state.session;
    if (existing != null && !existing.isTerminal) {
      return existing;
    }
    state = state.copyWith(isBusy: true, clearError: true);

    try {
      final localNow = _ref.read(localNowProvider)();
      final session = FocusSession(
        id: _ref.read(sessionIdFactoryProvider)(),
        startedAtUtc: localNow.toUtc(),
        startedLocalDate: LocalDate.fromLocal(localNow),
        protectionMode: setup.protectionMode,
        preset: SessionDurationPreset.fromMinutes(setup.durationMinutes),
      );
      final repository = _ref.read(focusTreeRepositoryProvider);
      await repository.writeTransaction(
        (transaction) => transaction.saveSession(session),
      );
      if (mounted) {
        state = FocusSessionFlowState(session: session);
      }
      return session;
    } on Object catch (error) {
      if (mounted) {
        state = state.copyWith(isBusy: false, error: error);
      }
      rethrow;
    }
  }

  Future<void> allowFiveMinuteBypass() async {
    final current = _requireActiveSession();
    if (state.isBusy) return;
    state = state.copyWith(isBusy: true, clearError: true);

    try {
      final repository = _ref.read(focusTreeRepositoryProvider);
      final updated = await repository.writeTransaction((transaction) async {
        final persisted = await transaction.findSessionById(current.id);
        if (persisted == null) {
          throw FocusSessionNotFoundException(current.id);
        }
        if (persisted.usedFiveMinuteBypass) {
          return persisted;
        }
        final bypassed = persisted.applyBypass(
          action: BypassAction.allowFiveMinutes,
          occurredAtUtc: _ref.read(localNowProvider)().toUtc(),
        );
        await transaction.saveSession(bypassed);
        return bypassed;
      });
      if (mounted) {
        state = FocusSessionFlowState(session: updated);
      }
    } on Object catch (error) {
      if (mounted) {
        state = state.copyWith(isBusy: false, error: error);
      }
      rethrow;
    }
  }

  Future<TreeCompletionViewData> complete() {
    final pending = _pendingCompletion;
    if (pending != null) return pending;

    late final Future<TreeCompletionViewData> operation;
    operation = _completeOnce().whenComplete(() {
      if (identical(_pendingCompletion, operation)) {
        _pendingCompletion = null;
      }
    });
    _pendingCompletion = operation;
    return operation;
  }

  Future<TreeCompletionViewData> _completeOnce() async {
    final current = _requireSession();
    final endedAtUtc = _ref.read(localNowProvider)().toUtc();
    if (!current.isTerminal) {
      final completesAt = current.startedAtUtc.add(current.plannedDuration);
      if (endedAtUtc.isBefore(completesAt)) {
        throw FocusSessionNotElapsedException(
          completesAt.difference(endedAtUtc),
        );
      }
    }
    final result = await _finish(
      current: current,
      terminalStatus: FocusSessionStatus.completed,
      protectedDuration: current.plannedDuration,
      endedAtUtc: endedAtUtc,
    );
    final viewData = TreeCompletionViewData.fromCompletionResult(result);
    if (viewData == null) {
      throw StateError('A completed session did not produce tree progress.');
    }
    return viewData;
  }

  Future<void> endEarly() async {
    final current = state.session;
    if (current == null || current.isTerminal) return;
    await _finish(
      current: current,
      terminalStatus: FocusSessionStatus.endedEarly,
    );
  }

  Future<CompleteFocusSessionResult> _finish({
    required FocusSession current,
    required FocusSessionStatus terminalStatus,
    Duration? protectedDuration,
    DateTime? endedAtUtc,
  }) async {
    if (state.isBusy) {
      throw StateError('A focus session operation is already running.');
    }
    state = state.copyWith(isBusy: true, clearError: true);

    try {
      final repository = _ref.read(focusTreeRepositoryProvider);
      final result = await CompleteFocusSession(repository: repository)(
        sessionId: current.id,
        terminalStatus: terminalStatus,
        endedAtUtc: endedAtUtc ?? _ref.read(localNowProvider)().toUtc(),
        protectedDuration: protectedDuration,
      );
      if (mounted) {
        state = FocusSessionFlowState(session: result.session);
      }
      _ref
          .read(treeProgressControllerProvider.notifier)
          .applyCompletion(result);
      try {
        await _ref.read(weeklyGrowthDaysControllerProvider.notifier).refresh();
      } on Object {
        // The transaction already committed. A report refresh failure must not
        // make a successful focus completion look like a failed save.
      }
      return result;
    } on Object catch (error) {
      if (mounted) {
        state = state.copyWith(isBusy: false, error: error);
      }
      rethrow;
    }
  }

  FocusSession _requireSession() {
    final current = state.session;
    if (current == null) {
      throw StateError('Start a focus session before completing it.');
    }
    return current;
  }

  FocusSession _requireActiveSession() {
    final current = _requireSession();
    if (current.isTerminal) {
      throw StateError('The focus session has already ended.');
    }
    return current;
  }
}

String _newSessionId() {
  final random = Random.secure();
  final bytes = List<int>.generate(16, (_) => random.nextInt(256));
  bytes[6] = (bytes[6] & 0x0f) | 0x40;
  bytes[8] = (bytes[8] & 0x3f) | 0x80;
  final value = bytes
      .map((byte) => byte.toRadixString(16).padLeft(2, '0'))
      .join();
  return '${value.substring(0, 8)}-'
      '${value.substring(8, 12)}-'
      '${value.substring(12, 16)}-'
      '${value.substring(16, 20)}-'
      '${value.substring(20)}';
}
