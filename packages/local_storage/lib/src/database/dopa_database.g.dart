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
  );
  static const VerificationMeta _sourceKindMeta = const VerificationMeta(
    'sourceKind',
  );
  @override
  late final GeneratedColumn<String> sourceKind = GeneratedColumn<String>(
    'source_kind',
    aliasedName,
    false,
    check: () => sourceKind.isIn(const ['focus', 'companion']),
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('focus'),
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
    sourceKind,
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
    if (data.containsKey('source_kind')) {
      context.handle(
        _sourceKindMeta,
        sourceKind.isAcceptableOrUnknown(data['source_kind']!, _sourceKindMeta),
      );
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
      sourceKind: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source_kind'],
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
  final String sourceKind;
  final String creditedLocalDate;
  final int creditedAtUtcMicros;
  final int ruleVersion;
  const TreeGrowthCreditRow({
    required this.treeId,
    required this.sourceSessionId,
    required this.sourceKind,
    required this.creditedLocalDate,
    required this.creditedAtUtcMicros,
    required this.ruleVersion,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['tree_id'] = Variable<String>(treeId);
    map['source_session_id'] = Variable<String>(sourceSessionId);
    map['source_kind'] = Variable<String>(sourceKind);
    map['credited_local_date'] = Variable<String>(creditedLocalDate);
    map['credited_at_utc_micros'] = Variable<int>(creditedAtUtcMicros);
    map['rule_version'] = Variable<int>(ruleVersion);
    return map;
  }

  TreeGrowthCreditsCompanion toCompanion(bool nullToAbsent) {
    return TreeGrowthCreditsCompanion(
      treeId: Value(treeId),
      sourceSessionId: Value(sourceSessionId),
      sourceKind: Value(sourceKind),
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
      sourceKind: serializer.fromJson<String>(json['sourceKind']),
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
      'sourceKind': serializer.toJson<String>(sourceKind),
      'creditedLocalDate': serializer.toJson<String>(creditedLocalDate),
      'creditedAtUtcMicros': serializer.toJson<int>(creditedAtUtcMicros),
      'ruleVersion': serializer.toJson<int>(ruleVersion),
    };
  }

  TreeGrowthCreditRow copyWith({
    String? treeId,
    String? sourceSessionId,
    String? sourceKind,
    String? creditedLocalDate,
    int? creditedAtUtcMicros,
    int? ruleVersion,
  }) => TreeGrowthCreditRow(
    treeId: treeId ?? this.treeId,
    sourceSessionId: sourceSessionId ?? this.sourceSessionId,
    sourceKind: sourceKind ?? this.sourceKind,
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
      sourceKind: data.sourceKind.present
          ? data.sourceKind.value
          : this.sourceKind,
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
          ..write('sourceKind: $sourceKind, ')
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
    sourceKind,
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
          other.sourceKind == this.sourceKind &&
          other.creditedLocalDate == this.creditedLocalDate &&
          other.creditedAtUtcMicros == this.creditedAtUtcMicros &&
          other.ruleVersion == this.ruleVersion);
}

class TreeGrowthCreditsCompanion extends UpdateCompanion<TreeGrowthCreditRow> {
  final Value<String> treeId;
  final Value<String> sourceSessionId;
  final Value<String> sourceKind;
  final Value<String> creditedLocalDate;
  final Value<int> creditedAtUtcMicros;
  final Value<int> ruleVersion;
  final Value<int> rowid;
  const TreeGrowthCreditsCompanion({
    this.treeId = const Value.absent(),
    this.sourceSessionId = const Value.absent(),
    this.sourceKind = const Value.absent(),
    this.creditedLocalDate = const Value.absent(),
    this.creditedAtUtcMicros = const Value.absent(),
    this.ruleVersion = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  TreeGrowthCreditsCompanion.insert({
    required String treeId,
    required String sourceSessionId,
    this.sourceKind = const Value.absent(),
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
    Expression<String>? sourceKind,
    Expression<String>? creditedLocalDate,
    Expression<int>? creditedAtUtcMicros,
    Expression<int>? ruleVersion,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (treeId != null) 'tree_id': treeId,
      if (sourceSessionId != null) 'source_session_id': sourceSessionId,
      if (sourceKind != null) 'source_kind': sourceKind,
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
    Value<String>? sourceKind,
    Value<String>? creditedLocalDate,
    Value<int>? creditedAtUtcMicros,
    Value<int>? ruleVersion,
    Value<int>? rowid,
  }) {
    return TreeGrowthCreditsCompanion(
      treeId: treeId ?? this.treeId,
      sourceSessionId: sourceSessionId ?? this.sourceSessionId,
      sourceKind: sourceKind ?? this.sourceKind,
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
    if (sourceKind.present) {
      map['source_kind'] = Variable<String>(sourceKind.value);
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
          ..write('sourceKind: $sourceKind, ')
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

class $CompanionRunsTable extends CompanionRuns
    with TableInfo<$CompanionRunsTable, CompanionRunRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CompanionRunsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _positionMsMeta = const VerificationMeta(
    'positionMs',
  );
  @override
  late final GeneratedColumn<int> positionMs = GeneratedColumn<int>(
    'position_ms',
    aliasedName,
    false,
    check: () => ComparableExpr(positionMs).isBiggerOrEqualValue(0),
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _playbackRevisionMeta = const VerificationMeta(
    'playbackRevision',
  );
  @override
  late final GeneratedColumn<int> playbackRevision = GeneratedColumn<int>(
    'playback_revision',
    aliasedName,
    false,
    check: () => ComparableExpr(playbackRevision).isBiggerOrEqualValue(0),
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _guidanceModeMeta = const VerificationMeta(
    'guidanceMode',
  );
  @override
  late final GeneratedColumn<String> guidanceMode = GeneratedColumn<String>(
    'guidance_mode',
    aliasedName,
    false,
    check: () =>
        guidanceMode.isIn(const ['textSample', 'humanMedia', 'textFallback']),
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('textSample'),
  );
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _contentIdMeta = const VerificationMeta(
    'contentId',
  );
  @override
  late final GeneratedColumn<String> contentId = GeneratedColumn<String>(
    'content_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _contentVersionMeta = const VerificationMeta(
    'contentVersion',
  );
  @override
  late final GeneratedColumn<int> contentVersion = GeneratedColumn<int>(
    'content_version',
    aliasedName,
    false,
    check: () => ComparableExpr(contentVersion).isBiggerThanValue(0),
    type: DriftSqlType.int,
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
  static const VerificationMeta _stepCountMeta = const VerificationMeta(
    'stepCount',
  );
  @override
  late final GeneratedColumn<int> stepCount = GeneratedColumn<int>(
    'step_count',
    aliasedName,
    false,
    check: () => ComparableExpr(stepCount).isBiggerThanValue(0),
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _stepIndexMeta = const VerificationMeta(
    'stepIndex',
  );
  @override
  late final GeneratedColumn<int> stepIndex = GeneratedColumn<int>(
    'step_index',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _guideCompletedMeta = const VerificationMeta(
    'guideCompleted',
  );
  @override
  late final GeneratedColumn<bool> guideCompleted = GeneratedColumn<bool>(
    'guide_completed',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("guide_completed" IN (0, 1))',
    ),
  );
  static const VerificationMeta _awaitingOutcomeMeta = const VerificationMeta(
    'awaitingOutcome',
  );
  @override
  late final GeneratedColumn<bool> awaitingOutcome = GeneratedColumn<bool>(
    'awaiting_outcome',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("awaiting_outcome" IN (0, 1))',
    ),
  );
  static const VerificationMeta _activeSlotMeta = const VerificationMeta(
    'activeSlot',
  );
  @override
  late final GeneratedColumn<int> activeSlot = GeneratedColumn<int>(
    'active_slot',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  @override
  List<GeneratedColumn> get $columns => [
    positionMs,
    playbackRevision,
    guidanceMode,
    id,
    contentId,
    contentVersion,
    startedAtUtcMicros,
    startedLocalDate,
    stepCount,
    stepIndex,
    guideCompleted,
    awaitingOutcome,
    activeSlot,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'companion_runs';
  @override
  VerificationContext validateIntegrity(
    Insertable<CompanionRunRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('position_ms')) {
      context.handle(
        _positionMsMeta,
        positionMs.isAcceptableOrUnknown(data['position_ms']!, _positionMsMeta),
      );
    }
    if (data.containsKey('playback_revision')) {
      context.handle(
        _playbackRevisionMeta,
        playbackRevision.isAcceptableOrUnknown(
          data['playback_revision']!,
          _playbackRevisionMeta,
        ),
      );
    }
    if (data.containsKey('guidance_mode')) {
      context.handle(
        _guidanceModeMeta,
        guidanceMode.isAcceptableOrUnknown(
          data['guidance_mode']!,
          _guidanceModeMeta,
        ),
      );
    }
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('content_id')) {
      context.handle(
        _contentIdMeta,
        contentId.isAcceptableOrUnknown(data['content_id']!, _contentIdMeta),
      );
    } else if (isInserting) {
      context.missing(_contentIdMeta);
    }
    if (data.containsKey('content_version')) {
      context.handle(
        _contentVersionMeta,
        contentVersion.isAcceptableOrUnknown(
          data['content_version']!,
          _contentVersionMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_contentVersionMeta);
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
    if (data.containsKey('step_count')) {
      context.handle(
        _stepCountMeta,
        stepCount.isAcceptableOrUnknown(data['step_count']!, _stepCountMeta),
      );
    } else if (isInserting) {
      context.missing(_stepCountMeta);
    }
    if (data.containsKey('step_index')) {
      context.handle(
        _stepIndexMeta,
        stepIndex.isAcceptableOrUnknown(data['step_index']!, _stepIndexMeta),
      );
    } else if (isInserting) {
      context.missing(_stepIndexMeta);
    }
    if (data.containsKey('guide_completed')) {
      context.handle(
        _guideCompletedMeta,
        guideCompleted.isAcceptableOrUnknown(
          data['guide_completed']!,
          _guideCompletedMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_guideCompletedMeta);
    }
    if (data.containsKey('awaiting_outcome')) {
      context.handle(
        _awaitingOutcomeMeta,
        awaitingOutcome.isAcceptableOrUnknown(
          data['awaiting_outcome']!,
          _awaitingOutcomeMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_awaitingOutcomeMeta);
    }
    if (data.containsKey('active_slot')) {
      context.handle(
        _activeSlotMeta,
        activeSlot.isAcceptableOrUnknown(data['active_slot']!, _activeSlotMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CompanionRunRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CompanionRunRow(
      positionMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}position_ms'],
      )!,
      playbackRevision: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}playback_revision'],
      )!,
      guidanceMode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}guidance_mode'],
      )!,
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      contentId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}content_id'],
      )!,
      contentVersion: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}content_version'],
      )!,
      startedAtUtcMicros: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}started_at_utc_micros'],
      )!,
      startedLocalDate: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}started_local_date'],
      )!,
      stepCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}step_count'],
      )!,
      stepIndex: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}step_index'],
      )!,
      guideCompleted: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}guide_completed'],
      )!,
      awaitingOutcome: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}awaiting_outcome'],
      )!,
      activeSlot: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}active_slot'],
      ),
    );
  }

  @override
  $CompanionRunsTable createAlias(String alias) {
    return $CompanionRunsTable(attachedDatabase, alias);
  }
}

class CompanionRunRow extends DataClass implements Insertable<CompanionRunRow> {
  final int positionMs;
  final int playbackRevision;
  final String guidanceMode;
  final String id;
  final String contentId;
  final int contentVersion;
  final int startedAtUtcMicros;
  final String startedLocalDate;
  final int stepCount;
  final int stepIndex;
  final bool guideCompleted;
  final bool awaitingOutcome;
  final int? activeSlot;
  const CompanionRunRow({
    required this.positionMs,
    required this.playbackRevision,
    required this.guidanceMode,
    required this.id,
    required this.contentId,
    required this.contentVersion,
    required this.startedAtUtcMicros,
    required this.startedLocalDate,
    required this.stepCount,
    required this.stepIndex,
    required this.guideCompleted,
    required this.awaitingOutcome,
    this.activeSlot,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['position_ms'] = Variable<int>(positionMs);
    map['playback_revision'] = Variable<int>(playbackRevision);
    map['guidance_mode'] = Variable<String>(guidanceMode);
    map['id'] = Variable<String>(id);
    map['content_id'] = Variable<String>(contentId);
    map['content_version'] = Variable<int>(contentVersion);
    map['started_at_utc_micros'] = Variable<int>(startedAtUtcMicros);
    map['started_local_date'] = Variable<String>(startedLocalDate);
    map['step_count'] = Variable<int>(stepCount);
    map['step_index'] = Variable<int>(stepIndex);
    map['guide_completed'] = Variable<bool>(guideCompleted);
    map['awaiting_outcome'] = Variable<bool>(awaitingOutcome);
    if (!nullToAbsent || activeSlot != null) {
      map['active_slot'] = Variable<int>(activeSlot);
    }
    return map;
  }

  CompanionRunsCompanion toCompanion(bool nullToAbsent) {
    return CompanionRunsCompanion(
      positionMs: Value(positionMs),
      playbackRevision: Value(playbackRevision),
      guidanceMode: Value(guidanceMode),
      id: Value(id),
      contentId: Value(contentId),
      contentVersion: Value(contentVersion),
      startedAtUtcMicros: Value(startedAtUtcMicros),
      startedLocalDate: Value(startedLocalDate),
      stepCount: Value(stepCount),
      stepIndex: Value(stepIndex),
      guideCompleted: Value(guideCompleted),
      awaitingOutcome: Value(awaitingOutcome),
      activeSlot: activeSlot == null && nullToAbsent
          ? const Value.absent()
          : Value(activeSlot),
    );
  }

  factory CompanionRunRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CompanionRunRow(
      positionMs: serializer.fromJson<int>(json['positionMs']),
      playbackRevision: serializer.fromJson<int>(json['playbackRevision']),
      guidanceMode: serializer.fromJson<String>(json['guidanceMode']),
      id: serializer.fromJson<String>(json['id']),
      contentId: serializer.fromJson<String>(json['contentId']),
      contentVersion: serializer.fromJson<int>(json['contentVersion']),
      startedAtUtcMicros: serializer.fromJson<int>(json['startedAtUtcMicros']),
      startedLocalDate: serializer.fromJson<String>(json['startedLocalDate']),
      stepCount: serializer.fromJson<int>(json['stepCount']),
      stepIndex: serializer.fromJson<int>(json['stepIndex']),
      guideCompleted: serializer.fromJson<bool>(json['guideCompleted']),
      awaitingOutcome: serializer.fromJson<bool>(json['awaitingOutcome']),
      activeSlot: serializer.fromJson<int?>(json['activeSlot']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'positionMs': serializer.toJson<int>(positionMs),
      'playbackRevision': serializer.toJson<int>(playbackRevision),
      'guidanceMode': serializer.toJson<String>(guidanceMode),
      'id': serializer.toJson<String>(id),
      'contentId': serializer.toJson<String>(contentId),
      'contentVersion': serializer.toJson<int>(contentVersion),
      'startedAtUtcMicros': serializer.toJson<int>(startedAtUtcMicros),
      'startedLocalDate': serializer.toJson<String>(startedLocalDate),
      'stepCount': serializer.toJson<int>(stepCount),
      'stepIndex': serializer.toJson<int>(stepIndex),
      'guideCompleted': serializer.toJson<bool>(guideCompleted),
      'awaitingOutcome': serializer.toJson<bool>(awaitingOutcome),
      'activeSlot': serializer.toJson<int?>(activeSlot),
    };
  }

  CompanionRunRow copyWith({
    int? positionMs,
    int? playbackRevision,
    String? guidanceMode,
    String? id,
    String? contentId,
    int? contentVersion,
    int? startedAtUtcMicros,
    String? startedLocalDate,
    int? stepCount,
    int? stepIndex,
    bool? guideCompleted,
    bool? awaitingOutcome,
    Value<int?> activeSlot = const Value.absent(),
  }) => CompanionRunRow(
    positionMs: positionMs ?? this.positionMs,
    playbackRevision: playbackRevision ?? this.playbackRevision,
    guidanceMode: guidanceMode ?? this.guidanceMode,
    id: id ?? this.id,
    contentId: contentId ?? this.contentId,
    contentVersion: contentVersion ?? this.contentVersion,
    startedAtUtcMicros: startedAtUtcMicros ?? this.startedAtUtcMicros,
    startedLocalDate: startedLocalDate ?? this.startedLocalDate,
    stepCount: stepCount ?? this.stepCount,
    stepIndex: stepIndex ?? this.stepIndex,
    guideCompleted: guideCompleted ?? this.guideCompleted,
    awaitingOutcome: awaitingOutcome ?? this.awaitingOutcome,
    activeSlot: activeSlot.present ? activeSlot.value : this.activeSlot,
  );
  CompanionRunRow copyWithCompanion(CompanionRunsCompanion data) {
    return CompanionRunRow(
      positionMs: data.positionMs.present
          ? data.positionMs.value
          : this.positionMs,
      playbackRevision: data.playbackRevision.present
          ? data.playbackRevision.value
          : this.playbackRevision,
      guidanceMode: data.guidanceMode.present
          ? data.guidanceMode.value
          : this.guidanceMode,
      id: data.id.present ? data.id.value : this.id,
      contentId: data.contentId.present ? data.contentId.value : this.contentId,
      contentVersion: data.contentVersion.present
          ? data.contentVersion.value
          : this.contentVersion,
      startedAtUtcMicros: data.startedAtUtcMicros.present
          ? data.startedAtUtcMicros.value
          : this.startedAtUtcMicros,
      startedLocalDate: data.startedLocalDate.present
          ? data.startedLocalDate.value
          : this.startedLocalDate,
      stepCount: data.stepCount.present ? data.stepCount.value : this.stepCount,
      stepIndex: data.stepIndex.present ? data.stepIndex.value : this.stepIndex,
      guideCompleted: data.guideCompleted.present
          ? data.guideCompleted.value
          : this.guideCompleted,
      awaitingOutcome: data.awaitingOutcome.present
          ? data.awaitingOutcome.value
          : this.awaitingOutcome,
      activeSlot: data.activeSlot.present
          ? data.activeSlot.value
          : this.activeSlot,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CompanionRunRow(')
          ..write('positionMs: $positionMs, ')
          ..write('playbackRevision: $playbackRevision, ')
          ..write('guidanceMode: $guidanceMode, ')
          ..write('id: $id, ')
          ..write('contentId: $contentId, ')
          ..write('contentVersion: $contentVersion, ')
          ..write('startedAtUtcMicros: $startedAtUtcMicros, ')
          ..write('startedLocalDate: $startedLocalDate, ')
          ..write('stepCount: $stepCount, ')
          ..write('stepIndex: $stepIndex, ')
          ..write('guideCompleted: $guideCompleted, ')
          ..write('awaitingOutcome: $awaitingOutcome, ')
          ..write('activeSlot: $activeSlot')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    positionMs,
    playbackRevision,
    guidanceMode,
    id,
    contentId,
    contentVersion,
    startedAtUtcMicros,
    startedLocalDate,
    stepCount,
    stepIndex,
    guideCompleted,
    awaitingOutcome,
    activeSlot,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CompanionRunRow &&
          other.positionMs == this.positionMs &&
          other.playbackRevision == this.playbackRevision &&
          other.guidanceMode == this.guidanceMode &&
          other.id == this.id &&
          other.contentId == this.contentId &&
          other.contentVersion == this.contentVersion &&
          other.startedAtUtcMicros == this.startedAtUtcMicros &&
          other.startedLocalDate == this.startedLocalDate &&
          other.stepCount == this.stepCount &&
          other.stepIndex == this.stepIndex &&
          other.guideCompleted == this.guideCompleted &&
          other.awaitingOutcome == this.awaitingOutcome &&
          other.activeSlot == this.activeSlot);
}

class CompanionRunsCompanion extends UpdateCompanion<CompanionRunRow> {
  final Value<int> positionMs;
  final Value<int> playbackRevision;
  final Value<String> guidanceMode;
  final Value<String> id;
  final Value<String> contentId;
  final Value<int> contentVersion;
  final Value<int> startedAtUtcMicros;
  final Value<String> startedLocalDate;
  final Value<int> stepCount;
  final Value<int> stepIndex;
  final Value<bool> guideCompleted;
  final Value<bool> awaitingOutcome;
  final Value<int?> activeSlot;
  final Value<int> rowid;
  const CompanionRunsCompanion({
    this.positionMs = const Value.absent(),
    this.playbackRevision = const Value.absent(),
    this.guidanceMode = const Value.absent(),
    this.id = const Value.absent(),
    this.contentId = const Value.absent(),
    this.contentVersion = const Value.absent(),
    this.startedAtUtcMicros = const Value.absent(),
    this.startedLocalDate = const Value.absent(),
    this.stepCount = const Value.absent(),
    this.stepIndex = const Value.absent(),
    this.guideCompleted = const Value.absent(),
    this.awaitingOutcome = const Value.absent(),
    this.activeSlot = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CompanionRunsCompanion.insert({
    this.positionMs = const Value.absent(),
    this.playbackRevision = const Value.absent(),
    this.guidanceMode = const Value.absent(),
    required String id,
    required String contentId,
    required int contentVersion,
    required int startedAtUtcMicros,
    required String startedLocalDate,
    required int stepCount,
    required int stepIndex,
    required bool guideCompleted,
    required bool awaitingOutcome,
    this.activeSlot = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       contentId = Value(contentId),
       contentVersion = Value(contentVersion),
       startedAtUtcMicros = Value(startedAtUtcMicros),
       startedLocalDate = Value(startedLocalDate),
       stepCount = Value(stepCount),
       stepIndex = Value(stepIndex),
       guideCompleted = Value(guideCompleted),
       awaitingOutcome = Value(awaitingOutcome);
  static Insertable<CompanionRunRow> custom({
    Expression<int>? positionMs,
    Expression<int>? playbackRevision,
    Expression<String>? guidanceMode,
    Expression<String>? id,
    Expression<String>? contentId,
    Expression<int>? contentVersion,
    Expression<int>? startedAtUtcMicros,
    Expression<String>? startedLocalDate,
    Expression<int>? stepCount,
    Expression<int>? stepIndex,
    Expression<bool>? guideCompleted,
    Expression<bool>? awaitingOutcome,
    Expression<int>? activeSlot,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (positionMs != null) 'position_ms': positionMs,
      if (playbackRevision != null) 'playback_revision': playbackRevision,
      if (guidanceMode != null) 'guidance_mode': guidanceMode,
      if (id != null) 'id': id,
      if (contentId != null) 'content_id': contentId,
      if (contentVersion != null) 'content_version': contentVersion,
      if (startedAtUtcMicros != null)
        'started_at_utc_micros': startedAtUtcMicros,
      if (startedLocalDate != null) 'started_local_date': startedLocalDate,
      if (stepCount != null) 'step_count': stepCount,
      if (stepIndex != null) 'step_index': stepIndex,
      if (guideCompleted != null) 'guide_completed': guideCompleted,
      if (awaitingOutcome != null) 'awaiting_outcome': awaitingOutcome,
      if (activeSlot != null) 'active_slot': activeSlot,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CompanionRunsCompanion copyWith({
    Value<int>? positionMs,
    Value<int>? playbackRevision,
    Value<String>? guidanceMode,
    Value<String>? id,
    Value<String>? contentId,
    Value<int>? contentVersion,
    Value<int>? startedAtUtcMicros,
    Value<String>? startedLocalDate,
    Value<int>? stepCount,
    Value<int>? stepIndex,
    Value<bool>? guideCompleted,
    Value<bool>? awaitingOutcome,
    Value<int?>? activeSlot,
    Value<int>? rowid,
  }) {
    return CompanionRunsCompanion(
      positionMs: positionMs ?? this.positionMs,
      playbackRevision: playbackRevision ?? this.playbackRevision,
      guidanceMode: guidanceMode ?? this.guidanceMode,
      id: id ?? this.id,
      contentId: contentId ?? this.contentId,
      contentVersion: contentVersion ?? this.contentVersion,
      startedAtUtcMicros: startedAtUtcMicros ?? this.startedAtUtcMicros,
      startedLocalDate: startedLocalDate ?? this.startedLocalDate,
      stepCount: stepCount ?? this.stepCount,
      stepIndex: stepIndex ?? this.stepIndex,
      guideCompleted: guideCompleted ?? this.guideCompleted,
      awaitingOutcome: awaitingOutcome ?? this.awaitingOutcome,
      activeSlot: activeSlot ?? this.activeSlot,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (positionMs.present) {
      map['position_ms'] = Variable<int>(positionMs.value);
    }
    if (playbackRevision.present) {
      map['playback_revision'] = Variable<int>(playbackRevision.value);
    }
    if (guidanceMode.present) {
      map['guidance_mode'] = Variable<String>(guidanceMode.value);
    }
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (contentId.present) {
      map['content_id'] = Variable<String>(contentId.value);
    }
    if (contentVersion.present) {
      map['content_version'] = Variable<int>(contentVersion.value);
    }
    if (startedAtUtcMicros.present) {
      map['started_at_utc_micros'] = Variable<int>(startedAtUtcMicros.value);
    }
    if (startedLocalDate.present) {
      map['started_local_date'] = Variable<String>(startedLocalDate.value);
    }
    if (stepCount.present) {
      map['step_count'] = Variable<int>(stepCount.value);
    }
    if (stepIndex.present) {
      map['step_index'] = Variable<int>(stepIndex.value);
    }
    if (guideCompleted.present) {
      map['guide_completed'] = Variable<bool>(guideCompleted.value);
    }
    if (awaitingOutcome.present) {
      map['awaiting_outcome'] = Variable<bool>(awaitingOutcome.value);
    }
    if (activeSlot.present) {
      map['active_slot'] = Variable<int>(activeSlot.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CompanionRunsCompanion(')
          ..write('positionMs: $positionMs, ')
          ..write('playbackRevision: $playbackRevision, ')
          ..write('guidanceMode: $guidanceMode, ')
          ..write('id: $id, ')
          ..write('contentId: $contentId, ')
          ..write('contentVersion: $contentVersion, ')
          ..write('startedAtUtcMicros: $startedAtUtcMicros, ')
          ..write('startedLocalDate: $startedLocalDate, ')
          ..write('stepCount: $stepCount, ')
          ..write('stepIndex: $stepIndex, ')
          ..write('guideCompleted: $guideCompleted, ')
          ..write('awaitingOutcome: $awaitingOutcome, ')
          ..write('activeSlot: $activeSlot, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CompanionOutcomesTable extends CompanionOutcomes
    with TableInfo<$CompanionOutcomesTable, CompanionOutcomeRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CompanionOutcomesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _runIdMeta = const VerificationMeta('runId');
  @override
  late final GeneratedColumn<String> runId = GeneratedColumn<String>(
    'run_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES companion_runs (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _outcomeMeta = const VerificationMeta(
    'outcome',
  );
  @override
  late final GeneratedColumn<String> outcome = GeneratedColumn<String>(
    'outcome',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _confirmedAtUtcMicrosMeta =
      const VerificationMeta('confirmedAtUtcMicros');
  @override
  late final GeneratedColumn<int> confirmedAtUtcMicros = GeneratedColumn<int>(
    'confirmed_at_utc_micros',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _confirmedLocalDateMeta =
      const VerificationMeta('confirmedLocalDate');
  @override
  late final GeneratedColumn<String> confirmedLocalDate =
      GeneratedColumn<String>(
        'confirmed_local_date',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      );
  @override
  List<GeneratedColumn> get $columns => [
    runId,
    outcome,
    confirmedAtUtcMicros,
    confirmedLocalDate,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'companion_outcomes';
  @override
  VerificationContext validateIntegrity(
    Insertable<CompanionOutcomeRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('run_id')) {
      context.handle(
        _runIdMeta,
        runId.isAcceptableOrUnknown(data['run_id']!, _runIdMeta),
      );
    } else if (isInserting) {
      context.missing(_runIdMeta);
    }
    if (data.containsKey('outcome')) {
      context.handle(
        _outcomeMeta,
        outcome.isAcceptableOrUnknown(data['outcome']!, _outcomeMeta),
      );
    } else if (isInserting) {
      context.missing(_outcomeMeta);
    }
    if (data.containsKey('confirmed_at_utc_micros')) {
      context.handle(
        _confirmedAtUtcMicrosMeta,
        confirmedAtUtcMicros.isAcceptableOrUnknown(
          data['confirmed_at_utc_micros']!,
          _confirmedAtUtcMicrosMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_confirmedAtUtcMicrosMeta);
    }
    if (data.containsKey('confirmed_local_date')) {
      context.handle(
        _confirmedLocalDateMeta,
        confirmedLocalDate.isAcceptableOrUnknown(
          data['confirmed_local_date']!,
          _confirmedLocalDateMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_confirmedLocalDateMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {runId};
  @override
  CompanionOutcomeRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CompanionOutcomeRow(
      runId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}run_id'],
      )!,
      outcome: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}outcome'],
      )!,
      confirmedAtUtcMicros: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}confirmed_at_utc_micros'],
      )!,
      confirmedLocalDate: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}confirmed_local_date'],
      )!,
    );
  }

  @override
  $CompanionOutcomesTable createAlias(String alias) {
    return $CompanionOutcomesTable(attachedDatabase, alias);
  }
}

class CompanionOutcomeRow extends DataClass
    implements Insertable<CompanionOutcomeRow> {
  final String runId;
  final String outcome;
  final int confirmedAtUtcMicros;
  final String confirmedLocalDate;
  const CompanionOutcomeRow({
    required this.runId,
    required this.outcome,
    required this.confirmedAtUtcMicros,
    required this.confirmedLocalDate,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['run_id'] = Variable<String>(runId);
    map['outcome'] = Variable<String>(outcome);
    map['confirmed_at_utc_micros'] = Variable<int>(confirmedAtUtcMicros);
    map['confirmed_local_date'] = Variable<String>(confirmedLocalDate);
    return map;
  }

  CompanionOutcomesCompanion toCompanion(bool nullToAbsent) {
    return CompanionOutcomesCompanion(
      runId: Value(runId),
      outcome: Value(outcome),
      confirmedAtUtcMicros: Value(confirmedAtUtcMicros),
      confirmedLocalDate: Value(confirmedLocalDate),
    );
  }

  factory CompanionOutcomeRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CompanionOutcomeRow(
      runId: serializer.fromJson<String>(json['runId']),
      outcome: serializer.fromJson<String>(json['outcome']),
      confirmedAtUtcMicros: serializer.fromJson<int>(
        json['confirmedAtUtcMicros'],
      ),
      confirmedLocalDate: serializer.fromJson<String>(
        json['confirmedLocalDate'],
      ),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'runId': serializer.toJson<String>(runId),
      'outcome': serializer.toJson<String>(outcome),
      'confirmedAtUtcMicros': serializer.toJson<int>(confirmedAtUtcMicros),
      'confirmedLocalDate': serializer.toJson<String>(confirmedLocalDate),
    };
  }

  CompanionOutcomeRow copyWith({
    String? runId,
    String? outcome,
    int? confirmedAtUtcMicros,
    String? confirmedLocalDate,
  }) => CompanionOutcomeRow(
    runId: runId ?? this.runId,
    outcome: outcome ?? this.outcome,
    confirmedAtUtcMicros: confirmedAtUtcMicros ?? this.confirmedAtUtcMicros,
    confirmedLocalDate: confirmedLocalDate ?? this.confirmedLocalDate,
  );
  CompanionOutcomeRow copyWithCompanion(CompanionOutcomesCompanion data) {
    return CompanionOutcomeRow(
      runId: data.runId.present ? data.runId.value : this.runId,
      outcome: data.outcome.present ? data.outcome.value : this.outcome,
      confirmedAtUtcMicros: data.confirmedAtUtcMicros.present
          ? data.confirmedAtUtcMicros.value
          : this.confirmedAtUtcMicros,
      confirmedLocalDate: data.confirmedLocalDate.present
          ? data.confirmedLocalDate.value
          : this.confirmedLocalDate,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CompanionOutcomeRow(')
          ..write('runId: $runId, ')
          ..write('outcome: $outcome, ')
          ..write('confirmedAtUtcMicros: $confirmedAtUtcMicros, ')
          ..write('confirmedLocalDate: $confirmedLocalDate')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(runId, outcome, confirmedAtUtcMicros, confirmedLocalDate);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CompanionOutcomeRow &&
          other.runId == this.runId &&
          other.outcome == this.outcome &&
          other.confirmedAtUtcMicros == this.confirmedAtUtcMicros &&
          other.confirmedLocalDate == this.confirmedLocalDate);
}

class CompanionOutcomesCompanion extends UpdateCompanion<CompanionOutcomeRow> {
  final Value<String> runId;
  final Value<String> outcome;
  final Value<int> confirmedAtUtcMicros;
  final Value<String> confirmedLocalDate;
  final Value<int> rowid;
  const CompanionOutcomesCompanion({
    this.runId = const Value.absent(),
    this.outcome = const Value.absent(),
    this.confirmedAtUtcMicros = const Value.absent(),
    this.confirmedLocalDate = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CompanionOutcomesCompanion.insert({
    required String runId,
    required String outcome,
    required int confirmedAtUtcMicros,
    required String confirmedLocalDate,
    this.rowid = const Value.absent(),
  }) : runId = Value(runId),
       outcome = Value(outcome),
       confirmedAtUtcMicros = Value(confirmedAtUtcMicros),
       confirmedLocalDate = Value(confirmedLocalDate);
  static Insertable<CompanionOutcomeRow> custom({
    Expression<String>? runId,
    Expression<String>? outcome,
    Expression<int>? confirmedAtUtcMicros,
    Expression<String>? confirmedLocalDate,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (runId != null) 'run_id': runId,
      if (outcome != null) 'outcome': outcome,
      if (confirmedAtUtcMicros != null)
        'confirmed_at_utc_micros': confirmedAtUtcMicros,
      if (confirmedLocalDate != null)
        'confirmed_local_date': confirmedLocalDate,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CompanionOutcomesCompanion copyWith({
    Value<String>? runId,
    Value<String>? outcome,
    Value<int>? confirmedAtUtcMicros,
    Value<String>? confirmedLocalDate,
    Value<int>? rowid,
  }) {
    return CompanionOutcomesCompanion(
      runId: runId ?? this.runId,
      outcome: outcome ?? this.outcome,
      confirmedAtUtcMicros: confirmedAtUtcMicros ?? this.confirmedAtUtcMicros,
      confirmedLocalDate: confirmedLocalDate ?? this.confirmedLocalDate,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (runId.present) {
      map['run_id'] = Variable<String>(runId.value);
    }
    if (outcome.present) {
      map['outcome'] = Variable<String>(outcome.value);
    }
    if (confirmedAtUtcMicros.present) {
      map['confirmed_at_utc_micros'] = Variable<int>(
        confirmedAtUtcMicros.value,
      );
    }
    if (confirmedLocalDate.present) {
      map['confirmed_local_date'] = Variable<String>(confirmedLocalDate.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CompanionOutcomesCompanion(')
          ..write('runId: $runId, ')
          ..write('outcome: $outcome, ')
          ..write('confirmedAtUtcMicros: $confirmedAtUtcMicros, ')
          ..write('confirmedLocalDate: $confirmedLocalDate, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $PhotoDiariesTable extends PhotoDiaries
    with TableInfo<$PhotoDiariesTable, PhotoDiaryRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PhotoDiariesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
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
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  static const VerificationMeta _bodyMeta = const VerificationMeta('body');
  @override
  late final GeneratedColumn<String> body = GeneratedColumn<String>(
    'body',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _originalMeta = const VerificationMeta(
    'original',
  );
  @override
  late final GeneratedColumn<Uint8List> original = GeneratedColumn<Uint8List>(
    'original',
    aliasedName,
    false,
    type: DriftSqlType.blob,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _artworkMeta = const VerificationMeta(
    'artwork',
  );
  @override
  late final GeneratedColumn<Uint8List> artwork = GeneratedColumn<Uint8List>(
    'artwork',
    aliasedName,
    true,
    type: DriftSqlType.blob,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _jobIdMeta = const VerificationMeta('jobId');
  @override
  late final GeneratedColumn<String> jobId = GeneratedColumn<String>(
    'job_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('local'),
  );
  static const VerificationMeta _styleVersionMeta = const VerificationMeta(
    'styleVersion',
  );
  @override
  late final GeneratedColumn<String> styleVersion = GeneratedColumn<String>(
    'style_version',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('dopa-gouache-v1'),
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
  @override
  List<GeneratedColumn> get $columns => [
    id,
    localDate,
    body,
    original,
    artwork,
    jobId,
    status,
    styleVersion,
    createdAtUtcMicros,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'photo_diaries';
  @override
  VerificationContext validateIntegrity(
    Insertable<PhotoDiaryRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('local_date')) {
      context.handle(
        _localDateMeta,
        localDate.isAcceptableOrUnknown(data['local_date']!, _localDateMeta),
      );
    } else if (isInserting) {
      context.missing(_localDateMeta);
    }
    if (data.containsKey('body')) {
      context.handle(
        _bodyMeta,
        body.isAcceptableOrUnknown(data['body']!, _bodyMeta),
      );
    }
    if (data.containsKey('original')) {
      context.handle(
        _originalMeta,
        original.isAcceptableOrUnknown(data['original']!, _originalMeta),
      );
    } else if (isInserting) {
      context.missing(_originalMeta);
    }
    if (data.containsKey('artwork')) {
      context.handle(
        _artworkMeta,
        artwork.isAcceptableOrUnknown(data['artwork']!, _artworkMeta),
      );
    }
    if (data.containsKey('job_id')) {
      context.handle(
        _jobIdMeta,
        jobId.isAcceptableOrUnknown(data['job_id']!, _jobIdMeta),
      );
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    }
    if (data.containsKey('style_version')) {
      context.handle(
        _styleVersionMeta,
        styleVersion.isAcceptableOrUnknown(
          data['style_version']!,
          _styleVersionMeta,
        ),
      );
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
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  PhotoDiaryRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PhotoDiaryRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      localDate: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}local_date'],
      )!,
      body: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}body'],
      )!,
      original: attachedDatabase.typeMapping.read(
        DriftSqlType.blob,
        data['${effectivePrefix}original'],
      )!,
      artwork: attachedDatabase.typeMapping.read(
        DriftSqlType.blob,
        data['${effectivePrefix}artwork'],
      ),
      jobId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}job_id'],
      ),
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      styleVersion: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}style_version'],
      )!,
      createdAtUtcMicros: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at_utc_micros'],
      )!,
    );
  }

  @override
  $PhotoDiariesTable createAlias(String alias) {
    return $PhotoDiariesTable(attachedDatabase, alias);
  }
}

class PhotoDiaryRow extends DataClass implements Insertable<PhotoDiaryRow> {
  final String id;
  final String localDate;
  final String body;
  final Uint8List original;
  final Uint8List? artwork;
  final String? jobId;
  final String status;
  final String styleVersion;
  final int createdAtUtcMicros;
  const PhotoDiaryRow({
    required this.id,
    required this.localDate,
    required this.body,
    required this.original,
    this.artwork,
    this.jobId,
    required this.status,
    required this.styleVersion,
    required this.createdAtUtcMicros,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['local_date'] = Variable<String>(localDate);
    map['body'] = Variable<String>(body);
    map['original'] = Variable<Uint8List>(original);
    if (!nullToAbsent || artwork != null) {
      map['artwork'] = Variable<Uint8List>(artwork);
    }
    if (!nullToAbsent || jobId != null) {
      map['job_id'] = Variable<String>(jobId);
    }
    map['status'] = Variable<String>(status);
    map['style_version'] = Variable<String>(styleVersion);
    map['created_at_utc_micros'] = Variable<int>(createdAtUtcMicros);
    return map;
  }

  PhotoDiariesCompanion toCompanion(bool nullToAbsent) {
    return PhotoDiariesCompanion(
      id: Value(id),
      localDate: Value(localDate),
      body: Value(body),
      original: Value(original),
      artwork: artwork == null && nullToAbsent
          ? const Value.absent()
          : Value(artwork),
      jobId: jobId == null && nullToAbsent
          ? const Value.absent()
          : Value(jobId),
      status: Value(status),
      styleVersion: Value(styleVersion),
      createdAtUtcMicros: Value(createdAtUtcMicros),
    );
  }

  factory PhotoDiaryRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PhotoDiaryRow(
      id: serializer.fromJson<String>(json['id']),
      localDate: serializer.fromJson<String>(json['localDate']),
      body: serializer.fromJson<String>(json['body']),
      original: serializer.fromJson<Uint8List>(json['original']),
      artwork: serializer.fromJson<Uint8List?>(json['artwork']),
      jobId: serializer.fromJson<String?>(json['jobId']),
      status: serializer.fromJson<String>(json['status']),
      styleVersion: serializer.fromJson<String>(json['styleVersion']),
      createdAtUtcMicros: serializer.fromJson<int>(json['createdAtUtcMicros']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'localDate': serializer.toJson<String>(localDate),
      'body': serializer.toJson<String>(body),
      'original': serializer.toJson<Uint8List>(original),
      'artwork': serializer.toJson<Uint8List?>(artwork),
      'jobId': serializer.toJson<String?>(jobId),
      'status': serializer.toJson<String>(status),
      'styleVersion': serializer.toJson<String>(styleVersion),
      'createdAtUtcMicros': serializer.toJson<int>(createdAtUtcMicros),
    };
  }

  PhotoDiaryRow copyWith({
    String? id,
    String? localDate,
    String? body,
    Uint8List? original,
    Value<Uint8List?> artwork = const Value.absent(),
    Value<String?> jobId = const Value.absent(),
    String? status,
    String? styleVersion,
    int? createdAtUtcMicros,
  }) => PhotoDiaryRow(
    id: id ?? this.id,
    localDate: localDate ?? this.localDate,
    body: body ?? this.body,
    original: original ?? this.original,
    artwork: artwork.present ? artwork.value : this.artwork,
    jobId: jobId.present ? jobId.value : this.jobId,
    status: status ?? this.status,
    styleVersion: styleVersion ?? this.styleVersion,
    createdAtUtcMicros: createdAtUtcMicros ?? this.createdAtUtcMicros,
  );
  PhotoDiaryRow copyWithCompanion(PhotoDiariesCompanion data) {
    return PhotoDiaryRow(
      id: data.id.present ? data.id.value : this.id,
      localDate: data.localDate.present ? data.localDate.value : this.localDate,
      body: data.body.present ? data.body.value : this.body,
      original: data.original.present ? data.original.value : this.original,
      artwork: data.artwork.present ? data.artwork.value : this.artwork,
      jobId: data.jobId.present ? data.jobId.value : this.jobId,
      status: data.status.present ? data.status.value : this.status,
      styleVersion: data.styleVersion.present
          ? data.styleVersion.value
          : this.styleVersion,
      createdAtUtcMicros: data.createdAtUtcMicros.present
          ? data.createdAtUtcMicros.value
          : this.createdAtUtcMicros,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PhotoDiaryRow(')
          ..write('id: $id, ')
          ..write('localDate: $localDate, ')
          ..write('body: $body, ')
          ..write('original: $original, ')
          ..write('artwork: $artwork, ')
          ..write('jobId: $jobId, ')
          ..write('status: $status, ')
          ..write('styleVersion: $styleVersion, ')
          ..write('createdAtUtcMicros: $createdAtUtcMicros')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    localDate,
    body,
    $driftBlobEquality.hash(original),
    $driftBlobEquality.hash(artwork),
    jobId,
    status,
    styleVersion,
    createdAtUtcMicros,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PhotoDiaryRow &&
          other.id == this.id &&
          other.localDate == this.localDate &&
          other.body == this.body &&
          $driftBlobEquality.equals(other.original, this.original) &&
          $driftBlobEquality.equals(other.artwork, this.artwork) &&
          other.jobId == this.jobId &&
          other.status == this.status &&
          other.styleVersion == this.styleVersion &&
          other.createdAtUtcMicros == this.createdAtUtcMicros);
}

class PhotoDiariesCompanion extends UpdateCompanion<PhotoDiaryRow> {
  final Value<String> id;
  final Value<String> localDate;
  final Value<String> body;
  final Value<Uint8List> original;
  final Value<Uint8List?> artwork;
  final Value<String?> jobId;
  final Value<String> status;
  final Value<String> styleVersion;
  final Value<int> createdAtUtcMicros;
  final Value<int> rowid;
  const PhotoDiariesCompanion({
    this.id = const Value.absent(),
    this.localDate = const Value.absent(),
    this.body = const Value.absent(),
    this.original = const Value.absent(),
    this.artwork = const Value.absent(),
    this.jobId = const Value.absent(),
    this.status = const Value.absent(),
    this.styleVersion = const Value.absent(),
    this.createdAtUtcMicros = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PhotoDiariesCompanion.insert({
    required String id,
    required String localDate,
    this.body = const Value.absent(),
    required Uint8List original,
    this.artwork = const Value.absent(),
    this.jobId = const Value.absent(),
    this.status = const Value.absent(),
    this.styleVersion = const Value.absent(),
    required int createdAtUtcMicros,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       localDate = Value(localDate),
       original = Value(original),
       createdAtUtcMicros = Value(createdAtUtcMicros);
  static Insertable<PhotoDiaryRow> custom({
    Expression<String>? id,
    Expression<String>? localDate,
    Expression<String>? body,
    Expression<Uint8List>? original,
    Expression<Uint8List>? artwork,
    Expression<String>? jobId,
    Expression<String>? status,
    Expression<String>? styleVersion,
    Expression<int>? createdAtUtcMicros,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (localDate != null) 'local_date': localDate,
      if (body != null) 'body': body,
      if (original != null) 'original': original,
      if (artwork != null) 'artwork': artwork,
      if (jobId != null) 'job_id': jobId,
      if (status != null) 'status': status,
      if (styleVersion != null) 'style_version': styleVersion,
      if (createdAtUtcMicros != null)
        'created_at_utc_micros': createdAtUtcMicros,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PhotoDiariesCompanion copyWith({
    Value<String>? id,
    Value<String>? localDate,
    Value<String>? body,
    Value<Uint8List>? original,
    Value<Uint8List?>? artwork,
    Value<String?>? jobId,
    Value<String>? status,
    Value<String>? styleVersion,
    Value<int>? createdAtUtcMicros,
    Value<int>? rowid,
  }) {
    return PhotoDiariesCompanion(
      id: id ?? this.id,
      localDate: localDate ?? this.localDate,
      body: body ?? this.body,
      original: original ?? this.original,
      artwork: artwork ?? this.artwork,
      jobId: jobId ?? this.jobId,
      status: status ?? this.status,
      styleVersion: styleVersion ?? this.styleVersion,
      createdAtUtcMicros: createdAtUtcMicros ?? this.createdAtUtcMicros,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (localDate.present) {
      map['local_date'] = Variable<String>(localDate.value);
    }
    if (body.present) {
      map['body'] = Variable<String>(body.value);
    }
    if (original.present) {
      map['original'] = Variable<Uint8List>(original.value);
    }
    if (artwork.present) {
      map['artwork'] = Variable<Uint8List>(artwork.value);
    }
    if (jobId.present) {
      map['job_id'] = Variable<String>(jobId.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (styleVersion.present) {
      map['style_version'] = Variable<String>(styleVersion.value);
    }
    if (createdAtUtcMicros.present) {
      map['created_at_utc_micros'] = Variable<int>(createdAtUtcMicros.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PhotoDiariesCompanion(')
          ..write('id: $id, ')
          ..write('localDate: $localDate, ')
          ..write('body: $body, ')
          ..write('original: $original, ')
          ..write('artwork: $artwork, ')
          ..write('jobId: $jobId, ')
          ..write('status: $status, ')
          ..write('styleVersion: $styleVersion, ')
          ..write('createdAtUtcMicros: $createdAtUtcMicros, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $PhotoDiaryRemoteStatesTable extends PhotoDiaryRemoteStates
    with TableInfo<$PhotoDiaryRemoteStatesTable, PhotoDiaryRemoteState> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PhotoDiaryRemoteStatesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _singletonMeta = const VerificationMeta(
    'singleton',
  );
  @override
  late final GeneratedColumn<int> singleton = GeneratedColumn<int>(
    'singleton',
    aliasedName,
    false,
    check: () => singleton.equals(1),
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [singleton];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'photo_diary_remote_states';
  @override
  VerificationContext validateIntegrity(
    Insertable<PhotoDiaryRemoteState> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('singleton')) {
      context.handle(
        _singletonMeta,
        singleton.isAcceptableOrUnknown(data['singleton']!, _singletonMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {singleton};
  @override
  PhotoDiaryRemoteState map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PhotoDiaryRemoteState(
      singleton: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}singleton'],
      )!,
    );
  }

  @override
  $PhotoDiaryRemoteStatesTable createAlias(String alias) {
    return $PhotoDiaryRemoteStatesTable(attachedDatabase, alias);
  }
}

class PhotoDiaryRemoteState extends DataClass
    implements Insertable<PhotoDiaryRemoteState> {
  final int singleton;
  const PhotoDiaryRemoteState({required this.singleton});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['singleton'] = Variable<int>(singleton);
    return map;
  }

  PhotoDiaryRemoteStatesCompanion toCompanion(bool nullToAbsent) {
    return PhotoDiaryRemoteStatesCompanion(singleton: Value(singleton));
  }

  factory PhotoDiaryRemoteState.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PhotoDiaryRemoteState(
      singleton: serializer.fromJson<int>(json['singleton']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{'singleton': serializer.toJson<int>(singleton)};
  }

  PhotoDiaryRemoteState copyWith({int? singleton}) =>
      PhotoDiaryRemoteState(singleton: singleton ?? this.singleton);
  PhotoDiaryRemoteState copyWithCompanion(
    PhotoDiaryRemoteStatesCompanion data,
  ) {
    return PhotoDiaryRemoteState(
      singleton: data.singleton.present ? data.singleton.value : this.singleton,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PhotoDiaryRemoteState(')
          ..write('singleton: $singleton')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => singleton.hashCode;
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PhotoDiaryRemoteState && other.singleton == this.singleton);
}

class PhotoDiaryRemoteStatesCompanion
    extends UpdateCompanion<PhotoDiaryRemoteState> {
  final Value<int> singleton;
  const PhotoDiaryRemoteStatesCompanion({
    this.singleton = const Value.absent(),
  });
  PhotoDiaryRemoteStatesCompanion.insert({
    this.singleton = const Value.absent(),
  });
  static Insertable<PhotoDiaryRemoteState> custom({
    Expression<int>? singleton,
  }) {
    return RawValuesInsertable({if (singleton != null) 'singleton': singleton});
  }

  PhotoDiaryRemoteStatesCompanion copyWith({Value<int>? singleton}) {
    return PhotoDiaryRemoteStatesCompanion(
      singleton: singleton ?? this.singleton,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (singleton.present) {
      map['singleton'] = Variable<int>(singleton.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PhotoDiaryRemoteStatesCompanion(')
          ..write('singleton: $singleton')
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
  late final $CompanionRunsTable companionRuns = $CompanionRunsTable(this);
  late final $CompanionOutcomesTable companionOutcomes =
      $CompanionOutcomesTable(this);
  late final $PhotoDiariesTable photoDiaries = $PhotoDiariesTable(this);
  late final $PhotoDiaryRemoteStatesTable photoDiaryRemoteStates =
      $PhotoDiaryRemoteStatesTable(this);
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
    companionRuns,
    companionOutcomes,
    photoDiaries,
    photoDiaryRemoteStates,
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
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'companion_runs',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('companion_outcomes', kind: UpdateKind.delete)],
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
          (
            FocusSessionRow,
            BaseReferences<
              _$DopaDatabase,
              $FocusSessionsTable,
              FocusSessionRow
            >,
          ),
          FocusSessionRow,
          PrefetchHooks Function()
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
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
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
      (
        FocusSessionRow,
        BaseReferences<_$DopaDatabase, $FocusSessionsTable, FocusSessionRow>,
      ),
      FocusSessionRow,
      PrefetchHooks Function()
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
      Value<String> sourceKind,
      required String creditedLocalDate,
      required int creditedAtUtcMicros,
      required int ruleVersion,
      Value<int> rowid,
    });
typedef $$TreeGrowthCreditsTableUpdateCompanionBuilder =
    TreeGrowthCreditsCompanion Function({
      Value<String> treeId,
      Value<String> sourceSessionId,
      Value<String> sourceKind,
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
  ColumnFilters<String> get sourceSessionId => $composableBuilder(
    column: $table.sourceSessionId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sourceKind => $composableBuilder(
    column: $table.sourceKind,
    builder: (column) => ColumnFilters(column),
  );

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
  ColumnOrderings<String> get sourceSessionId => $composableBuilder(
    column: $table.sourceSessionId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sourceKind => $composableBuilder(
    column: $table.sourceKind,
    builder: (column) => ColumnOrderings(column),
  );

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
  GeneratedColumn<String> get sourceSessionId => $composableBuilder(
    column: $table.sourceSessionId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get sourceKind => $composableBuilder(
    column: $table.sourceKind,
    builder: (column) => column,
  );

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
          PrefetchHooks Function({bool treeId})
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
                Value<String> sourceKind = const Value.absent(),
                Value<String> creditedLocalDate = const Value.absent(),
                Value<int> creditedAtUtcMicros = const Value.absent(),
                Value<int> ruleVersion = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TreeGrowthCreditsCompanion(
                treeId: treeId,
                sourceSessionId: sourceSessionId,
                sourceKind: sourceKind,
                creditedLocalDate: creditedLocalDate,
                creditedAtUtcMicros: creditedAtUtcMicros,
                ruleVersion: ruleVersion,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String treeId,
                required String sourceSessionId,
                Value<String> sourceKind = const Value.absent(),
                required String creditedLocalDate,
                required int creditedAtUtcMicros,
                required int ruleVersion,
                Value<int> rowid = const Value.absent(),
              }) => TreeGrowthCreditsCompanion.insert(
                treeId: treeId,
                sourceSessionId: sourceSessionId,
                sourceKind: sourceKind,
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
          prefetchHooksCallback: ({treeId = false}) {
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
      PrefetchHooks Function({bool treeId})
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
typedef $$CompanionRunsTableCreateCompanionBuilder =
    CompanionRunsCompanion Function({
      Value<int> positionMs,
      Value<int> playbackRevision,
      Value<String> guidanceMode,
      required String id,
      required String contentId,
      required int contentVersion,
      required int startedAtUtcMicros,
      required String startedLocalDate,
      required int stepCount,
      required int stepIndex,
      required bool guideCompleted,
      required bool awaitingOutcome,
      Value<int?> activeSlot,
      Value<int> rowid,
    });
typedef $$CompanionRunsTableUpdateCompanionBuilder =
    CompanionRunsCompanion Function({
      Value<int> positionMs,
      Value<int> playbackRevision,
      Value<String> guidanceMode,
      Value<String> id,
      Value<String> contentId,
      Value<int> contentVersion,
      Value<int> startedAtUtcMicros,
      Value<String> startedLocalDate,
      Value<int> stepCount,
      Value<int> stepIndex,
      Value<bool> guideCompleted,
      Value<bool> awaitingOutcome,
      Value<int?> activeSlot,
      Value<int> rowid,
    });

final class $$CompanionRunsTableReferences
    extends
        BaseReferences<_$DopaDatabase, $CompanionRunsTable, CompanionRunRow> {
  $$CompanionRunsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static MultiTypedResultKey<$CompanionOutcomesTable, List<CompanionOutcomeRow>>
  _companionOutcomesRefsTable(_$DopaDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.companionOutcomes,
        aliasName: 'companion_runs__id__companion_outcomes__run_id',
      );

  $$CompanionOutcomesTableProcessedTableManager get companionOutcomesRefs {
    final manager = $$CompanionOutcomesTableTableManager(
      $_db,
      $_db.companionOutcomes,
    ).filter((f) => f.runId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _companionOutcomesRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$CompanionRunsTableFilterComposer
    extends Composer<_$DopaDatabase, $CompanionRunsTable> {
  $$CompanionRunsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get positionMs => $composableBuilder(
    column: $table.positionMs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get playbackRevision => $composableBuilder(
    column: $table.playbackRevision,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get guidanceMode => $composableBuilder(
    column: $table.guidanceMode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get contentId => $composableBuilder(
    column: $table.contentId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get contentVersion => $composableBuilder(
    column: $table.contentVersion,
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

  ColumnFilters<int> get stepCount => $composableBuilder(
    column: $table.stepCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get stepIndex => $composableBuilder(
    column: $table.stepIndex,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get guideCompleted => $composableBuilder(
    column: $table.guideCompleted,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get awaitingOutcome => $composableBuilder(
    column: $table.awaitingOutcome,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get activeSlot => $composableBuilder(
    column: $table.activeSlot,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> companionOutcomesRefs(
    Expression<bool> Function($$CompanionOutcomesTableFilterComposer f) f,
  ) {
    final $$CompanionOutcomesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.companionOutcomes,
      getReferencedColumn: (t) => t.runId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CompanionOutcomesTableFilterComposer(
            $db: $db,
            $table: $db.companionOutcomes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$CompanionRunsTableOrderingComposer
    extends Composer<_$DopaDatabase, $CompanionRunsTable> {
  $$CompanionRunsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get positionMs => $composableBuilder(
    column: $table.positionMs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get playbackRevision => $composableBuilder(
    column: $table.playbackRevision,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get guidanceMode => $composableBuilder(
    column: $table.guidanceMode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get contentId => $composableBuilder(
    column: $table.contentId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get contentVersion => $composableBuilder(
    column: $table.contentVersion,
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

  ColumnOrderings<int> get stepCount => $composableBuilder(
    column: $table.stepCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get stepIndex => $composableBuilder(
    column: $table.stepIndex,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get guideCompleted => $composableBuilder(
    column: $table.guideCompleted,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get awaitingOutcome => $composableBuilder(
    column: $table.awaitingOutcome,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get activeSlot => $composableBuilder(
    column: $table.activeSlot,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CompanionRunsTableAnnotationComposer
    extends Composer<_$DopaDatabase, $CompanionRunsTable> {
  $$CompanionRunsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get positionMs => $composableBuilder(
    column: $table.positionMs,
    builder: (column) => column,
  );

  GeneratedColumn<int> get playbackRevision => $composableBuilder(
    column: $table.playbackRevision,
    builder: (column) => column,
  );

  GeneratedColumn<String> get guidanceMode => $composableBuilder(
    column: $table.guidanceMode,
    builder: (column) => column,
  );

  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get contentId =>
      $composableBuilder(column: $table.contentId, builder: (column) => column);

  GeneratedColumn<int> get contentVersion => $composableBuilder(
    column: $table.contentVersion,
    builder: (column) => column,
  );

  GeneratedColumn<int> get startedAtUtcMicros => $composableBuilder(
    column: $table.startedAtUtcMicros,
    builder: (column) => column,
  );

  GeneratedColumn<String> get startedLocalDate => $composableBuilder(
    column: $table.startedLocalDate,
    builder: (column) => column,
  );

  GeneratedColumn<int> get stepCount =>
      $composableBuilder(column: $table.stepCount, builder: (column) => column);

  GeneratedColumn<int> get stepIndex =>
      $composableBuilder(column: $table.stepIndex, builder: (column) => column);

  GeneratedColumn<bool> get guideCompleted => $composableBuilder(
    column: $table.guideCompleted,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get awaitingOutcome => $composableBuilder(
    column: $table.awaitingOutcome,
    builder: (column) => column,
  );

  GeneratedColumn<int> get activeSlot => $composableBuilder(
    column: $table.activeSlot,
    builder: (column) => column,
  );

  Expression<T> companionOutcomesRefs<T extends Object>(
    Expression<T> Function($$CompanionOutcomesTableAnnotationComposer a) f,
  ) {
    final $$CompanionOutcomesTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.companionOutcomes,
          getReferencedColumn: (t) => t.runId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$CompanionOutcomesTableAnnotationComposer(
                $db: $db,
                $table: $db.companionOutcomes,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$CompanionRunsTableTableManager
    extends
        RootTableManager<
          _$DopaDatabase,
          $CompanionRunsTable,
          CompanionRunRow,
          $$CompanionRunsTableFilterComposer,
          $$CompanionRunsTableOrderingComposer,
          $$CompanionRunsTableAnnotationComposer,
          $$CompanionRunsTableCreateCompanionBuilder,
          $$CompanionRunsTableUpdateCompanionBuilder,
          (CompanionRunRow, $$CompanionRunsTableReferences),
          CompanionRunRow,
          PrefetchHooks Function({bool companionOutcomesRefs})
        > {
  $$CompanionRunsTableTableManager(_$DopaDatabase db, $CompanionRunsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CompanionRunsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CompanionRunsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CompanionRunsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> positionMs = const Value.absent(),
                Value<int> playbackRevision = const Value.absent(),
                Value<String> guidanceMode = const Value.absent(),
                Value<String> id = const Value.absent(),
                Value<String> contentId = const Value.absent(),
                Value<int> contentVersion = const Value.absent(),
                Value<int> startedAtUtcMicros = const Value.absent(),
                Value<String> startedLocalDate = const Value.absent(),
                Value<int> stepCount = const Value.absent(),
                Value<int> stepIndex = const Value.absent(),
                Value<bool> guideCompleted = const Value.absent(),
                Value<bool> awaitingOutcome = const Value.absent(),
                Value<int?> activeSlot = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CompanionRunsCompanion(
                positionMs: positionMs,
                playbackRevision: playbackRevision,
                guidanceMode: guidanceMode,
                id: id,
                contentId: contentId,
                contentVersion: contentVersion,
                startedAtUtcMicros: startedAtUtcMicros,
                startedLocalDate: startedLocalDate,
                stepCount: stepCount,
                stepIndex: stepIndex,
                guideCompleted: guideCompleted,
                awaitingOutcome: awaitingOutcome,
                activeSlot: activeSlot,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                Value<int> positionMs = const Value.absent(),
                Value<int> playbackRevision = const Value.absent(),
                Value<String> guidanceMode = const Value.absent(),
                required String id,
                required String contentId,
                required int contentVersion,
                required int startedAtUtcMicros,
                required String startedLocalDate,
                required int stepCount,
                required int stepIndex,
                required bool guideCompleted,
                required bool awaitingOutcome,
                Value<int?> activeSlot = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CompanionRunsCompanion.insert(
                positionMs: positionMs,
                playbackRevision: playbackRevision,
                guidanceMode: guidanceMode,
                id: id,
                contentId: contentId,
                contentVersion: contentVersion,
                startedAtUtcMicros: startedAtUtcMicros,
                startedLocalDate: startedLocalDate,
                stepCount: stepCount,
                stepIndex: stepIndex,
                guideCompleted: guideCompleted,
                awaitingOutcome: awaitingOutcome,
                activeSlot: activeSlot,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$CompanionRunsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({companionOutcomesRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (companionOutcomesRefs) db.companionOutcomes,
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (companionOutcomesRefs)
                    await $_getPrefetchedData<
                      CompanionRunRow,
                      $CompanionRunsTable,
                      CompanionOutcomeRow
                    >(
                      currentTable: table,
                      referencedTable: $$CompanionRunsTableReferences
                          ._companionOutcomesRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$CompanionRunsTableReferences(
                            db,
                            table,
                            p0,
                          ).companionOutcomesRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.runId == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$CompanionRunsTableProcessedTableManager =
    ProcessedTableManager<
      _$DopaDatabase,
      $CompanionRunsTable,
      CompanionRunRow,
      $$CompanionRunsTableFilterComposer,
      $$CompanionRunsTableOrderingComposer,
      $$CompanionRunsTableAnnotationComposer,
      $$CompanionRunsTableCreateCompanionBuilder,
      $$CompanionRunsTableUpdateCompanionBuilder,
      (CompanionRunRow, $$CompanionRunsTableReferences),
      CompanionRunRow,
      PrefetchHooks Function({bool companionOutcomesRefs})
    >;
typedef $$CompanionOutcomesTableCreateCompanionBuilder =
    CompanionOutcomesCompanion Function({
      required String runId,
      required String outcome,
      required int confirmedAtUtcMicros,
      required String confirmedLocalDate,
      Value<int> rowid,
    });
typedef $$CompanionOutcomesTableUpdateCompanionBuilder =
    CompanionOutcomesCompanion Function({
      Value<String> runId,
      Value<String> outcome,
      Value<int> confirmedAtUtcMicros,
      Value<String> confirmedLocalDate,
      Value<int> rowid,
    });

final class $$CompanionOutcomesTableReferences
    extends
        BaseReferences<
          _$DopaDatabase,
          $CompanionOutcomesTable,
          CompanionOutcomeRow
        > {
  $$CompanionOutcomesTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $CompanionRunsTable _runIdTable(_$DopaDatabase db) => db.companionRuns
      .createAlias('companion_outcomes__run_id__companion_runs__id');

  $$CompanionRunsTableProcessedTableManager get runId {
    final $_column = $_itemColumn<String>('run_id')!;

    final manager = $$CompanionRunsTableTableManager(
      $_db,
      $_db.companionRuns,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_runIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$CompanionOutcomesTableFilterComposer
    extends Composer<_$DopaDatabase, $CompanionOutcomesTable> {
  $$CompanionOutcomesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get outcome => $composableBuilder(
    column: $table.outcome,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get confirmedAtUtcMicros => $composableBuilder(
    column: $table.confirmedAtUtcMicros,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get confirmedLocalDate => $composableBuilder(
    column: $table.confirmedLocalDate,
    builder: (column) => ColumnFilters(column),
  );

  $$CompanionRunsTableFilterComposer get runId {
    final $$CompanionRunsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.runId,
      referencedTable: $db.companionRuns,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CompanionRunsTableFilterComposer(
            $db: $db,
            $table: $db.companionRuns,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$CompanionOutcomesTableOrderingComposer
    extends Composer<_$DopaDatabase, $CompanionOutcomesTable> {
  $$CompanionOutcomesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get outcome => $composableBuilder(
    column: $table.outcome,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get confirmedAtUtcMicros => $composableBuilder(
    column: $table.confirmedAtUtcMicros,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get confirmedLocalDate => $composableBuilder(
    column: $table.confirmedLocalDate,
    builder: (column) => ColumnOrderings(column),
  );

  $$CompanionRunsTableOrderingComposer get runId {
    final $$CompanionRunsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.runId,
      referencedTable: $db.companionRuns,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CompanionRunsTableOrderingComposer(
            $db: $db,
            $table: $db.companionRuns,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$CompanionOutcomesTableAnnotationComposer
    extends Composer<_$DopaDatabase, $CompanionOutcomesTable> {
  $$CompanionOutcomesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get outcome =>
      $composableBuilder(column: $table.outcome, builder: (column) => column);

  GeneratedColumn<int> get confirmedAtUtcMicros => $composableBuilder(
    column: $table.confirmedAtUtcMicros,
    builder: (column) => column,
  );

  GeneratedColumn<String> get confirmedLocalDate => $composableBuilder(
    column: $table.confirmedLocalDate,
    builder: (column) => column,
  );

  $$CompanionRunsTableAnnotationComposer get runId {
    final $$CompanionRunsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.runId,
      referencedTable: $db.companionRuns,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CompanionRunsTableAnnotationComposer(
            $db: $db,
            $table: $db.companionRuns,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$CompanionOutcomesTableTableManager
    extends
        RootTableManager<
          _$DopaDatabase,
          $CompanionOutcomesTable,
          CompanionOutcomeRow,
          $$CompanionOutcomesTableFilterComposer,
          $$CompanionOutcomesTableOrderingComposer,
          $$CompanionOutcomesTableAnnotationComposer,
          $$CompanionOutcomesTableCreateCompanionBuilder,
          $$CompanionOutcomesTableUpdateCompanionBuilder,
          (CompanionOutcomeRow, $$CompanionOutcomesTableReferences),
          CompanionOutcomeRow,
          PrefetchHooks Function({bool runId})
        > {
  $$CompanionOutcomesTableTableManager(
    _$DopaDatabase db,
    $CompanionOutcomesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CompanionOutcomesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CompanionOutcomesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CompanionOutcomesTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> runId = const Value.absent(),
                Value<String> outcome = const Value.absent(),
                Value<int> confirmedAtUtcMicros = const Value.absent(),
                Value<String> confirmedLocalDate = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CompanionOutcomesCompanion(
                runId: runId,
                outcome: outcome,
                confirmedAtUtcMicros: confirmedAtUtcMicros,
                confirmedLocalDate: confirmedLocalDate,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String runId,
                required String outcome,
                required int confirmedAtUtcMicros,
                required String confirmedLocalDate,
                Value<int> rowid = const Value.absent(),
              }) => CompanionOutcomesCompanion.insert(
                runId: runId,
                outcome: outcome,
                confirmedAtUtcMicros: confirmedAtUtcMicros,
                confirmedLocalDate: confirmedLocalDate,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$CompanionOutcomesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({runId = false}) {
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
                    if (runId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.runId,
                        referencedTable: $$CompanionOutcomesTableReferences
                            ._runIdTable(db),
                        referencedColumn: $$CompanionOutcomesTableReferences
                            ._runIdTable(db)
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

typedef $$CompanionOutcomesTableProcessedTableManager =
    ProcessedTableManager<
      _$DopaDatabase,
      $CompanionOutcomesTable,
      CompanionOutcomeRow,
      $$CompanionOutcomesTableFilterComposer,
      $$CompanionOutcomesTableOrderingComposer,
      $$CompanionOutcomesTableAnnotationComposer,
      $$CompanionOutcomesTableCreateCompanionBuilder,
      $$CompanionOutcomesTableUpdateCompanionBuilder,
      (CompanionOutcomeRow, $$CompanionOutcomesTableReferences),
      CompanionOutcomeRow,
      PrefetchHooks Function({bool runId})
    >;
typedef $$PhotoDiariesTableCreateCompanionBuilder =
    PhotoDiariesCompanion Function({
      required String id,
      required String localDate,
      Value<String> body,
      required Uint8List original,
      Value<Uint8List?> artwork,
      Value<String?> jobId,
      Value<String> status,
      Value<String> styleVersion,
      required int createdAtUtcMicros,
      Value<int> rowid,
    });
typedef $$PhotoDiariesTableUpdateCompanionBuilder =
    PhotoDiariesCompanion Function({
      Value<String> id,
      Value<String> localDate,
      Value<String> body,
      Value<Uint8List> original,
      Value<Uint8List?> artwork,
      Value<String?> jobId,
      Value<String> status,
      Value<String> styleVersion,
      Value<int> createdAtUtcMicros,
      Value<int> rowid,
    });

class $$PhotoDiariesTableFilterComposer
    extends Composer<_$DopaDatabase, $PhotoDiariesTable> {
  $$PhotoDiariesTableFilterComposer({
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

  ColumnFilters<String> get localDate => $composableBuilder(
    column: $table.localDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get body => $composableBuilder(
    column: $table.body,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<Uint8List> get original => $composableBuilder(
    column: $table.original,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<Uint8List> get artwork => $composableBuilder(
    column: $table.artwork,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get jobId => $composableBuilder(
    column: $table.jobId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get styleVersion => $composableBuilder(
    column: $table.styleVersion,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAtUtcMicros => $composableBuilder(
    column: $table.createdAtUtcMicros,
    builder: (column) => ColumnFilters(column),
  );
}

class $$PhotoDiariesTableOrderingComposer
    extends Composer<_$DopaDatabase, $PhotoDiariesTable> {
  $$PhotoDiariesTableOrderingComposer({
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

  ColumnOrderings<String> get localDate => $composableBuilder(
    column: $table.localDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get body => $composableBuilder(
    column: $table.body,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<Uint8List> get original => $composableBuilder(
    column: $table.original,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<Uint8List> get artwork => $composableBuilder(
    column: $table.artwork,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get jobId => $composableBuilder(
    column: $table.jobId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get styleVersion => $composableBuilder(
    column: $table.styleVersion,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAtUtcMicros => $composableBuilder(
    column: $table.createdAtUtcMicros,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$PhotoDiariesTableAnnotationComposer
    extends Composer<_$DopaDatabase, $PhotoDiariesTable> {
  $$PhotoDiariesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get localDate =>
      $composableBuilder(column: $table.localDate, builder: (column) => column);

  GeneratedColumn<String> get body =>
      $composableBuilder(column: $table.body, builder: (column) => column);

  GeneratedColumn<Uint8List> get original =>
      $composableBuilder(column: $table.original, builder: (column) => column);

  GeneratedColumn<Uint8List> get artwork =>
      $composableBuilder(column: $table.artwork, builder: (column) => column);

  GeneratedColumn<String> get jobId =>
      $composableBuilder(column: $table.jobId, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<String> get styleVersion => $composableBuilder(
    column: $table.styleVersion,
    builder: (column) => column,
  );

  GeneratedColumn<int> get createdAtUtcMicros => $composableBuilder(
    column: $table.createdAtUtcMicros,
    builder: (column) => column,
  );
}

class $$PhotoDiariesTableTableManager
    extends
        RootTableManager<
          _$DopaDatabase,
          $PhotoDiariesTable,
          PhotoDiaryRow,
          $$PhotoDiariesTableFilterComposer,
          $$PhotoDiariesTableOrderingComposer,
          $$PhotoDiariesTableAnnotationComposer,
          $$PhotoDiariesTableCreateCompanionBuilder,
          $$PhotoDiariesTableUpdateCompanionBuilder,
          (
            PhotoDiaryRow,
            BaseReferences<_$DopaDatabase, $PhotoDiariesTable, PhotoDiaryRow>,
          ),
          PhotoDiaryRow,
          PrefetchHooks Function()
        > {
  $$PhotoDiariesTableTableManager(_$DopaDatabase db, $PhotoDiariesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PhotoDiariesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PhotoDiariesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PhotoDiariesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> localDate = const Value.absent(),
                Value<String> body = const Value.absent(),
                Value<Uint8List> original = const Value.absent(),
                Value<Uint8List?> artwork = const Value.absent(),
                Value<String?> jobId = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<String> styleVersion = const Value.absent(),
                Value<int> createdAtUtcMicros = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PhotoDiariesCompanion(
                id: id,
                localDate: localDate,
                body: body,
                original: original,
                artwork: artwork,
                jobId: jobId,
                status: status,
                styleVersion: styleVersion,
                createdAtUtcMicros: createdAtUtcMicros,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String localDate,
                Value<String> body = const Value.absent(),
                required Uint8List original,
                Value<Uint8List?> artwork = const Value.absent(),
                Value<String?> jobId = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<String> styleVersion = const Value.absent(),
                required int createdAtUtcMicros,
                Value<int> rowid = const Value.absent(),
              }) => PhotoDiariesCompanion.insert(
                id: id,
                localDate: localDate,
                body: body,
                original: original,
                artwork: artwork,
                jobId: jobId,
                status: status,
                styleVersion: styleVersion,
                createdAtUtcMicros: createdAtUtcMicros,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$PhotoDiariesTableProcessedTableManager =
    ProcessedTableManager<
      _$DopaDatabase,
      $PhotoDiariesTable,
      PhotoDiaryRow,
      $$PhotoDiariesTableFilterComposer,
      $$PhotoDiariesTableOrderingComposer,
      $$PhotoDiariesTableAnnotationComposer,
      $$PhotoDiariesTableCreateCompanionBuilder,
      $$PhotoDiariesTableUpdateCompanionBuilder,
      (
        PhotoDiaryRow,
        BaseReferences<_$DopaDatabase, $PhotoDiariesTable, PhotoDiaryRow>,
      ),
      PhotoDiaryRow,
      PrefetchHooks Function()
    >;
typedef $$PhotoDiaryRemoteStatesTableCreateCompanionBuilder =
    PhotoDiaryRemoteStatesCompanion Function({Value<int> singleton});
typedef $$PhotoDiaryRemoteStatesTableUpdateCompanionBuilder =
    PhotoDiaryRemoteStatesCompanion Function({Value<int> singleton});

class $$PhotoDiaryRemoteStatesTableFilterComposer
    extends Composer<_$DopaDatabase, $PhotoDiaryRemoteStatesTable> {
  $$PhotoDiaryRemoteStatesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get singleton => $composableBuilder(
    column: $table.singleton,
    builder: (column) => ColumnFilters(column),
  );
}

class $$PhotoDiaryRemoteStatesTableOrderingComposer
    extends Composer<_$DopaDatabase, $PhotoDiaryRemoteStatesTable> {
  $$PhotoDiaryRemoteStatesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get singleton => $composableBuilder(
    column: $table.singleton,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$PhotoDiaryRemoteStatesTableAnnotationComposer
    extends Composer<_$DopaDatabase, $PhotoDiaryRemoteStatesTable> {
  $$PhotoDiaryRemoteStatesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get singleton =>
      $composableBuilder(column: $table.singleton, builder: (column) => column);
}

class $$PhotoDiaryRemoteStatesTableTableManager
    extends
        RootTableManager<
          _$DopaDatabase,
          $PhotoDiaryRemoteStatesTable,
          PhotoDiaryRemoteState,
          $$PhotoDiaryRemoteStatesTableFilterComposer,
          $$PhotoDiaryRemoteStatesTableOrderingComposer,
          $$PhotoDiaryRemoteStatesTableAnnotationComposer,
          $$PhotoDiaryRemoteStatesTableCreateCompanionBuilder,
          $$PhotoDiaryRemoteStatesTableUpdateCompanionBuilder,
          (
            PhotoDiaryRemoteState,
            BaseReferences<
              _$DopaDatabase,
              $PhotoDiaryRemoteStatesTable,
              PhotoDiaryRemoteState
            >,
          ),
          PhotoDiaryRemoteState,
          PrefetchHooks Function()
        > {
  $$PhotoDiaryRemoteStatesTableTableManager(
    _$DopaDatabase db,
    $PhotoDiaryRemoteStatesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PhotoDiaryRemoteStatesTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer: () =>
              $$PhotoDiaryRemoteStatesTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$PhotoDiaryRemoteStatesTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback: ({
            Value<int> singleton = const Value.absent(),
          }) => PhotoDiaryRemoteStatesCompanion(singleton: singleton),
          createCompanionCallback: ({
            Value<int> singleton = const Value.absent(),
          }) => PhotoDiaryRemoteStatesCompanion.insert(singleton: singleton),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$PhotoDiaryRemoteStatesTableProcessedTableManager =
    ProcessedTableManager<
      _$DopaDatabase,
      $PhotoDiaryRemoteStatesTable,
      PhotoDiaryRemoteState,
      $$PhotoDiaryRemoteStatesTableFilterComposer,
      $$PhotoDiaryRemoteStatesTableOrderingComposer,
      $$PhotoDiaryRemoteStatesTableAnnotationComposer,
      $$PhotoDiaryRemoteStatesTableCreateCompanionBuilder,
      $$PhotoDiaryRemoteStatesTableUpdateCompanionBuilder,
      (
        PhotoDiaryRemoteState,
        BaseReferences<
          _$DopaDatabase,
          $PhotoDiaryRemoteStatesTable,
          PhotoDiaryRemoteState
        >,
      ),
      PhotoDiaryRemoteState,
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
  $$CompanionRunsTableTableManager get companionRuns =>
      $$CompanionRunsTableTableManager(_db, _db.companionRuns);
  $$CompanionOutcomesTableTableManager get companionOutcomes =>
      $$CompanionOutcomesTableTableManager(_db, _db.companionOutcomes);
  $$PhotoDiariesTableTableManager get photoDiaries =>
      $$PhotoDiariesTableTableManager(_db, _db.photoDiaries);
  $$PhotoDiaryRemoteStatesTableTableManager get photoDiaryRemoteStates =>
      $$PhotoDiaryRemoteStatesTableTableManager(
        _db,
        _db.photoDiaryRemoteStates,
      );
}
