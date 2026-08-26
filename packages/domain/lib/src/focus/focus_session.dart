import '../shared/local_date.dart';
import '../shared/validation.dart';

enum ProtectionMode { shield, accessibility, timerOnly }

enum SessionDurationPreset {
  fiveMinutes(5),
  tenMinutes(10),
  twentyFiveMinutes(25),
  fiftyMinutes(50);

  const SessionDurationPreset(this.minutes);

  final int minutes;

  Duration get duration => Duration(minutes: minutes);

  static SessionDurationPreset fromMinutes(int minutes) => switch (minutes) {
        5 => SessionDurationPreset.fiveMinutes,
        10 => SessionDurationPreset.tenMinutes,
        25 => SessionDurationPreset.twentyFiveMinutes,
        50 => SessionDurationPreset.fiftyMinutes,
        _ => throw ArgumentError.value(
            minutes,
            'minutes',
            'Only 5, 10, 25, and 50 minute presets are supported.',
          ),
      };
}

/// A choice made from the two-step safety bypass UI.
///
/// [cancel] dismisses the bypass choice and does not cancel the focus session.
enum BypassAction { allowFiveMinutes, endSession, cancel }

enum FocusSessionStatus {
  active,
  completed,
  endedEarly,
  cancelled,
  invalidRecovery,
}

extension FocusSessionStatusSemantics on FocusSessionStatus {
  bool get isTerminal => this != FocusSessionStatus.active;
}

/// A locally persisted focus attempt.
///
/// [id] and [startedLocalDate] are captured at session start and never change.
/// Only a normally [FocusSessionStatus.completed] session is eligible for tree
/// growth. Protection mode and a five-minute bypass do not affect eligibility.
final class FocusSession {
  factory FocusSession({
    required String id,
    required DateTime startedAtUtc,
    required LocalDate startedLocalDate,
    required ProtectionMode protectionMode,
    SessionDurationPreset preset = SessionDurationPreset.tenMinutes,
    Duration protectedDuration = Duration.zero,
    FocusSessionStatus status = FocusSessionStatus.active,
    DateTime? endedAtUtc,
    bool usedFiveMinuteBypass = false,
  }) {
    final validId = requireNonBlank(id, 'id');
    final validStartedAtUtc = requireUtc(startedAtUtc, 'startedAtUtc');
    if (protectedDuration.isNegative) {
      throw ArgumentError.value(
        protectedDuration,
        'protectedDuration',
        'Must not be negative.',
      );
    }
    if (status.isTerminal != (endedAtUtc != null)) {
      throw ArgumentError(
        'Active sessions must not have endedAtUtc, and terminal sessions must '
        'have endedAtUtc.',
      );
    }
    if (endedAtUtc != null) {
      requireUtc(endedAtUtc, 'endedAtUtc');
      if (endedAtUtc.isBefore(validStartedAtUtc)) {
        throw ArgumentError.value(
          endedAtUtc,
          'endedAtUtc',
          'Must not be before startedAtUtc.',
        );
      }
      if (status == FocusSessionStatus.completed &&
          endedAtUtc.isBefore(validStartedAtUtc.add(preset.duration))) {
        throw ArgumentError.value(
          endedAtUtc,
          'endedAtUtc',
          'A completed session must reach its planned duration.',
        );
      }
    }

    return FocusSession._(
      id: validId,
      startedAtUtc: validStartedAtUtc,
      startedLocalDate: startedLocalDate,
      protectionMode: protectionMode,
      preset: preset,
      protectedDuration: protectedDuration,
      status: status,
      endedAtUtc: endedAtUtc,
      usedFiveMinuteBypass: usedFiveMinuteBypass,
    );
  }

  const FocusSession._({
    required this.id,
    required this.startedAtUtc,
    required this.startedLocalDate,
    required this.protectionMode,
    required this.preset,
    required this.protectedDuration,
    required this.status,
    required this.endedAtUtc,
    required this.usedFiveMinuteBypass,
  });

  final String id;
  final DateTime startedAtUtc;
  final LocalDate startedLocalDate;
  final ProtectionMode protectionMode;
  final SessionDurationPreset preset;

  /// Planned time is fixed by [preset]; arbitrary durations are not accepted.
  Duration get plannedDuration => preset.duration;

  /// Time for which a native or timer-only protection adapter was effective.
  /// This metric never affects whether the session can grow the tree.
  final Duration protectedDuration;
  final FocusSessionStatus status;
  final DateTime? endedAtUtc;
  final bool usedFiveMinuteBypass;

  bool get isTerminal => status.isTerminal;
  bool get isNormallyCompleted => status == FocusSessionStatus.completed;
  bool get qualifiesForTreeGrowth => isNormallyCompleted;

  FocusSession applyBypass({
    required BypassAction action,
    required DateTime occurredAtUtc,
  }) {
    if (isTerminal) {
      throw StateError('A terminal focus session cannot accept a bypass.');
    }
    requireUtc(occurredAtUtc, 'occurredAtUtc');
    if (occurredAtUtc.isBefore(startedAtUtc)) {
      throw ArgumentError.value(
        occurredAtUtc,
        'occurredAtUtc',
        'Must not be before startedAtUtc.',
      );
    }

    return switch (action) {
      BypassAction.allowFiveMinutes => copyWith(usedFiveMinuteBypass: true),
      BypassAction.endSession => finish(
          status: FocusSessionStatus.endedEarly,
          endedAtUtc: occurredAtUtc,
        ),
      BypassAction.cancel => this,
    };
  }

  FocusSession finish({
    required FocusSessionStatus status,
    required DateTime endedAtUtc,
    Duration? protectedDuration,
  }) {
    if (isTerminal) {
      throw StateError('A terminal focus session cannot be finalized again.');
    }
    if (!status.isTerminal) {
      throw ArgumentError.value(
        status,
        'status',
        'A final status must be terminal.',
      );
    }

    return copyWith(
      status: status,
      endedAtUtc: endedAtUtc,
      protectedDuration: protectedDuration,
    );
  }

  FocusSession copyWith({
    ProtectionMode? protectionMode,
    SessionDurationPreset? preset,
    Duration? protectedDuration,
    FocusSessionStatus? status,
    DateTime? endedAtUtc,
    bool? usedFiveMinuteBypass,
  }) =>
      FocusSession(
        id: id,
        startedAtUtc: startedAtUtc,
        startedLocalDate: startedLocalDate,
        protectionMode: protectionMode ?? this.protectionMode,
        preset: preset ?? this.preset,
        protectedDuration: protectedDuration ?? this.protectedDuration,
        status: status ?? this.status,
        endedAtUtc: endedAtUtc ?? this.endedAtUtc,
        usedFiveMinuteBypass: usedFiveMinuteBypass ?? this.usedFiveMinuteBypass,
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FocusSession &&
          id == other.id &&
          startedAtUtc == other.startedAtUtc &&
          startedLocalDate == other.startedLocalDate &&
          protectionMode == other.protectionMode &&
          preset == other.preset &&
          protectedDuration == other.protectedDuration &&
          status == other.status &&
          endedAtUtc == other.endedAtUtc &&
          usedFiveMinuteBypass == other.usedFiveMinuteBypass;

  @override
  int get hashCode => Object.hash(
        id,
        startedAtUtc,
        startedLocalDate,
        protectionMode,
        preset,
        protectedDuration,
        status,
        endedAtUtc,
        usedFiveMinuteBypass,
      );
}
