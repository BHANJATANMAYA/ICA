// GENERATED CODE - Run: flutter pub run build_runner build --delete-conflicting-outputs
// ignore_for_file: type=lint

import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

part 'app_database.g.dart';

// ─────────────────────────────────────────────
// TABLE DEFINITIONS
// ─────────────────────────────────────────────

/// Mirrors Supabase class_schedules table.
/// UUID stored as TEXT (drift has no native UUID type).
class CachedSchedules extends Table {
  TextColumn get id => text()();
  TextColumn get batchId => text().named('batch_id')();
  TextColumn get classDate => text().named('class_date')(); // ISO date string
  TextColumn get startTime => text().named('start_time')();
  TextColumn get endTime => text().named('end_time')();
  TextColumn get status => text().withDefault(const Constant('scheduled'))();
  TextColumn get updatedAt => text().named('updated_at')();

  @override
  Set<Column> get primaryKey => {id};
}

/// Mirrors Supabase attendance_records table with geofence_verified added.
class CachedAttendance extends Table {
  TextColumn get id => text()();
  TextColumn get studentId => text().named('student_id')();
  TextColumn get batchId => text().named('batch_id')();
  TextColumn get classDate => text().named('class_date')(); // ISO date string
  TextColumn get status => text().withDefault(const Constant('present'))();
  BoolColumn get geofenceVerified =>
      boolean().named('geofence_verified').withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}

/// Mirrors Supabase notifications table with FCM-relevant fields.
class CachedNotifications extends Table {
  TextColumn get id => text()();
  TextColumn get targetParentId => text().named('target_parent_id')();
  TextColumn get title => text().withDefault(const Constant(''))();
  TextColumn get body => text().withDefault(const Constant(''))();
  TextColumn get type => text().withDefault(const Constant('general'))();
  BoolColumn get isRead =>
      boolean().named('is_read').withDefault(const Constant(false))();
  TextColumn get readAt => text().named('read_at').nullable()();
  TextColumn get deepLink => text().named('deep_link').nullable()();
  TextColumn get createdAt => text().named('created_at')();

  @override
  Set<Column> get primaryKey => {id};
}

/// Write-first geofence event log. Synced to Supabase when online.
class GeofenceLogs extends Table {
  TextColumn get id => text()();
  TextColumn get studentId => text().named('student_id')();
  RealColumn get lat => real()();
  RealColumn get lng => real()();
  RealColumn get accuracy => real()();
  TextColumn get eventType =>
      text().named('event_type').withDefault(const Constant('enter'))();
  TextColumn get timestamp => text()(); // ISO datetime string
  /// Whether this log has been synced to Supabase geofence_logs table.
  BoolColumn get synced =>
      boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}

/// Mirrors Supabase plans table for offline billing display.
class CachedPlans extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  RealColumn get price => real()();
  IntColumn get durationMonths =>
      integer().named('duration_months').withDefault(const Constant(1))();
  TextColumn get durationType =>
      text().named('duration_type').withDefault(const Constant('monthly'))();
  BoolColumn get isActive =>
      boolean().named('is_active').withDefault(const Constant(true))();

  @override
  Set<Column> get primaryKey => {id};
}

// ─────────────────────────────────────────────
// DATABASE
// ─────────────────────────────────────────────

@DriftDatabase(tables: [
  CachedSchedules,
  CachedAttendance,
  CachedNotifications,
  GeofenceLogs,
  CachedPlans,
])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (Migrator m) async {
          await m.createAll();
        },
      );

  // ─── CachedSchedules ───

  Future<List<CachedSchedule>> getAllSchedules() =>
      select(cachedSchedules).get();

  Future<void> upsertSchedule(CachedSchedulesCompanion entry) =>
      into(cachedSchedules).insertOnConflictUpdate(entry);

  Future<void> upsertSchedules(List<CachedSchedulesCompanion> entries) =>
      batch((b) => b.insertAllOnConflictUpdate(cachedSchedules, entries));

  // ─── CachedAttendance ───

  Future<List<CachedAttendanceData>> getAttendanceForStudent(
          String studentId) =>
      (select(cachedAttendance)
            ..where((t) => t.studentId.equals(studentId)))
          .get();

  Future<void> upsertAttendance(CachedAttendanceCompanion entry) =>
      into(cachedAttendance).insertOnConflictUpdate(entry);

  // ─── CachedNotifications ───

  Future<List<CachedNotification>> getNotificationsForParent(
          String parentId) =>
      (select(cachedNotifications)
            ..where((t) => t.targetParentId.equals(parentId))
            ..orderBy([(t) => OrderingTerm.desc(t.createdAt)]))
          .get();

  Future<int> getUnreadCountForParent(String parentId) async {
    final result = await (select(cachedNotifications)
          ..where((t) =>
              t.targetParentId.equals(parentId) & t.isRead.equals(false)))
        .get();
    return result.length;
  }

  Future<void> upsertNotification(CachedNotificationsCompanion entry) =>
      into(cachedNotifications).insertOnConflictUpdate(entry);

  Future<void> upsertNotifications(
          List<CachedNotificationsCompanion> entries) =>
      batch((b) => b.insertAllOnConflictUpdate(cachedNotifications, entries));

  Future<void> markNotificationRead(String id) =>
      (update(cachedNotifications)..where((t) => t.id.equals(id))).write(
        CachedNotificationsCompanion(
          isRead: const Value(true),
          readAt: Value(DateTime.now().toIso8601String()),
        ),
      );

  Future<void> markAllNotificationsRead(String parentId) =>
      (update(cachedNotifications)
            ..where((t) => t.targetParentId.equals(parentId)))
          .write(
        CachedNotificationsCompanion(
          isRead: const Value(true),
          readAt: Value(DateTime.now().toIso8601String()),
        ),
      );

  // ─── GeofenceLogs ───

  Future<void> insertGeofenceLog(GeofenceLogsCompanion entry) =>
      into(geofenceLogs).insert(entry);

  Future<List<GeofenceLog>> getUnsyncedGeofenceLogs() =>
      (select(geofenceLogs)..where((t) => t.synced.equals(false))).get();

  Future<void> markGeofenceLogSynced(String id) =>
      (update(geofenceLogs)..where((t) => t.id.equals(id))).write(
        const GeofenceLogsCompanion(synced: Value(true)),
      );

  // ─── CachedPlans ───

  Future<List<CachedPlan>> getAllPlans() => select(cachedPlans).get();

  Future<void> upsertPlans(List<CachedPlansCompanion> entries) =>
      batch((b) => b.insertAllOnConflictUpdate(cachedPlans, entries));
}

// ─────────────────────────────────────────────
// DATABASE CONNECTION
// ─────────────────────────────────────────────

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'ica_cache.sqlite'));
    return NativeDatabase.createInBackground(file);
  });
}
