import 'package:dopa_local_storage/dopa_local_storage.dart';
import 'package:drift/native.dart';
import 'package:sqlite3/sqlite3.dart';
import 'package:test/test.dart';

void main() {
  for (final version in [2, 3]) {
    test(
      'v$version upgrade preserves focus, growth and check-ins with empty companion tables',
      () async {
        final sqlite = sqlite3.openInMemory();
        sqlite
          ..execute(_v1FocusSessionsSql)
          ..execute(_v1TreeCompanionsSql)
          ..execute(_v1TreeGrowthCreditsSql)
          ..execute(
            "ALTER TABLE focus_sessions ADD COLUMN intention TEXT NOT NULL DEFAULT ''",
          )
          ..execute('''INSERT INTO focus_sessions VALUES (
          'legacy', 1000000, '2026-09-09', 'timerOnly', 5, 300, 300,
          'completed', 301000000, 0, 'kept intention')''')
          ..execute(
            "INSERT INTO tree_companions VALUES ('tree', 1, 'zelkovaV1', 1, 1)",
          )
          ..execute(
            "INSERT INTO tree_growth_credits VALUES ('tree', 'legacy', '2026-09-09', 301000000, 1)",
          );
        if (version == 3) {
          sqlite
            ..execute('''CREATE TABLE seven_day_experiments (
            singleton_key INTEGER NOT NULL PRIMARY KEY DEFAULT 1 CHECK (singleton_key = 1),
            started_local_date TEXT NOT NULL,
            length_days INTEGER NOT NULL DEFAULT 7 CHECK (length_days = 7))''')
            ..execute(
              '''CREATE TABLE daily_check_ins (
            local_date TEXT NOT NULL PRIMARY KEY,
            intention_alignment TEXT NOT NULL CHECK (intention_alignment IN ('yes','no','skipped')))''',
            )
            ..execute(
              "INSERT INTO seven_day_experiments VALUES (1, '2026-09-09', 7)",
            )
            ..execute(
              "INSERT INTO daily_check_ins VALUES ('2026-09-09', 'no')",
            );
        }
        final oldSchema = sqlite
            .select(
              "SELECT sql FROM sqlite_master WHERE type = 'table' AND name <> 'tree_growth_credits' ORDER BY name",
            )
            .map((row) => row['sql'])
            .toList();
        sqlite.execute('PRAGMA user_version = $version');
        final database = DopaDatabase(NativeDatabase.opened(sqlite));
        addTearDown(database.close);
        final legacy = await database
            .select(database.focusSessions)
            .getSingle();
        expect(legacy.intention, 'kept intention');
        expect(legacy.status, 'completed');
        expect(legacy.protectedDurationSeconds, 300);
        expect(
          (await database.select(database.treeCompanions).getSingle()).id,
          'tree',
        );
        expect(
          (await database.select(database.treeGrowthCredits).getSingle())
              .sourceSessionId,
          'legacy',
        );
        expect(await database.select(database.companionRuns).get(), isEmpty);
        expect(
          await database.select(database.companionOutcomes).get(),
          isEmpty,
        );
        if (version == 3) {
          expect(
            (await database.select(database.dailyCheckIns).getSingle())
                .intentionAlignment,
            'no',
          );
          expect(
            (await database.select(database.sevenDayExperiments).getSingle())
                .startedLocalDate,
            '2026-09-09',
          );
        }
        final newSchema = sqlite
            .select("SELECT sql FROM sqlite_master WHERE type = 'table'")
            .map((row) => row['sql'])
            .toList();
        expect(newSchema, containsAll(oldSchema));
        // Existing growth constraints survive the additive migration.
        expect(
          () => sqlite.execute(
            "INSERT INTO tree_growth_credits VALUES ('tree', 'legacy', '2026-09-09', 301000001, 1, 'focus')",
          ),
          throwsA(isA<SqliteException>()),
        );
        expect(sqlite.select('PRAGMA user_version').single.values.single, 6);
      },
    );
  }

  test('v1 focus sessions gain an empty intention on upgrade', () async {
    final sqlite = sqlite3.openInMemory();
    sqlite
      ..execute(_v1FocusSessionsSql)
      ..execute(_v1TreeCompanionsSql)
      ..execute(_v1TreeGrowthCreditsSql)
      ..execute('''
        INSERT INTO focus_sessions (
          id,
          started_at_utc_micros,
          started_local_date,
          protection_mode,
          duration_preset_minutes,
          planned_duration_seconds,
          protected_duration_seconds,
          status,
          used_five_minute_bypass
        ) VALUES (
          'legacy-session',
          ${DateTime.utc(2026, 8, 26, 1).microsecondsSinceEpoch},
          '2026-08-26',
          'timerOnly',
          10,
          600,
          0,
          'active',
          0
        )
      ''')
      ..execute('PRAGMA user_version = 1');

    final database = DopaDatabase(NativeDatabase.opened(sqlite));
    addTearDown(database.close);

    final row = await database.select(database.focusSessions).getSingle();
    expect(row.id, 'legacy-session');
    expect(row.intention, isEmpty);
    expect(row.status, 'active');
    expect(await database.select(database.sevenDayExperiments).get(), isEmpty);
    expect(await database.select(database.dailyCheckIns).get(), isEmpty);
  });
}

const _v1FocusSessionsSql = '''
CREATE TABLE focus_sessions (
  id TEXT NOT NULL PRIMARY KEY,
  started_at_utc_micros INTEGER NOT NULL,
  started_local_date TEXT NOT NULL,
  protection_mode TEXT NOT NULL,
  duration_preset_minutes INTEGER NOT NULL
    CHECK (duration_preset_minutes IN (5, 10, 25, 50)),
  planned_duration_seconds INTEGER NOT NULL
    CHECK (planned_duration_seconds > 0),
  protected_duration_seconds INTEGER NOT NULL
    CHECK (protected_duration_seconds >= 0),
  status TEXT NOT NULL,
  ended_at_utc_micros INTEGER NULL,
  used_five_minute_bypass INTEGER NOT NULL
    CHECK ("used_five_minute_bypass" IN (0, 1)),
  CHECK (protection_mode IN ('shield', 'accessibility', 'timerOnly')),
  CHECK (status IN (
    'active', 'completed', 'endedEarly', 'cancelled', 'invalidRecovery'
  )),
  CHECK (
    (status = 'active' AND ended_at_utc_micros IS NULL) OR
    (status <> 'active' AND ended_at_utc_micros IS NOT NULL)
  ),
  CHECK (
    ended_at_utc_micros IS NULL OR
    ended_at_utc_micros >= started_at_utc_micros
  ),
  CHECK (planned_duration_seconds = duration_preset_minutes * 60)
)
''';

const _v1TreeCompanionsSql = '''
CREATE TABLE tree_companions (
  id TEXT NOT NULL PRIMARY KEY,
  singleton_key INTEGER NOT NULL DEFAULT 1
    CHECK (singleton_key = 1) UNIQUE,
  species TEXT NOT NULL CHECK (species = 'zelkovaV1'),
  created_at_utc_micros INTEGER NOT NULL,
  rule_version INTEGER NOT NULL CHECK (rule_version > 0)
)
''';

const _v1TreeGrowthCreditsSql = '''
CREATE TABLE tree_growth_credits (
  tree_id TEXT NOT NULL REFERENCES tree_companions (id) ON DELETE CASCADE,
  source_session_id TEXT NOT NULL
    REFERENCES focus_sessions (id) ON DELETE RESTRICT,
  credited_local_date TEXT NOT NULL,
  credited_at_utc_micros INTEGER NOT NULL,
  rule_version INTEGER NOT NULL CHECK (rule_version > 0),
  PRIMARY KEY (source_session_id),
  UNIQUE (tree_id, credited_local_date)
)
''';
