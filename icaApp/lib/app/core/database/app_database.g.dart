// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $CachedSchedulesTable extends CachedSchedules
    with TableInfo<$CachedSchedulesTable, CachedSchedule> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CachedSchedulesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _batchIdMeta = const VerificationMeta(
    'batchId',
  );
  @override
  late final GeneratedColumn<String> batchId = GeneratedColumn<String>(
    'batch_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _classDateMeta = const VerificationMeta(
    'classDate',
  );
  @override
  late final GeneratedColumn<String> classDate = GeneratedColumn<String>(
    'class_date',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _startTimeMeta = const VerificationMeta(
    'startTime',
  );
  @override
  late final GeneratedColumn<String> startTime = GeneratedColumn<String>(
    'start_time',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _endTimeMeta = const VerificationMeta(
    'endTime',
  );
  @override
  late final GeneratedColumn<String> endTime = GeneratedColumn<String>(
    'end_time',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('scheduled'),
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<String> updatedAt = GeneratedColumn<String>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    batchId,
    classDate,
    startTime,
    endTime,
    status,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'cached_schedules';
  @override
  VerificationContext validateIntegrity(
    Insertable<CachedSchedule> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('batch_id')) {
      context.handle(
        _batchIdMeta,
        batchId.isAcceptableOrUnknown(data['batch_id']!, _batchIdMeta),
      );
    } else if (isInserting) {
      context.missing(_batchIdMeta);
    }
    if (data.containsKey('class_date')) {
      context.handle(
        _classDateMeta,
        classDate.isAcceptableOrUnknown(data['class_date']!, _classDateMeta),
      );
    } else if (isInserting) {
      context.missing(_classDateMeta);
    }
    if (data.containsKey('start_time')) {
      context.handle(
        _startTimeMeta,
        startTime.isAcceptableOrUnknown(data['start_time']!, _startTimeMeta),
      );
    } else if (isInserting) {
      context.missing(_startTimeMeta);
    }
    if (data.containsKey('end_time')) {
      context.handle(
        _endTimeMeta,
        endTime.isAcceptableOrUnknown(data['end_time']!, _endTimeMeta),
      );
    } else if (isInserting) {
      context.missing(_endTimeMeta);
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CachedSchedule map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CachedSchedule(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      batchId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}batch_id'],
      )!,
      classDate: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}class_date'],
      )!,
      startTime: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}start_time'],
      )!,
      endTime: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}end_time'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $CachedSchedulesTable createAlias(String alias) {
    return $CachedSchedulesTable(attachedDatabase, alias);
  }
}

class CachedSchedule extends DataClass implements Insertable<CachedSchedule> {
  final String id;
  final String batchId;
  final String classDate;
  final String startTime;
  final String endTime;
  final String status;
  final String updatedAt;
  const CachedSchedule({
    required this.id,
    required this.batchId,
    required this.classDate,
    required this.startTime,
    required this.endTime,
    required this.status,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['batch_id'] = Variable<String>(batchId);
    map['class_date'] = Variable<String>(classDate);
    map['start_time'] = Variable<String>(startTime);
    map['end_time'] = Variable<String>(endTime);
    map['status'] = Variable<String>(status);
    map['updated_at'] = Variable<String>(updatedAt);
    return map;
  }

  CachedSchedulesCompanion toCompanion(bool nullToAbsent) {
    return CachedSchedulesCompanion(
      id: Value(id),
      batchId: Value(batchId),
      classDate: Value(classDate),
      startTime: Value(startTime),
      endTime: Value(endTime),
      status: Value(status),
      updatedAt: Value(updatedAt),
    );
  }

  factory CachedSchedule.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CachedSchedule(
      id: serializer.fromJson<String>(json['id']),
      batchId: serializer.fromJson<String>(json['batchId']),
      classDate: serializer.fromJson<String>(json['classDate']),
      startTime: serializer.fromJson<String>(json['startTime']),
      endTime: serializer.fromJson<String>(json['endTime']),
      status: serializer.fromJson<String>(json['status']),
      updatedAt: serializer.fromJson<String>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'batchId': serializer.toJson<String>(batchId),
      'classDate': serializer.toJson<String>(classDate),
      'startTime': serializer.toJson<String>(startTime),
      'endTime': serializer.toJson<String>(endTime),
      'status': serializer.toJson<String>(status),
      'updatedAt': serializer.toJson<String>(updatedAt),
    };
  }

  CachedSchedule copyWith({
    String? id,
    String? batchId,
    String? classDate,
    String? startTime,
    String? endTime,
    String? status,
    String? updatedAt,
  }) => CachedSchedule(
    id: id ?? this.id,
    batchId: batchId ?? this.batchId,
    classDate: classDate ?? this.classDate,
    startTime: startTime ?? this.startTime,
    endTime: endTime ?? this.endTime,
    status: status ?? this.status,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  CachedSchedule copyWithCompanion(CachedSchedulesCompanion data) {
    return CachedSchedule(
      id: data.id.present ? data.id.value : this.id,
      batchId: data.batchId.present ? data.batchId.value : this.batchId,
      classDate: data.classDate.present ? data.classDate.value : this.classDate,
      startTime: data.startTime.present ? data.startTime.value : this.startTime,
      endTime: data.endTime.present ? data.endTime.value : this.endTime,
      status: data.status.present ? data.status.value : this.status,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CachedSchedule(')
          ..write('id: $id, ')
          ..write('batchId: $batchId, ')
          ..write('classDate: $classDate, ')
          ..write('startTime: $startTime, ')
          ..write('endTime: $endTime, ')
          ..write('status: $status, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    batchId,
    classDate,
    startTime,
    endTime,
    status,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CachedSchedule &&
          other.id == this.id &&
          other.batchId == this.batchId &&
          other.classDate == this.classDate &&
          other.startTime == this.startTime &&
          other.endTime == this.endTime &&
          other.status == this.status &&
          other.updatedAt == this.updatedAt);
}

class CachedSchedulesCompanion extends UpdateCompanion<CachedSchedule> {
  final Value<String> id;
  final Value<String> batchId;
  final Value<String> classDate;
  final Value<String> startTime;
  final Value<String> endTime;
  final Value<String> status;
  final Value<String> updatedAt;
  final Value<int> rowid;
  const CachedSchedulesCompanion({
    this.id = const Value.absent(),
    this.batchId = const Value.absent(),
    this.classDate = const Value.absent(),
    this.startTime = const Value.absent(),
    this.endTime = const Value.absent(),
    this.status = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CachedSchedulesCompanion.insert({
    required String id,
    required String batchId,
    required String classDate,
    required String startTime,
    required String endTime,
    this.status = const Value.absent(),
    required String updatedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       batchId = Value(batchId),
       classDate = Value(classDate),
       startTime = Value(startTime),
       endTime = Value(endTime),
       updatedAt = Value(updatedAt);
  static Insertable<CachedSchedule> custom({
    Expression<String>? id,
    Expression<String>? batchId,
    Expression<String>? classDate,
    Expression<String>? startTime,
    Expression<String>? endTime,
    Expression<String>? status,
    Expression<String>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (batchId != null) 'batch_id': batchId,
      if (classDate != null) 'class_date': classDate,
      if (startTime != null) 'start_time': startTime,
      if (endTime != null) 'end_time': endTime,
      if (status != null) 'status': status,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CachedSchedulesCompanion copyWith({
    Value<String>? id,
    Value<String>? batchId,
    Value<String>? classDate,
    Value<String>? startTime,
    Value<String>? endTime,
    Value<String>? status,
    Value<String>? updatedAt,
    Value<int>? rowid,
  }) {
    return CachedSchedulesCompanion(
      id: id ?? this.id,
      batchId: batchId ?? this.batchId,
      classDate: classDate ?? this.classDate,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      status: status ?? this.status,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (batchId.present) {
      map['batch_id'] = Variable<String>(batchId.value);
    }
    if (classDate.present) {
      map['class_date'] = Variable<String>(classDate.value);
    }
    if (startTime.present) {
      map['start_time'] = Variable<String>(startTime.value);
    }
    if (endTime.present) {
      map['end_time'] = Variable<String>(endTime.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<String>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CachedSchedulesCompanion(')
          ..write('id: $id, ')
          ..write('batchId: $batchId, ')
          ..write('classDate: $classDate, ')
          ..write('startTime: $startTime, ')
          ..write('endTime: $endTime, ')
          ..write('status: $status, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CachedAttendanceTable extends CachedAttendance
    with TableInfo<$CachedAttendanceTable, CachedAttendanceData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CachedAttendanceTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _studentIdMeta = const VerificationMeta(
    'studentId',
  );
  @override
  late final GeneratedColumn<String> studentId = GeneratedColumn<String>(
    'student_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _batchIdMeta = const VerificationMeta(
    'batchId',
  );
  @override
  late final GeneratedColumn<String> batchId = GeneratedColumn<String>(
    'batch_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _classDateMeta = const VerificationMeta(
    'classDate',
  );
  @override
  late final GeneratedColumn<String> classDate = GeneratedColumn<String>(
    'class_date',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('present'),
  );
  static const VerificationMeta _geofenceVerifiedMeta = const VerificationMeta(
    'geofenceVerified',
  );
  @override
  late final GeneratedColumn<bool> geofenceVerified = GeneratedColumn<bool>(
    'geofence_verified',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("geofence_verified" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    studentId,
    batchId,
    classDate,
    status,
    geofenceVerified,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'cached_attendance';
  @override
  VerificationContext validateIntegrity(
    Insertable<CachedAttendanceData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('student_id')) {
      context.handle(
        _studentIdMeta,
        studentId.isAcceptableOrUnknown(data['student_id']!, _studentIdMeta),
      );
    } else if (isInserting) {
      context.missing(_studentIdMeta);
    }
    if (data.containsKey('batch_id')) {
      context.handle(
        _batchIdMeta,
        batchId.isAcceptableOrUnknown(data['batch_id']!, _batchIdMeta),
      );
    } else if (isInserting) {
      context.missing(_batchIdMeta);
    }
    if (data.containsKey('class_date')) {
      context.handle(
        _classDateMeta,
        classDate.isAcceptableOrUnknown(data['class_date']!, _classDateMeta),
      );
    } else if (isInserting) {
      context.missing(_classDateMeta);
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    }
    if (data.containsKey('geofence_verified')) {
      context.handle(
        _geofenceVerifiedMeta,
        geofenceVerified.isAcceptableOrUnknown(
          data['geofence_verified']!,
          _geofenceVerifiedMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CachedAttendanceData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CachedAttendanceData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      studentId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}student_id'],
      )!,
      batchId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}batch_id'],
      )!,
      classDate: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}class_date'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      geofenceVerified: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}geofence_verified'],
      )!,
    );
  }

  @override
  $CachedAttendanceTable createAlias(String alias) {
    return $CachedAttendanceTable(attachedDatabase, alias);
  }
}

class CachedAttendanceData extends DataClass
    implements Insertable<CachedAttendanceData> {
  final String id;
  final String studentId;
  final String batchId;
  final String classDate;
  final String status;
  final bool geofenceVerified;
  const CachedAttendanceData({
    required this.id,
    required this.studentId,
    required this.batchId,
    required this.classDate,
    required this.status,
    required this.geofenceVerified,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['student_id'] = Variable<String>(studentId);
    map['batch_id'] = Variable<String>(batchId);
    map['class_date'] = Variable<String>(classDate);
    map['status'] = Variable<String>(status);
    map['geofence_verified'] = Variable<bool>(geofenceVerified);
    return map;
  }

  CachedAttendanceCompanion toCompanion(bool nullToAbsent) {
    return CachedAttendanceCompanion(
      id: Value(id),
      studentId: Value(studentId),
      batchId: Value(batchId),
      classDate: Value(classDate),
      status: Value(status),
      geofenceVerified: Value(geofenceVerified),
    );
  }

  factory CachedAttendanceData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CachedAttendanceData(
      id: serializer.fromJson<String>(json['id']),
      studentId: serializer.fromJson<String>(json['studentId']),
      batchId: serializer.fromJson<String>(json['batchId']),
      classDate: serializer.fromJson<String>(json['classDate']),
      status: serializer.fromJson<String>(json['status']),
      geofenceVerified: serializer.fromJson<bool>(json['geofenceVerified']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'studentId': serializer.toJson<String>(studentId),
      'batchId': serializer.toJson<String>(batchId),
      'classDate': serializer.toJson<String>(classDate),
      'status': serializer.toJson<String>(status),
      'geofenceVerified': serializer.toJson<bool>(geofenceVerified),
    };
  }

  CachedAttendanceData copyWith({
    String? id,
    String? studentId,
    String? batchId,
    String? classDate,
    String? status,
    bool? geofenceVerified,
  }) => CachedAttendanceData(
    id: id ?? this.id,
    studentId: studentId ?? this.studentId,
    batchId: batchId ?? this.batchId,
    classDate: classDate ?? this.classDate,
    status: status ?? this.status,
    geofenceVerified: geofenceVerified ?? this.geofenceVerified,
  );
  CachedAttendanceData copyWithCompanion(CachedAttendanceCompanion data) {
    return CachedAttendanceData(
      id: data.id.present ? data.id.value : this.id,
      studentId: data.studentId.present ? data.studentId.value : this.studentId,
      batchId: data.batchId.present ? data.batchId.value : this.batchId,
      classDate: data.classDate.present ? data.classDate.value : this.classDate,
      status: data.status.present ? data.status.value : this.status,
      geofenceVerified: data.geofenceVerified.present
          ? data.geofenceVerified.value
          : this.geofenceVerified,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CachedAttendanceData(')
          ..write('id: $id, ')
          ..write('studentId: $studentId, ')
          ..write('batchId: $batchId, ')
          ..write('classDate: $classDate, ')
          ..write('status: $status, ')
          ..write('geofenceVerified: $geofenceVerified')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, studentId, batchId, classDate, status, geofenceVerified);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CachedAttendanceData &&
          other.id == this.id &&
          other.studentId == this.studentId &&
          other.batchId == this.batchId &&
          other.classDate == this.classDate &&
          other.status == this.status &&
          other.geofenceVerified == this.geofenceVerified);
}

class CachedAttendanceCompanion extends UpdateCompanion<CachedAttendanceData> {
  final Value<String> id;
  final Value<String> studentId;
  final Value<String> batchId;
  final Value<String> classDate;
  final Value<String> status;
  final Value<bool> geofenceVerified;
  final Value<int> rowid;
  const CachedAttendanceCompanion({
    this.id = const Value.absent(),
    this.studentId = const Value.absent(),
    this.batchId = const Value.absent(),
    this.classDate = const Value.absent(),
    this.status = const Value.absent(),
    this.geofenceVerified = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CachedAttendanceCompanion.insert({
    required String id,
    required String studentId,
    required String batchId,
    required String classDate,
    this.status = const Value.absent(),
    this.geofenceVerified = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       studentId = Value(studentId),
       batchId = Value(batchId),
       classDate = Value(classDate);
  static Insertable<CachedAttendanceData> custom({
    Expression<String>? id,
    Expression<String>? studentId,
    Expression<String>? batchId,
    Expression<String>? classDate,
    Expression<String>? status,
    Expression<bool>? geofenceVerified,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (studentId != null) 'student_id': studentId,
      if (batchId != null) 'batch_id': batchId,
      if (classDate != null) 'class_date': classDate,
      if (status != null) 'status': status,
      if (geofenceVerified != null) 'geofence_verified': geofenceVerified,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CachedAttendanceCompanion copyWith({
    Value<String>? id,
    Value<String>? studentId,
    Value<String>? batchId,
    Value<String>? classDate,
    Value<String>? status,
    Value<bool>? geofenceVerified,
    Value<int>? rowid,
  }) {
    return CachedAttendanceCompanion(
      id: id ?? this.id,
      studentId: studentId ?? this.studentId,
      batchId: batchId ?? this.batchId,
      classDate: classDate ?? this.classDate,
      status: status ?? this.status,
      geofenceVerified: geofenceVerified ?? this.geofenceVerified,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (studentId.present) {
      map['student_id'] = Variable<String>(studentId.value);
    }
    if (batchId.present) {
      map['batch_id'] = Variable<String>(batchId.value);
    }
    if (classDate.present) {
      map['class_date'] = Variable<String>(classDate.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (geofenceVerified.present) {
      map['geofence_verified'] = Variable<bool>(geofenceVerified.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CachedAttendanceCompanion(')
          ..write('id: $id, ')
          ..write('studentId: $studentId, ')
          ..write('batchId: $batchId, ')
          ..write('classDate: $classDate, ')
          ..write('status: $status, ')
          ..write('geofenceVerified: $geofenceVerified, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CachedNotificationsTable extends CachedNotifications
    with TableInfo<$CachedNotificationsTable, CachedNotification> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CachedNotificationsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _targetParentIdMeta = const VerificationMeta(
    'targetParentId',
  );
  @override
  late final GeneratedColumn<String> targetParentId = GeneratedColumn<String>(
    'target_parent_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
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
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
    'type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('general'),
  );
  static const VerificationMeta _isReadMeta = const VerificationMeta('isRead');
  @override
  late final GeneratedColumn<bool> isRead = GeneratedColumn<bool>(
    'is_read',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_read" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _readAtMeta = const VerificationMeta('readAt');
  @override
  late final GeneratedColumn<String> readAt = GeneratedColumn<String>(
    'read_at',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _deepLinkMeta = const VerificationMeta(
    'deepLink',
  );
  @override
  late final GeneratedColumn<String> deepLink = GeneratedColumn<String>(
    'deep_link',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<String> createdAt = GeneratedColumn<String>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    targetParentId,
    title,
    body,
    type,
    isRead,
    readAt,
    deepLink,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'cached_notifications';
  @override
  VerificationContext validateIntegrity(
    Insertable<CachedNotification> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('target_parent_id')) {
      context.handle(
        _targetParentIdMeta,
        targetParentId.isAcceptableOrUnknown(
          data['target_parent_id']!,
          _targetParentIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_targetParentIdMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    }
    if (data.containsKey('body')) {
      context.handle(
        _bodyMeta,
        body.isAcceptableOrUnknown(data['body']!, _bodyMeta),
      );
    }
    if (data.containsKey('type')) {
      context.handle(
        _typeMeta,
        type.isAcceptableOrUnknown(data['type']!, _typeMeta),
      );
    }
    if (data.containsKey('is_read')) {
      context.handle(
        _isReadMeta,
        isRead.isAcceptableOrUnknown(data['is_read']!, _isReadMeta),
      );
    }
    if (data.containsKey('read_at')) {
      context.handle(
        _readAtMeta,
        readAt.isAcceptableOrUnknown(data['read_at']!, _readAtMeta),
      );
    }
    if (data.containsKey('deep_link')) {
      context.handle(
        _deepLinkMeta,
        deepLink.isAcceptableOrUnknown(data['deep_link']!, _deepLinkMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CachedNotification map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CachedNotification(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      targetParentId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}target_parent_id'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      body: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}body'],
      )!,
      type: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}type'],
      )!,
      isRead: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_read'],
      )!,
      readAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}read_at'],
      ),
      deepLink: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}deep_link'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $CachedNotificationsTable createAlias(String alias) {
    return $CachedNotificationsTable(attachedDatabase, alias);
  }
}

class CachedNotification extends DataClass
    implements Insertable<CachedNotification> {
  final String id;
  final String targetParentId;
  final String title;
  final String body;
  final String type;
  final bool isRead;
  final String? readAt;
  final String? deepLink;
  final String createdAt;
  const CachedNotification({
    required this.id,
    required this.targetParentId,
    required this.title,
    required this.body,
    required this.type,
    required this.isRead,
    this.readAt,
    this.deepLink,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['target_parent_id'] = Variable<String>(targetParentId);
    map['title'] = Variable<String>(title);
    map['body'] = Variable<String>(body);
    map['type'] = Variable<String>(type);
    map['is_read'] = Variable<bool>(isRead);
    if (!nullToAbsent || readAt != null) {
      map['read_at'] = Variable<String>(readAt);
    }
    if (!nullToAbsent || deepLink != null) {
      map['deep_link'] = Variable<String>(deepLink);
    }
    map['created_at'] = Variable<String>(createdAt);
    return map;
  }

  CachedNotificationsCompanion toCompanion(bool nullToAbsent) {
    return CachedNotificationsCompanion(
      id: Value(id),
      targetParentId: Value(targetParentId),
      title: Value(title),
      body: Value(body),
      type: Value(type),
      isRead: Value(isRead),
      readAt: readAt == null && nullToAbsent
          ? const Value.absent()
          : Value(readAt),
      deepLink: deepLink == null && nullToAbsent
          ? const Value.absent()
          : Value(deepLink),
      createdAt: Value(createdAt),
    );
  }

  factory CachedNotification.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CachedNotification(
      id: serializer.fromJson<String>(json['id']),
      targetParentId: serializer.fromJson<String>(json['targetParentId']),
      title: serializer.fromJson<String>(json['title']),
      body: serializer.fromJson<String>(json['body']),
      type: serializer.fromJson<String>(json['type']),
      isRead: serializer.fromJson<bool>(json['isRead']),
      readAt: serializer.fromJson<String?>(json['readAt']),
      deepLink: serializer.fromJson<String?>(json['deepLink']),
      createdAt: serializer.fromJson<String>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'targetParentId': serializer.toJson<String>(targetParentId),
      'title': serializer.toJson<String>(title),
      'body': serializer.toJson<String>(body),
      'type': serializer.toJson<String>(type),
      'isRead': serializer.toJson<bool>(isRead),
      'readAt': serializer.toJson<String?>(readAt),
      'deepLink': serializer.toJson<String?>(deepLink),
      'createdAt': serializer.toJson<String>(createdAt),
    };
  }

  CachedNotification copyWith({
    String? id,
    String? targetParentId,
    String? title,
    String? body,
    String? type,
    bool? isRead,
    Value<String?> readAt = const Value.absent(),
    Value<String?> deepLink = const Value.absent(),
    String? createdAt,
  }) => CachedNotification(
    id: id ?? this.id,
    targetParentId: targetParentId ?? this.targetParentId,
    title: title ?? this.title,
    body: body ?? this.body,
    type: type ?? this.type,
    isRead: isRead ?? this.isRead,
    readAt: readAt.present ? readAt.value : this.readAt,
    deepLink: deepLink.present ? deepLink.value : this.deepLink,
    createdAt: createdAt ?? this.createdAt,
  );
  CachedNotification copyWithCompanion(CachedNotificationsCompanion data) {
    return CachedNotification(
      id: data.id.present ? data.id.value : this.id,
      targetParentId: data.targetParentId.present
          ? data.targetParentId.value
          : this.targetParentId,
      title: data.title.present ? data.title.value : this.title,
      body: data.body.present ? data.body.value : this.body,
      type: data.type.present ? data.type.value : this.type,
      isRead: data.isRead.present ? data.isRead.value : this.isRead,
      readAt: data.readAt.present ? data.readAt.value : this.readAt,
      deepLink: data.deepLink.present ? data.deepLink.value : this.deepLink,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CachedNotification(')
          ..write('id: $id, ')
          ..write('targetParentId: $targetParentId, ')
          ..write('title: $title, ')
          ..write('body: $body, ')
          ..write('type: $type, ')
          ..write('isRead: $isRead, ')
          ..write('readAt: $readAt, ')
          ..write('deepLink: $deepLink, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    targetParentId,
    title,
    body,
    type,
    isRead,
    readAt,
    deepLink,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CachedNotification &&
          other.id == this.id &&
          other.targetParentId == this.targetParentId &&
          other.title == this.title &&
          other.body == this.body &&
          other.type == this.type &&
          other.isRead == this.isRead &&
          other.readAt == this.readAt &&
          other.deepLink == this.deepLink &&
          other.createdAt == this.createdAt);
}

class CachedNotificationsCompanion extends UpdateCompanion<CachedNotification> {
  final Value<String> id;
  final Value<String> targetParentId;
  final Value<String> title;
  final Value<String> body;
  final Value<String> type;
  final Value<bool> isRead;
  final Value<String?> readAt;
  final Value<String?> deepLink;
  final Value<String> createdAt;
  final Value<int> rowid;
  const CachedNotificationsCompanion({
    this.id = const Value.absent(),
    this.targetParentId = const Value.absent(),
    this.title = const Value.absent(),
    this.body = const Value.absent(),
    this.type = const Value.absent(),
    this.isRead = const Value.absent(),
    this.readAt = const Value.absent(),
    this.deepLink = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CachedNotificationsCompanion.insert({
    required String id,
    required String targetParentId,
    this.title = const Value.absent(),
    this.body = const Value.absent(),
    this.type = const Value.absent(),
    this.isRead = const Value.absent(),
    this.readAt = const Value.absent(),
    this.deepLink = const Value.absent(),
    required String createdAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       targetParentId = Value(targetParentId),
       createdAt = Value(createdAt);
  static Insertable<CachedNotification> custom({
    Expression<String>? id,
    Expression<String>? targetParentId,
    Expression<String>? title,
    Expression<String>? body,
    Expression<String>? type,
    Expression<bool>? isRead,
    Expression<String>? readAt,
    Expression<String>? deepLink,
    Expression<String>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (targetParentId != null) 'target_parent_id': targetParentId,
      if (title != null) 'title': title,
      if (body != null) 'body': body,
      if (type != null) 'type': type,
      if (isRead != null) 'is_read': isRead,
      if (readAt != null) 'read_at': readAt,
      if (deepLink != null) 'deep_link': deepLink,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CachedNotificationsCompanion copyWith({
    Value<String>? id,
    Value<String>? targetParentId,
    Value<String>? title,
    Value<String>? body,
    Value<String>? type,
    Value<bool>? isRead,
    Value<String?>? readAt,
    Value<String?>? deepLink,
    Value<String>? createdAt,
    Value<int>? rowid,
  }) {
    return CachedNotificationsCompanion(
      id: id ?? this.id,
      targetParentId: targetParentId ?? this.targetParentId,
      title: title ?? this.title,
      body: body ?? this.body,
      type: type ?? this.type,
      isRead: isRead ?? this.isRead,
      readAt: readAt ?? this.readAt,
      deepLink: deepLink ?? this.deepLink,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (targetParentId.present) {
      map['target_parent_id'] = Variable<String>(targetParentId.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (body.present) {
      map['body'] = Variable<String>(body.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (isRead.present) {
      map['is_read'] = Variable<bool>(isRead.value);
    }
    if (readAt.present) {
      map['read_at'] = Variable<String>(readAt.value);
    }
    if (deepLink.present) {
      map['deep_link'] = Variable<String>(deepLink.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<String>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CachedNotificationsCompanion(')
          ..write('id: $id, ')
          ..write('targetParentId: $targetParentId, ')
          ..write('title: $title, ')
          ..write('body: $body, ')
          ..write('type: $type, ')
          ..write('isRead: $isRead, ')
          ..write('readAt: $readAt, ')
          ..write('deepLink: $deepLink, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $GeofenceLogsTable extends GeofenceLogs
    with TableInfo<$GeofenceLogsTable, GeofenceLog> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $GeofenceLogsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _studentIdMeta = const VerificationMeta(
    'studentId',
  );
  @override
  late final GeneratedColumn<String> studentId = GeneratedColumn<String>(
    'student_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _latMeta = const VerificationMeta('lat');
  @override
  late final GeneratedColumn<double> lat = GeneratedColumn<double>(
    'lat',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _lngMeta = const VerificationMeta('lng');
  @override
  late final GeneratedColumn<double> lng = GeneratedColumn<double>(
    'lng',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _accuracyMeta = const VerificationMeta(
    'accuracy',
  );
  @override
  late final GeneratedColumn<double> accuracy = GeneratedColumn<double>(
    'accuracy',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _eventTypeMeta = const VerificationMeta(
    'eventType',
  );
  @override
  late final GeneratedColumn<String> eventType = GeneratedColumn<String>(
    'event_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('enter'),
  );
  static const VerificationMeta _timestampMeta = const VerificationMeta(
    'timestamp',
  );
  @override
  late final GeneratedColumn<String> timestamp = GeneratedColumn<String>(
    'timestamp',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _syncedMeta = const VerificationMeta('synced');
  @override
  late final GeneratedColumn<bool> synced = GeneratedColumn<bool>(
    'synced',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("synced" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    studentId,
    lat,
    lng,
    accuracy,
    eventType,
    timestamp,
    synced,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'geofence_logs';
  @override
  VerificationContext validateIntegrity(
    Insertable<GeofenceLog> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('student_id')) {
      context.handle(
        _studentIdMeta,
        studentId.isAcceptableOrUnknown(data['student_id']!, _studentIdMeta),
      );
    } else if (isInserting) {
      context.missing(_studentIdMeta);
    }
    if (data.containsKey('lat')) {
      context.handle(
        _latMeta,
        lat.isAcceptableOrUnknown(data['lat']!, _latMeta),
      );
    } else if (isInserting) {
      context.missing(_latMeta);
    }
    if (data.containsKey('lng')) {
      context.handle(
        _lngMeta,
        lng.isAcceptableOrUnknown(data['lng']!, _lngMeta),
      );
    } else if (isInserting) {
      context.missing(_lngMeta);
    }
    if (data.containsKey('accuracy')) {
      context.handle(
        _accuracyMeta,
        accuracy.isAcceptableOrUnknown(data['accuracy']!, _accuracyMeta),
      );
    } else if (isInserting) {
      context.missing(_accuracyMeta);
    }
    if (data.containsKey('event_type')) {
      context.handle(
        _eventTypeMeta,
        eventType.isAcceptableOrUnknown(data['event_type']!, _eventTypeMeta),
      );
    }
    if (data.containsKey('timestamp')) {
      context.handle(
        _timestampMeta,
        timestamp.isAcceptableOrUnknown(data['timestamp']!, _timestampMeta),
      );
    } else if (isInserting) {
      context.missing(_timestampMeta);
    }
    if (data.containsKey('synced')) {
      context.handle(
        _syncedMeta,
        synced.isAcceptableOrUnknown(data['synced']!, _syncedMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  GeofenceLog map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return GeofenceLog(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      studentId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}student_id'],
      )!,
      lat: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}lat'],
      )!,
      lng: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}lng'],
      )!,
      accuracy: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}accuracy'],
      )!,
      eventType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}event_type'],
      )!,
      timestamp: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}timestamp'],
      )!,
      synced: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}synced'],
      )!,
    );
  }

  @override
  $GeofenceLogsTable createAlias(String alias) {
    return $GeofenceLogsTable(attachedDatabase, alias);
  }
}

class GeofenceLog extends DataClass implements Insertable<GeofenceLog> {
  final String id;
  final String studentId;
  final double lat;
  final double lng;
  final double accuracy;
  final String eventType;
  final String timestamp;

  /// Whether this log has been synced to Supabase geofence_logs table.
  final bool synced;
  const GeofenceLog({
    required this.id,
    required this.studentId,
    required this.lat,
    required this.lng,
    required this.accuracy,
    required this.eventType,
    required this.timestamp,
    required this.synced,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['student_id'] = Variable<String>(studentId);
    map['lat'] = Variable<double>(lat);
    map['lng'] = Variable<double>(lng);
    map['accuracy'] = Variable<double>(accuracy);
    map['event_type'] = Variable<String>(eventType);
    map['timestamp'] = Variable<String>(timestamp);
    map['synced'] = Variable<bool>(synced);
    return map;
  }

  GeofenceLogsCompanion toCompanion(bool nullToAbsent) {
    return GeofenceLogsCompanion(
      id: Value(id),
      studentId: Value(studentId),
      lat: Value(lat),
      lng: Value(lng),
      accuracy: Value(accuracy),
      eventType: Value(eventType),
      timestamp: Value(timestamp),
      synced: Value(synced),
    );
  }

  factory GeofenceLog.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return GeofenceLog(
      id: serializer.fromJson<String>(json['id']),
      studentId: serializer.fromJson<String>(json['studentId']),
      lat: serializer.fromJson<double>(json['lat']),
      lng: serializer.fromJson<double>(json['lng']),
      accuracy: serializer.fromJson<double>(json['accuracy']),
      eventType: serializer.fromJson<String>(json['eventType']),
      timestamp: serializer.fromJson<String>(json['timestamp']),
      synced: serializer.fromJson<bool>(json['synced']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'studentId': serializer.toJson<String>(studentId),
      'lat': serializer.toJson<double>(lat),
      'lng': serializer.toJson<double>(lng),
      'accuracy': serializer.toJson<double>(accuracy),
      'eventType': serializer.toJson<String>(eventType),
      'timestamp': serializer.toJson<String>(timestamp),
      'synced': serializer.toJson<bool>(synced),
    };
  }

  GeofenceLog copyWith({
    String? id,
    String? studentId,
    double? lat,
    double? lng,
    double? accuracy,
    String? eventType,
    String? timestamp,
    bool? synced,
  }) => GeofenceLog(
    id: id ?? this.id,
    studentId: studentId ?? this.studentId,
    lat: lat ?? this.lat,
    lng: lng ?? this.lng,
    accuracy: accuracy ?? this.accuracy,
    eventType: eventType ?? this.eventType,
    timestamp: timestamp ?? this.timestamp,
    synced: synced ?? this.synced,
  );
  GeofenceLog copyWithCompanion(GeofenceLogsCompanion data) {
    return GeofenceLog(
      id: data.id.present ? data.id.value : this.id,
      studentId: data.studentId.present ? data.studentId.value : this.studentId,
      lat: data.lat.present ? data.lat.value : this.lat,
      lng: data.lng.present ? data.lng.value : this.lng,
      accuracy: data.accuracy.present ? data.accuracy.value : this.accuracy,
      eventType: data.eventType.present ? data.eventType.value : this.eventType,
      timestamp: data.timestamp.present ? data.timestamp.value : this.timestamp,
      synced: data.synced.present ? data.synced.value : this.synced,
    );
  }

  @override
  String toString() {
    return (StringBuffer('GeofenceLog(')
          ..write('id: $id, ')
          ..write('studentId: $studentId, ')
          ..write('lat: $lat, ')
          ..write('lng: $lng, ')
          ..write('accuracy: $accuracy, ')
          ..write('eventType: $eventType, ')
          ..write('timestamp: $timestamp, ')
          ..write('synced: $synced')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    studentId,
    lat,
    lng,
    accuracy,
    eventType,
    timestamp,
    synced,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is GeofenceLog &&
          other.id == this.id &&
          other.studentId == this.studentId &&
          other.lat == this.lat &&
          other.lng == this.lng &&
          other.accuracy == this.accuracy &&
          other.eventType == this.eventType &&
          other.timestamp == this.timestamp &&
          other.synced == this.synced);
}

class GeofenceLogsCompanion extends UpdateCompanion<GeofenceLog> {
  final Value<String> id;
  final Value<String> studentId;
  final Value<double> lat;
  final Value<double> lng;
  final Value<double> accuracy;
  final Value<String> eventType;
  final Value<String> timestamp;
  final Value<bool> synced;
  final Value<int> rowid;
  const GeofenceLogsCompanion({
    this.id = const Value.absent(),
    this.studentId = const Value.absent(),
    this.lat = const Value.absent(),
    this.lng = const Value.absent(),
    this.accuracy = const Value.absent(),
    this.eventType = const Value.absent(),
    this.timestamp = const Value.absent(),
    this.synced = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  GeofenceLogsCompanion.insert({
    required String id,
    required String studentId,
    required double lat,
    required double lng,
    required double accuracy,
    this.eventType = const Value.absent(),
    required String timestamp,
    this.synced = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       studentId = Value(studentId),
       lat = Value(lat),
       lng = Value(lng),
       accuracy = Value(accuracy),
       timestamp = Value(timestamp);
  static Insertable<GeofenceLog> custom({
    Expression<String>? id,
    Expression<String>? studentId,
    Expression<double>? lat,
    Expression<double>? lng,
    Expression<double>? accuracy,
    Expression<String>? eventType,
    Expression<String>? timestamp,
    Expression<bool>? synced,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (studentId != null) 'student_id': studentId,
      if (lat != null) 'lat': lat,
      if (lng != null) 'lng': lng,
      if (accuracy != null) 'accuracy': accuracy,
      if (eventType != null) 'event_type': eventType,
      if (timestamp != null) 'timestamp': timestamp,
      if (synced != null) 'synced': synced,
      if (rowid != null) 'rowid': rowid,
    });
  }

  GeofenceLogsCompanion copyWith({
    Value<String>? id,
    Value<String>? studentId,
    Value<double>? lat,
    Value<double>? lng,
    Value<double>? accuracy,
    Value<String>? eventType,
    Value<String>? timestamp,
    Value<bool>? synced,
    Value<int>? rowid,
  }) {
    return GeofenceLogsCompanion(
      id: id ?? this.id,
      studentId: studentId ?? this.studentId,
      lat: lat ?? this.lat,
      lng: lng ?? this.lng,
      accuracy: accuracy ?? this.accuracy,
      eventType: eventType ?? this.eventType,
      timestamp: timestamp ?? this.timestamp,
      synced: synced ?? this.synced,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (studentId.present) {
      map['student_id'] = Variable<String>(studentId.value);
    }
    if (lat.present) {
      map['lat'] = Variable<double>(lat.value);
    }
    if (lng.present) {
      map['lng'] = Variable<double>(lng.value);
    }
    if (accuracy.present) {
      map['accuracy'] = Variable<double>(accuracy.value);
    }
    if (eventType.present) {
      map['event_type'] = Variable<String>(eventType.value);
    }
    if (timestamp.present) {
      map['timestamp'] = Variable<String>(timestamp.value);
    }
    if (synced.present) {
      map['synced'] = Variable<bool>(synced.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('GeofenceLogsCompanion(')
          ..write('id: $id, ')
          ..write('studentId: $studentId, ')
          ..write('lat: $lat, ')
          ..write('lng: $lng, ')
          ..write('accuracy: $accuracy, ')
          ..write('eventType: $eventType, ')
          ..write('timestamp: $timestamp, ')
          ..write('synced: $synced, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CachedPlansTable extends CachedPlans
    with TableInfo<$CachedPlansTable, CachedPlan> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CachedPlansTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _priceMeta = const VerificationMeta('price');
  @override
  late final GeneratedColumn<double> price = GeneratedColumn<double>(
    'price',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _durationMonthsMeta = const VerificationMeta(
    'durationMonths',
  );
  @override
  late final GeneratedColumn<int> durationMonths = GeneratedColumn<int>(
    'duration_months',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  static const VerificationMeta _durationTypeMeta = const VerificationMeta(
    'durationType',
  );
  @override
  late final GeneratedColumn<String> durationType = GeneratedColumn<String>(
    'duration_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('monthly'),
  );
  static const VerificationMeta _isActiveMeta = const VerificationMeta(
    'isActive',
  );
  @override
  late final GeneratedColumn<bool> isActive = GeneratedColumn<bool>(
    'is_active',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_active" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    price,
    durationMonths,
    durationType,
    isActive,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'cached_plans';
  @override
  VerificationContext validateIntegrity(
    Insertable<CachedPlan> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('price')) {
      context.handle(
        _priceMeta,
        price.isAcceptableOrUnknown(data['price']!, _priceMeta),
      );
    } else if (isInserting) {
      context.missing(_priceMeta);
    }
    if (data.containsKey('duration_months')) {
      context.handle(
        _durationMonthsMeta,
        durationMonths.isAcceptableOrUnknown(
          data['duration_months']!,
          _durationMonthsMeta,
        ),
      );
    }
    if (data.containsKey('duration_type')) {
      context.handle(
        _durationTypeMeta,
        durationType.isAcceptableOrUnknown(
          data['duration_type']!,
          _durationTypeMeta,
        ),
      );
    }
    if (data.containsKey('is_active')) {
      context.handle(
        _isActiveMeta,
        isActive.isAcceptableOrUnknown(data['is_active']!, _isActiveMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CachedPlan map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CachedPlan(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      price: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}price'],
      )!,
      durationMonths: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}duration_months'],
      )!,
      durationType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}duration_type'],
      )!,
      isActive: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_active'],
      )!,
    );
  }

  @override
  $CachedPlansTable createAlias(String alias) {
    return $CachedPlansTable(attachedDatabase, alias);
  }
}

class CachedPlan extends DataClass implements Insertable<CachedPlan> {
  final String id;
  final String name;
  final double price;
  final int durationMonths;
  final String durationType;
  final bool isActive;
  const CachedPlan({
    required this.id,
    required this.name,
    required this.price,
    required this.durationMonths,
    required this.durationType,
    required this.isActive,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['price'] = Variable<double>(price);
    map['duration_months'] = Variable<int>(durationMonths);
    map['duration_type'] = Variable<String>(durationType);
    map['is_active'] = Variable<bool>(isActive);
    return map;
  }

  CachedPlansCompanion toCompanion(bool nullToAbsent) {
    return CachedPlansCompanion(
      id: Value(id),
      name: Value(name),
      price: Value(price),
      durationMonths: Value(durationMonths),
      durationType: Value(durationType),
      isActive: Value(isActive),
    );
  }

  factory CachedPlan.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CachedPlan(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      price: serializer.fromJson<double>(json['price']),
      durationMonths: serializer.fromJson<int>(json['durationMonths']),
      durationType: serializer.fromJson<String>(json['durationType']),
      isActive: serializer.fromJson<bool>(json['isActive']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'price': serializer.toJson<double>(price),
      'durationMonths': serializer.toJson<int>(durationMonths),
      'durationType': serializer.toJson<String>(durationType),
      'isActive': serializer.toJson<bool>(isActive),
    };
  }

  CachedPlan copyWith({
    String? id,
    String? name,
    double? price,
    int? durationMonths,
    String? durationType,
    bool? isActive,
  }) => CachedPlan(
    id: id ?? this.id,
    name: name ?? this.name,
    price: price ?? this.price,
    durationMonths: durationMonths ?? this.durationMonths,
    durationType: durationType ?? this.durationType,
    isActive: isActive ?? this.isActive,
  );
  CachedPlan copyWithCompanion(CachedPlansCompanion data) {
    return CachedPlan(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      price: data.price.present ? data.price.value : this.price,
      durationMonths: data.durationMonths.present
          ? data.durationMonths.value
          : this.durationMonths,
      durationType: data.durationType.present
          ? data.durationType.value
          : this.durationType,
      isActive: data.isActive.present ? data.isActive.value : this.isActive,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CachedPlan(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('price: $price, ')
          ..write('durationMonths: $durationMonths, ')
          ..write('durationType: $durationType, ')
          ..write('isActive: $isActive')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, name, price, durationMonths, durationType, isActive);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CachedPlan &&
          other.id == this.id &&
          other.name == this.name &&
          other.price == this.price &&
          other.durationMonths == this.durationMonths &&
          other.durationType == this.durationType &&
          other.isActive == this.isActive);
}

class CachedPlansCompanion extends UpdateCompanion<CachedPlan> {
  final Value<String> id;
  final Value<String> name;
  final Value<double> price;
  final Value<int> durationMonths;
  final Value<String> durationType;
  final Value<bool> isActive;
  final Value<int> rowid;
  const CachedPlansCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.price = const Value.absent(),
    this.durationMonths = const Value.absent(),
    this.durationType = const Value.absent(),
    this.isActive = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CachedPlansCompanion.insert({
    required String id,
    required String name,
    required double price,
    this.durationMonths = const Value.absent(),
    this.durationType = const Value.absent(),
    this.isActive = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name),
       price = Value(price);
  static Insertable<CachedPlan> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<double>? price,
    Expression<int>? durationMonths,
    Expression<String>? durationType,
    Expression<bool>? isActive,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (price != null) 'price': price,
      if (durationMonths != null) 'duration_months': durationMonths,
      if (durationType != null) 'duration_type': durationType,
      if (isActive != null) 'is_active': isActive,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CachedPlansCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<double>? price,
    Value<int>? durationMonths,
    Value<String>? durationType,
    Value<bool>? isActive,
    Value<int>? rowid,
  }) {
    return CachedPlansCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      price: price ?? this.price,
      durationMonths: durationMonths ?? this.durationMonths,
      durationType: durationType ?? this.durationType,
      isActive: isActive ?? this.isActive,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (price.present) {
      map['price'] = Variable<double>(price.value);
    }
    if (durationMonths.present) {
      map['duration_months'] = Variable<int>(durationMonths.value);
    }
    if (durationType.present) {
      map['duration_type'] = Variable<String>(durationType.value);
    }
    if (isActive.present) {
      map['is_active'] = Variable<bool>(isActive.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CachedPlansCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('price: $price, ')
          ..write('durationMonths: $durationMonths, ')
          ..write('durationType: $durationType, ')
          ..write('isActive: $isActive, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $CachedSchedulesTable cachedSchedules = $CachedSchedulesTable(
    this,
  );
  late final $CachedAttendanceTable cachedAttendance = $CachedAttendanceTable(
    this,
  );
  late final $CachedNotificationsTable cachedNotifications =
      $CachedNotificationsTable(this);
  late final $GeofenceLogsTable geofenceLogs = $GeofenceLogsTable(this);
  late final $CachedPlansTable cachedPlans = $CachedPlansTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    cachedSchedules,
    cachedAttendance,
    cachedNotifications,
    geofenceLogs,
    cachedPlans,
  ];
}

typedef $$CachedSchedulesTableCreateCompanionBuilder =
    CachedSchedulesCompanion Function({
      required String id,
      required String batchId,
      required String classDate,
      required String startTime,
      required String endTime,
      Value<String> status,
      required String updatedAt,
      Value<int> rowid,
    });
typedef $$CachedSchedulesTableUpdateCompanionBuilder =
    CachedSchedulesCompanion Function({
      Value<String> id,
      Value<String> batchId,
      Value<String> classDate,
      Value<String> startTime,
      Value<String> endTime,
      Value<String> status,
      Value<String> updatedAt,
      Value<int> rowid,
    });

class $$CachedSchedulesTableFilterComposer
    extends Composer<_$AppDatabase, $CachedSchedulesTable> {
  $$CachedSchedulesTableFilterComposer({
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

  ColumnFilters<String> get batchId => $composableBuilder(
    column: $table.batchId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get classDate => $composableBuilder(
    column: $table.classDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get startTime => $composableBuilder(
    column: $table.startTime,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get endTime => $composableBuilder(
    column: $table.endTime,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$CachedSchedulesTableOrderingComposer
    extends Composer<_$AppDatabase, $CachedSchedulesTable> {
  $$CachedSchedulesTableOrderingComposer({
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

  ColumnOrderings<String> get batchId => $composableBuilder(
    column: $table.batchId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get classDate => $composableBuilder(
    column: $table.classDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get startTime => $composableBuilder(
    column: $table.startTime,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get endTime => $composableBuilder(
    column: $table.endTime,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CachedSchedulesTableAnnotationComposer
    extends Composer<_$AppDatabase, $CachedSchedulesTable> {
  $$CachedSchedulesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get batchId =>
      $composableBuilder(column: $table.batchId, builder: (column) => column);

  GeneratedColumn<String> get classDate =>
      $composableBuilder(column: $table.classDate, builder: (column) => column);

  GeneratedColumn<String> get startTime =>
      $composableBuilder(column: $table.startTime, builder: (column) => column);

  GeneratedColumn<String> get endTime =>
      $composableBuilder(column: $table.endTime, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<String> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$CachedSchedulesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CachedSchedulesTable,
          CachedSchedule,
          $$CachedSchedulesTableFilterComposer,
          $$CachedSchedulesTableOrderingComposer,
          $$CachedSchedulesTableAnnotationComposer,
          $$CachedSchedulesTableCreateCompanionBuilder,
          $$CachedSchedulesTableUpdateCompanionBuilder,
          (
            CachedSchedule,
            BaseReferences<
              _$AppDatabase,
              $CachedSchedulesTable,
              CachedSchedule
            >,
          ),
          CachedSchedule,
          PrefetchHooks Function()
        > {
  $$CachedSchedulesTableTableManager(
    _$AppDatabase db,
    $CachedSchedulesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CachedSchedulesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CachedSchedulesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CachedSchedulesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> batchId = const Value.absent(),
                Value<String> classDate = const Value.absent(),
                Value<String> startTime = const Value.absent(),
                Value<String> endTime = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<String> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CachedSchedulesCompanion(
                id: id,
                batchId: batchId,
                classDate: classDate,
                startTime: startTime,
                endTime: endTime,
                status: status,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String batchId,
                required String classDate,
                required String startTime,
                required String endTime,
                Value<String> status = const Value.absent(),
                required String updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => CachedSchedulesCompanion.insert(
                id: id,
                batchId: batchId,
                classDate: classDate,
                startTime: startTime,
                endTime: endTime,
                status: status,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$CachedSchedulesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CachedSchedulesTable,
      CachedSchedule,
      $$CachedSchedulesTableFilterComposer,
      $$CachedSchedulesTableOrderingComposer,
      $$CachedSchedulesTableAnnotationComposer,
      $$CachedSchedulesTableCreateCompanionBuilder,
      $$CachedSchedulesTableUpdateCompanionBuilder,
      (
        CachedSchedule,
        BaseReferences<_$AppDatabase, $CachedSchedulesTable, CachedSchedule>,
      ),
      CachedSchedule,
      PrefetchHooks Function()
    >;
typedef $$CachedAttendanceTableCreateCompanionBuilder =
    CachedAttendanceCompanion Function({
      required String id,
      required String studentId,
      required String batchId,
      required String classDate,
      Value<String> status,
      Value<bool> geofenceVerified,
      Value<int> rowid,
    });
typedef $$CachedAttendanceTableUpdateCompanionBuilder =
    CachedAttendanceCompanion Function({
      Value<String> id,
      Value<String> studentId,
      Value<String> batchId,
      Value<String> classDate,
      Value<String> status,
      Value<bool> geofenceVerified,
      Value<int> rowid,
    });

class $$CachedAttendanceTableFilterComposer
    extends Composer<_$AppDatabase, $CachedAttendanceTable> {
  $$CachedAttendanceTableFilterComposer({
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

  ColumnFilters<String> get studentId => $composableBuilder(
    column: $table.studentId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get batchId => $composableBuilder(
    column: $table.batchId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get classDate => $composableBuilder(
    column: $table.classDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get geofenceVerified => $composableBuilder(
    column: $table.geofenceVerified,
    builder: (column) => ColumnFilters(column),
  );
}

class $$CachedAttendanceTableOrderingComposer
    extends Composer<_$AppDatabase, $CachedAttendanceTable> {
  $$CachedAttendanceTableOrderingComposer({
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

  ColumnOrderings<String> get studentId => $composableBuilder(
    column: $table.studentId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get batchId => $composableBuilder(
    column: $table.batchId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get classDate => $composableBuilder(
    column: $table.classDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get geofenceVerified => $composableBuilder(
    column: $table.geofenceVerified,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CachedAttendanceTableAnnotationComposer
    extends Composer<_$AppDatabase, $CachedAttendanceTable> {
  $$CachedAttendanceTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get studentId =>
      $composableBuilder(column: $table.studentId, builder: (column) => column);

  GeneratedColumn<String> get batchId =>
      $composableBuilder(column: $table.batchId, builder: (column) => column);

  GeneratedColumn<String> get classDate =>
      $composableBuilder(column: $table.classDate, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<bool> get geofenceVerified => $composableBuilder(
    column: $table.geofenceVerified,
    builder: (column) => column,
  );
}

class $$CachedAttendanceTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CachedAttendanceTable,
          CachedAttendanceData,
          $$CachedAttendanceTableFilterComposer,
          $$CachedAttendanceTableOrderingComposer,
          $$CachedAttendanceTableAnnotationComposer,
          $$CachedAttendanceTableCreateCompanionBuilder,
          $$CachedAttendanceTableUpdateCompanionBuilder,
          (
            CachedAttendanceData,
            BaseReferences<
              _$AppDatabase,
              $CachedAttendanceTable,
              CachedAttendanceData
            >,
          ),
          CachedAttendanceData,
          PrefetchHooks Function()
        > {
  $$CachedAttendanceTableTableManager(
    _$AppDatabase db,
    $CachedAttendanceTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CachedAttendanceTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CachedAttendanceTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CachedAttendanceTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> studentId = const Value.absent(),
                Value<String> batchId = const Value.absent(),
                Value<String> classDate = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<bool> geofenceVerified = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CachedAttendanceCompanion(
                id: id,
                studentId: studentId,
                batchId: batchId,
                classDate: classDate,
                status: status,
                geofenceVerified: geofenceVerified,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String studentId,
                required String batchId,
                required String classDate,
                Value<String> status = const Value.absent(),
                Value<bool> geofenceVerified = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CachedAttendanceCompanion.insert(
                id: id,
                studentId: studentId,
                batchId: batchId,
                classDate: classDate,
                status: status,
                geofenceVerified: geofenceVerified,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$CachedAttendanceTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CachedAttendanceTable,
      CachedAttendanceData,
      $$CachedAttendanceTableFilterComposer,
      $$CachedAttendanceTableOrderingComposer,
      $$CachedAttendanceTableAnnotationComposer,
      $$CachedAttendanceTableCreateCompanionBuilder,
      $$CachedAttendanceTableUpdateCompanionBuilder,
      (
        CachedAttendanceData,
        BaseReferences<
          _$AppDatabase,
          $CachedAttendanceTable,
          CachedAttendanceData
        >,
      ),
      CachedAttendanceData,
      PrefetchHooks Function()
    >;
typedef $$CachedNotificationsTableCreateCompanionBuilder =
    CachedNotificationsCompanion Function({
      required String id,
      required String targetParentId,
      Value<String> title,
      Value<String> body,
      Value<String> type,
      Value<bool> isRead,
      Value<String?> readAt,
      Value<String?> deepLink,
      required String createdAt,
      Value<int> rowid,
    });
typedef $$CachedNotificationsTableUpdateCompanionBuilder =
    CachedNotificationsCompanion Function({
      Value<String> id,
      Value<String> targetParentId,
      Value<String> title,
      Value<String> body,
      Value<String> type,
      Value<bool> isRead,
      Value<String?> readAt,
      Value<String?> deepLink,
      Value<String> createdAt,
      Value<int> rowid,
    });

class $$CachedNotificationsTableFilterComposer
    extends Composer<_$AppDatabase, $CachedNotificationsTable> {
  $$CachedNotificationsTableFilterComposer({
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

  ColumnFilters<String> get targetParentId => $composableBuilder(
    column: $table.targetParentId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get body => $composableBuilder(
    column: $table.body,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isRead => $composableBuilder(
    column: $table.isRead,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get readAt => $composableBuilder(
    column: $table.readAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get deepLink => $composableBuilder(
    column: $table.deepLink,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$CachedNotificationsTableOrderingComposer
    extends Composer<_$AppDatabase, $CachedNotificationsTable> {
  $$CachedNotificationsTableOrderingComposer({
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

  ColumnOrderings<String> get targetParentId => $composableBuilder(
    column: $table.targetParentId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get body => $composableBuilder(
    column: $table.body,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isRead => $composableBuilder(
    column: $table.isRead,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get readAt => $composableBuilder(
    column: $table.readAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get deepLink => $composableBuilder(
    column: $table.deepLink,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CachedNotificationsTableAnnotationComposer
    extends Composer<_$AppDatabase, $CachedNotificationsTable> {
  $$CachedNotificationsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get targetParentId => $composableBuilder(
    column: $table.targetParentId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get body =>
      $composableBuilder(column: $table.body, builder: (column) => column);

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<bool> get isRead =>
      $composableBuilder(column: $table.isRead, builder: (column) => column);

  GeneratedColumn<String> get readAt =>
      $composableBuilder(column: $table.readAt, builder: (column) => column);

  GeneratedColumn<String> get deepLink =>
      $composableBuilder(column: $table.deepLink, builder: (column) => column);

  GeneratedColumn<String> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$CachedNotificationsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CachedNotificationsTable,
          CachedNotification,
          $$CachedNotificationsTableFilterComposer,
          $$CachedNotificationsTableOrderingComposer,
          $$CachedNotificationsTableAnnotationComposer,
          $$CachedNotificationsTableCreateCompanionBuilder,
          $$CachedNotificationsTableUpdateCompanionBuilder,
          (
            CachedNotification,
            BaseReferences<
              _$AppDatabase,
              $CachedNotificationsTable,
              CachedNotification
            >,
          ),
          CachedNotification,
          PrefetchHooks Function()
        > {
  $$CachedNotificationsTableTableManager(
    _$AppDatabase db,
    $CachedNotificationsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CachedNotificationsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CachedNotificationsTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$CachedNotificationsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> targetParentId = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String> body = const Value.absent(),
                Value<String> type = const Value.absent(),
                Value<bool> isRead = const Value.absent(),
                Value<String?> readAt = const Value.absent(),
                Value<String?> deepLink = const Value.absent(),
                Value<String> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CachedNotificationsCompanion(
                id: id,
                targetParentId: targetParentId,
                title: title,
                body: body,
                type: type,
                isRead: isRead,
                readAt: readAt,
                deepLink: deepLink,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String targetParentId,
                Value<String> title = const Value.absent(),
                Value<String> body = const Value.absent(),
                Value<String> type = const Value.absent(),
                Value<bool> isRead = const Value.absent(),
                Value<String?> readAt = const Value.absent(),
                Value<String?> deepLink = const Value.absent(),
                required String createdAt,
                Value<int> rowid = const Value.absent(),
              }) => CachedNotificationsCompanion.insert(
                id: id,
                targetParentId: targetParentId,
                title: title,
                body: body,
                type: type,
                isRead: isRead,
                readAt: readAt,
                deepLink: deepLink,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$CachedNotificationsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CachedNotificationsTable,
      CachedNotification,
      $$CachedNotificationsTableFilterComposer,
      $$CachedNotificationsTableOrderingComposer,
      $$CachedNotificationsTableAnnotationComposer,
      $$CachedNotificationsTableCreateCompanionBuilder,
      $$CachedNotificationsTableUpdateCompanionBuilder,
      (
        CachedNotification,
        BaseReferences<
          _$AppDatabase,
          $CachedNotificationsTable,
          CachedNotification
        >,
      ),
      CachedNotification,
      PrefetchHooks Function()
    >;
typedef $$GeofenceLogsTableCreateCompanionBuilder =
    GeofenceLogsCompanion Function({
      required String id,
      required String studentId,
      required double lat,
      required double lng,
      required double accuracy,
      Value<String> eventType,
      required String timestamp,
      Value<bool> synced,
      Value<int> rowid,
    });
typedef $$GeofenceLogsTableUpdateCompanionBuilder =
    GeofenceLogsCompanion Function({
      Value<String> id,
      Value<String> studentId,
      Value<double> lat,
      Value<double> lng,
      Value<double> accuracy,
      Value<String> eventType,
      Value<String> timestamp,
      Value<bool> synced,
      Value<int> rowid,
    });

class $$GeofenceLogsTableFilterComposer
    extends Composer<_$AppDatabase, $GeofenceLogsTable> {
  $$GeofenceLogsTableFilterComposer({
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

  ColumnFilters<String> get studentId => $composableBuilder(
    column: $table.studentId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get lat => $composableBuilder(
    column: $table.lat,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get lng => $composableBuilder(
    column: $table.lng,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get accuracy => $composableBuilder(
    column: $table.accuracy,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get eventType => $composableBuilder(
    column: $table.eventType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get timestamp => $composableBuilder(
    column: $table.timestamp,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get synced => $composableBuilder(
    column: $table.synced,
    builder: (column) => ColumnFilters(column),
  );
}

class $$GeofenceLogsTableOrderingComposer
    extends Composer<_$AppDatabase, $GeofenceLogsTable> {
  $$GeofenceLogsTableOrderingComposer({
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

  ColumnOrderings<String> get studentId => $composableBuilder(
    column: $table.studentId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get lat => $composableBuilder(
    column: $table.lat,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get lng => $composableBuilder(
    column: $table.lng,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get accuracy => $composableBuilder(
    column: $table.accuracy,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get eventType => $composableBuilder(
    column: $table.eventType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get timestamp => $composableBuilder(
    column: $table.timestamp,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get synced => $composableBuilder(
    column: $table.synced,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$GeofenceLogsTableAnnotationComposer
    extends Composer<_$AppDatabase, $GeofenceLogsTable> {
  $$GeofenceLogsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get studentId =>
      $composableBuilder(column: $table.studentId, builder: (column) => column);

  GeneratedColumn<double> get lat =>
      $composableBuilder(column: $table.lat, builder: (column) => column);

  GeneratedColumn<double> get lng =>
      $composableBuilder(column: $table.lng, builder: (column) => column);

  GeneratedColumn<double> get accuracy =>
      $composableBuilder(column: $table.accuracy, builder: (column) => column);

  GeneratedColumn<String> get eventType =>
      $composableBuilder(column: $table.eventType, builder: (column) => column);

  GeneratedColumn<String> get timestamp =>
      $composableBuilder(column: $table.timestamp, builder: (column) => column);

  GeneratedColumn<bool> get synced =>
      $composableBuilder(column: $table.synced, builder: (column) => column);
}

class $$GeofenceLogsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $GeofenceLogsTable,
          GeofenceLog,
          $$GeofenceLogsTableFilterComposer,
          $$GeofenceLogsTableOrderingComposer,
          $$GeofenceLogsTableAnnotationComposer,
          $$GeofenceLogsTableCreateCompanionBuilder,
          $$GeofenceLogsTableUpdateCompanionBuilder,
          (
            GeofenceLog,
            BaseReferences<_$AppDatabase, $GeofenceLogsTable, GeofenceLog>,
          ),
          GeofenceLog,
          PrefetchHooks Function()
        > {
  $$GeofenceLogsTableTableManager(_$AppDatabase db, $GeofenceLogsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$GeofenceLogsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$GeofenceLogsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$GeofenceLogsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> studentId = const Value.absent(),
                Value<double> lat = const Value.absent(),
                Value<double> lng = const Value.absent(),
                Value<double> accuracy = const Value.absent(),
                Value<String> eventType = const Value.absent(),
                Value<String> timestamp = const Value.absent(),
                Value<bool> synced = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => GeofenceLogsCompanion(
                id: id,
                studentId: studentId,
                lat: lat,
                lng: lng,
                accuracy: accuracy,
                eventType: eventType,
                timestamp: timestamp,
                synced: synced,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String studentId,
                required double lat,
                required double lng,
                required double accuracy,
                Value<String> eventType = const Value.absent(),
                required String timestamp,
                Value<bool> synced = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => GeofenceLogsCompanion.insert(
                id: id,
                studentId: studentId,
                lat: lat,
                lng: lng,
                accuracy: accuracy,
                eventType: eventType,
                timestamp: timestamp,
                synced: synced,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$GeofenceLogsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $GeofenceLogsTable,
      GeofenceLog,
      $$GeofenceLogsTableFilterComposer,
      $$GeofenceLogsTableOrderingComposer,
      $$GeofenceLogsTableAnnotationComposer,
      $$GeofenceLogsTableCreateCompanionBuilder,
      $$GeofenceLogsTableUpdateCompanionBuilder,
      (
        GeofenceLog,
        BaseReferences<_$AppDatabase, $GeofenceLogsTable, GeofenceLog>,
      ),
      GeofenceLog,
      PrefetchHooks Function()
    >;
typedef $$CachedPlansTableCreateCompanionBuilder =
    CachedPlansCompanion Function({
      required String id,
      required String name,
      required double price,
      Value<int> durationMonths,
      Value<String> durationType,
      Value<bool> isActive,
      Value<int> rowid,
    });
typedef $$CachedPlansTableUpdateCompanionBuilder =
    CachedPlansCompanion Function({
      Value<String> id,
      Value<String> name,
      Value<double> price,
      Value<int> durationMonths,
      Value<String> durationType,
      Value<bool> isActive,
      Value<int> rowid,
    });

class $$CachedPlansTableFilterComposer
    extends Composer<_$AppDatabase, $CachedPlansTable> {
  $$CachedPlansTableFilterComposer({
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

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get price => $composableBuilder(
    column: $table.price,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get durationMonths => $composableBuilder(
    column: $table.durationMonths,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get durationType => $composableBuilder(
    column: $table.durationType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isActive => $composableBuilder(
    column: $table.isActive,
    builder: (column) => ColumnFilters(column),
  );
}

class $$CachedPlansTableOrderingComposer
    extends Composer<_$AppDatabase, $CachedPlansTable> {
  $$CachedPlansTableOrderingComposer({
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

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get price => $composableBuilder(
    column: $table.price,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get durationMonths => $composableBuilder(
    column: $table.durationMonths,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get durationType => $composableBuilder(
    column: $table.durationType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isActive => $composableBuilder(
    column: $table.isActive,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CachedPlansTableAnnotationComposer
    extends Composer<_$AppDatabase, $CachedPlansTable> {
  $$CachedPlansTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<double> get price =>
      $composableBuilder(column: $table.price, builder: (column) => column);

  GeneratedColumn<int> get durationMonths => $composableBuilder(
    column: $table.durationMonths,
    builder: (column) => column,
  );

  GeneratedColumn<String> get durationType => $composableBuilder(
    column: $table.durationType,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isActive =>
      $composableBuilder(column: $table.isActive, builder: (column) => column);
}

class $$CachedPlansTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CachedPlansTable,
          CachedPlan,
          $$CachedPlansTableFilterComposer,
          $$CachedPlansTableOrderingComposer,
          $$CachedPlansTableAnnotationComposer,
          $$CachedPlansTableCreateCompanionBuilder,
          $$CachedPlansTableUpdateCompanionBuilder,
          (
            CachedPlan,
            BaseReferences<_$AppDatabase, $CachedPlansTable, CachedPlan>,
          ),
          CachedPlan,
          PrefetchHooks Function()
        > {
  $$CachedPlansTableTableManager(_$AppDatabase db, $CachedPlansTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CachedPlansTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CachedPlansTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CachedPlansTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<double> price = const Value.absent(),
                Value<int> durationMonths = const Value.absent(),
                Value<String> durationType = const Value.absent(),
                Value<bool> isActive = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CachedPlansCompanion(
                id: id,
                name: name,
                price: price,
                durationMonths: durationMonths,
                durationType: durationType,
                isActive: isActive,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String name,
                required double price,
                Value<int> durationMonths = const Value.absent(),
                Value<String> durationType = const Value.absent(),
                Value<bool> isActive = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CachedPlansCompanion.insert(
                id: id,
                name: name,
                price: price,
                durationMonths: durationMonths,
                durationType: durationType,
                isActive: isActive,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$CachedPlansTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CachedPlansTable,
      CachedPlan,
      $$CachedPlansTableFilterComposer,
      $$CachedPlansTableOrderingComposer,
      $$CachedPlansTableAnnotationComposer,
      $$CachedPlansTableCreateCompanionBuilder,
      $$CachedPlansTableUpdateCompanionBuilder,
      (
        CachedPlan,
        BaseReferences<_$AppDatabase, $CachedPlansTable, CachedPlan>,
      ),
      CachedPlan,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$CachedSchedulesTableTableManager get cachedSchedules =>
      $$CachedSchedulesTableTableManager(_db, _db.cachedSchedules);
  $$CachedAttendanceTableTableManager get cachedAttendance =>
      $$CachedAttendanceTableTableManager(_db, _db.cachedAttendance);
  $$CachedNotificationsTableTableManager get cachedNotifications =>
      $$CachedNotificationsTableTableManager(_db, _db.cachedNotifications);
  $$GeofenceLogsTableTableManager get geofenceLogs =>
      $$GeofenceLogsTableTableManager(_db, _db.geofenceLogs);
  $$CachedPlansTableTableManager get cachedPlans =>
      $$CachedPlansTableTableManager(_db, _db.cachedPlans);
}
