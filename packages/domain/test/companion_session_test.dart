import 'package:dopa_domain/dopa_domain.dart';
import 'package:test/test.dart';

CompanionRun run({
  int stepIndex = 0,
  int stepCount = 4,
  bool guideCompleted = false,
  bool awaitingOutcome = false,
}) => CompanionRun(
  id: 'run',
  contentId: deskCompanionContent.id,
  contentVersion: 1,
  startedAtUtc: DateTime.utc(2026, 9, 10, 14, 59),
  startedLocalDate: LocalDate(2026, 9, 10),
  stepCount: stepCount,
  stepIndex: stepIndex,
  guideCompleted: guideCompleted,
  awaitingOutcome: awaitingOutcome,
);

void main() {
  test(
    'four guide advances ask for a result without creating a self-report',
    () {
      var current = run();
      for (var i = 0; i < 3; i++) {
        current = current.advanceGuide();
        expect(current.awaitingOutcome, isFalse);
      }
      current = current.advanceGuide();
      expect(current.guideCompleted, isTrue);
      expect(current.awaitingOutcome, isTrue);
      expect(current.stepIndex, 3);
      expect(current.startedLocalDate, LocalDate(2026, 9, 10));
      expect(identical(current.advanceGuide(), current), isTrue);
    },
  );

  test(
    'early end retains the current step without claiming guide completion',
    () {
      final current = run().advanceGuide().requestOutcome();
      expect(current.stepIndex, 1);
      expect(current.awaitingOutcome, isTrue);
      expect(current.guideCompleted, isFalse);
      expect(current.advanceGuide().stepIndex, 1);
    },
  );

  test('invalid progress and contradictory completion states are rejected', () {
    expect(() => run(stepIndex: -1), throwsArgumentError);
    expect(() => run(stepIndex: 4), throwsArgumentError);
    expect(() => run(stepCount: 0), throwsArgumentError);
    expect(() => run(guideCompleted: true), throwsArgumentError);
    expect(() => run(stepIndex: 3, guideCompleted: true), throwsArgumentError);
    expect(
      () => run(guideCompleted: true, awaitingOutcome: true),
      throwsArgumentError,
    );
  });
}
