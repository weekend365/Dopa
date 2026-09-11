import 'package:dopa/app/dopa_app.dart';
import 'package:dopa/app/router/dopa_router.dart';
import 'package:dopa/features/companion/application/companion_controller.dart';
import 'package:dopa/features/companion/application/companion_media.dart';
import 'package:dopa/features/today/presentation/today_page.dart';
import 'package:dopa/features/companion/presentation/companion_copy.dart';
import 'package:dopa/features/tree_companion/application/tree_companion_providers.dart';
import 'package:dopa_domain/dopa_domain.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'fake_companion_repository.dart';

void main() {
  late FakeCompanionRepository repo;
  late ProviderContainer container;
  setUp(() {
    repo = FakeCompanionRepository();
    container = ProviderContainer(
      overrides: [
        companionMediaProvider.overrideWith((ref) async => null),
        companionRepositoryProvider.overrideWithValue(repo),
        companionSampleEnabledProvider.overrideWithValue(true),
        activeDestinationProvider.overrideWith((ref) => Stream.value(null)),
        treeProgressProvider.overrideWithValue(
          const TreeGrowthPolicy().progressFor(7),
        ),
      ],
    );
  });
  tearDown(() => container.dispose());
  Future<void> tap(WidgetTester t, Finder f) async {
    if (f.evaluate().isEmpty) await t.scrollUntilVisible(f, 150);
    await t.ensureVisible(f);
    await t.pumpAndSettle();
    await t.tap(f);
    await t.pumpAndSettle();
  }

  Future<void> open(WidgetTester t) async {
    container.read(dopaRouterProvider).go('/companion');
    await t.pumpWidget(
      UncontrolledProviderScope(container: container, child: const DopaApp()),
    );
    await t.pumpAndSettle();
  }

  Future<void> start(WidgetTester t) async {
    await open(t);
    await tap(t, find.byKey(const ValueKey('companion-start')));
  }

  testWidgets(
    'guide advances only by Next; end does not automatically record',
    (t) async {
      await start(t);
      await t.pump(const Duration(minutes: 3));
      expect(repo.active!.stepIndex, 0);
      expect(find.byType(SwitchListTile), findsNothing);
      for (var i = 0; i < 4; i++) {
        await tap(t, find.byKey(const ValueKey('companion-next')));
      }
      expect(find.text('실제로 해본 만큼만'), findsOneWidget);
      expect(repo.records, isEmpty);
      await tap(t, find.text('조금 시작했어요'));
      expect(repo.records.single.outcome, CompanionOutcome.started);
      expect(find.text('5분 더 집중하기'), findsOneWidget);
      expect(find.text('여기서 마치기'), findsOneWidget);
      await t.pumpWidget(const SizedBox());
    },
  );
  for (final outcome in CompanionOutcome.values) {
    testWidgets('voluntary early result ${outcome.name}', (t) async {
      await start(t);
      await tap(t, find.text('여기서 마치고 결과 선택'));
      await tap(t, find.text(companionOutcomeLabel(outcome)));
      expect(repo.records.single.outcome, outcome);
      expect(repo.records.single.run.guideCompleted, false);
      expect(find.text(companionClosingCopy(outcome)), findsOneWidget);
      await t.pumpWidget(const SizedBox());
    });
  }
  testWidgets('pause and re-entry preserve the step', (t) async {
    await start(t);
    await tap(t, find.byKey(const ValueKey('companion-next')));
    await tap(t, find.text('나중에 이어하기'));
    await open(t);
    expect(find.text('2 / 4'), findsOneWidget);
    expect(repo.records, isEmpty);
    await t.pumpWidget(const SizedBox());
  });
  testWidgets('save failure keeps outcome choices for idempotent retry', (
    t,
  ) async {
    await start(t);
    await tap(t, find.text('여기서 마치고 결과 선택'));
    repo.failSubmit = true;
    await tap(t, find.text('하려던 만큼 했어요'));
    expect(find.textContaining('저장하지 못했어요'), findsOneWidget);
    repo.failSubmit = false;
    await tap(t, find.text('하려던 만큼 했어요'));
    expect(repo.records, hasLength(1));
    await t.pumpWidget(const SizedBox());
  });
  testWidgets('read failure is recoverable', (t) async {
    repo.failRead = true;
    await open(t);
    expect(find.text('다시 시도하기'), findsOneWidget);
    repo.failRead = false;
    await tap(t, find.text('다시 시도하기'));
    expect(find.byKey(const ValueKey('companion-start')), findsOneWidget);
    await t.pumpWidget(const SizedBox());
  });
  testWidgets(
    '320 width and 200 percent Korean guide and results remain operable',
    (t) async {
      t.view.physicalSize = const Size(320, 700);
      t.view.devicePixelRatio = 1;
      t.platformDispatcher.textScaleFactorTestValue = 2;
      addTearDown(t.view.resetPhysicalSize);
      addTearDown(t.view.resetDevicePixelRatio);
      addTearDown(t.platformDispatcher.clearTextScaleFactorTestValue);
      await start(t);
      expect(t.takeException(), isNull);
      await tap(t, find.text('여기서 마치고 결과 선택'));
      await tap(t, find.text('조금 시작했어요'));
      await t.scrollUntilVisible(find.text('5분 더 집중하기'), 150);
      expect(t.takeException(), isNull);
      await t.pumpWidget(const SizedBox());
    },
  );
}
