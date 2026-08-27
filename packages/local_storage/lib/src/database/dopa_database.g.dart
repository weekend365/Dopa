// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'dopa_database.dart';

// ignore_for_file: type=lint
class $FocusSessionsTable extends FocusSessions
    with TableInfo<$FocusSessionsTable, FocusSessionRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $FocusSessionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _startedAtUtcMicrosMeta =
      const VerificationMeta('startedAtUtcMicros');
  @override
  late final GeneratedColumn<int> startedAtUtcMicros = GeneratedColumn<int>(
    'started_at_utc_micros',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _startedLocalDateMeta = const VerificationMeta(
    'startedLocalDate',
  );
  @override
  late final GeneratedColumn<String> startedLocalDate = GeneratedColumn<String>(
    'started_local_date',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _protectionModeMeta = const VerificationMeta(
    'protectionMode',
  );
  @override
  late final GeneratedColumn<String> protectionMode = GeneratedColumn<String>(
    'protection_mode',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _durationPresetMinutesMeta =
      const VerificationMeta('durationPresetMinutes');
  @override
  late final GeneratedColumn<int> durationPresetMinutes = GeneratedColumn<int>(
    'duration_preset_minutes',
    aliasedName,
    false,
    check: () => durationPresetMinutes.isIn(const <int>[5, 10, 25, 50]),
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _plannedDurationSecondsMeta =
      const VerificationMeta('plannedDurationSeconds');
  @override
  late final GeneratedColumn<int> plannedDurationSeconds = GeneratedColumn<int>(
    'planned_duration_seconds',
    aliasedName,
    false,
    check: () => ComparableExpr(plannedDurationSeconds).isBiggerThanValue(0),
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _protectedDurationSecondsMeta =
      const VerificationMeta('protectedDurationSeconds');
  @override
  late final GeneratedColumn<int> protectedDurationSeconds =
      GeneratedColumn<int>(
        'protected_duration_seconds',
        aliasedName,
        false,
        check: () =>
            ComparableExpr(protectedDurationSeconds).isBiggerOrEqualValue(0),
        type: DriftSqlType.int,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _endedAtUtcMicrosMeta = const VerificationMeta(
    'endedAtUtcMicros',
  );
  @override
  late final GeneratedColumn<int> endedAtUtcMicros = GeneratedColumn<int>(
    'ended_at_utc_micros',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _usedFiveMinuteBypassMeta =
      const VerificationMeta('usedFiveMinuteBypass');
  @override
  late final GeneratedColumn<bool> usedFiveMinuteBypass = GeneratedColumn<bool>(
    'used_five_minute_bypass',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("used_five_minute_bypass" IN (0, 1))',
    ),
  );
  static const VerificationMeta _intentionMeta = const VerificationMeta(
    'intention',
  );
  @override
  late final GeneratedColumn<String> intention = GeneratedColumn<String>(
    'intention',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant<String>(''),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    startedAtUtcMicros,
    startedLocalDate,
    protectionMode,
    durationPresetMinutes,
    plannedDurationSeconds,
    protectedDurationSeconds,
    status,
    endedAtUtcMicros,
    usedFiveMinuteBypass,
    intention,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'focus_sessions';
  @override
  VerificationContext validateIntegrity(
    Insertable<FocusSessionRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('started_at_utc_micros')) {
      context.handle(
        _startedAtUtcMicrosMeta,
        startedAtUtcMicros.isAcceptableOrUnknown(
          data['started_at_utc_micros']!,
          _startedAtUtcMicrosMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_startedAtUtcMicrosMeta);
    }
    if (data.containsKey('started_local_date')) {
      context.handle(
        _startedLocalDateMeta,
        startedLocalDate.isAcceptableOrUnknown(
          data['started_local_date']!,
          _startedLocalDateMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_startedLocalDateMeta);
    }
    if (data.containsKey('protection_mode')) {
      context.handle(
        _protectionModeMeta,
        protectionMode.isAcceptableOrUnknown(
          data['protection_mode']!,
          _protectionModeMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_protectionModeMeta);
    }
    if (data.containsKey('duration_preset_minutes')) {
      context.handle(
        _durationPresetMinutesMeta,
        durationPresetMinutes.isAcceptableOrUnknown(
          data['duration_preset_minutes']!,
          _durationPresetMinutesMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_durationPresetMinutesMeta);
    }
    if (data.containsKey('planned_duration_seconds')) {
      context.handle(
        _plannedDurationSecondsMeta,
        plannedDurationSeconds.isAcceptableOrUnknown(
          data['planned_duration_seconds']!,
          _plannedDurationSecondsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_plannedDurationSecondsMeta);
    }
    if (data.containsKey('protected_duration_seconds')) {
      context.handle(
        _protectedDurationSecondsMeta,
        protectedDurationSeconds.isAcceptableOrUnknown(
          data['protected_duration_seconds']!,
          _protectedDurationSecondsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_protectedDurationSecondsMeta);
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    } else if (isInserting) {
      context.missing(_statusMeta);
    }
    if (data.containsKey('ended_at_utc_micros')) {
      context.handle(
        _endedAtUtcMicrosMeta,
        endedAtUtcMicros.isAcceptableOrUnknown(
          data['ended_at_utc_micros']!,
          _endedAtUtcMicrosMeta,
        ),
      );
    }
    if (data.containsKey('used_five_minute_bypass')) {
      context.handle(
        _usedFiveMinuteBypassMeta,
        usedFiveMinuteBypass.isAcceptableOrUnknown(
          data['used_five_minute_bypass']!,
          _usedFiveMinuteBypassMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_usedFiveMinuteBypassMeta);
    }
    if (data.containsKey('intention')) {
      context.handle(
        _intentionMeta,
        intention.isAcceptableOrUnknown(data['intention']!, _intentionMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  FocusSessionRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return FocusSessionRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      startedAtUtcMicros: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}started_at_utc_micros'],
      )!,
      startedLocalDate: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}started_local_date'],
      )!,
      protectionMode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}protection_mode'],
      )!,
      durationPresetMinutes: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}duration_preset_minutes'],
      )!,
      plannedDurationSeconds: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}planned_duration_seconds'],
      )!,
      protectedDurationSeconds: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}protected_duration_seconds'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      endedAtUtcMicros: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}ended_at_utc_micros'],
      ),
      usedFiveMinuteBypass: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}used_five_minute_bypass'],
      )!,
      intention: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}intention'],
      )!,
    );
  }

  @override
  $FocusSessionsTable createAlias(String alias) {
    return $FocusSessionsTable(attachedDatabase, alias);
  }
}

class FocusSessionRow extends DataClass implements Insertable<FocusSessionRow> {
  final String id;
  final int startedAtUtcMicros;
  final String startedLocalDate;
  final String protectionMode;
  final int durationPresetMinutes;
  final int plannedDurationSeconds;
  final int protectedDurationSeconds;
  final String status;
  final int? endedAtUtcMicros;
  final bool usedFiveMinuteBypass;
  final String intention;
  const FocusSessionRow({
    required this.id,
    required this.startedAtUtcMicros,
    required this.startedLocalDate,
    required this.protectionMode,
    required this.durationPresetMinutes,
    required this.plannedDurationSeconds,
    required this.protectedDurationSeconds,
    required this.status,
    this.endedAtUtcMicros,
    required this.usedFiveMinuteBypass,
    required this.intention,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['started_at_utc_micros'] = Variable<int>(startedAtUtcMicros);
    map['started_local_date'] = Variable<String>(startedLocalDate);
    map['protection_mode'] = Variable<String>(protectionMode);
    map['duration_preset_minutes'] = Variable<int>(durationPresetMinutes);
    map['planned_duration_seconds'] = Variable<int>(plannedDurationSeconds);
    map['protected_duration_seconds'] = Variable<int>(protectedDurationSeconds);
    map['status'] = Variable<String>(status);
    if (!nullToAbsent || endedAtUtcMicros != null) {
      map['ended_at_utc_micros'] = Variable<int>(endedAtUtcMicros);
    }
    map['used_five_minute_bypass'] = Variable<bool>(usedFiveMinuteBypass);
    map['intention'] = Variable<String>(intention);
    return map;
  }

  FocusSessionsCompanion toCompanion(bool nullToAbsent) {
    return FocusSessionsCompanion(
      id: Value(id),
      startedAtUtcMicros: Value(startedAtUtcMicros),
      startedLocalDate: Value(startedLocalDate),
      protectionMode: Value(protectionMode),
      durationPresetMinutes: Value(durationPresetMinutes),
      plannedDurationSeconds: Value(plannedDurationSeconds),
      protectedDurationSeconds: Value(protectedDurationSeconds),
      status: Value(status),
      endedAtUtcMicros: endedAtUtcMicros == null && nullToAbsent
          ? const Value.absent()
          : Value(endedAtUtcMicros),
      usedFiveMinuteBypass: Value(usedFiveMinuteBypass),
      intention: Value(intention),
    );
  }

  factory FocusSessionRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return FocusSessionRow(
      id: serializer.fromJson<String>(json['id']),
      startedAtUtcMicros: serializer.fromJson<int>(json['startedAtUtcMicros']),
      startedLocalDate: serializer.fromJson<String>(json['startedLocalDate']),
      protectionMode: serializer.fromJson<String>(json['protectionMode']),
      durationPresetMinutes: serializer.fromJson<int>(
        json['durationPresetMinutes'],
      ),
      plannedDurationSeconds: serializer.fromJson<int>(
        json['plannedDurationSeconds'],
      ),
      protectedDurationSeconds: serializer.fromJson<int>(
        json['protectedDurationSeconds'],
      ),
      status: serializer.fromJson<String>(json['status']),
      endedAtUtcMicros: serializer.fromJson<int?>(json['endedAtUtcMicros']),
      usedFiveMinuteBypass: serializer.fromJson<bool>(
        json['usedFiveMinuteBypass'],
      ),
      intention: serializer.fromJson<String>(json['intention']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'startedAtUtcMicros': serializer.toJson<int>(startedAtUtcMicros),
      'startedLocalDate': serializer.toJson<String>(startedLocalDate),
      'protectionMode': serializer.toJson<String>(protectionMode),
      'durationPresetMinutes': serializer.toJson<int>(durationPresetMinutes),
      'plannedDurationSeconds': serializer.toJson<int>(plannedDurationSeconds),
      'protectedDurationSeconds': serializer.toJson<int>(
        protectedDurationSeconds,
      ),
      'status': serializer.toJson<String>(status),
      'endedAtUtcMicros': serializer.toJson<int?>(endedAtUtcMicros),
      'usedFiveMinuteBypass': serializer.toJson<bool>(usedFiveMinuteBypass),
      'intention': serializer.toJson<String>(intention),
    };
  }

  FocusSessionRow copyWith({
    String? id,
    int? startedAtUtcMicros,
    String? startedLocalDate,
    String? protectionMode,
    int? durationPresetMinutes,
    int? plannedDurationSeconds,
    int? protectedDurationSeconds,
    String? status,
    Value<int?> endedAtUtcMicros = const Value.absent(),
    bool? usedFiveMinuteBypass,
    String? intention,
  }) => FocusSessionRow(
    id: id ?? this.id,
    startedAtUtcMicros: startedAtUtcMicros ?? this.startedAtUtcMicros,
    startedLocalDate: startedLocalDate ?? this.startedLocalDate,
    protectionMode: protectionMode ?? this.protectionMode,
    durationPresetMinutes: durationPresetMinutes ?? this.durationPresetMinutes,
    plannedDurationSeconds:
        plannedDurationSeconds ?? this.plannedDurationSeconds,
    protectedDurationSeconds:
        protectedDurationSeconds ?? this.protectedDurationSeconds,
    status: status ?? this.status,
    endedAtUtcMicros: endedAtUtcMicros.present
        ? endedAtUtcMicros.value
        : this.endedAtUtcMicros,
    usedFiveMinuteBypass: usedFiveMinuteBypass ?? this.usedFiveMinuteBypass,
    intention: intention ?? this.intention,
  );
  FocusSessionRow copyWithCompanion(FocusSessionsCompanion data) {
    return FocusSessionRow(
      id: data.id.present ? data.id.value : this.id,
      startedAtUtcMicros: data.startedAtUtcMicros.present
          ? data.startedAtUtcMicros.value
          : this.startedAtUtcMicros,
      startedLocalDate: data.startedLocalDate.present
          ? data.startedLocalDate.value
          : this.startedLocalDate,
      protectionMode: data.protectionMode.present
          ? data.protectionMode.value
          : this.protectionMode,
      durationPresetMinutes: data.durationPresetMinutes.present
          ? data.durationPresetMinutes.value
          : this.durationPresetMinutes,
      plannedDurationSeconds: data.plannedDurationSeconds.present
          ? data.plannedDurationSeconds.value
          : this.plannedDurationSeconds,
      protectedDurationSeconds: data.protectedDurationSeconds.present
          ? data.protectedDurationSeconds.value
          : this.protectedDurationSeconds,
      status: data.status.present ? data.status.value : this.status,
      endedAtUtcMicros: data.endedAtUtcMicros.present
          ? data.endedAtUtcMicros.value
          : this.endedAtUtcMicros,
      usedFiveMinuteBypass: data.usedFiveMinuteBypass.present
          ? data.usedFiveMinuteBypass.value
          : this.usedFiveMinuteBypass,
      intention: data.intention.present ? data.intention.value : this.intention,
    );
  }

  @override
  String toString() {
    return (StringBuffer('FocusSessionRow(')
          ..write('id: $id, ')
          ..write('startedAtUtcMicros: $startedAtUtcMicros, ')
          ..write('startedLocalDate: $startedLocalDate, ')
          ..write('protectionMode: $protectionMode, ')
          ..write('durationPresetMinutes: $durationPresetMinutes, ')
          ..write('plannedDurationSeconds: $plannedDurationSeconds, ')
          ..write('protectedDurationSeconds: $protectedDurationSeconds, ')
          ..write('status: $status, ')
          ..write('endedAtUtcMicros: $endedAtUtcMicros, ')
          ..write('usedFiveMinuteBypass: $usedFiveMinuteBypass, ')
          ..write('intention: $intention')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    startedAtUtcMicros,
    startedLocalDate,
    protectionMode,
    durationPresetMinutes,
    plannedDurationSeconds,
    protectedDurationSeconds,
    status,
    endedAtUtcMicros,
    usedFiveMinuteBypass,
    intention,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is FocusSessionRow &&
          other.id == this.id &&
          other.startedAtUtcMicros == this.startedAtUtcMicros &&
          other.startedLocalDate == this.startedLocalDate &&
          other.protectionMode == this.protectionMode &&
          other.durationPresetMinutes == this.durationPresetMinutes &&
          other.plannedDurationSeconds == this.plannedDurationSeconds &&
          other.protectedDurationSeconds == this.protectedDurationSeconds &&
          other.status == this.status &&
          other.endedAtUtcMicros == this.endedAtUtcMicros &&
          other.usedFiveMinuteBypass == this.usedFiveMinuteBypass &&
          other.intention == this.intention);
}

class FocusSessionsCompanion extends UpdateCompanion<FocusSessionRow> {
  final Value<String> id;
  final Value<int> startedAtUtcMicros;
  final Value<String> startedLocalDate;
  final Value<String> protectionMode;
  final Value<int> durationPresetMinutes;
  final Value<int> plannedDurationSeconds;
  final Value<int> protectedDurationSeconds;
  final Value<String> status;
  final Value<int?> endedAtUtcMicros;
  final Value<bool> usedFiveMinuteBypass;
  final Value<String> intention;
  final Value<int> rowid;
  const FocusSessionsCompanion({
    this.id = const Value.absent(),
    this.startedAtUtcMicros = const Value.absent(),
    this.startedLocalDate = const Value.absent(),
    this.protectionMode = const Value.absent(),
    this.durationPresetMinutes = const Value.absent(),
    this.plannedDurationSeconds = const Value.absent(),
    this.protectedDurationSeconds = const Value.absent(),
    this.status = const Value.absent(),
    this.endedAtUtcMicros = const Value.absent(),
    this.usedFiveMinuteBypass = const Value.absent(),
    this.intention = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  FocusSessionsCompanion.insert({
    required String id,
    required int startedAtUtcMicros,
    required String startedLocalDate,
    required String protectionMode,
    required int durationPresetMinutes,
    required int plannedDurationSeconds,
    required int protectedDurationSeconds,
    required String status,
    this.endedAtUtcMicros = const Value.absent(),
    required bool usedFiveMinuteBypass,
    this.intention = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       startedAtUtcMicros = Value(startedAtUtcMicros),
       startedLocalDate = Value(startedLocalDate),
       protectionMode = Value(protectionMode),
       durationPresetMinutes = Value(durationPresetMinutes),
       plannedDurationSeconds = Value(plannedDurationSeconds),
       protectedDurationSeconds = Value(protectedDurationSeconds),
       status = Value(status),
       usedFiveMinuteBypass = Value(usedFiveMinuteBypass);
  static Insertable<FocusSessionRow> custom({
    Expression<String>? id,
    Expression<int>? startedAtUtcMicros,
    Expression<String>? startedLocalDate,
    Expression<String>? protectionMode,
    Expression<int>? durationPresetMinutes,
    Expression<int>? plannedDurationSeconds,
    Expression<int>? protectedDurationSeconds,
    Expression<String>? status,
    Expression<int>? endedAtUtcMicros,
    Expression<bool>? usedFiveMinuteBypass,
    Expression<String>? intention,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (startedAtUtcMicros != null)
        'started_at_utc_micros': startedAtUtcMicros,
      if (startedLocalDate != null) 'started_local_date': startedLocalDate,
      if (protectionMode != null) 'protection_mode': protectionMode,
      if (durationPresetMinutes != null)
        'duration_preset_minutes': durationPresetMinutes,
      if (plannedDurationSeconds != null)
        'planned_duration_seconds': plannedDurationSeconds,
      if (protectedDurationSeconds != null)
        'protected_duration_seconds': protectedDurationSeconds,
      if (status != null) 'status': status,
      if (endedAtUtcMicros != null) 'ended_at_utc_micros': endedAtUtcMicros,
      if (usedFiveMinuteBypass != null)
        'used_five_minute_bypass': usedFiveMinuteBypass,
      if (intention != null) 'intention': intention,
      if (rowid != null) 'rowid': rowid,
    });
  }

  FocusSessionsCompanion copyWith({
    Value<String>? id,
    Value<int>? startedAtUtcMicros,
    Value<String>? startedLocalDate,
    Value<String>? protectionMode,
    Value<int>? durationPresetMinutes,
    Value<int>? plannedDurationSeconds,
    Value<int>? protectedDurationSeconds,
    Value<String>? status,
    Value<int?>? endedAtUtcMicros,
    Value<bool>? usedFiveMinuteBypass,
    Value<String>? intention,
    Value<int>? rowid,
  }) {
    return FocusSessionsCompanion(
      id: id ?? this.id,
      startedAtUtcMicros: startedAtUtcMicros ?? this.startedAtUtcMicros,
      startedLocalDate: startedLocalDate ?? this.startedLocalDate,
      protectionMode: protectionMode ?? this.protectionMode,
      durationPresetMinutes:
          durationPresetMinutes ?? this.durationPresetMinutes,
      plannedDurationSeconds:
          plannedDurationSeconds ?? this.plannedDurationSeconds,
      protectedDurationSeconds:
          protectedDurationSeconds ?? this.protectedDurationSeconds,
      status: status ?? this.status,
      endedAtUtcMicros: endedAtUtcMicros ?? this.endedAtUtcMicros,
      usedFiveMinuteBypass: usedFiveMinuteBypass ?? this.usedFiveMinuteBypass,
      intention: intention ?? this.intention,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (startedAtUtcMicros.present) {
      map['started_at_utc_micros'] = Variable<int>(startedAtUtcMicros.value);
    }
    if (startedLocalDate.present) {
      map['started_local_date'] = Variable<String>(startedLocalDate.value);
    }
    if (protectionMode.present) {
      map['protection_mode'] = Variable<String>(protectionMode.value);
    }
    if (durationPresetMinutes.present) {
      map['duration_preset_minutes'] = Variable<int>(
        durationPresetMinutes.value,
      );
    }
    if (plannedDurationSeconds.present) {
      map['planned_duration_seconds'] = Variable<int>(
        plannedDurationSeconds.value,
      );
    }
    if (protectedDurationSeconds.present) {
      map['protected_duration_seconds'] = Variable<int>(
        protectedDurationSeconds.value,
      );
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (endedAtUtcMicros.present) {
      map['ended_at_utc_micros'] = Variable<int>(endedAtUtcMicros.value);
    }
    if (usedFiveMinuteBypass.present) {
      map['used_five_minute_bypass'] = Variable<bool>(
        usedFiveMinuteBypass.value,
      );
    }
    if (intention.present) {
      map['intention'] = Variable<String>(intention.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('FocusSessionsCompanion(')
          ..write('id: $id, ')
          ..write('startedAtUtcMicros: $startedAtUtcMicros, ')
          ..write('startedLocalDate: $startedLocalDate, ')
          ..write('protectionMode: $protectionMode, ')
          ..write('durationPresetMinutes: $durationPresetMinutes, ')
          ..write('plannedDurationSeconds: $plannedDurationSeconds, ')
          ..write('protectedDurationSeconds: $protectedDurationSeconds, ')
          ..write('status: $status, ')
          ..write('endedAtUtcMicros: $endedAtUtcMicros, ')
          ..write('usedFiveMinuteBypass: $usedFiveMinuteBypass, ')
          ..write('intention: $intention, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $TreeCompanionsTable extends TreeCompanions
    with TableInfo<$TreeCompanionsTable, TreeCompanionRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TreeCompanionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _singletonKeyMeta = const VerificationMeta(
    'singletonKey',
  );
  @override
  late final GeneratedColumn<int> singletonKey = GeneratedColumn<int>(
    'singleton_key',
    aliasedName,
    false,
    check: () => singletonKey.equals(1),
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
    defaultValue: const Constant<int>(1),
  );
  static const VerificationMeta _speciesMeta = const VerificationMeta(
    'species',
  );
  @override
  late final GeneratedColumn<String> species = GeneratedColumn<String>(
    'species',
    aliasedName,
    false,
    check: () => species.equals('zelkovaV1'),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtUtcMicrosMeta =
      const VerificationMeta('createdAtUtcMicros');
  @override
  late final GeneratedColumn<int> createdAtUtcMicros = GeneratedColumn<int>(
    'created_at_utc_micros',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _ruleVersionMeta = const VerificationMeta(
    'ruleVersion',
  );
  @override
  late final GeneratedColumn<int> ruleVersion = GeneratedColumn<int>(
    'rule_version',
    aliasedName,
    false,
    check: () => ComparableExpr(ruleVersion).isBiggerThanValue(0),
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    singletonKey,
    species,
    createdAtUtcMicros,
    ruleVersion,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'tree_companions';
  @override
  VerificationContext validateIntegrity(
    Insertable<TreeCompanionRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('singleton_key')) {
      context.handle(
        _singletonKeyMeta,
        singletonKey.isAcceptableOrUnknown(
          data['singleton_key']!,
          _singletonKeyMeta,
        ),
      );
    }
    if (data.containsKey('species')) {
      context.handle(
        _speciesMeta,
        species.isAcceptableOrUnknown(data['species']!, _speciesMeta),
      );
    } else if (isInserting) {
      context.missing(_speciesMeta);
    }
    if (data.containsKey('created_at_utc_micros')) {
      context.handle(
        _createdAtUtcMicrosMeta,
        createdAtUtcMicros.isAcceptableOrUnknown(
          data['created_at_utc_micros']!,
          _createdAtUtcMicrosMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_createdAtUtcMicrosMeta);
    }
    if (data.containsKey('rule_version')) {
      context.handle(
        _ruleVersionMeta,
        ruleVersion.isAcceptableOrUnknown(
          data['rule_version']!,
          _ruleVersionMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_ruleVersionMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  TreeCompanionRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TreeCompanionRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      singletonKey: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}singleton_key'],
      )!,
      species: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}species'],
      )!,
      createdAtUtcMicros: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at_utc_micros'],
      )!,
      ruleVersion: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}rule_version'],
      )!,
    );
  }

  @override
  $TreeCompanionsTable createAlias(String alias) {
    return $TreeCompanionsTable(attachedDatabase, alias);
  }
}

class TreeCompanionRow extends DataClass
    implements Insertable<TreeCompanionRow> {
  final String id;
  final int singletonKey;
  final String species;
  final int createdAtUtcMicros;
  final int ruleVersion;
  const TreeCompanionRow({
    required this.id,
    required this.singletonKey,
    required this.species,
    required this.createdAtUtcMicros,
    required this.ruleVersion,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['singleton_key'] = Variable<int>(singletonKey);
    map['species'] = Variable<String>(species);
    map['created_at_utc_micros'] = Variable<int>(createdAtUtcMicros);
    map['rule_version'] = Variable<int>(ruleVersion);
    return map;
  }

  TreeCompanionsCompanion toCompanion(bool nullToAbsent) {
    return TreeCompanionsCompanion(
      id: Value(id),
      singletonKey: Value(singletonKey),
      species: Value(species),
      createdAtUtcMicros: Value(createdAtUtcMicros),
      ruleVersion: Value(ruleVersion),
    );
  }

  factory TreeCompanionRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TreeCompanionRow(
      id: serializer.fromJson<String>(json['id']),
      singletonKey: serializer.fromJson<int>(json['singletonKey']),
      species: serializer.fromJson<String>(json['species']),
      createdAtUtcMicros: serializer.fromJson<int>(json['createdAtUtcMicros']),
      ruleVersion: serializer.fromJson<int>(json['ruleVersion']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'singletonKey': serializer.toJson<int>(singletonKey),
      'species': serializer.toJson<String>(species),
      'createdAtUtcMicros': serializer.toJson<int>(createdAtUtcMicros),
      'ruleVersion': serializer.toJson<int>(ruleVersion),
    };
  }

  TreeCompanionRow copyWith({
    String? id,
    int? singletonKey,
    String? species,
    int? createdAtUtcMicros,
    int? ruleVersion,
  }) => TreeCompanionRow(
    id: id ?? this.id,
    singletonKey: singletonKey ?? this.singletonKey,
    species: species ?? this.species,
    createdAtUtcMicros: createdAtUtcMicros ?? this.createdAtUtcMicros,
    ruleVersion: ruleVersion ?? this.ruleVersion,
  );
  TreeCompanionRow copyWithCompanion(TreeCompanionsCompanion data) {
    return TreeCompanionRow(
      id: data.id.present ? data.id.value : this.id,
      singletonKey: data.singletonKey.present
          ? data.singletonKey.value
          : this.singletonKey,
      species: data.species.present ? data.species.value : this.species,
      createdAtUtcMicros: data.createdAtUtcMicros.present
          ? data.createdAtUtcMicros.value
          : this.createdAtUtcMicros,
      ruleVersion: data.ruleVersion.present
          ? data.ruleVersion.value
          : this.ruleVersion,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TreeCompanionRow(')
          ..write('id: $id, ')
          ..write('singletonKey: $singletonKey, ')
          ..write('species: $species, ')
          ..write('createdAtUtcMicros: $createdAtUtcMicros, ')
          ..write('ruleVersion: $ruleVersion')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, singletonKey, species, createdAtUtcMicros, ruleVersion);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TreeCompanionRow &&
          other.id == this.id &&
          other.singletonKey == this.singletonKey &&
          other.species == this.species &&
          other.createdAtUtcMicros == this.createdAtUtcMicros &&
          other.ruleVersion == this.ruleVersion);
}

class TreeCompanionsCompanion extends UpdateCompanion<TreeCompanionRow> {
  final Value<String> id;
  final Value<int> singletonKey;
  final Value<String> species;
  final Value<int> createdAtUtcMicros;
  final Value<int> ruleVersion;
  final Value<int> rowid;
  const TreeCompanionsCompanion({
    this.id = const Value.absent(),
    this.singletonKey = const Value.absent(),
    this.species = const Value.absent(),
    this.createdAtUtcMicros = const Value.absent(),
    this.ruleVersion = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  TreeCompanionsCompanion.insert({
    required String id,
    this.singletonKey = const Value.absent(),
    required String species,
    required int createdAtUtcMicros,
    required int ruleVersion,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       species = Value(species),
       createdAtUtcMicros = Value(createdAtUtcMicros),
       ruleVersion = Value(ruleVersion);
  static Insertable<TreeCompanionRow> custom({
    Expression<String>? id,
    Expression<int>? singletonKey,
    Expression<String>? species,
    Expression<int>? createdAtUtcMicros,
    Expression<int>? ruleVersion,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (singletonKey != null) 'singleton_key': singletonKey,
      if (species != null) 'species': species,
      if (createdAtUtcMicros != null)
        'created_at_utc_micros': createdAtUtcMicros,
      if (ruleVersion != null) 'rule_version': ruleVersion,
      if (rowid != null) 'rowid': rowid,
    });
  }

  TreeCompanionsCompanion copyWith({
    Value<String>? id,
    Value<int>? singletonKey,
    Value<String>? species,
    Value<int>? createdAtUtcMicros,
    Value<int>? ruleVersion,
    Value<int>? rowid,
  }) {
    return TreeCompanionsCompanion(
      id: id ?? this.id,
      singletonKey: singletonKey ?? this.singletonKey,
      species: species ?? this.species,
      createdAtUtcMicros: createdAtUtcMicros ?? this.createdAtUtcMicros,
      ruleVersion: ruleVersion ?? this.ruleVersion,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (singletonKey.present) {
      map['singleton_key'] = Variable<int>(singletonKey.value);
    }
    if (species.present) {
      map['species'] = Variable<String>(species.value);
    }
    if (createdAtUtcMicros.present) {
      map['created_at_utc_micros'] = Variable<int>(createdAtUtcMicros.value);
    }
    if (ruleVersion.present) {
      map['rule_version'] = Variable<int>(ruleVersion.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TreeCompanionsCompanion(')
          ..write('id: $id, ')
          ..write('singletonKey: $singletonKey, ')
          ..write('species: $species, ')
          ..write('createdAtUtcMicros: $createdAtUtcMicros, ')
          ..write('ruleVersion: $ruleVersion, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $TreeGrowthCreditsTable extends TreeGrowthCredits
    with TableInfo<$TreeGrowthCreditsTable, TreeGrowthCreditRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TreeGrowthCreditsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _treeIdMeta = const VerificationMeta('treeId');
  @override
  late final GeneratedColumn<String> treeId = GeneratedColumn<String>(
    'tree_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES tree_companions (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _sourceSessionIdMeta = const VerificationMeta(
    'sourceSessionId',
  );
  @override
  late final GeneratedColumn<String> sourceSessionId = GeneratedColumn<String>(
    'source_session_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES focus_sessions (id) ON DELETE RESTRICT',
    ),
  );
  static const VerificationMeta _creditedLocalDateMeta = const VerificationMeta(
    'creditedLocalDate',
  );
  @override
  late final GeneratedColumn<String> creditedLocalDate =
      GeneratedColumn<String>(
        'credited_local_date',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _creditedAtUtcMicrosMeta =
      const VerificationMeta('creditedAtUtcMicros');
  @override
  late final GeneratedColumn<int> creditedAtUtcMicros = GeneratedColumn<int>(
    'credited_at_utc_micros',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _ruleVersionMeta = const VerificationMeta(
    'ruleVersion',
  );
  @override
  late final GeneratedColumn<int> ruleVersion = GeneratedColumn<int>(
    'rule_version',
    aliasedName,
    false,
    check: () => ComparableExpr(ruleVersion).isBiggerThanValue(0),
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    treeId,
    sourceSessionId,
    creditedLocalDate,
    creditedAtUtcMicros,
    ruleVersion,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'tree_growth_credits';
  @override
  VerificationContext validateIntegrity(
    Insertable<TreeGrowthCreditRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('tree_id')) {
      context.handle(
        _treeIdMeta,
        treeId.isAcceptableOrUnknown(data['tree_id']!, _treeIdMeta),
      );
    } else if (isInserting) {
      context.missing(_treeIdMeta);
    }
    if (data.containsKey('source_session_id')) {
      context.handle(
        _sourceSessionIdMeta,
        sourceSessionId.isAcceptableOrUnknown(
          data['source_session_id']!,
          _sourceSessionIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_sourceSessionIdMeta);
    }
    if (data.containsKey('credited_local_date')) {
      context.handle(
        _creditedLocalDateMeta,
        creditedLocalDate.isAcceptableOrUnknown(
          data['credited_local_date']!,
          _creditedLocalDateMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_creditedLocalDateMeta);
    }
    if (data.containsKey('credited_at_utc_micros')) {
      context.handle(
        _creditedAtUtcMicrosMeta,
        creditedAtUtcMicros.isAcceptableOrUnknown(
          data['credited_at_utc_micros']!,
          _creditedAtUtcMicrosMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_creditedAtUtcMicrosMeta);
    }
    if (data.containsKey('rule_version')) {
      context.handle(
        _ruleVersionMeta,
        ruleVersion.isAcceptableOrUnknown(
          data['rule_version']!,
          _ruleVersionMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_ruleVersionMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {sourceSessionId};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {treeId, creditedLocalDate},
  ];
  @override
  TreeGrowthCreditRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TreeGrowthCreditRow(
      treeId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}tree_id'],
      )!,
      sourceSessionId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source_session_id'],
      )!,
      creditedLocalDate: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}credited_local_date'],
      )!,
      creditedAtUtcMicros: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}credited_at_utc_micros'],
      )!,
      ruleVersion: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}rule_version'],
      )!,
    );
  }

  @override
  $TreeGrowthCreditsTable createAlias(String alias) {
    return $TreeGrowthCreditsTable(attachedDatabase, alias);
  }
}

class TreeGrowthCreditRow extends DataClass
    implements Insertable<TreeGrowthCreditRow> {
  final String treeId;
  final String sourceSessionId;
  final String creditedLocalDate;
  final int creditedAtUtcMicros;
  final int ruleVersion;
  const TreeGrowthCreditRow({
    required this.treeId,
    required this.sourceSessionId,
    required this.creditedLocalDate,
    required this.creditedAtUtcMicros,
    required this.ruleVersion,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['tree_id'] = Variable<String>(treeId);
    map['source_session_id'] = Variable<String>(sourceSessionId);
    map['credited_local_date'] = Variable<String>(creditedLocalDate);
    map['credited_at_utc_micros'] = Variable<int>(creditedAtUtcMicros);
    map['rule_version'] = Variable<int>(ruleVersion);
    return map;
  }

  TreeGrowthCreditsCompanion toCompanion(bool nullToAbsent) {
    return TreeGrowthCreditsCompanion(
      treeId: Value(treeId),
      sourceSessionId: Value(sourceSessionId),
      creditedLocalDate: Value(creditedLocalDate),
      creditedAtUtcMicros: Value(creditedAtUtcMicros),
      ruleVersion: Value(ruleVersion),
    );
  }

  factory TreeGrowthCreditRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TreeGrowthCreditRow(
      treeId: serializer.fromJson<String>(json['treeId']),
      sourceSessionId: serializer.fromJson<String>(json['sourceSessionId']),
      creditedLocalDate: serializer.fromJson<String>(json['creditedLocalDate']),
      creditedAtUtcMicros: serializer.fromJson<int>(
        json['creditedAtUtcMicros'],
      ),
      ruleVersion: serializer.fromJson<int>(json['ruleVersion']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'treeId': serializer.toJson<String>(treeId),
      'sourceSessionId': serializer.toJson<String>(sourceSessionId),
      'creditedLocalDate': serializer.toJson<String>(creditedLocalDate),
      'creditedAtUtcMicros': serializer.toJson<int>(creditedAtUtcMicros),
      'ruleVersion': serializer.toJson<int>(ruleVersion),
    };
  }

  TreeGrowthCreditRow copyWith({
    String? treeId,
    String? sourceSessionId,
    String? creditedLocalDate,
    int? creditedAtUtcMicros,
    int? ruleVersion,
  }) => TreeGrowthCreditRow(
    treeId: treeId ?? this.treeId,
    sourceSessionId: sourceSessionId ?? this.sourceSessionId,
    creditedLocalDate: creditedLocalDate ?? this.creditedLocalDate,
    creditedAtUtcMicros: creditedAtUtcMicros ?? this.creditedAtUtcMicros,
    ruleVersion: ruleVersion ?? this.ruleVersion,
  );
  TreeGrowthCreditRow copyWithCompanion(TreeGrowthCreditsCompanion data) {
    return TreeGrowthCreditRow(
      treeId: data.treeId.present ? data.treeId.value : this.treeId,
      sourceSessionId: data.sourceSessionId.present
          ? data.sourceSessionId.value
          : this.sourceSessionId,
      creditedLocalDate: data.creditedLocalDate.present
          ? data.creditedLocalDate.value
          : this.creditedLocalDate,
      creditedAtUtcMicros: data.creditedAtUtcMicros.present
          ? data.creditedAtUtcMicros.value
          : this.creditedAtUtcMicros,
      ruleVersion: data.ruleVersion.present
          ? data.ruleVersion.value
          : this.ruleVersion,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TreeGrowthCreditRow(')
          ..write('treeId: $treeId, ')
          ..write('sourceSessionId: $sourceSessionId, ')
          ..write('creditedLocalDate: $creditedLocalDate, ')
          ..write('creditedAtUtcMicros: $creditedAtUtcMicros, ')
          ..write('ruleVersion: $ruleVersion')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    treeId,
    sourceSessionId,
    creditedLocalDate,
    creditedAtUtcMicros,
    ruleVersion,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TreeGrowthCreditRow &&
          other.treeId == this.treeId &&
          other.sourceSessionId == this.sourceSessionId &&
          other.creditedLocalDate == this.creditedLocalDate &&
          other.creditedAtUtcMicros == this.creditedAtUtcMicros &&
          other.ruleVersion == this.ruleVersion);
}

class TreeGrowthCreditsCompanion extends UpdateCompanion<TreeGrowthCreditRow> {
  final Value<String> treeId;
  final Value<String> sourceSessionId;
  final Value<String> creditedLocalDate;
  final Value<int> creditedAtUtcMicros;
  final Value<int> ruleVersion;
  final Value<int> rowid;
  const TreeGrowthCreditsCompanion({
    this.treeId = const Value.absent(),
    this.sourceSessionId = const Value.absent(),
    this.creditedLocalDate = const Value.absent(),
    this.creditedAtUtcMicros = const Value.absent(),
    this.ruleVersion = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  TreeGrowthCreditsCompanion.insert({
    required String treeId,
    required String sourceSessionId,
    required String creditedLocalDate,
    required int creditedAtUtcMicros,
    required int ruleVersion,
    this.rowid = const Value.absent(),
  }) : treeId = Value(treeId),
       sourceSessionId = Value(sourceSessionId),
       creditedLocalDate = Value(creditedLocalDate),
       creditedAtUtcMicros = Value(creditedAtUtcMicros),
       ruleVersion = Value(ruleVersion);
  static Insertable<TreeGrowthCreditRow> custom({
    Expression<String>? treeId,
    Expression<String>? sourceSessionId,
    Expression<String>? creditedLocalDate,
    Expression<int>? creditedAtUtcMicros,
    Expression<int>? ruleVersion,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (treeId != null) 'tree_id': treeId,
      if (sourceSessionId != null) 'source_session_id': sourceSessionId,
      if (creditedLocalDate != null) 'credited_local_date': creditedLocalDate,
      if (creditedAtUtcMicros != null)
        'credited_at_utc_micros': creditedAtUtcMicros,
      if (ruleVersion != null) 'rule_version': ruleVersion,
      if (rowid != null) 'rowid': rowid,
    });
  }

  TreeGrowthCreditsCompanion copyWith({
    Value<String>? treeId,
    Value<String>? sourceSessionId,
    Value<String>? creditedLocalDate,
    Value<int>? creditedAtUtcMicros,
    Value<int>? ruleVersion,
    Value<int>? rowid,
  }) {
    return TreeGrowthCreditsCompanion(
      treeId: treeId ?? this.treeId,
      sourceSessionId: sourceSessionId ?? this.sourceSessionId,
      creditedLocalDate: creditedLocalDate ?? this.creditedLocalDate,
      creditedAtUtcMicros: creditedAtUtcMicros ?? this.creditedAtUtcMicros,
      ruleVersion: ruleVersion ?? this.ruleVersion,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (treeId.present) {
      map['tree_id'] = Variable<String>(treeId.value);
    }
    if (sourceSessionId.present) {
      map['source_session_id'] = Variable<String>(sourceSessionId.value);
    }
    if (creditedLocalDate.present) {
      map['credited_local_date'] = Variable<String>(creditedLocalDate.value);
    }
    if (creditedAtUtcMicros.present) {
      map['credited_at_utc_micros'] = Variable<int>(creditedAtUtcMicros.value);
    }
    if (ruleVersion.present) {
      map['rule_version'] = Variable<int>(ruleVersion.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TreeGrowthCreditsCompanion(')
          ..write('treeId: $treeId, ')
          ..write('sourceSessionId: $sourceSessionId, ')
          ..write('creditedLocalDate: $creditedLocalDate, ')
          ..write('creditedAtUtcMicros: $creditedAtUtcMicros, ')
          ..write('ruleVersion: $ruleVersion, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SevenDayExperimentsTable extends SevenDayExperiments
    with TableInfo<$SevenDayExperimentsTable, SevenDayExperimentRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SevenDayExperimentsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _singletonKeyMeta = const VerificationMeta(
    'singletonKey',
  );
  @override
  late final GeneratedColumn<int> singletonKey = GeneratedColumn<int>(
    'singleton_key',
    aliasedName,
    false,
    check: () => singletonKey.equals(1),
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant<int>(1),
  );
  static const VerificationMeta _startedLocalDateMeta = const VerificationMeta(
    'startedLocalDate',
  );
  @override
  late final GeneratedColumn<String> startedLocalDate = GeneratedColumn<String>(
    'started_local_date',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _lengthDaysMeta = const VerificationMeta(
    'lengthDays',
  );
  @override
  late final GeneratedColumn<int> lengthDays = GeneratedColumn<int>(
    'length_days',
    aliasedName,
    false,
    check: () => lengthDays.equals(7),
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant<int>(7),
  );
  @override
  List<GeneratedColumn> get $columns => [
    singletonKey,
    startedLocalDate,
    lengthDays,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'seven_day_experiments';
  @override
  VerificationContext validateIntegrity(
    Insertable<SevenDayExperimentRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('singleton_key')) {
      context.handle(
        _singletonKeyMeta,
        singletonKey.isAcceptableOrUnknown(
          data['singleton_key']!,
          _singletonKeyMeta,
        ),
      );
    }
    if (data.containsKey('started_local_date')) {
      context.handle(
        _startedLocalDateMeta,
        startedLocalDate.isAcceptableOrUnknown(
          data['started_local_date']!,
          _startedLocalDateMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_startedLocalDateMeta);
    }
    if (data.containsKey('length_days')) {
      context.handle(
        _lengthDaysMeta,
        lengthDays.isAcceptableOrUnknown(data['length_days']!, _lengthDaysMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {singletonKey};
  @override
  SevenDayExperimentRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SevenDayExperimentRow(
      singletonKey: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}singleton_key'],
      )!,
      startedLocalDate: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}started_local_date'],
      )!,
      lengthDays: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}length_days'],
      )!,
    );
  }

  @override
  $SevenDayExperimentsTable createAlias(String alias) {
    return $SevenDayExperimentsTable(attachedDatabase, alias);
  }
}

class SevenDayExperimentRow extends DataClass
    implements Insertable<SevenDayExperimentRow> {
  final int singletonKey;
  final String startedLocalDate;
  final int lengthDays;
  const SevenDayExperimentRow({
    required this.singletonKey,
    required this.startedLocalDate,
    required this.lengthDays,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['singleton_key'] = Variable<int>(singletonKey);
    map['started_local_date'] = Variable<String>(startedLocalDate);
    map['length_days'] = Variable<int>(lengthDays);
    return map;
  }

  SevenDayExperimentsCompanion toCompanion(bool nullToAbsent) {
    return SevenDayExperimentsCompanion(
      singletonKey: Value(singletonKey),
      startedLocalDate: Value(startedLocalDate),
      lengthDays: Value(lengthDays),
    );
  }

  factory SevenDayExperimentRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SevenDayExperimentRow(
      singletonKey: serializer.fromJson<int>(json['singletonKey']),
      startedLocalDate: serializer.fromJson<String>(json['startedLocalDate']),
      lengthDays: serializer.fromJson<int>(json['lengthDays']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'singletonKey': serializer.toJson<int>(singletonKey),
      'startedLocalDate': serializer.toJson<String>(startedLocalDate),
      'lengthDays': serializer.toJson<int>(lengthDays),
    };
  }

  SevenDayExperimentRow copyWith({
    int? singletonKey,
    String? startedLocalDate,
    int? lengthDays,
  }) => SevenDayExperimentRow(
    singletonKey: singletonKey ?? this.singletonKey,
    startedLocalDate: startedLocalDate ?? this.startedLocalDate,
    lengthDays: lengthDays ?? this.lengthDays,
  );
  SevenDayExperimentRow copyWithCompanion(SevenDayExperimentsCompanion data) {
    return SevenDayExperimentRow(
      singletonKey: data.singletonKey.present
          ? data.singletonKey.value
          : this.singletonKey,
      startedLocalDate: data.startedLocalDate.present
          ? data.startedLocalDate.value
          : this.startedLocalDate,
      lengthDays: data.lengthDays.present
          ? data.lengthDays.value
          : this.lengthDays,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SevenDayExperimentRow(')
          ..write('singletonKey: $singletonKey, ')
          ..write('startedLocalDate: $startedLocalDate, ')
          ..write('lengthDays: $lengthDays')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(singletonKey, startedLocalDate, lengthDays);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SevenDayExperimentRow &&
          other.singletonKey == this.singletonKey &&
          other.startedLocalDate == this.startedLocalDate &&
          other.lengthDays == this.lengthDays);
}

class SevenDayExperimentsCompanion
    extends UpdateCompanion<SevenDayExperimentRow> {
  final Value<int> singletonKey;
  final Value<String> startedLocalDate;
  final Value<int> lengthDays;
  const SevenDayExperimentsCompanion({
    this.singletonKey = const Value.absent(),
    this.startedLocalDate = const Value.absent(),
    this.lengthDays = const Value.absent(),
  });
  SevenDayExperimentsCompanion.insert({
    this.singletonKey = const Value.absent(),
    required String startedLocalDate,
    this.lengthDays = const Value.absent(),
  }) : startedLocalDate = Value(startedLocalDate);
  static Insertable<SevenDayExperimentRow> custom({
    Expression<int>? singletonKey,
    Expression<String>? startedLocalDate,
    Expression<int>? lengthDays,
  }) {
    return RawValuesInsertable({
      if (singletonKey != null) 'singleton_key': singletonKey,
      if (startedLocalDate != null) 'started_local_date': startedLocalDate,
      if (lengthDays != null) 'length_days': lengthDays,
    });
  }

  SevenDayExperimentsCompanion copyWith({
    Value<int>? singletonKey,
    Value<String>? startedLocalDate,
    Value<int>? lengthDays,
  }) {
    return SevenDayExperimentsCompanion(
      singletonKey: singletonKey ?? this.singletonKey,
      startedLocalDate: startedLocalDate ?? this.startedLocalDate,
      lengthDays: lengthDays ?? this.lengthDays,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (singletonKey.present) {
      map['singleton_key'] = Variable<int>(singletonKey.value);
    }
    if (startedLocalDate.present) {
      map['started_local_date'] = Variable<String>(startedLocalDate.value);
    }
    if (lengthDays.present) {
      map['length_days'] = Variable<int>(lengthDays.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SevenDayExperimentsCompanion(')
          ..write('singletonKey: $singletonKey, ')
          ..write('startedLocalDate: $startedLocalDate, ')
          ..write('lengthDays: $lengthDays')
          ..write(')'))
        .toString();
  }
}

class $DailyCheckInsTable extends DailyCheckIns
    with TableInfo<$DailyCheckInsTable, DailyCheckInRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DailyCheckInsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _localDateMeta = const VerificationMeta(
    'localDate',
  );
  @override
  late final GeneratedColumn<String> localDate = GeneratedColumn<String>(
    'local_date',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _intentionAlignmentMeta =
      const VerificationMeta('intentionAlignment');
  @override
  late final GeneratedColumn<String> intentionAlignment =
      GeneratedColumn<String>(
        'intention_alignment',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      );
  @override
  List<GeneratedColumn> get $columns => [localDate, intentionAlignment];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'daily_check_ins';
  @override
  VerificationContext validateIntegrity(
    Insertable<DailyCheckInRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('local_date')) {
      context.handle(
        _localDateMeta,
        localDate.isAcceptableOrUnknown(data['local_date']!, _localDateMeta),
      );
    } else if (isInserting) {
      context.missing(_localDateMeta);
    }
    if (data.containsKey('intention_alignment')) {
      context.handle(
        _intentionAlignmentMeta,
        intentionAlignment.isAcceptableOrUnknown(
          data['intention_alignment']!,
          _intentionAlignmentMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_intentionAlignmentMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {localDate};
  @override
  DailyCheckInRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DailyCheckInRow(
      localDate: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}local_date'],
      )!,
      intentionAlignment: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}intention_alignment'],
      )!,
    );
  }

  @override
  $DailyCheckInsTable createAlias(String alias) {
    return $DailyCheckInsTable(attachedDatabase, alias);
  }
}

class DailyCheckInRow extends DataClass implements Insertable<DailyCheckInRow> {
  final String localDate;
  final String intentionAlignment;
  const DailyCheckInRow({
    required this.localDate,
    required this.intentionAlignment,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['local_date'] = Variable<String>(localDate);
    map['intention_alignment'] = Variable<String>(intentionAlignment);
    return map;
  }

  DailyCheckInsCompanion toCompanion(bool nullToAbsent) {
    return DailyCheckInsCompanion(
      localDate: Value(localDate),
      intentionAlignment: Value(intentionAlignment),
    );
  }

  factory DailyCheckInRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DailyCheckInRow(
      localDate: serializer.fromJson<String>(json['localDate']),
      intentionAlignment: serializer.fromJson<String>(
        json['intentionAlignment'],
      ),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'localDate': serializer.toJson<String>(localDate),
      'intentionAlignment': serializer.toJson<String>(intentionAlignment),
    };
  }

  DailyCheckInRow copyWith({String? localDate, String? intentionAlignment}) =>
      DailyCheckInRow(
        localDate: localDate ?? this.localDate,
        intentionAlignment: intentionAlignment ?? this.intentionAlignment,
      );
  DailyCheckInRow copyWithCompanion(DailyCheckInsCompanion data) {
    return DailyCheckInRow(
      localDate: data.localDate.present ? data.localDate.value : this.localDate,
      intentionAlignment: data.intentionAlignment.present
          ? data.intentionAlignment.value
          : this.intentionAlignment,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DailyCheckInRow(')
          ..write('localDate: $localDate, ')
          ..write('intentionAlignment: $intentionAlignment')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(localDate, intentionAlignment);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DailyCheckInRow &&
          other.localDate == this.localDate &&
          other.intentionAlignment == this.intentionAlignment);
}

class DailyCheckInsCompanion extends UpdateCompanion<DailyCheckInRow> {
  final Value<String> localDate;
  final Value<String> intentionAlignment;
  final Value<int> rowid;
  const DailyCheckInsCompanion({
    this.localDate = const Value.absent(),
    this.intentionAlignment = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  DailyCheckInsCompanion.insert({
    required String localDate,
    required String intentionAlignment,
    this.rowid = const Value.absent(),
  }) : localDate = Value(localDate),
       intentionAlignment = Value(intentionAlignment);
  static Insertable<DailyCheckInRow> custom({
    Expression<String>? localDate,
    Expression<String>? intentionAlignment,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (localDate != null) 'local_date': localDate,
      if (intentionAlignment != null) 'intention_alignment': intentionAlignment,
      if (rowid != null) 'rowid': rowid,
    });
  }

  DailyCheckInsCompanion copyWith({
    Value<String>? localDate,
    Value<String>? intentionAlignment,
    Value<int>? rowid,
  }) {
    return DailyCheckInsCompanion(
      localDate: localDate ?? this.localDate,
      intentionAlignment: intentionAlignment ?? this.intentionAlignment,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (localDate.present) {
      map['local_date'] = Variable<String>(localDate.value);
    }
    if (intentionAlignment.present) {
      map['intention_alignment'] = Variable<String>(intentionAlignment.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DailyCheckInsCompanion(')
          ..write('localDate: $localDate, ')
          ..write('intentionAlignment: $intentionAlignment, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$DopaDatabase extends GeneratedDatabase {
  _$DopaDatabase(QueryExecutor e) : super(e);
  $DopaDatabaseManager get managers => $DopaDatabaseManager(this);
  late final $FocusSessionsTable focusSessions = $FocusSessionsTable(this);
  late final $TreeCompanionsTable treeCompanions = $TreeCompanionsTable(this);
  late final $TreeGrowthCreditsTable treeGrowthCredits =
      $TreeGrowthCreditsTable(this);
  late final $SevenDayExperimentsTable sevenDayExperiments =
      $SevenDayExperimentsTable(this);
  late final $DailyCheckInsTable dailyCheckIns = $DailyCheckInsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    focusSessions,
    treeCompanions,
    treeGrowthCredits,
    sevenDayExperiments,
    dailyCheckIns,
  ];
  @override
  StreamQueryUpdateRules get streamUpdateRules => const StreamQueryUpdateRules([
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'tree_companions',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('tree_growth_credits', kind: UpdateKind.delete)],
    ),
  ]);
}

typedef $$FocusSessionsTableCreateCompanionBuilder =
    FocusSessionsCompanion Function({
      required String id,
      required int startedAtUtcMicros,
      required String startedLocalDate,
      required String protectionMode,
      required int durationPresetMinutes,
      required int plannedDurationSeconds,
      required int protectedDurationSeconds,
      required String status,
      Value<int?> endedAtUtcMicros,
      required bool usedFiveMinuteBypass,
      Value<String> intention,
      Value<int> rowid,
    });
typedef $$FocusSessionsTableUpdateCompanionBuilder =
    FocusSessionsCompanion Function({
      Value<String> id,
      Value<int> startedAtUtcMicros,
      Value<String> startedLocalDate,
      Value<String> protectionMode,
      Value<int> durationPresetMinutes,
      Value<int> plannedDurationSeconds,
      Value<int> protectedDurationSeconds,
      Value<String> status,
      Value<int?> endedAtUtcMicros,
      Value<bool> usedFiveMinuteBypass,
      Value<String> intention,
      Value<int> rowid,
    });

final class $$FocusSessionsTableReferences
    extends
        BaseReferences<_$DopaDatabase, $FocusSessionsTable, FocusSessionRow> {
  $$FocusSessionsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static MultiTypedResultKey<$TreeGrowthCreditsTable, List<TreeGrowthCreditRow>>
  _treeGrowthCreditsRefsTable(_$DopaDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.treeGrowthCredits,
        aliasName: 'focus_sessions__id__tree_growth_credits__source_session_id',
      );

  $$TreeGrowthCreditsTableProcessedTableManager get treeGrowthCreditsRefs {
    final manager =
        $$TreeGrowthCreditsTableTableManager(
          $_db,
          $_db.treeGrowthCredits,
        ).filter(
          (f) => f.sourceSessionId.id.sqlEquals($_itemColumn<String>('id')!),
        );

    final cache = $_typedResult.readTableOrNull(
      _treeGrowthCreditsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$FocusSessionsTableFilterComposer
    extends Composer<_$DopaDatabase, $FocusSessionsTable> {
  $$FocusSessionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get startedAtUtcMicros => $composableBuilder(
    column: $table.startedAtUtcMicros,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get startedLocalDate => $composableBuilder(
    column: $table.startedLocalDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get protectionMode => $composableBuilder(
    column: $table.protectionMode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get durationPresetMinutes => $composableBuilder(
    column: $table.durationPresetMinutes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get plannedDurationSeconds => $composableBuilder(
    column: $table.plannedDurationSeconds,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get protectedDurationSeconds => $composableBuilder(
    column: $table.protectedDurationSeconds,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get endedAtUtcMicros => $composableBuilder(
    column: $table.endedAtUtcMicros,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get usedFiveMinuteBypass => $composableBuilder(
    column: $table.usedFiveMinuteBypass,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get intention => $composableBuilder(
    column: $table.intention,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> treeGrowthCreditsRefs(
    Expression<bool> Function($$TreeGrowthCreditsTableFilterComposer f) f,
  ) {
    final $$TreeGrowthCreditsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.treeGrowthCredits,
      getReferencedColumn: (t) => t.sourceSessionId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TreeGrowthCreditsTableFilterComposer(
            $db: $db,
            $table: $db.treeGrowthCredits,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$FocusSessionsTableOrderingComposer
    extends Composer<_$DopaDatabase, $FocusSessionsTable> {
  $$FocusSessionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get startedAtUtcMicros => $composableBuilder(
    column: $table.startedAtUtcMicros,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get startedLocalDate => $composableBuilder(
    column: $table.startedLocalDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get protectionMode => $composableBuilder(
    column: $table.protectionMode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get durationPresetMinutes => $composableBuilder(
    column: $table.durationPresetMinutes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get plannedDurationSeconds => $composableBuilder(
    column: $table.plannedDurationSeconds,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get protectedDurationSeconds => $composableBuilder(
    column: $table.protectedDurationSeconds,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get endedAtUtcMicros => $composableBuilder(
    column: $table.endedAtUtcMicros,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get usedFiveMinuteBypass => $composableBuilder(
    column: $table.usedFiveMinuteBypass,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get intention => $composableBuilder(
    column: $table.intention,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$FocusSessionsTableAnnotationComposer
    extends Composer<_$DopaDatabase, $FocusSessionsTable> {
  $$FocusSessionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get startedAtUtcMicros => $composableBuilder(
    column: $table.startedAtUtcMicros,
    builder: (column) => column,
  );

  GeneratedColumn<String> get startedLocalDate => $composableBuilder(
    column: $table.startedLocalDate,
    builder: (column) => column,
  );

  GeneratedColumn<String> get protectionMode => $composableBuilder(
    column: $table.protectionMode,
    builder: (column) => column,
  );

  GeneratedColumn<int> get durationPresetMinutes => $composableBuilder(
    column: $table.durationPresetMinutes,
    builder: (column) => column,
  );

  GeneratedColumn<int> get plannedDurationSeconds => $composableBuilder(
    column: $table.plannedDurationSeconds,
    builder: (column) => column,
  );

  GeneratedColumn<int> get protectedDurationSeconds => $composableBuilder(
    column: $table.protectedDurationSeconds,
    builder: (column) => column,
  );

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<int> get endedAtUtcMicros => $composableBuilder(
    column: $table.endedAtUtcMicros,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get usedFiveMinuteBypass => $composableBuilder(
    column: $table.usedFiveMinuteBypass,
    builder: (column) => column,
  );

  GeneratedColumn<String> get intention =>
      $composableBuilder(column: $table.intention, builder: (column) => column);

  Expression<T> treeGrowthCreditsRefs<T extends Object>(
    Expression<T> Function($$TreeGrowthCreditsTableAnnotationComposer a) f,
  ) {
    final $$TreeGrowthCreditsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.treeGrowthCredits,
          getReferencedColumn: (t) => t.sourceSessionId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$TreeGrowthCreditsTableAnnotationComposer(
                $db: $db,
                $table: $db.treeGrowthCredits,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$FocusSessionsTableTableManager
    extends
        RootTableManager<
          _$DopaDatabase,
          $FocusSessionsTable,
          FocusSessionRow,
          $$FocusSessionsTableFilterComposer,
          $$FocusSessionsTableOrderingComposer,
          $$FocusSessionsTableAnnotationComposer,
          $$FocusSessionsTableCreateCompanionBuilder,
          $$FocusSessionsTableUpdateCompanionBuilder,
          (FocusSessionRow, $$FocusSessionsTableReferences),
          FocusSessionRow,
          PrefetchHooks Function({bool treeGrowthCreditsRefs})
        > {
  $$FocusSessionsTableTableManager(_$DopaDatabase db, $FocusSessionsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$FocusSessionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$FocusSessionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$FocusSessionsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<int> startedAtUtcMicros = const Value.absent(),
                Value<String> startedLocalDate = const Value.absent(),
                Value<String> protectionMode = const Value.absent(),
                Value<int> durationPresetMinutes = const Value.absent(),
                Value<int> plannedDurationSeconds = const Value.absent(),
                Value<int> protectedDurationSeconds = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<int?> endedAtUtcMicros = const Value.absent(),
                Value<bool> usedFiveMinuteBypass = const Value.absent(),
                Value<String> intention = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => FocusSessionsCompanion(
                id: id,
                startedAtUtcMicros: startedAtUtcMicros,
                startedLocalDate: startedLocalDate,
                protectionMode: protectionMode,
                durationPresetMinutes: durationPresetMinutes,
                plannedDurationSeconds: plannedDurationSeconds,
                protectedDurationSeconds: protectedDurationSeconds,
                status: status,
                endedAtUtcMicros: endedAtUtcMicros,
                usedFiveMinuteBypass: usedFiveMinuteBypass,
                intention: intention,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required int startedAtUtcMicros,
                required String startedLocalDate,
                required String protectionMode,
                required int durationPresetMinutes,
                required int plannedDurationSeconds,
                required int protectedDurationSeconds,
                required String status,
                Value<int?> endedAtUtcMicros = const Value.absent(),
                required bool usedFiveMinuteBypass,
                Value<String> intention = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => FocusSessionsCompanion.insert(
                id: id,
                startedAtUtcMicros: startedAtUtcMicros,
                startedLocalDate: startedLocalDate,
                protectionMode: protectionMode,
                durationPresetMinutes: durationPresetMinutes,
                plannedDurationSeconds: plannedDurationSeconds,
                protectedDurationSeconds: protectedDurationSeconds,
                status: status,
                endedAtUtcMicros: endedAtUtcMicros,
                usedFiveMinuteBypass: usedFiveMinuteBypass,
                intention: intention,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$FocusSessionsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({treeGrowthCreditsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (treeGrowthCreditsRefs) db.treeGrowthCredits,
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (treeGrowthCreditsRefs)
                    await $_getPrefetchedData<
                      FocusSessionRow,
                      $FocusSessionsTable,
                      TreeGrowthCreditRow
                    >(
                      currentTable: table,
                      referencedTable: $$FocusSessionsTableReferences
                          ._treeGrowthCreditsRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$FocusSessionsTableReferences(
                            db,
                            table,
                            p0,
                          ).treeGrowthCreditsRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where(
                            (e) => e.sourceSessionId == item.id,
                          ),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$FocusSessionsTableProcessedTableManager =
    ProcessedTableManager<
      _$DopaDatabase,
      $FocusSessionsTable,
      FocusSessionRow,
      $$FocusSessionsTableFilterComposer,
      $$FocusSessionsTableOrderingComposer,
      $$FocusSessionsTableAnnotationComposer,
      $$FocusSessionsTableCreateCompanionBuilder,
      $$FocusSessionsTableUpdateCompanionBuilder,
      (FocusSessionRow, $$FocusSessionsTableReferences),
      FocusSessionRow,
      PrefetchHooks Function({bool treeGrowthCreditsRefs})
    >;
typedef $$TreeCompanionsTableCreateCompanionBuilder =
    TreeCompanionsCompanion Function({
      required String id,
      Value<int> singletonKey,
      required String species,
      required int createdAtUtcMicros,
      required int ruleVersion,
      Value<int> rowid,
    });
typedef $$TreeCompanionsTableUpdateCompanionBuilder =
    TreeCompanionsCompanion Function({
      Value<String> id,
      Value<int> singletonKey,
      Value<String> species,
      Value<int> createdAtUtcMicros,
      Value<int> ruleVersion,
      Value<int> rowid,
    });

final class $$TreeCompanionsTableReferences
    extends
        BaseReferences<_$DopaDatabase, $TreeCompanionsTable, TreeCompanionRow> {
  $$TreeCompanionsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static MultiTypedResultKey<$TreeGrowthCreditsTable, List<TreeGrowthCreditRow>>
  _treeGrowthCreditsRefsTable(_$DopaDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.treeGrowthCredits,
        aliasName: 'tree_companions__id__tree_growth_credits__tree_id',
      );

  $$TreeGrowthCreditsTableProcessedTableManager get treeGrowthCreditsRefs {
    final manager = $$TreeGrowthCreditsTableTableManager(
      $_db,
      $_db.treeGrowthCredits,
    ).filter((f) => f.treeId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _treeGrowthCreditsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$TreeCompanionsTableFilterComposer
    extends Composer<_$DopaDatabase, $TreeCompanionsTable> {
  $$TreeCompanionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get singletonKey => $composableBuilder(
    column: $table.singletonKey,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get species => $composableBuilder(
    column: $table.species,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAtUtcMicros => $composableBuilder(
    column: $table.createdAtUtcMicros,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get ruleVersion => $composableBuilder(
    column: $table.ruleVersion,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> treeGrowthCreditsRefs(
    Expression<bool> Function($$TreeGrowthCreditsTableFilterComposer f) f,
  ) {
    final $$TreeGrowthCreditsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.treeGrowthCredits,
      getReferencedColumn: (t) => t.treeId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TreeGrowthCreditsTableFilterComposer(
            $db: $db,
            $table: $db.treeGrowthCredits,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$TreeCompanionsTableOrderingComposer
    extends Composer<_$DopaDatabase, $TreeCompanionsTable> {
  $$TreeCompanionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get singletonKey => $composableBuilder(
    column: $table.singletonKey,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get species => $composableBuilder(
    column: $table.species,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAtUtcMicros => $composableBuilder(
    column: $table.createdAtUtcMicros,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get ruleVersion => $composableBuilder(
    column: $table.ruleVersion,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$TreeCompanionsTableAnnotationComposer
    extends Composer<_$DopaDatabase, $TreeCompanionsTable> {
  $$TreeCompanionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get singletonKey => $composableBuilder(
    column: $table.singletonKey,
    builder: (column) => column,
  );

  GeneratedColumn<String> get species =>
      $composableBuilder(column: $table.species, builder: (column) => column);

  GeneratedColumn<int> get createdAtUtcMicros => $composableBuilder(
    column: $table.createdAtUtcMicros,
    builder: (column) => column,
  );

  GeneratedColumn<int> get ruleVersion => $composableBuilder(
    column: $table.ruleVersion,
    builder: (column) => column,
  );

  Expression<T> treeGrowthCreditsRefs<T extends Object>(
    Expression<T> Function($$TreeGrowthCreditsTableAnnotationComposer a) f,
  ) {
    final $$TreeGrowthCreditsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.treeGrowthCredits,
          getReferencedColumn: (t) => t.treeId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$TreeGrowthCreditsTableAnnotationComposer(
                $db: $db,
                $table: $db.treeGrowthCredits,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$TreeCompanionsTableTableManager
    extends
        RootTableManager<
          _$DopaDatabase,
          $TreeCompanionsTable,
          TreeCompanionRow,
          $$TreeCompanionsTableFilterComposer,
          $$TreeCompanionsTableOrderingComposer,
          $$TreeCompanionsTableAnnotationComposer,
          $$TreeCompanionsTableCreateCompanionBuilder,
          $$TreeCompanionsTableUpdateCompanionBuilder,
          (TreeCompanionRow, $$TreeCompanionsTableReferences),
          TreeCompanionRow,
          PrefetchHooks Function({bool treeGrowthCreditsRefs})
        > {
  $$TreeCompanionsTableTableManager(
    _$DopaDatabase db,
    $TreeCompanionsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TreeCompanionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TreeCompanionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TreeCompanionsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<int> singletonKey = const Value.absent(),
                Value<String> species = const Value.absent(),
                Value<int> createdAtUtcMicros = const Value.absent(),
                Value<int> ruleVersion = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TreeCompanionsCompanion(
                id: id,
                singletonKey: singletonKey,
                species: species,
                createdAtUtcMicros: createdAtUtcMicros,
                ruleVersion: ruleVersion,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                Value<int> singletonKey = const Value.absent(),
                required String species,
                required int createdAtUtcMicros,
                required int ruleVersion,
                Value<int> rowid = const Value.absent(),
              }) => TreeCompanionsCompanion.insert(
                id: id,
                singletonKey: singletonKey,
                species: species,
                createdAtUtcMicros: createdAtUtcMicros,
                ruleVersion: ruleVersion,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$TreeCompanionsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({treeGrowthCreditsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (treeGrowthCreditsRefs) db.treeGrowthCredits,
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (treeGrowthCreditsRefs)
                    await $_getPrefetchedData<
                      TreeCompanionRow,
                      $TreeCompanionsTable,
                      TreeGrowthCreditRow
                    >(
                      currentTable: table,
                      referencedTable: $$TreeCompanionsTableReferences
                          ._treeGrowthCreditsRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$TreeCompanionsTableReferences(
                            db,
                            table,
                            p0,
                          ).treeGrowthCreditsRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.treeId == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$TreeCompanionsTableProcessedTableManager =
    ProcessedTableManager<
      _$DopaDatabase,
      $TreeCompanionsTable,
      TreeCompanionRow,
      $$TreeCompanionsTableFilterComposer,
      $$TreeCompanionsTableOrderingComposer,
      $$TreeCompanionsTableAnnotationComposer,
      $$TreeCompanionsTableCreateCompanionBuilder,
      $$TreeCompanionsTableUpdateCompanionBuilder,
      (TreeCompanionRow, $$TreeCompanionsTableReferences),
      TreeCompanionRow,
      PrefetchHooks Function({bool treeGrowthCreditsRefs})
    >;
typedef $$TreeGrowthCreditsTableCreateCompanionBuilder =
    TreeGrowthCreditsCompanion Function({
      required String treeId,
      required String sourceSessionId,
      required String creditedLocalDate,
      required int creditedAtUtcMicros,
      required int ruleVersion,
      Value<int> rowid,
    });
typedef $$TreeGrowthCreditsTableUpdateCompanionBuilder =
    TreeGrowthCreditsCompanion Function({
      Value<String> treeId,
      Value<String> sourceSessionId,
      Value<String> creditedLocalDate,
      Value<int> creditedAtUtcMicros,
      Value<int> ruleVersion,
      Value<int> rowid,
    });

final class $$TreeGrowthCreditsTableReferences
    extends
        BaseReferences<
          _$DopaDatabase,
          $TreeGrowthCreditsTable,
          TreeGrowthCreditRow
        > {
  $$TreeGrowthCreditsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $TreeCompanionsTable _treeIdTable(_$DopaDatabase db) => db
      .treeCompanions
      .createAlias('tree_growth_credits__tree_id__tree_companions__id');

  $$TreeCompanionsTableProcessedTableManager get treeId {
    final $_column = $_itemColumn<String>('tree_id')!;

    final manager = $$TreeCompanionsTableTableManager(
      $_db,
      $_db.treeCompanions,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_treeIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $FocusSessionsTable _sourceSessionIdTable(_$DopaDatabase db) =>
      db.focusSessions.createAlias(
        'tree_growth_credits__source_session_id__focus_sessions__id',
      );

  $$FocusSessionsTableProcessedTableManager get sourceSessionId {
    final $_column = $_itemColumn<String>('source_session_id')!;

    final manager = $$FocusSessionsTableTableManager(
      $_db,
      $_db.focusSessions,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_sourceSessionIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$TreeGrowthCreditsTableFilterComposer
    extends Composer<_$DopaDatabase, $TreeGrowthCreditsTable> {
  $$TreeGrowthCreditsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get creditedLocalDate => $composableBuilder(
    column: $table.creditedLocalDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get creditedAtUtcMicros => $composableBuilder(
    column: $table.creditedAtUtcMicros,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get ruleVersion => $composableBuilder(
    column: $table.ruleVersion,
    builder: (column) => ColumnFilters(column),
  );

  $$TreeCompanionsTableFilterComposer get treeId {
    final $$TreeCompanionsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.treeId,
      referencedTable: $db.treeCompanions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TreeCompanionsTableFilterComposer(
            $db: $db,
            $table: $db.treeCompanions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$FocusSessionsTableFilterComposer get sourceSessionId {
    final $$FocusSessionsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sourceSessionId,
      referencedTable: $db.focusSessions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$FocusSessionsTableFilterComposer(
            $db: $db,
            $table: $db.focusSessions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$TreeGrowthCreditsTableOrderingComposer
    extends Composer<_$DopaDatabase, $TreeGrowthCreditsTable> {
  $$TreeGrowthCreditsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get creditedLocalDate => $composableBuilder(
    column: $table.creditedLocalDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get creditedAtUtcMicros => $composableBuilder(
    column: $table.creditedAtUtcMicros,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get ruleVersion => $composableBuilder(
    column: $table.ruleVersion,
    builder: (column) => ColumnOrderings(column),
  );

  $$TreeCompanionsTableOrderingComposer get treeId {
    final $$TreeCompanionsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.treeId,
      referencedTable: $db.treeCompanions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TreeCompanionsTableOrderingComposer(
            $db: $db,
            $table: $db.treeCompanions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$FocusSessionsTableOrderingComposer get sourceSessionId {
    final $$FocusSessionsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sourceSessionId,
      referencedTable: $db.focusSessions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$FocusSessionsTableOrderingComposer(
            $db: $db,
            $table: $db.focusSessions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$TreeGrowthCreditsTableAnnotationComposer
    extends Composer<_$DopaDatabase, $TreeGrowthCreditsTable> {
  $$TreeGrowthCreditsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get creditedLocalDate => $composableBuilder(
    column: $table.creditedLocalDate,
    builder: (column) => column,
  );

  GeneratedColumn<int> get creditedAtUtcMicros => $composableBuilder(
    column: $table.creditedAtUtcMicros,
    builder: (column) => column,
  );

  GeneratedColumn<int> get ruleVersion => $composableBuilder(
    column: $table.ruleVersion,
    builder: (column) => column,
  );

  $$TreeCompanionsTableAnnotationComposer get treeId {
    final $$TreeCompanionsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.treeId,
      referencedTable: $db.treeCompanions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TreeCompanionsTableAnnotationComposer(
            $db: $db,
            $table: $db.treeCompanions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$FocusSessionsTableAnnotationComposer get sourceSessionId {
    final $$FocusSessionsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sourceSessionId,
      referencedTable: $db.focusSessions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$FocusSessionsTableAnnotationComposer(
            $db: $db,
            $table: $db.focusSessions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$TreeGrowthCreditsTableTableManager
    extends
        RootTableManager<
          _$DopaDatabase,
          $TreeGrowthCreditsTable,
          TreeGrowthCreditRow,
          $$TreeGrowthCreditsTableFilterComposer,
          $$TreeGrowthCreditsTableOrderingComposer,
          $$TreeGrowthCreditsTableAnnotationComposer,
          $$TreeGrowthCreditsTableCreateCompanionBuilder,
          $$TreeGrowthCreditsTableUpdateCompanionBuilder,
          (TreeGrowthCreditRow, $$TreeGrowthCreditsTableReferences),
          TreeGrowthCreditRow,
          PrefetchHooks Function({bool treeId, bool sourceSessionId})
        > {
  $$TreeGrowthCreditsTableTableManager(
    _$DopaDatabase db,
    $TreeGrowthCreditsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TreeGrowthCreditsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TreeGrowthCreditsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TreeGrowthCreditsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> treeId = const Value.absent(),
                Value<String> sourceSessionId = const Value.absent(),
                Value<String> creditedLocalDate = const Value.absent(),
                Value<int> creditedAtUtcMicros = const Value.absent(),
                Value<int> ruleVersion = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TreeGrowthCreditsCompanion(
                treeId: treeId,
                sourceSessionId: sourceSessionId,
                creditedLocalDate: creditedLocalDate,
                creditedAtUtcMicros: creditedAtUtcMicros,
                ruleVersion: ruleVersion,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String treeId,
                required String sourceSessionId,
                required String creditedLocalDate,
                required int creditedAtUtcMicros,
                required int ruleVersion,
                Value<int> rowid = const Value.absent(),
              }) => TreeGrowthCreditsCompanion.insert(
                treeId: treeId,
                sourceSessionId: sourceSessionId,
                creditedLocalDate: creditedLocalDate,
                creditedAtUtcMicros: creditedAtUtcMicros,
                ruleVersion: ruleVersion,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$TreeGrowthCreditsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({treeId = false, sourceSessionId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (treeId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.treeId,
                        referencedTable: $$TreeGrowthCreditsTableReferences
                            ._treeIdTable(db),
                        referencedColumn: $$TreeGrowthCreditsTableReferences
                            ._treeIdTable(db)
                            .id,
                      ) as T;
                    }
                    if (sourceSessionId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.sourceSessionId,
                        referencedTable: $$TreeGrowthCreditsTableReferences
                            ._sourceSessionIdTable(db),
                        referencedColumn: $$TreeGrowthCreditsTableReferences
                            ._sourceSessionIdTable(db)
                            .id,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$TreeGrowthCreditsTableProcessedTableManager =
    ProcessedTableManager<
      _$DopaDatabase,
      $TreeGrowthCreditsTable,
      TreeGrowthCreditRow,
      $$TreeGrowthCreditsTableFilterComposer,
      $$TreeGrowthCreditsTableOrderingComposer,
      $$TreeGrowthCreditsTableAnnotationComposer,
      $$TreeGrowthCreditsTableCreateCompanionBuilder,
      $$TreeGrowthCreditsTableUpdateCompanionBuilder,
      (TreeGrowthCreditRow, $$TreeGrowthCreditsTableReferences),
      TreeGrowthCreditRow,
      PrefetchHooks Function({bool treeId, bool sourceSessionId})
    >;
typedef $$SevenDayExperimentsTableCreateCompanionBuilder =
    SevenDayExperimentsCompanion Function({
      Value<int> singletonKey,
      required String startedLocalDate,
      Value<int> lengthDays,
    });
typedef $$SevenDayExperimentsTableUpdateCompanionBuilder =
    SevenDayExperimentsCompanion Function({
      Value<int> singletonKey,
      Value<String> startedLocalDate,
      Value<int> lengthDays,
    });

class $$SevenDayExperimentsTableFilterComposer
    extends Composer<_$DopaDatabase, $SevenDayExperimentsTable> {
  $$SevenDayExperimentsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get singletonKey => $composableBuilder(
    column: $table.singletonKey,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get startedLocalDate => $composableBuilder(
    column: $table.startedLocalDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get lengthDays => $composableBuilder(
    column: $table.lengthDays,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SevenDayExperimentsTableOrderingComposer
    extends Composer<_$DopaDatabase, $SevenDayExperimentsTable> {
  $$SevenDayExperimentsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get singletonKey => $composableBuilder(
    column: $table.singletonKey,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get startedLocalDate => $composableBuilder(
    column: $table.startedLocalDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get lengthDays => $composableBuilder(
    column: $table.lengthDays,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SevenDayExperimentsTableAnnotationComposer
    extends Composer<_$DopaDatabase, $SevenDayExperimentsTable> {
  $$SevenDayExperimentsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get singletonKey => $composableBuilder(
    column: $table.singletonKey,
    builder: (column) => column,
  );

  GeneratedColumn<String> get startedLocalDate => $composableBuilder(
    column: $table.startedLocalDate,
    builder: (column) => column,
  );

  GeneratedColumn<int> get lengthDays => $composableBuilder(
    column: $table.lengthDays,
    builder: (column) => column,
  );
}

class $$SevenDayExperimentsTableTableManager
    extends
        RootTableManager<
          _$DopaDatabase,
          $SevenDayExperimentsTable,
          SevenDayExperimentRow,
          $$SevenDayExperimentsTableFilterComposer,
          $$SevenDayExperimentsTableOrderingComposer,
          $$SevenDayExperimentsTableAnnotationComposer,
          $$SevenDayExperimentsTableCreateCompanionBuilder,
          $$SevenDayExperimentsTableUpdateCompanionBuilder,
          (
            SevenDayExperimentRow,
            BaseReferences<
              _$DopaDatabase,
              $SevenDayExperimentsTable,
              SevenDayExperimentRow
            >,
          ),
          SevenDayExperimentRow,
          PrefetchHooks Function()
        > {
  $$SevenDayExperimentsTableTableManager(
    _$DopaDatabase db,
    $SevenDayExperimentsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SevenDayExperimentsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SevenDayExperimentsTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$SevenDayExperimentsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> singletonKey = const Value.absent(),
                Value<String> startedLocalDate = const Value.absent(),
                Value<int> lengthDays = const Value.absent(),
              }) => SevenDayExperimentsCompanion(
                singletonKey: singletonKey,
                startedLocalDate: startedLocalDate,
                lengthDays: lengthDays,
              ),
          createCompanionCallback:
              ({
                Value<int> singletonKey = const Value.absent(),
                required String startedLocalDate,
                Value<int> lengthDays = const Value.absent(),
              }) => SevenDayExperimentsCompanion.insert(
                singletonKey: singletonKey,
                startedLocalDate: startedLocalDate,
                lengthDays: lengthDays,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SevenDayExperimentsTableProcessedTableManager =
    ProcessedTableManager<
      _$DopaDatabase,
      $SevenDayExperimentsTable,
      SevenDayExperimentRow,
      $$SevenDayExperimentsTableFilterComposer,
      $$SevenDayExperimentsTableOrderingComposer,
      $$SevenDayExperimentsTableAnnotationComposer,
      $$SevenDayExperimentsTableCreateCompanionBuilder,
      $$SevenDayExperimentsTableUpdateCompanionBuilder,
      (
        SevenDayExperimentRow,
        BaseReferences<
          _$DopaDatabase,
          $SevenDayExperimentsTable,
          SevenDayExperimentRow
        >,
      ),
      SevenDayExperimentRow,
      PrefetchHooks Function()
    >;
typedef $$DailyCheckInsTableCreateCompanionBuilder =
    DailyCheckInsCompanion Function({
      required String localDate,
      required String intentionAlignment,
      Value<int> rowid,
    });
typedef $$DailyCheckInsTableUpdateCompanionBuilder =
    DailyCheckInsCompanion Function({
      Value<String> localDate,
      Value<String> intentionAlignment,
      Value<int> rowid,
    });

class $$DailyCheckInsTableFilterComposer
    extends Composer<_$DopaDatabase, $DailyCheckInsTable> {
  $$DailyCheckInsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get localDate => $composableBuilder(
    column: $table.localDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get intentionAlignment => $composableBuilder(
    column: $table.intentionAlignment,
    builder: (column) => ColumnFilters(column),
  );
}

class $$DailyCheckInsTableOrderingComposer
    extends Composer<_$DopaDatabase, $DailyCheckInsTable> {
  $$DailyCheckInsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get localDate => $composableBuilder(
    column: $table.localDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get intentionAlignment => $composableBuilder(
    column: $table.intentionAlignment,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$DailyCheckInsTableAnnotationComposer
    extends Composer<_$DopaDatabase, $DailyCheckInsTable> {
  $$DailyCheckInsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get localDate =>
      $composableBuilder(column: $table.localDate, builder: (column) => column);

  GeneratedColumn<String> get intentionAlignment => $composableBuilder(
    column: $table.intentionAlignment,
    builder: (column) => column,
  );
}

class $$DailyCheckInsTableTableManager
    extends
        RootTableManager<
          _$DopaDatabase,
          $DailyCheckInsTable,
          DailyCheckInRow,
          $$DailyCheckInsTableFilterComposer,
          $$DailyCheckInsTableOrderingComposer,
          $$DailyCheckInsTableAnnotationComposer,
          $$DailyCheckInsTableCreateCompanionBuilder,
          $$DailyCheckInsTableUpdateCompanionBuilder,
          (
            DailyCheckInRow,
            BaseReferences<
              _$DopaDatabase,
              $DailyCheckInsTable,
              DailyCheckInRow
            >,
          ),
          DailyCheckInRow,
          PrefetchHooks Function()
        > {
  $$DailyCheckInsTableTableManager(_$DopaDatabase db, $DailyCheckInsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DailyCheckInsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DailyCheckInsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DailyCheckInsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> localDate = const Value.absent(),
                Value<String> intentionAlignment = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => DailyCheckInsCompanion(
                localDate: localDate,
                intentionAlignment: intentionAlignment,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String localDate,
                required String intentionAlignment,
                Value<int> rowid = const Value.absent(),
              }) => DailyCheckInsCompanion.insert(
                localDate: localDate,
                intentionAlignment: intentionAlignment,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$DailyCheckInsTableProcessedTableManager =
    ProcessedTableManager<
      _$DopaDatabase,
      $DailyCheckInsTable,
      DailyCheckInRow,
      $$DailyCheckInsTableFilterComposer,
      $$DailyCheckInsTableOrderingComposer,
      $$DailyCheckInsTableAnnotationComposer,
      $$DailyCheckInsTableCreateCompanionBuilder,
      $$DailyCheckInsTableUpdateCompanionBuilder,
      (
        DailyCheckInRow,
        BaseReferences<_$DopaDatabase, $DailyCheckInsTable, DailyCheckInRow>,
      ),
      DailyCheckInRow,
      PrefetchHooks Function()
    >;

class $DopaDatabaseManager {
  final _$DopaDatabase _db;
  $DopaDatabaseManager(this._db);
  $$FocusSessionsTableTableManager get focusSessions =>
      $$FocusSessionsTableTableManager(_db, _db.focusSessions);
  $$TreeCompanionsTableTableManager get treeCompanions =>
      $$TreeCompanionsTableTableManager(_db, _db.treeCompanions);
  $$TreeGrowthCreditsTableTableManager get treeGrowthCredits =>
      $$TreeGrowthCreditsTableTableManager(_db, _db.treeGrowthCredits);
  $$SevenDayExperimentsTableTableManager get sevenDayExperiments =>
      $$SevenDayExperimentsTableTableManager(_db, _db.sevenDayExperiments);
  $$DailyCheckInsTableTableManager get dailyCheckIns =>
      $$DailyCheckInsTableTableManager(_db, _db.dailyCheckIns);
}
