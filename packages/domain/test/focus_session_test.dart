import 'package:dopa_domain/dopa_domain.dart';
import 'package:test/test.dart';

void main() {
  final startedAtUtc = DateTime.utc(2026, 8, 26, 1);
  final localDate = LocalDate(2026, 8, 26);

  FocusSession activeSession({
    ProtectionMode protectionMode = ProtectionMode.shield,
  }) =>
      FocusSession(
        id: 'session-stable-id',
        startedAtUtc: startedAtUtc,
        startedLocalDate: localDate,
        protectionMode: protectionMode,
      );

  group('FocusSession invariants', () {
    test('supports only the four product duration presets', () {
      expect(SessionDurationPreset.fromMinutes(5).minutes, 5);
      expect(SessionDurationPreset.fromMinutes(10).duration,
          const Duration(minutes: 10));
      expect(SessionDurationPreset.fromMinutes(25).minutes, 25);
      expect(SessionDurationPreset.fromMinutes(50).minutes, 50);
      expect(
        () => SessionDurationPreset.fromMinutes(15),
        throwsArgumentError,
      );
    });

    test('keeps a stable ID and logical start date through completion', () {
      final completed = activeSession()
          .copyWith(
            preset: SessionDurationPreset.twentyFiveMinutes,
          )
          .finish(
            status: FocusSessionStatus.completed,
            endedAtUtc: startedAtUtc.add(const Duration(minutes: 25)),
            protectedDuration: const Duration(minutes: 8),
          );

      expect(completed.id, 'session-stable-id');
      expect(completed.startedLocalDate, localDate);
      expect(completed.preset, SessionDurationPreset.twentyFiveMinutes);
      expect(completed.plannedDuration, const Duration(minutes: 25));
      expect(completed.protectedDuration, const Duration(minutes: 8));
      expect(completed.isTerminal, isTrue);
      expect(completed.isNormallyCompleted, isTrue);
      expect(completed.qualifiesForTreeGrowth, isTrue);
    });

    test('requires nonblank IDs and UTC timestamps', () {
      expect(
        () => FocusSession(
          id: '  ',
          startedAtUtc: startedAtUtc,
          startedLocalDate: localDate,
          protectionMode: ProtectionMode.timerOnly,
        ),
        throwsArgumentError,
      );
      expect(
        () => FocusSession(
          id: 'session',
          startedAtUtc: DateTime(2026, 8, 26),
          startedLocalDate: localDate,
          protectionMode: ProtectionMode.timerOnly,
        ),
        throwsArgumentError,
      );
    });

    test('rejects negative protected duration', () {
      expect(
        () => FocusSession(
          id: 'session',
          startedAtUtc: startedAtUtc,
          startedLocalDate: localDate,
          protectionMode: ProtectionMode.shield,
          protectedDuration: const Duration(seconds: -1),
        ),
        throwsArgumentError,
      );
    });

    test('requires active/terminal timestamps to match status', () {
      expect(
        () => FocusSession(
          id: 'session',
          startedAtUtc: startedAtUtc,
          startedLocalDate: localDate,
          protectionMode: ProtectionMode.shield,
          endedAtUtc: startedAtUtc.add(const Duration(minutes: 1)),
        ),
        throwsArgumentError,
      );
      expect(
        () => FocusSession(
          id: 'session',
          startedAtUtc: startedAtUtc,
          startedLocalDate: localDate,
          protectionMode: ProtectionMode.shield,
          status: FocusSessionStatus.completed,
        ),
        throwsArgumentError,
      );
    });

    test('normal completion cannot finish before the planned duration', () {
      expect(
        () => activeSession().finish(
          status: FocusSessionStatus.completed,
          endedAtUtc: startedAtUtc.add(
            const Duration(minutes: 9, seconds: 59),
          ),
        ),
        throwsArgumentError,
      );
    });
  });

  group('bypass and completion semantics', () {
    test('allowFiveMinutes preserves an active, growth-eligible path', () {
      final bypassed = activeSession().applyBypass(
        action: BypassAction.allowFiveMinutes,
        occurredAtUtc: startedAtUtc.add(const Duration(minutes: 2)),
      );
      final completed = bypassed.finish(
        status: FocusSessionStatus.completed,
        endedAtUtc: startedAtUtc.add(const Duration(minutes: 10)),
      );

      expect(bypassed.status, FocusSessionStatus.active);
      expect(bypassed.usedFiveMinuteBypass, isTrue);
      expect(bypassed.preset, SessionDurationPreset.tenMinutes);
      expect(bypassed.protectedDuration, Duration.zero);
      expect(completed.qualifiesForTreeGrowth, isTrue);
    });

    test('endSession ends early and is not growth eligible', () {
      final ended = activeSession().applyBypass(
        action: BypassAction.endSession,
        occurredAtUtc: startedAtUtc.add(const Duration(minutes: 2)),
      );

      expect(ended.status, FocusSessionStatus.endedEarly);
      expect(ended.qualifiesForTreeGrowth, isFalse);
    });

    test('cancel dismisses bypass without cancelling the session', () {
      final session = activeSession();
      final afterCancel = session.applyBypass(
        action: BypassAction.cancel,
        occurredAtUtc: startedAtUtc.add(const Duration(minutes: 2)),
      );

      expect(identical(afterCancel, session), isTrue);
      expect(afterCancel.status, FocusSessionStatus.active);
    });

    test('only normal completion qualifies across protection modes', () {
      for (final protectionMode in ProtectionMode.values) {
        final completed = activeSession(protectionMode: protectionMode).finish(
          status: FocusSessionStatus.completed,
          endedAtUtc: startedAtUtc.add(const Duration(minutes: 10)),
        );
        expect(completed.qualifiesForTreeGrowth, isTrue);
      }

      for (final status in <FocusSessionStatus>[
        FocusSessionStatus.endedEarly,
        FocusSessionStatus.cancelled,
        FocusSessionStatus.invalidRecovery,
      ]) {
        final ended = activeSession().finish(
          status: status,
          endedAtUtc: startedAtUtc.add(const Duration(minutes: 2)),
        );
        expect(ended.qualifiesForTreeGrowth, isFalse);
      }
    });

    test('duration and protected time do not affect growth eligibility', () {
      for (final preset in SessionDurationPreset.values) {
        final completed = activeSession()
            .copyWith(
              preset: preset,
              protectedDuration: Duration(minutes: preset.minutes ~/ 2),
            )
            .finish(
              status: FocusSessionStatus.completed,
              endedAtUtc: startedAtUtc.add(preset.duration),
            );

        expect(completed.qualifiesForTreeGrowth, isTrue);
      }
    });
  });
}
