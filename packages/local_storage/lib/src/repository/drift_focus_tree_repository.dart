import 'dart:math';

import 'package:dopa_domain/dopa_domain.dart' as domain;
import 'package:drift/drift.dart';
import 'package:sqlite3/common.dart';

import '../database/dopa_database.dart';

typedef TreeIdFactory = String Function();

/// Raised when persisted values cannot be represented by the domain contract.
final class StoredDataIntegrityException implements Exception {
  const StoredDataIntegrityException({
    required this.table,
    required this.rowIdentifier,
    required this.reason,
    this.cause,
  });

  final String table;
  final String rowIdentifier;
  final String reason;
  final Object? cause;

  @override
  String toString() =>
      'StoredDataIntegrityException('
      'table: $table, row: $rowIdentifier, reason: $reason)';
}

/// Drift-backed, device-only implementation of the focus/tree repository.
final class DriftFocusTreeRepository implements domain.FocusTreeRepository {
  DriftFocusTreeRepository({
    required DopaDatabase database,
    TreeIdFactory? treeIdFactory,
  }) : _database = database,
       _treeIdFactory = treeIdFactory ?? _newUuidV4;

  final DopaDatabase _database;
  final TreeIdFactory _treeIdFactory;

  @override
  Future<T> writeTransaction<T>(
    Future<T> Function(domain.FocusTreeTransaction transaction) operation,
  ) => _database.transaction(
    () => operation(
      _DriftFocusTreeTransaction(
        database: _database,
        treeIdFactory: _treeIdFactory,
      ),
    ),
  );

  /// Rebuilds the current visual progress from the immutable local ledger.
  ///
  /// A missing tree represents a fresh installation and returns the seed
  /// stage. The app boundary still calls [domain.EnsureTreeCompanion] so the
  /// singleton exists after consent.
  Future<domain.TreeProgress> readTreeProgress({
    domain.TreeGrowthPolicy policy = const domain.TreeGrowthPolicy(),
  }) {
    return _database.transaction(() async {
      final treeQuery = _database.select(_database.treeCompanions)
        ..where((TreeCompanions table) => table.singletonKey.equals(1));
      final treeRow = await treeQuery.getSingleOrNull();
      if (treeRow == null) {
        return policy.progressFor(0);
      }
      if (treeRow.ruleVersion != policy.ruleVersion) {
        throw StoredDataIntegrityException(
          table: 'tree_companions',
          rowIdentifier: treeRow.id,
          reason: 'Tree rule version is not supported by this client.',
        );
      }

      final totalGrowthDays = await _countGrowthCredits(treeRow.id);
      return policy.progressFor(totalGrowthDays);
    });
  }

  /// Counts credited growth dates in `[startInclusive, endExclusive)`.
  Future<int> countGrowthDaysInRange({
    required domain.LocalDate startInclusive,
    required domain.LocalDate endExclusive,
  }) async {
    if (startInclusive.compareTo(endExclusive) >= 0) {
      throw ArgumentError.value(
        endExclusive,
        'endExclusive',
        'Must be after startInclusive.',
      );
    }

    final countExpression = _database.treeGrowthCredits.sourceSessionId.count();
    final query = _database.selectOnly(_database.treeGrowthCredits)
      ..addColumns(<Expression<Object>>[countExpression])
      ..where(
        _database.treeGrowthCredits.creditedLocalDate.isBiggerOrEqualValue(
              startInclusive.toIso8601String(),
            ) &
            _database.treeGrowthCredits.creditedLocalDate.isSmallerThanValue(
              endExclusive.toIso8601String(),
            ),
      );
    final row = await query.getSingle();
    return row.read(countExpression) ?? 0;
  }

  /// Returns the most recently started unfinished session for app recovery.
  Future<domain.FocusSession?> readActiveFocusSession() async {
    final query = _database.select(_database.focusSessions)
      ..where((FocusSessions table) => table.status.equals('active'))
      ..orderBy(<OrderingTerm Function(FocusSessions)>[
        (FocusSessions table) => OrderingTerm.desc(table.startedAtUtcMicros),
      ])
      ..limit(1);
    final row = await query.getSingleOrNull();
    return row == null ? null : _sessionFromRow(row);
  }

  /// Removes sessions, the singleton tree, and all growth credits atomically.
  Future<void> deleteAllLocalData() => _database.deleteAllLocalData();

  Future<int> _countGrowthCredits(String treeId) async {
    final countExpression = _database.treeGrowthCredits.sourceSessionId.count();
    final query = _database.selectOnly(_database.treeGrowthCredits)
      ..addColumns(<Expression<Object>>[countExpression])
      ..where(_database.treeGrowthCredits.treeId.equals(treeId));
    final row = await query.getSingle();
    return row.read(countExpression) ?? 0;
  }
}

final class _DriftFocusTreeTransaction implements domain.FocusTreeTransaction {
  const _DriftFocusTreeTransaction({
    required DopaDatabase database,
    required TreeIdFactory treeIdFactory,
  }) : _database = database,
       _treeIdFactory = treeIdFactory;

  final DopaDatabase _database;
  final TreeIdFactory _treeIdFactory;

  @override
  Future<domain.FocusSession?> findSessionById(String sessionId) async {
    final query = _database.select(_database.focusSessions)
      ..where((FocusSessions table) => table.id.equals(sessionId));
    final row = await query.getSingleOrNull();
    return row == null ? null : _sessionFromRow(row);
  }

  @override
  Future<void> saveSession(domain.FocusSession session) async {
    final existing = await findSessionById(session.id);
    if (existing != null) {
      _validateSessionUpdate(existing: existing, next: session);
    }

    final row = _sessionToCompanion(session);
    if (existing == null) {
      await _database.into(_database.focusSessions).insert(row);
    } else {
      final updated =
          await (_database.update(_database.focusSessions)
                ..where((FocusSessions table) => table.id.equals(session.id)))
              .write(row);
      if (updated != 1) {
        throw StateError('Expected to update exactly one focus session.');
      }
    }
  }

  @override
  Future<domain.TreeCompanion> getOrCreateTree({
    required DateTime createdAtUtc,
    required int ruleVersion,
  }) async {
    final existing = await _findSingletonTree();
    if (existing != null) {
      return existing;
    }

    final tree = domain.TreeCompanion(
      id: _treeIdFactory(),
      createdAtUtc: createdAtUtc,
      ruleVersion: ruleVersion,
    );
    try {
      await _database
          .into(_database.treeCompanions)
          .insert(
            TreeCompanionsCompanion.insert(
              id: tree.id,
              species: tree.species.name,
              createdAtUtcMicros: tree.createdAtUtc.microsecondsSinceEpoch,
              ruleVersion: tree.ruleVersion,
            ),
          );
      return tree;
    } on SqliteException catch (error) {
      final concurrentlyCreated = await _findSingletonTree();
      if (concurrentlyCreated != null) {
        return concurrentlyCreated;
      }
      Error.throwWithStackTrace(error, StackTrace.current);
    }
  }

  @override
  Future<domain.TreeGrowthCredit?> findGrowthCreditBySourceSessionId(
    String sourceSessionId,
  ) async {
    final query = _database.select(_database.treeGrowthCredits)
      ..where(
        (TreeGrowthCredits table) =>
            table.sourceSessionId.equals(sourceSessionId),
      );
    final row = await query.getSingleOrNull();
    return row == null ? null : _creditFromRow(row);
  }

  @override
  Future<domain.TreeGrowthCreditInsertOutcome> tryInsertGrowthCredit(
    domain.TreeGrowthCredit credit,
  ) async {
    try {
      await _database
          .into(_database.treeGrowthCredits)
          .insert(
            TreeGrowthCreditsCompanion.insert(
              treeId: credit.treeId,
              sourceSessionId: credit.sourceSessionId,
              creditedLocalDate: credit.creditedLocalDate.toIso8601String(),
              creditedAtUtcMicros: credit.creditedAtUtc.microsecondsSinceEpoch,
              ruleVersion: credit.ruleVersion,
            ),
          );
      return domain.TreeGrowthCreditInsertOutcome.inserted;
    } on SqliteException catch (error) {
      final sourceDuplicate = await findGrowthCreditBySourceSessionId(
        credit.sourceSessionId,
      );
      if (sourceDuplicate != null) {
        return domain.TreeGrowthCreditInsertOutcome.duplicateSourceSession;
      }

      final localDateQuery = _database.select(_database.treeGrowthCredits)
        ..where(
          (TreeGrowthCredits table) =>
              table.treeId.equals(credit.treeId) &
              table.creditedLocalDate.equals(
                credit.creditedLocalDate.toIso8601String(),
              ),
        );
      if (await localDateQuery.getSingleOrNull() != null) {
        return domain.TreeGrowthCreditInsertOutcome.duplicateLocalDate;
      }

      Error.throwWithStackTrace(error, StackTrace.current);
    }
  }

  @override
  Future<int> countGrowthCredits(String treeId) async {
    final countExpression = _database.treeGrowthCredits.sourceSessionId.count();
    final query = _database.selectOnly(_database.treeGrowthCredits)
      ..addColumns(<Expression<Object>>[countExpression])
      ..where(_database.treeGrowthCredits.treeId.equals(treeId));
    final row = await query.getSingle();
    return row.read(countExpression) ?? 0;
  }

  Future<domain.TreeCompanion?> _findSingletonTree() async {
    final query = _database.select(_database.treeCompanions)
      ..where((TreeCompanions table) => table.singletonKey.equals(1));
    final row = await query.getSingleOrNull();
    return row == null ? null : _treeFromRow(row);
  }
}

FocusSessionsCompanion _sessionToCompanion(domain.FocusSession session) =>
    FocusSessionsCompanion.insert(
      id: session.id,
      startedAtUtcMicros: session.startedAtUtc.microsecondsSinceEpoch,
      startedLocalDate: session.startedLocalDate.toIso8601String(),
      protectionMode: session.protectionMode.name,
      durationPresetMinutes: session.preset.minutes,
      plannedDurationSeconds: session.plannedDuration.inSeconds,
      protectedDurationSeconds: session.protectedDuration.inSeconds,
      status: session.status.name,
      endedAtUtcMicros: Value<int?>(session.endedAtUtc?.microsecondsSinceEpoch),
      usedFiveMinuteBypass: session.usedFiveMinuteBypass,
      intention: Value<String>(session.intention),
    );

domain.FocusSession _sessionFromRow(FocusSessionRow row) {
  try {
    final preset = domain.SessionDurationPreset.fromMinutes(
      row.durationPresetMinutes,
    );
    if (row.plannedDurationSeconds != preset.duration.inSeconds) {
      throw StateError('Planned duration does not match its preset.');
    }

    return domain.FocusSession(
      id: row.id,
      startedAtUtc: _utcFromMicros(row.startedAtUtcMicros),
      startedLocalDate: domain.LocalDate.parse(row.startedLocalDate),
      protectionMode: _enumByName(
        values: domain.ProtectionMode.values,
        name: row.protectionMode,
        field: 'protectionMode',
      ),
      preset: preset,
      protectedDuration: Duration(seconds: row.protectedDurationSeconds),
      status: _enumByName(
        values: domain.FocusSessionStatus.values,
        name: row.status,
        field: 'status',
      ),
      endedAtUtc: row.endedAtUtcMicros == null
          ? null
          : _utcFromMicros(row.endedAtUtcMicros!),
      usedFiveMinuteBypass: row.usedFiveMinuteBypass,
      intention: row.intention,
    );
  } on Object catch (error) {
    throw StoredDataIntegrityException(
      table: 'focus_sessions',
      rowIdentifier: row.id,
      reason: 'Stored focus session violates the domain contract.',
      cause: error,
    );
  }
}

domain.TreeCompanion _treeFromRow(TreeCompanionRow row) {
  try {
    return domain.TreeCompanion(
      id: row.id,
      species: _enumByName(
        values: domain.TreeSpecies.values,
        name: row.species,
        field: 'species',
      ),
      createdAtUtc: _utcFromMicros(row.createdAtUtcMicros),
      ruleVersion: row.ruleVersion,
    );
  } on Object catch (error) {
    throw StoredDataIntegrityException(
      table: 'tree_companions',
      rowIdentifier: row.id,
      reason: 'Stored tree companion violates the domain contract.',
      cause: error,
    );
  }
}

domain.TreeGrowthCredit _creditFromRow(TreeGrowthCreditRow row) {
  try {
    return domain.TreeGrowthCredit(
      treeId: row.treeId,
      sourceSessionId: row.sourceSessionId,
      creditedLocalDate: domain.LocalDate.parse(row.creditedLocalDate),
      creditedAtUtc: _utcFromMicros(row.creditedAtUtcMicros),
      ruleVersion: row.ruleVersion,
    );
  } on Object catch (error) {
    throw StoredDataIntegrityException(
      table: 'tree_growth_credits',
      rowIdentifier: row.sourceSessionId,
      reason: 'Stored growth credit violates the domain contract.',
      cause: error,
    );
  }
}

void _validateSessionUpdate({
  required domain.FocusSession existing,
  required domain.FocusSession next,
}) {
  final startMetadataChanged =
      existing.startedAtUtc != next.startedAtUtc ||
      existing.startedLocalDate != next.startedLocalDate ||
      existing.protectionMode != next.protectionMode ||
      existing.preset != next.preset ||
      existing.intention != next.intention;
  if (startMetadataChanged) {
    throw StateError('A persisted session\'s start metadata is immutable.');
  }
  if (existing.isTerminal && existing != next) {
    throw StateError('A terminal focus session is immutable.');
  }
}

DateTime _utcFromMicros(int value) =>
    DateTime.fromMicrosecondsSinceEpoch(value, isUtc: true);

T _enumByName<T extends Enum>({
  required List<T> values,
  required String name,
  required String field,
}) {
  for (final value in values) {
    if (value.name == name) {
      return value;
    }
  }
  throw FormatException('Unknown $field value.', name);
}

String _newUuidV4() {
  final random = Random.secure();
  final bytes = List<int>.generate(16, (_) => random.nextInt(256));
  bytes[6] = (bytes[6] & 0x0f) | 0x40;
  bytes[8] = (bytes[8] & 0x3f) | 0x80;
  final hex = bytes.map((int byte) => byte.toRadixString(16).padLeft(2, '0'));
  final value = hex.join();
  return '${value.substring(0, 8)}-'
      '${value.substring(8, 12)}-'
      '${value.substring(12, 16)}-'
      '${value.substring(16, 20)}-'
      '${value.substring(20)}';
}
