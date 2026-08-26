import 'dart:async';

import 'package:dopa_domain/dopa_domain.dart';
import 'package:test/test.dart';

void main() {
  group('EnsureTreeCompanion', () {
    test('creates one seed tree and returns it on repeated calls', () async {
      final repository = _MemoryFocusTreeRepository();
      final ensureTree = EnsureTreeCompanion(repository: repository);
      final firstCreationAt = DateTime.utc(2026, 8, 26);

      final first = await ensureTree(createdAtUtc: firstCreationAt);
      final second = await ensureTree(
        createdAtUtc: firstCreationAt.add(const Duration(days: 1)),
      );

      expect(first, second);
      expect(first.species, TreeSpecies.zelkovaV1);
      expect(first.createdAtUtc, firstCreationAt);
      expect(first.ruleVersion, 1);
      expect(
          const TreeGrowthPolicy().progressFor(0).stage, TreeGrowthStage.seed);
      expect(repository.treeCreationCount, 1);
    });

    test('requires an explicit UTC creation timestamp', () {
      final ensureTree = EnsureTreeCompanion(
        repository: _MemoryFocusTreeRepository(),
      );

      expect(
        () => ensureTree(createdAtUtc: DateTime(2026, 8, 26)),
        throwsArgumentError,
      );
    });

    test('pre-created seed is reused by the first completed session', () async {
      final repository = _MemoryFocusTreeRepository();
      final createdAtUtc = DateTime.utc(2026, 8, 26);
      final seed = await EnsureTreeCompanion(repository: repository)(
        createdAtUtc: createdAtUtc,
      );
      final session = _session(id: 'first-after-consent');
      repository.sessions[session.id] = session;

      final result = await _complete(
        CompleteFocusSession(repository: repository),
        session,
      );

      expect(result.tree, seed);
      expect(repository.treeCreationCount, 1);
      expect(result.progress!.stage, TreeGrowthStage.sprout);
    });
  });

  group('CompleteFocusSession', () {
    test('atomically completes and awards the first normal session', () async {
      final repository = _MemoryFocusTreeRepository();
      final session = _session(id: 'session-1');
      repository.sessions[session.id] = session;
      final useCase = CompleteFocusSession(repository: repository);

      final result = await useCase(
        sessionId: session.id,
        terminalStatus: FocusSessionStatus.completed,
        endedAtUtc: session.startedAtUtc.add(const Duration(minutes: 10)),
        protectedDuration: const Duration(minutes: 7),
      );

      expect(result.awardStatus, GrowthAwardStatus.awarded);
      expect(result.didAwardGrowth, isTrue);
      expect(result.session.status, FocusSessionStatus.completed);
      expect(result.session.protectedDuration, const Duration(minutes: 7));
      expect(repository.sessions[session.id]!.status,
          FocusSessionStatus.completed);
      expect(result.credit!.sourceSessionId, session.id);
      expect(result.credit!.creditedLocalDate, session.startedLocalDate);
      expect(result.credit!.ruleVersion, 1);
      expect(result.tree!.species, TreeSpecies.zelkovaV1);
      expect(result.progress, const TypeMatcher<TreeProgress>());
      expect(result.progress!.totalGrowthDays, 1);
      expect(result.progress!.stage, TreeGrowthStage.sprout);
      expect(repository.credits, hasLength(1));
    });

    test('duplicate callbacks never add another ledger row', () async {
      final repository = _MemoryFocusTreeRepository();
      final session = _session(id: 'session-duplicate');
      repository.sessions[session.id] = session;
      final useCase = CompleteFocusSession(repository: repository);

      final first = await _complete(useCase, session);
      final persistedEnd = repository.sessions[session.id]!.endedAtUtc;
      final second = await useCase(
        sessionId: session.id,
        terminalStatus: FocusSessionStatus.completed,
        endedAtUtc: session.startedAtUtc.add(const Duration(minutes: 11)),
      );

      expect(first.awardStatus, GrowthAwardStatus.awarded);
      expect(
        second.awardStatus,
        GrowthAwardStatus.alreadyAwardedForSession,
      );
      expect(repository.sessions[session.id]!.endedAtUtc, persistedEnd);
      expect(repository.credits, hasLength(1));
      expect(second.progress!.totalGrowthDays, 1);
    });

    test('concurrent duplicate callbacks are conflict-safe', () async {
      final repository = _MemoryFocusTreeRepository();
      final session = _session(id: 'session-concurrent');
      repository.sessions[session.id] = session;
      final useCase = CompleteFocusSession(repository: repository);

      final results = await Future.wait(<Future<CompleteFocusSessionResult>>[
        _complete(useCase, session),
        _complete(useCase, session),
      ]);

      expect(
        results.map((result) => result.awardStatus),
        containsAll(<GrowthAwardStatus>[
          GrowthAwardStatus.awarded,
          GrowthAwardStatus.alreadyAwardedForSession,
        ]),
      );
      expect(repository.credits, hasLength(1));
    });

    test('two completed sessions on one logical date grow only once', () async {
      final repository = _MemoryFocusTreeRepository();
      final first = _session(id: 'same-day-1');
      final second = _session(
        id: 'same-day-2',
        startedAtUtc: first.startedAtUtc.add(const Duration(hours: 2)),
      );
      repository.sessions
        ..[first.id] = first
        ..[second.id] = second;
      final useCase = CompleteFocusSession(repository: repository);

      final firstResult = await _complete(useCase, first);
      final secondResult = await _complete(useCase, second);

      expect(firstResult.awardStatus, GrowthAwardStatus.awarded);
      expect(
        secondResult.awardStatus,
        GrowthAwardStatus.alreadyAwardedForLocalDate,
      );
      expect(
          repository.sessions[second.id]!.status, FocusSessionStatus.completed);
      expect(repository.credits, hasLength(1));
      expect(secondResult.progress!.totalGrowthDays, 1);
    });

    test('normal completion grows across every protection mode', () async {
      final repository = _MemoryFocusTreeRepository();
      final useCase = CompleteFocusSession(repository: repository);

      for (var index = 0; index < ProtectionMode.values.length; index++) {
        final session = _session(
          id: 'mode-$index',
          localDate: LocalDate(2026, 8, 26).addDays(index),
          protectionMode: ProtectionMode.values[index],
        );
        repository.sessions[session.id] = session;

        final result = await _complete(useCase, session);
        expect(result.awardStatus, GrowthAwardStatus.awarded);
      }

      expect(repository.credits, hasLength(ProtectionMode.values.length));
    });

    test('five-minute bypass followed by completion still grows', () async {
      final repository = _MemoryFocusTreeRepository();
      final original = _session(id: 'bypassed');
      final bypassed = original.applyBypass(
        action: BypassAction.allowFiveMinutes,
        occurredAtUtc: original.startedAtUtc.add(const Duration(minutes: 2)),
      );
      repository.sessions[bypassed.id] = bypassed;

      final result = await _complete(
        CompleteFocusSession(repository: repository),
        bypassed,
      );

      expect(result.awardStatus, GrowthAwardStatus.awarded);
      expect(result.session.usedFiveMinuteBypass, isTrue);
      expect(repository.credits, hasLength(1));
    });

    test('early end, cancellation, and invalid recovery never grow', () async {
      for (final status in <FocusSessionStatus>[
        FocusSessionStatus.endedEarly,
        FocusSessionStatus.cancelled,
        FocusSessionStatus.invalidRecovery,
      ]) {
        final repository = _MemoryFocusTreeRepository();
        final session = _session(id: 'ineligible-${status.name}');
        repository.sessions[session.id] = session;
        final result = await CompleteFocusSession(repository: repository)(
          sessionId: session.id,
          terminalStatus: status,
          endedAtUtc: session.startedAtUtc.add(const Duration(minutes: 2)),
        );

        expect(result.awardStatus, GrowthAwardStatus.ineligibleSession);
        expect(result.tree, isNull);
        expect(result.progress, isNull);
        expect(repository.credits, isEmpty);
      }
    });

    test('endSession bypass is an idempotent, ineligible early end', () async {
      final repository = _MemoryFocusTreeRepository();
      final original = _session(id: 'bypass-end');
      final ended = original.applyBypass(
        action: BypassAction.endSession,
        occurredAtUtc: original.startedAtUtc.add(const Duration(minutes: 2)),
      );
      repository.sessions[ended.id] = ended;
      final useCase = CompleteFocusSession(repository: repository);

      final result = await useCase(
        sessionId: ended.id,
        terminalStatus: FocusSessionStatus.endedEarly,
        endedAtUtc: ended.endedAtUtc!,
      );

      expect(result.awardStatus, GrowthAwardStatus.ineligibleSession);
      expect(repository.credits, isEmpty);
    });

    test('midnight and timezone changes cannot move the logical credit date',
        () async {
      final repository = _MemoryFocusTreeRepository();
      final session = _session(
        id: 'cross-midnight',
        localDate: LocalDate(2026, 8, 26),
        // 23:55 in Korea at start; completion is after local midnight.
        startedAtUtc: DateTime.utc(2026, 8, 26, 14, 55),
      );
      repository.sessions[session.id] = session;
      final useCase = CompleteFocusSession(repository: repository);

      final result = await useCase(
        sessionId: session.id,
        terminalStatus: FocusSessionStatus.completed,
        endedAtUtc: DateTime.utc(2026, 8, 26, 15, 5),
      );

      expect(result.credit!.creditedLocalDate, LocalDate(2026, 8, 26));
      expect(result.credit!.creditedAtUtc, DateTime.utc(2026, 8, 26, 15, 5));
    });

    test('a terminal status cannot later be rewritten as completed', () async {
      final repository = _MemoryFocusTreeRepository();
      final session = _session(id: 'conflict');
      repository.sessions[session.id] = session;
      final useCase = CompleteFocusSession(repository: repository);
      await useCase(
        sessionId: session.id,
        terminalStatus: FocusSessionStatus.endedEarly,
        endedAtUtc: session.startedAtUtc.add(const Duration(minutes: 2)),
      );

      await expectLater(
        _complete(useCase, session),
        throwsA(isA<FocusSessionFinalizationConflict>()),
      );
      expect(repository.credits, isEmpty);
    });

    test('rejects missing sessions and a nonterminal command', () async {
      final repository = _MemoryFocusTreeRepository();
      final useCase = CompleteFocusSession(repository: repository);

      await expectLater(
        useCase(
          sessionId: 'missing',
          terminalStatus: FocusSessionStatus.completed,
          endedAtUtc: DateTime.utc(2026, 8, 26),
        ),
        throwsA(isA<FocusSessionNotFoundException>()),
      );
      expect(
        () => useCase(
          sessionId: 'missing',
          terminalStatus: FocusSessionStatus.active,
          endedAtUtc: DateTime.utc(2026, 8, 26),
        ),
        throwsArgumentError,
      );
    });

    test('rejects completion before the persisted start instant', () async {
      final repository = _MemoryFocusTreeRepository();
      final session = _session(id: 'time-travel');
      repository.sessions[session.id] = session;

      await expectLater(
        CompleteFocusSession(repository: repository)(
          sessionId: session.id,
          terminalStatus: FocusSessionStatus.completed,
          endedAtUtc: session.startedAtUtc.subtract(const Duration(seconds: 1)),
        ),
        throwsArgumentError,
      );
    });

    test('rejects early completion without finalizing or growing', () async {
      final repository = _MemoryFocusTreeRepository();
      final session = _session(id: 'too-early');
      repository.sessions[session.id] = session;

      await expectLater(
        CompleteFocusSession(repository: repository)(
          sessionId: session.id,
          terminalStatus: FocusSessionStatus.completed,
          endedAtUtc: session.startedAtUtc.add(
            const Duration(minutes: 9, seconds: 59),
          ),
        ),
        throwsArgumentError,
      );

      expect(repository.sessions[session.id], session);
      expect(repository.credits, isEmpty);
    });

    test('derives one post-mature ring after 120 growth days', () async {
      final repository = _MemoryFocusTreeRepository();
      final useCase = CompleteFocusSession(repository: repository);
      CompleteFocusSessionResult? latest;

      for (var index = 0; index < 120; index++) {
        final session = _session(
          id: 'day-$index',
          localDate: LocalDate(2026, 1, 1).addDays(index),
        );
        repository.sessions[session.id] = session;
        latest = await _complete(useCase, session);
      }

      expect(repository.credits, hasLength(120));
      expect(latest!.progress!.totalGrowthDays, 120);
      expect(latest.progress!.stage, TreeGrowthStage.mature);
      expect(latest.progress!.nextThreshold, isNull);
      expect(latest.progress!.postMatureRingCount, 1);
    });

    test(
      'refuses to append credits to a tree with another rule version',
      () async {
        final repository = _MemoryFocusTreeRepository();
        final session = _session(id: 'rule-version-conflict');
        repository.sessions[session.id] = session;
        repository.tree = TreeCompanion(
          id: 'legacy-tree',
          createdAtUtc: session.startedAtUtc,
          ruleVersion: 2,
        );

        await expectLater(
          _complete(CompleteFocusSession(repository: repository), session),
          throwsA(isA<TreeRuleVersionConflict>()),
        );
        expect(repository.credits, isEmpty);
      },
    );
  });
}

FocusSession _session({
  required String id,
  LocalDate? localDate,
  DateTime? startedAtUtc,
  ProtectionMode protectionMode = ProtectionMode.timerOnly,
}) {
  final logicalDate = localDate ?? LocalDate(2026, 8, 26);
  return FocusSession(
    id: id,
    startedAtUtc: startedAtUtc ??
        DateTime.utc(logicalDate.year, logicalDate.month, logicalDate.day, 1),
    startedLocalDate: logicalDate,
    protectionMode: protectionMode,
  );
}

Future<CompleteFocusSessionResult> _complete(
  CompleteFocusSession useCase,
  FocusSession session,
) =>
    useCase(
      sessionId: session.id,
      terminalStatus: FocusSessionStatus.completed,
      endedAtUtc: session.startedAtUtc.add(const Duration(minutes: 10)),
    );

final class _MemoryFocusTreeRepository
    implements FocusTreeRepository, FocusTreeTransaction {
  final Map<String, FocusSession> sessions = <String, FocusSession>{};
  final List<TreeGrowthCredit> credits = <TreeGrowthCredit>[];
  TreeCompanion? tree;
  int treeCreationCount = 0;
  Future<void> _transactionTail = Future<void>.value();

  @override
  Future<T> writeTransaction<T>(
    Future<T> Function(FocusTreeTransaction transaction) operation,
  ) {
    final completer = Completer<T>();
    _transactionTail = _transactionTail.then((_) async {
      try {
        completer.complete(await operation(this));
      } on Object catch (error, stackTrace) {
        completer.completeError(error, stackTrace);
      }
    });
    return completer.future;
  }

  @override
  Future<FocusSession?> findSessionById(String sessionId) async =>
      sessions[sessionId];

  @override
  Future<void> saveSession(FocusSession session) async {
    sessions[session.id] = session;
  }

  @override
  Future<TreeCompanion> getOrCreateTree({
    required DateTime createdAtUtc,
    required int ruleVersion,
  }) async {
    if (tree == null) {
      tree = TreeCompanion(
        id: 'device-tree',
        createdAtUtc: createdAtUtc,
        ruleVersion: ruleVersion,
      );
      treeCreationCount += 1;
    }
    return tree!;
  }

  @override
  Future<TreeGrowthCredit?> findGrowthCreditBySourceSessionId(
    String sourceSessionId,
  ) async {
    for (final credit in credits) {
      if (credit.sourceSessionId == sourceSessionId) {
        return credit;
      }
    }
    return null;
  }

  @override
  Future<TreeGrowthCreditInsertOutcome> tryInsertGrowthCredit(
    TreeGrowthCredit credit,
  ) async {
    if (credits.any(
      (existing) => existing.sourceSessionId == credit.sourceSessionId,
    )) {
      return TreeGrowthCreditInsertOutcome.duplicateSourceSession;
    }
    if (credits.any(
      (existing) =>
          existing.treeId == credit.treeId &&
          existing.creditedLocalDate == credit.creditedLocalDate,
    )) {
      return TreeGrowthCreditInsertOutcome.duplicateLocalDate;
    }
    credits.add(credit);
    return TreeGrowthCreditInsertOutcome.inserted;
  }

  @override
  Future<int> countGrowthCredits(String treeId) async =>
      credits.where((credit) => credit.treeId == treeId).length;
}
