import 'package:dopa_domain/dopa_domain.dart';
import 'package:test/test.dart';

void main() {
  final startedAtUtc = DateTime.utc(2026, 8, 27, 3);
  final session = FocusSession(
    id: 'recover-session',
    startedAtUtc: startedAtUtc,
    startedLocalDate: LocalDate(2026, 8, 27),
    protectionMode: ProtectionMode.timerOnly,
    preset: SessionDurationPreset.tenMinutes,
    intention: '읽던 문서 한 단락 마치기',
  );

  ActiveFocusRecoveryKind classify(DateTime nowUtc) =>
      classifyActiveFocusRecovery(session: session, nowUtc: nowUtc);

  test('resumes while the planned window is still open', () {
    expect(classify(startedAtUtc), ActiveFocusRecoveryKind.resume);
    expect(
      classify(startedAtUtc.add(const Duration(minutes: 9, seconds: 59))),
      ActiveFocusRecoveryKind.resume,
    );
  });

  test('allows completion during the one-hour grace after planned end', () {
    expect(
      classify(startedAtUtc.add(const Duration(minutes: 10))),
      ActiveFocusRecoveryKind.complete,
    );
    expect(
      classify(
        startedAtUtc.add(const Duration(hours: 1, minutes: 9, seconds: 59)),
      ),
      ActiveFocusRecoveryKind.complete,
    );
  });

  test('invalidates a session abandoned past the grace window', () {
    expect(
      classify(startedAtUtc.add(const Duration(hours: 1, minutes: 10))),
      ActiveFocusRecoveryKind.invalidate,
    );
  });

  test('invalidates a wall clock earlier than session start', () {
    expect(
      classify(startedAtUtc.subtract(const Duration(seconds: 1))),
      ActiveFocusRecoveryKind.invalidate,
    );
    expect(
      invalidRecoveryEndedAtUtc(
        session: session,
        nowUtc: startedAtUtc.subtract(const Duration(minutes: 5)),
      ),
      startedAtUtc,
    );
  });

  test('uses now as the invalid recovery end after a forward jump', () {
    final now = startedAtUtc.add(const Duration(hours: 8));
    expect(invalidRecoveryEndedAtUtc(session: session, nowUtc: now), now);
  });

  test('refuses to classify a terminal session', () {
    final ended = session.finish(
      status: FocusSessionStatus.endedEarly,
      endedAtUtc: startedAtUtc.add(const Duration(minutes: 2)),
    );
    expect(
      () => classifyActiveFocusRecovery(
        session: ended,
        nowUtc: startedAtUtc.add(const Duration(minutes: 3)),
      ),
      throwsArgumentError,
    );
  });
}
