import '../shared/validation.dart';
import 'focus_session.dart';

/// How an unfinished local session should be treated after process death,
/// reboot, or a wall-clock jump.
enum ActiveFocusRecoveryKind {
  /// The planned window is still open. Resume the timer.
  resume,

  /// The planned duration has elapsed, but the session is still inside the
  /// recovery grace. Do not auto-complete; let the user confirm completion.
  complete,

  /// The attempt is no longer trustworthy. Finalize as [FocusSessionStatus.invalidRecovery]
  /// without tree growth and keep [FocusSession.intention] for a new start.
  invalidate,
}

/// Product recovery window after the planned end.
///
/// Brief OEM kills and reboots fit inside an hour. An overnight or multi-hour
/// abandoned row must not be completed for growth. A wall clock earlier than
/// [FocusSession.startedAtUtc] is treated the same way because elapsed time
/// cannot be trusted.
const Duration activeFocusRecoveryGrace = Duration(hours: 1);

/// Classifies an active session against [nowUtc].
///
/// Terminal sessions are not recovered here; callers should ignore them.
ActiveFocusRecoveryKind classifyActiveFocusRecovery({
  required FocusSession session,
  required DateTime nowUtc,
}) {
  requireUtc(nowUtc, 'nowUtc');
  if (session.isTerminal) {
    throw ArgumentError.value(
      session.status,
      'session',
      'Only active sessions can be classified for recovery.',
    );
  }

  final plannedEnd = session.startedAtUtc.add(session.plannedDuration);
  final invalidAt = plannedEnd.add(activeFocusRecoveryGrace);

  if (nowUtc.isBefore(session.startedAtUtc)) {
    return ActiveFocusRecoveryKind.invalidate;
  }
  if (nowUtc.isBefore(plannedEnd)) {
    return ActiveFocusRecoveryKind.resume;
  }
  if (nowUtc.isBefore(invalidAt)) {
    return ActiveFocusRecoveryKind.complete;
  }
  return ActiveFocusRecoveryKind.invalidate;
}

/// Instant used when finalizing an invalidated session.
///
/// Clock rollback cannot produce an [FocusSession.endedAtUtc] before start, so
/// the start instant is reused.
DateTime invalidRecoveryEndedAtUtc({
  required FocusSession session,
  required DateTime nowUtc,
}) {
  requireUtc(nowUtc, 'nowUtc');
  if (nowUtc.isBefore(session.startedAtUtc)) {
    return session.startedAtUtc;
  }
  return nowUtc;
}
