import 'package:drift/drift.dart';

part 'dopa_database.g.dart';

@DataClassName('FocusSessionRow')
class FocusSessions extends Table {
  TextColumn get id => text()();

  IntColumn get startedAtUtcMicros => integer()();

  TextColumn get startedLocalDate => text()();

  TextColumn get protectionMode => text()();

  IntColumn get durationPresetMinutes =>
      integer().check(durationPresetMinutes.isIn(const <int>[5, 10, 25, 50]))();

  IntColumn get plannedDurationSeconds =>
      integer().check(plannedDurationSeconds.isBiggerThanValue(0))();

  IntColumn get protectedDurationSeconds =>
      integer().check(protectedDurationSeconds.isBiggerOrEqualValue(0))();

  TextColumn get status => text()();

  IntColumn get endedAtUtcMicros => integer().nullable()();

  BoolColumn get usedFiveMinuteBypass => boolean()();

  TextColumn get intention => text().withDefault(const Constant<String>(''))();

  @override
  List<String> get customConstraints => const <String>[
    "CHECK (protection_mode IN ('shield', 'accessibility', 'timerOnly'))",
    "CHECK (status IN ('active', 'completed', 'endedEarly', 'cancelled', "
        "'invalidRecovery'))",
    "CHECK ((status = 'active' AND ended_at_utc_micros IS NULL) OR "
        "(status <> 'active' AND ended_at_utc_micros IS NOT NULL))",
    'CHECK (ended_at_utc_micros IS NULL OR '
        'ended_at_utc_micros >= started_at_utc_micros)',
    'CHECK (planned_duration_seconds = duration_preset_minutes * 60)',
  ];

  @override
  Set<Column<Object>> get primaryKey => <Column<Object>>{id};

  @override
  String get tableName => 'focus_sessions';
}

@DataClassName('TreeCompanionRow')
class TreeCompanions extends Table {
  TextColumn get id => text()();

  IntColumn get singletonKey => integer()
      .withDefault(const Constant<int>(1))
      .check(singletonKey.equals(1))
      .unique()();

  TextColumn get species => text().check(species.equals('zelkovaV1'))();

  IntColumn get createdAtUtcMicros => integer()();

  IntColumn get ruleVersion =>
      integer().check(ruleVersion.isBiggerThanValue(0))();

  @override
  Set<Column<Object>> get primaryKey => <Column<Object>>{id};

  @override
  String get tableName => 'tree_companions';
}

@DataClassName('TreeGrowthCreditRow')
class TreeGrowthCredits extends Table {
  TextColumn get treeId =>
      text().references(TreeCompanions, #id, onDelete: KeyAction.cascade)();

  TextColumn get sourceSessionId =>
      text().references(FocusSessions, #id, onDelete: KeyAction.restrict)();

  TextColumn get creditedLocalDate => text()();

  IntColumn get creditedAtUtcMicros => integer()();

  IntColumn get ruleVersion =>
      integer().check(ruleVersion.isBiggerThanValue(0))();

  @override
  Set<Column<Object>> get primaryKey => <Column<Object>>{sourceSessionId};

  @override
  List<Set<Column<Object>>> get uniqueKeys => <Set<Column<Object>>>[
    <Column<Object>>{treeId, creditedLocalDate},
  ];

  @override
  String get tableName => 'tree_growth_credits';
}

@DataClassName('SevenDayExperimentRow')
class SevenDayExperiments extends Table {
  IntColumn get singletonKey => integer()
      .withDefault(const Constant<int>(1))
      .check(singletonKey.equals(1))();

  TextColumn get startedLocalDate => text()();

  IntColumn get lengthDays => integer()
      .withDefault(const Constant<int>(7))
      .check(lengthDays.equals(7))();

  @override
  Set<Column<Object>> get primaryKey => <Column<Object>>{singletonKey};

  @override
  String get tableName => 'seven_day_experiments';
}

@DataClassName('DailyCheckInRow')
class DailyCheckIns extends Table {
  TextColumn get localDate => text()();

  TextColumn get intentionAlignment => text()();

  @override
  List<String> get customConstraints => const <String>[
    "CHECK (intention_alignment IN ('yes', 'no', 'skipped'))",
  ];

  @override
  Set<Column<Object>> get primaryKey => <Column<Object>>{localDate};

  @override
  String get tableName => 'daily_check_ins';
}

@DriftDatabase(
  tables: <Type>[
    FocusSessions,
    TreeCompanions,
    TreeGrowthCredits,
    SevenDayExperiments,
    DailyCheckIns,
  ],
)
class DopaDatabase extends _$DopaDatabase {
  DopaDatabase(super.executor);

  @override
  int get schemaVersion => 3;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (Migrator migrator) => migrator.createAll(),
    onUpgrade: (Migrator migrator, int from, int to) async {
      if (from < 2) {
        await migrator.addColumn(focusSessions, focusSessions.intention);
      }
      if (from < 3) {
        await migrator.createTable(sevenDayExperiments);
        await migrator.createTable(dailyCheckIns);
      }
    },
    beforeOpen: (OpeningDetails details) async {
      await customStatement('PRAGMA foreign_keys = ON');
    },
  );

  /// Removes all account-scoped local data in one transaction.
  ///
  /// Deleting the singleton tree cascades to its immutable growth ledger. Focus
  /// sessions are removed afterwards so the ledger's source-session reference
  /// can remain restrictive during ordinary operation.
  Future<void> deleteAllLocalData() => transaction(() async {
    await delete(dailyCheckIns).go();
    await delete(sevenDayExperiments).go();
    await delete(treeCompanions).go();
    await delete(focusSessions).go();
  });
}
