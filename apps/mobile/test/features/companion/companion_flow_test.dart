import 'package:dopa/app/dopa_app.dart';
import 'package:dopa/app/router/dopa_router.dart';
import 'package:dopa/features/companion/application/companion_controller.dart';
import 'package:dopa/features/companion/presentation/companion_copy.dart';
import 'package:dopa/features/experiment/application/daily_check_in_controller.dart';
import 'package:dopa/features/focus/application/focus_session_controller.dart';
import 'package:dopa/features/tree_companion/application/tree_companion_providers.dart';
import 'package:dopa_domain/dopa_domain.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'fake_companion_repository.dart';

void main() {
  late FakeCompanionRepository repo;
  late ProviderContainer container;
  var nextId = 0;
  setUp(() {
    repo = FakeCompanionRepository();
    container = ProviderContainer(
      overrides: [
        companionRepositoryProvider.overrideWithValue(repo),
        companionSampleEnabledProvider.overrideWithValue(true),
        treeProgressProvider.overrideWithValue(
          const TreeGrowthPolicy().progressFor(7),
        ),
        experimentAttemptDaysProvider.overrideWithValue(2),
        weeklyGrowthDaysProvider.overrideWithValue(1),
        todaysCheckInProvider.overrideWithValue(null),
        localNowProvider.overrideWithValue(() => DateTime(2026, 9, 10, 12)),
        sessionIdFactoryProvider.overrideWithValue(() => 'run-${nextId++}'),
      ],
    );
  });
  tearDown(() => container.dispose());

  Future<void> pumpApp(
    WidgetTester tester, {
    String route = '/companion',
  }) async {
    container.read(dopaRouterProvider).go(route);
    await tester.pumpWidget(
      UncontrolledProviderScope(container: container, child: const DopaApp()),
    );
    await tester.pumpAndSettle();
  }

  Future<void> tap(WidgetTester tester, Finder finder) async {
    await tester.ensureVisible(finder);
    await tester.pumpAndSettle();
    await tester.tap(finder);
    await tester.pumpAndSettle();
  }

  Future<void> start(WidgetTester tester) async {
    await pumpApp(tester);
    await tap(tester, find.byKey(const ValueKey('companion-start')));
  }

  testWidgets(
    'home → free guide → explicit result → separate history and home',
    (tester) async {
      await pumpApp(tester, route: '/today');
      expect(find.text('10분 집중 시작'), findsOneWidget);
      await tester.scrollUntilVisible(
        find.byKey(const ValueKey('companion-entry-start')),
        150,
      );
      await tap(tester, find.byKey(const ValueKey('companion-entry-start')));
      expect(find.textContaining('영상과 음성은 아직 제공하지 않아요'), findsOneWidget);
      await tap(tester, find.byKey(const ValueKey('companion-start')));
      for (var i = 0; i < 4; i++) {
        await tap(tester, find.byKey(const ValueKey('companion-next')));
      }
      expect(find.text('안내가 끝났어요'), findsOneWidget);
      expect(repo.records, isEmpty);
      await tap(tester, find.text('조금 시작했어요'));
      expect(repo.records.single.outcome, CompanionOutcome.started);
      expect(find.textContaining('작게 시작한 것도 기록으로 남겼어요'), findsOneWidget);
      await tap(tester, find.text('생활 행동 기록 보기'));
      expect(find.text('2026-09-10 · 직접 확인'), findsOneWidget);
      expect(find.text('조금 시작했어요'), findsOneWidget);
      await tap(tester, find.byTooltip('오늘로 돌아가기'));
      expect(find.text('함께 자란 7일 · 작은 나무'), findsOneWidget);
      expect(find.text('2/7일'), findsOneWidget);
      await tester.pumpWidget(const SizedBox.shrink());
    },
  );

  for (final outcome in CompanionOutcome.values) {
    testWidgets(
      'early result ${outcome.name} is voluntary and gets a gentle ending',
      (tester) async {
        await start(tester);
        await tap(tester, find.text('여기서 마치고 결과 선택'));
        expect(repo.records, isEmpty);
        await tap(tester, find.text(companionOutcomeLabel(outcome)));
        expect(repo.records.single.outcome, outcome);
        expect(repo.records.single.run.guideCompleted, isFalse);
        expect(find.text(companionClosingCopy(outcome)), findsOneWidget);
        expect(find.text('오늘은 여기까지'), findsOneWidget);
        await tester.pumpWidget(const SizedBox.shrink());
      },
    );
  }

  testWidgets('leave and re-enter restores the pending step paused', (
    tester,
  ) async {
    await start(tester);
    await tap(tester, find.byKey(const ValueKey('companion-next')));
    await tap(tester, find.text('나중에 이어하기'));
    expect(repo.records, isEmpty);
    container.read(dopaRouterProvider).push('/companion');
    await tester.pumpAndSettle();
    expect(find.text('2 / 4 안내'), findsOneWidget);
    expect(find.text('이어하기'), findsOneWidget);
    await tap(tester, find.text('이어하기'));
    expect(find.text('일시정지'), findsOneWidget);
    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets(
    'automatic guide pauses on background, never records an outcome',
    (tester) async {
      await start(tester);
      await tap(tester, find.byType(SwitchListTile));
      await tester.pump(const Duration(seconds: 30));
      await tester.pumpAndSettle();
      expect(repo.active!.stepIndex, 1);
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
      await tester.pump(const Duration(minutes: 3));
      expect(repo.active!.stepIndex, 1);
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
      await tester.pumpAndSettle();
      expect(find.text('이어하기'), findsOneWidget);
      await tap(tester, find.text('이어하기'));
      for (var i = 0; i < 3; i++) {
        await tester.pump(const Duration(seconds: 30));
        await tester.pumpAndSettle();
      }
      expect(find.text('안내가 끝났어요'), findsOneWidget);
      expect(repo.records, isEmpty);
      await tester.pump(const Duration(minutes: 2));
      expect(repo.records, isEmpty);
      await tester.pumpWidget(const SizedBox.shrink());
    },
  );

  testWidgets('save error keeps choices available and retry stores once', (
    tester,
  ) async {
    await start(tester);
    await tap(tester, find.text('여기서 마치고 결과 선택'));
    repo.failSubmit = true;
    await tap(tester, find.text('하려던 만큼 했어요'));
    expect(find.textContaining('저장하지 못했어요'), findsOneWidget);
    expect(find.text('생활 행동 기록을 남겼어요'), findsNothing);
    repo.failSubmit = false;
    await tap(tester, find.text('하려던 만큼 했어요'));
    expect(repo.records, hasLength(1));
    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('read error can retry; pending result survives screen re-entry', (
    tester,
  ) async {
    repo.failRead = true;
    await pumpApp(tester);
    expect(find.text('다시 불러오기'), findsOneWidget);
    repo.failRead = false;
    await tap(tester, find.text('다시 불러오기'));
    await tap(tester, find.byKey(const ValueKey('companion-start')));
    await tap(tester, find.text('여기서 마치고 결과 선택'));
    await tap(tester, find.text('결과는 나중에 남기기'));
    container.read(dopaRouterProvider).push('/companion');
    await tester.pumpAndSettle();
    expect(find.text('조금 시작했어요'), findsOneWidget);
    expect(repo.records, isEmpty);
    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets(
    'history read/delete errors permit retry and individual deletion',
    (tester) async {
      await start(tester);
      await tap(tester, find.text('여기서 마치고 결과 선택'));
      await tap(tester, find.text('오늘은 어려웠어요'));
      repo.failHistory = true;
      await tap(tester, find.text('생활 행동 기록 보기'));
      expect(find.text('기록을 불러오지 못했어요.'), findsOneWidget);
      repo.failHistory = false;
      await tap(tester, find.text('다시 불러오기'));
      repo.failDelete = true;
      await tap(tester, find.text('기록 삭제'));
      await tap(tester, find.text('삭제'));
      expect(find.text('삭제하지 못했어요. 다시 시도해주세요.'), findsOneWidget);
      expect(repo.records, hasLength(1));
      repo.failDelete = false;
      await tap(tester, find.text('기록 삭제'));
      await tap(tester, find.text('삭제'));
      expect(find.text('아직 직접 남긴 생활 행동 기록이 없어요.'), findsOneWidget);
      await tester.pumpWidget(const SizedBox.shrink());
    },
  );

  testWidgets(
    '200% Korean guide, results and history fit a small phone and expose semantics',
    (tester) async {
      tester.view.physicalSize = const Size(320, 568);
      tester.view.devicePixelRatio = 1;
      tester.platformDispatcher.textScaleFactorTestValue = 2;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
      final semantics = tester.ensureSemantics();
      await start(tester);
      expect(tester.takeException(), isNull);
      await tap(tester, find.byKey(const ValueKey('companion-next')));
      expect(find.textContaining('손 닿는 곳의 종이만'), findsOneWidget);
      await tap(tester, find.text('여기서 마치고 결과 선택'));
      await tester.ensureVisible(find.text('조금 시작했어요'));
      await tester.pumpAndSettle();
      expect(
        tester.getSemantics(find.text('조금 시작했어요')),
        matchesSemantics(
          label: '조금 시작했어요',
          isButton: true,
          hasEnabledState: true,
          isEnabled: true,
          isFocusable: true,
          hasTapAction: true,
          hasFocusAction: true,
        ),
      );
      await tap(tester, find.text('조금 시작했어요'));
      await tap(tester, find.text('생활 행동 기록 보기'));
      await tester.ensureVisible(find.text('기록 삭제'));
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox.shrink());
      semantics.dispose();
    },
  );

  testWidgets('sample-off hides entry and rejects session/history deep links', (
    tester,
  ) async {
    container.updateOverrides([
      companionRepositoryProvider.overrideWithValue(repo),
      companionSampleEnabledProvider.overrideWithValue(false),
      treeProgressProvider.overrideWithValue(
        const TreeGrowthPolicy().progressFor(7),
      ),
      experimentAttemptDaysProvider.overrideWithValue(2),
      weeklyGrowthDaysProvider.overrideWithValue(1),
      todaysCheckInProvider.overrideWithValue(null),
      localNowProvider.overrideWithValue(() => DateTime(2026, 9, 10, 12)),
      sessionIdFactoryProvider.overrideWithValue(() => 'hidden'),
    ]);
    await pumpApp(tester, route: '/companion/history');
    expect(
      container
          .read(dopaRouterProvider)
          .routeInformationProvider
          .value
          .uri
          .path,
      '/today',
    );
    await tester.drag(find.byType(ListView).first, const Offset(0, -1000));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('companion-entry')), findsNothing);
    expect(repo.active, isNull);
    await tester.pumpWidget(const SizedBox.shrink());
  });
}
