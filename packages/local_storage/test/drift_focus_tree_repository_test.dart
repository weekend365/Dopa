import 'package:dopa_domain/dopa_domain.dart';
import 'package:dopa_local_storage/dopa_local_storage.dart';
import 'package:drift/native.dart';
import 'package:test/test.dart';

void main() {
  group('DriftFocusTreeRepository', () {
    late DopaDatabase database;
    late DriftFocusTreeRepository repository;

    setUp(() {
      database = DopaDatabase(NativeDatabase.memory());
      repository = DriftFocusTreeRepository(
        database: database,
        treeIdFactory: () => 'device-tree',
      );
    });

    tearDown(() => database.close());

    test('creates exactly one device-local tree', () async {
      final ensureTree = EnsureTreeCompanion(repository: repository);

      final first = await ensureTree(createdAtUtc: DateTime.utc(2026, 8, 26));
      final second = await ensureTree(createdAtUtc: DateTime.utc(2026, 8, 27));

      expect(second, first);
      expect(first.id, 'device-tree');
      expect(first.species, TreeSpecies.zelkovaV1);
      expect(first.createdAtUtc, DateTime.utc(2026, 8, 26));
      expect(
        await database.select(database.treeCompanions).get(),
        hasLength(1),
      );
    });

    test(
      'round-trips session fields and atomically awards first growth',
      () async {
        final original =
            _session(
              id: 'session-round-trip',
              protectionMode: ProtectionMode.accessibility,
              preset: SessionDurationPreset.twentyFiveMinutes,
              intention: '보고서 첫 문단',
            ).applyBypass(
              action: BypassAction.allowFiveMinutes,
              occurredAtUtc: DateTime.utc(2026, 8, 26, 1, 2),
            );
        await _save(repository, original);

        final result = await CompleteFocusSession(repository: repository)(
          sessionId: original.id,
          terminalStatus: FocusSessionStatus.completed,
          endedAtUtc: DateTime.utc(2026, 8, 26, 1, 25),
          protectedDuration: const Duration(minutes: 17),
        );
        final reloaded = await _find(repository, original.id);

        expect(result.awardStatus, GrowthAwardStatus.awarded);
        expect(result.progress!.totalGrowthDays, 1);
        expect(result.progress!.stage, TreeGrowthStage.sprout);
        expect(reloaded, result.session);
        expect(reloaded!.preset, SessionDurationPreset.twentyFiveMinutes);
        expect(reloaded.protectionMode, ProtectionMode.accessibility);
        expect(reloaded.protectedDuration, const Duration(minutes: 17));
        expect(reloaded.usedFiveMinuteBypass, isTrue);
        expect(reloaded.intention, '보고서 첫 문단');
        expect(
          await database.select(database.focusSessions).get(),
          hasLength(1),
        );
        expect(
          await database.select(database.treeGrowthCredits).get(),
          hasLength(1),
        );
      },
    );

    test(
      'derives progress and report ranges from the immutable ledger',
      () async {
        expect(
          await repository.readTreeProgress(),
          const TreeGrowthPolicy().progressFor(0),
        );

        final first = _session(id: 'range-first');
        final second = _session(
          id: 'range-second',
          startedAtUtc: DateTime.utc(2026, 8, 28, 1),
          startedLocalDate: LocalDate(2026, 8, 28),
        );
        await _save(repository, first);
        await _save(repository, second);
        final complete = CompleteFocusSession(repository: repository);
        await _complete(complete, first);
        await _complete(complete, second);

        final progress = await repository.readTreeProgress();
        expect(progress.totalGrowthDays, 2);
        expect(progress.stage, TreeGrowthStage.sprout);
        expect(
          await repository.countGrowthDaysInRange(
            startInclusive: LocalDate(2026, 8, 26),
            endExclusive: LocalDate(2026, 8, 27),
          ),
          1,
        );
        expect(
          await repository.countGrowthDaysInRange(
            startInclusive: LocalDate(2026, 8, 26),
            endExclusive: LocalDate(2026, 8, 29),
          ),
          2,
        );
        await expectLater(
          repository.countGrowthDaysInRange(
            startInclusive: LocalDate(2026, 8, 29),
            endExclusive: LocalDate(2026, 8, 29),
          ),
          throwsArgumentError,
        );
      },
    );

    test('returns the latest active session for restart recovery', () async {
      final older = _session(
        id: 'active-older',
        startedAtUtc: DateTime.utc(2026, 8, 26, 1),
      );
      final latest = _session(
        id: 'active-latest',
        startedAtUtc: DateTime.utc(2026, 8, 26, 3),
      );
      final completed =
          _session(
            id: 'completed-between',
            startedAtUtc: DateTime.utc(2026, 8, 26, 2),
          ).finish(
            status: FocusSessionStatus.completed,
            endedAtUtc: DateTime.utc(2026, 8, 26, 2, 10),
          );
      await _save(repository, older);
      await _save(repository, completed);
      await _save(repository, latest);

      expect(await repository.readActiveFocusSession(), latest);
    });

    test(
      'duplicate completion callbacks keep a single source credit',
      () async {
        final session = _session(id: 'session-duplicate');
        await _save(repository, session);
        final complete = CompleteFocusSession(repository: repository);

        final first = await _complete(complete, session);
        final second = await complete(
          sessionId: session.id,
          terminalStatus: FocusSessionStatus.completed,
          endedAtUtc: session.startedAtUtc.add(const Duration(minutes: 11)),
        );

        expect(first.awardStatus, GrowthAwardStatus.awarded);
        expect(second.awardStatus, GrowthAwardStatus.alreadyAwardedForSession);
        expect(second.credit, first.credit);
        expect(second.progress!.totalGrowthDays, 1);
        expect(
          await database.select(database.treeGrowthCredits).get(),
          hasLength(1),
        );
      },
    );

    test('source session unique key rejects a second ledger date', () async {
      final session = _session(id: 'source-key');
      await _save(repository, session);
      final tree = await EnsureTreeCompanion(repository: repository)(
        createdAtUtc: session.startedAtUtc,
      );

      final outcomes = await repository.writeTransaction((
        FocusTreeTransaction transaction,
      ) async {
        final first = await transaction.tryInsertGrowthCredit(
          TreeGrowthCredit(
            treeId: tree.id,
            sourceSessionId: session.id,
            creditedLocalDate: session.startedLocalDate,
            creditedAtUtc: session.startedAtUtc,
            ruleVersion: 1,
          ),
        );
        final duplicate = await transaction.tryInsertGrowthCredit(
          TreeGrowthCredit(
            treeId: tree.id,
            sourceSessionId: session.id,
            creditedLocalDate: session.startedLocalDate.addDays(1),
            creditedAtUtc: session.startedAtUtc.add(const Duration(days: 1)),
            ruleVersion: 1,
          ),
        );
        return (first, duplicate);
      });

      expect(outcomes.$1, TreeGrowthCreditInsertOutcome.inserted);
      expect(outcomes.$2, TreeGrowthCreditInsertOutcome.duplicateSourceSession);
      expect(
        await database.select(database.treeGrowthCredits).get(),
        hasLength(1),
      );
    });

    test(
      'concurrent duplicate callbacks are serialized and award once',
      () async {
        final session = _session(id: 'session-concurrent');
        await _save(repository, session);
        final complete = CompleteFocusSession(repository: repository);

        final results = await Future.wait(<Future<CompleteFocusSessionResult>>[
          _complete(complete, session),
          _complete(complete, session),
        ]);

        expect(
          results.map(
            (CompleteFocusSessionResult result) => result.awardStatus,
          ),
          containsAll(<GrowthAwardStatus>[
            GrowthAwardStatus.awarded,
            GrowthAwardStatus.alreadyAwardedForSession,
          ]),
        );
        expect(
          await database.select(database.treeGrowthCredits).get(),
          hasLength(1),
        );
      },
    );

    test('two sessions on one captured local date grow only once', () async {
      final first = _session(id: 'same-day-first');
      final second = _session(
        id: 'same-day-second',
        startedAtUtc: DateTime.utc(2026, 8, 26, 14, 55),
      );
      await _save(repository, first);
      await _save(repository, second);
      final complete = CompleteFocusSession(repository: repository);

      final firstResult = await _complete(complete, first);
      final secondResult = await complete(
        sessionId: second.id,
        terminalStatus: FocusSessionStatus.completed,
        // The completion crosses midnight in Korea. The start date remains the
        // ledger key, even if the device timezone later changes.
        endedAtUtc: DateTime.utc(2026, 8, 26, 15, 5),
      );

      expect(firstResult.awardStatus, GrowthAwardStatus.awarded);
      expect(
        secondResult.awardStatus,
        GrowthAwardStatus.alreadyAwardedForLocalDate,
      );
      expect(secondResult.credit, isNull);
      expect(
        (await _find(repository, second.id))!.status,
        FocusSessionStatus.completed,
      );
      final credits = await database.select(database.treeGrowthCredits).get();
      expect(credits, hasLength(1));
      expect(credits.single.creditedLocalDate, '2026-08-26');
    });

    test(
      'ineligible terminal status persists without creating tree growth',
      () async {
        final session = _session(id: 'ended-early');
        await _save(repository, session);

        final result = await CompleteFocusSession(repository: repository)(
          sessionId: session.id,
          terminalStatus: FocusSessionStatus.endedEarly,
          endedAtUtc: session.startedAtUtc.add(const Duration(minutes: 2)),
        );

        expect(result.awardStatus, GrowthAwardStatus.ineligibleSession);
        expect(
          (await _find(repository, session.id))!.status,
          FocusSessionStatus.endedEarly,
        );
        expect(await database.select(database.treeCompanions).get(), isEmpty);
        expect(
          await database.select(database.treeGrowthCredits).get(),
          isEmpty,
        );
      },
    );

    test(
      'rolls session finalization back if growth persistence fails',
      () async {
        final invalidRepository = DriftFocusTreeRepository(
          database: database,
          treeIdFactory: () => '',
        );
        final session = _session(id: 'must-roll-back');
        await _save(invalidRepository, session);

        await expectLater(
          _complete(
            CompleteFocusSession(repository: invalidRepository),
            session,
          ),
          throwsArgumentError,
        );

        final persisted = await _find(invalidRepository, session.id);
        expect(persisted!.status, FocusSessionStatus.active);
        expect(persisted.endedAtUtc, isNull);
        expect(await database.select(database.treeCompanions).get(), isEmpty);
        expect(
          await database.select(database.treeGrowthCredits).get(),
          isEmpty,
        );
      },
    );

    test(
      'rolls completion back on a persisted rule-version conflict',
      () async {
        final session = _session(id: 'rule-version-rollback');
        await _save(repository, session);
        await database
            .into(database.treeCompanions)
            .insert(
              TreeCompanionsCompanion.insert(
                id: 'legacy-tree',
                species: TreeSpecies.zelkovaV1.name,
                createdAtUtcMicros: session.startedAtUtc.microsecondsSinceEpoch,
                ruleVersion: 2,
              ),
            );

        await expectLater(
          _complete(CompleteFocusSession(repository: repository), session),
          throwsA(isA<TreeRuleVersionConflict>()),
        );

        final persisted = await _find(repository, session.id);
        expect(persisted!.status, FocusSessionStatus.active);
        expect(persisted.endedAtUtc, isNull);
        expect(
          await database.select(database.treeGrowthCredits).get(),
          isEmpty,
        );
      },
    );

    test('account deletion removes sessions, tree, and ledger rows', () async {
      final session = _session(id: 'delete-me');
      await _save(repository, session);
      await _complete(CompleteFocusSession(repository: repository), session);

      await repository.deleteAllLocalData();

      expect(await database.select(database.focusSessions).get(), isEmpty);
      expect(await database.select(database.treeCompanions).get(), isEmpty);
      expect(await database.select(database.treeGrowthCredits).get(), isEmpty);
      expect(
        await database.select(database.sevenDayExperiments).get(),
        isEmpty,
      );
      expect(await database.select(database.dailyCheckIns).get(), isEmpty);
    });

    test(
      'experiment attempt days ignore check-ins and invalid recovery',
      () async {
        await repository.writeTransaction(
          (transaction) => transaction.getOrCreateExperiment(
            startedOn: LocalDate(2026, 8, 27),
          ),
        );
        await _save(
          repository,
          _session(
            id: 'attempt-1',
            startedAtUtc: DateTime.utc(2026, 8, 27, 1),
            startedLocalDate: LocalDate(2026, 8, 27),
          ),
        );
        await _save(
          repository,
          _session(
            id: 'early-same-day',
            startedAtUtc: DateTime.utc(2026, 8, 27, 4),
            startedLocalDate: LocalDate(2026, 8, 27),
          ).finish(
            status: FocusSessionStatus.endedEarly,
            endedAtUtc: DateTime.utc(2026, 8, 27, 4, 2),
          ),
        );
        await _save(
          repository,
          _session(
            id: 'attempt-2',
            startedAtUtc: DateTime.utc(2026, 8, 28, 1),
            startedLocalDate: LocalDate(2026, 8, 28),
          ),
        );
        await _save(
          repository,
          _session(
            id: 'outside-window',
            startedAtUtc: DateTime.utc(2026, 9, 4, 1),
            startedLocalDate: LocalDate(2026, 9, 4),
          ),
        );
        await _save(
          repository,
          _session(
            id: 'invalid',
            startedAtUtc: DateTime.utc(2026, 8, 29, 1),
            startedLocalDate: LocalDate(2026, 8, 29),
          ).finish(
            status: FocusSessionStatus.invalidRecovery,
            endedAtUtc: DateTime.utc(2026, 8, 29, 3),
          ),
        );
        await repository.writeTransaction(
          (transaction) => transaction.saveCheckIn(
            DailyCheckIn(
              localDate: LocalDate(2026, 8, 30),
              intentionAlignment: IntentionAlignment.yes,
            ),
          ),
        );

        expect(await repository.countExperimentAttemptDays(), 2);

        final kept = await repository.writeTransaction(
          (transaction) => transaction.getOrCreateExperiment(
            startedOn: LocalDate(2026, 9, 1),
          ),
        );
        expect(kept.startedOn, LocalDate(2026, 8, 27));
      },
    );
  });
}

FocusSession _session({
  required String id,
  DateTime? startedAtUtc,
  LocalDate? startedLocalDate,
  ProtectionMode protectionMode = ProtectionMode.timerOnly,
  SessionDurationPreset preset = SessionDurationPreset.tenMinutes,
  String intention = '',
}) => FocusSession(
  id: id,
  startedAtUtc: startedAtUtc ?? DateTime.utc(2026, 8, 26, 1),
  startedLocalDate: startedLocalDate ?? LocalDate(2026, 8, 26),
  protectionMode: protectionMode,
  preset: preset,
  intention: intention,
);

Future<void> _save(DriftFocusTreeRepository repository, FocusSession session) =>
    repository.writeTransaction(
      (FocusTreeTransaction transaction) => transaction.saveSession(session),
    );

Future<FocusSession?> _find(
  DriftFocusTreeRepository repository,
  String sessionId,
) => repository.writeTransaction(
  (FocusTreeTransaction transaction) => transaction.findSessionById(sessionId),
);

Future<CompleteFocusSessionResult> _complete(
  CompleteFocusSession complete,
  FocusSession session,
) => complete(
  sessionId: session.id,
  terminalStatus: FocusSessionStatus.completed,
  endedAtUtc: session.startedAtUtc.add(session.plannedDuration),
);
