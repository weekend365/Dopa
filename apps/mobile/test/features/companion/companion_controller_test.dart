import 'dart:async';

import 'package:dopa/core/app_environment.dart';
import 'package:dopa/features/companion/application/companion_controller.dart';
import 'package:dopa_domain/dopa_domain.dart';
import 'package:flutter_test/flutter_test.dart';

import 'fake_companion_repository.dart';

void main() {
  late FakeCompanionRepository repo;
  late CompanionController controller;
  var saved = 0;
  var ids = 0;
  setUp(() async {
    repo = FakeCompanionRepository();
    saved = 0;
    controller = CompanionController(
      repository: repo,
      now: () => DateTime(2026, 9, 10, 23, 59),
      newId: () => 'run-${ids++}',
      onSaved: () => saved++,
    );
    await Future<void>.delayed(Duration.zero);
  });
  tearDown(() => controller.dispose());

  test('completed text guide is available in every flavor', () {
    expect(companionSampleAvailable(DopaEnvironment.dev), isTrue);
    expect(companionSampleAvailable(DopaEnvironment.prod), isTrue);
  });

  test('restore is paused and preserves the saved stage', () async {
    await controller.start();
    await controller.next();
    await controller.load();
    expect(controller.state.run!.stepIndex, 1);
    expect(controller.state.playing, isFalse);
    expect(controller.state.record, isNull);
    expect(saved, 0);
  });

  test('read and start failures show no success and allow retry', () async {
    repo.failRead = true;
    expect(await controller.load(), isFalse);
    expect(controller.state.failure, CompanionFailure.dataUnavailable);
    repo.failRead = false;
    await controller.load();
    repo.failStart = true;
    expect(await controller.start(), isFalse);
    expect(repo.active, isNull);
    repo.failStart = false;
    expect(await controller.start(), isTrue);
    expect(controller.state.run, isNotNull);
  });

  test(
    'failed progress stays on the current step and permits retry or early end',
    () async {
      await controller.start();
      repo.failNext = true;
      expect(await controller.next(), isFalse);
      expect(controller.state.run!.stepIndex, 0);
      expect(controller.state.playing, isFalse);
      repo.failNext = false;
      expect(await controller.next(), isTrue);
      expect(controller.state.run!.stepIndex, 1);
      await controller.finishGuide();
      expect(controller.state.run!.guideCompleted, isFalse);
      expect(controller.state.run!.awaitingOutcome, isTrue);
    },
  );

  test('all guide steps end only in an unanswered result screen', () async {
    await controller.start();
    for (var i = 0; i < 4; i++) {
      await controller.next();
    }
    expect(controller.state.run!.guideCompleted, isTrue);
    expect(controller.state.run!.awaitingOutcome, isTrue);
    expect(controller.state.playing, isFalse);
    expect(repo.records, isEmpty);
    expect(saved, 0);
  });

  test('failure and double tap do not report saved twice', () async {
    await controller.start();
    await controller.finishGuide();
    repo.failSubmit = true;
    expect(await controller.submit(CompanionOutcome.started), isFalse);
    expect(controller.state.record, isNull);
    expect(saved, 0);
    repo.failSubmit = false;
    repo.submitGate = Completer<void>();
    final pending = controller.submit(CompanionOutcome.started);
    expect(await controller.submit(CompanionOutcome.asPlanned), isFalse);
    repo.submitGate!.complete();
    await pending;
    expect(controller.state.record!.outcome, CompanionOutcome.started);
    await controller.submit(CompanionOutcome.difficult);
    expect(repo.records, hasLength(1));
    expect(saved, 1);
    expect(repo.submissions, 2); // One failed attempt, one committed attempt.
  });

  test('background while a save is pending cannot restart playback', () async {
    await controller.start();
    repo.nextGate = Completer<void>();
    final pending = controller.next();
    controller.pause();
    repo.nextGate!.complete();
    await pending;
    expect(controller.state.run!.stepIndex, 1);
    expect(controller.state.playing, isFalse);
  });

  test(
    'unsupported saved content is not silently played as the current version',
    () async {
      repo.active = CompanionRun(
        id: 'old',
        contentId: 'desk_space',
        contentVersion: 99,
        startedAtUtc: DateTime.utc(2026, 9, 10),
        startedLocalDate: LocalDate(2026, 9, 10),
        stepCount: 4,
      );
      await controller.load();
      expect(controller.state.failure, CompanionFailure.contentUnavailable);
      expect(controller.state.playing, isFalse);
      expect(repo.active!.contentVersion, 99);
    },
  );
}
