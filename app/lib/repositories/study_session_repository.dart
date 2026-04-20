import 'package:sqflite/sqflite.dart';
import '../core/database/database_helper.dart';
import '../core/services/auto_sync_service.dart';
import '../models/study_session.dart';

class StudySessionRepository {
  static final StudySessionRepository _instance = StudySessionRepository._internal();
  factory StudySessionRepository() => _instance;
  StudySessionRepository._internal() {
    DatabaseHelper().registerWebCacheClear(() {
      _sessionsInMemory.clear();
    });
  }

  final DatabaseHelper _dbHelper = DatabaseHelper();
  final List<StudySession> _sessionsInMemory = [];

  Future<void> insertStudySession(StudySession session) async {
    if (_dbHelper.isWeb) {
      _sessionsInMemory.removeWhere((s) => s.id == session.id);
      _sessionsInMemory.add(session);
      return;
    }
    final db = await _dbHelper.database;
    await db.insert(
      'study_sessions',
      session.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    AutoSyncService().triggerBackup();
  }

  Future<void> deleteStudySession(String id) async {
    if (_dbHelper.isWeb) {
      _sessionsInMemory.removeWhere((s) => s.id == id);
      return;
    }
    final db = await _dbHelper.database;
    await db.delete('study_sessions', where: 'id = ?', whereArgs: [id]);
    AutoSyncService().triggerBackup();
  }

  Future<List<StudySession>> getAllStudySessions() async {
    if (_dbHelper.isWeb) {
      return List.from(_sessionsInMemory)..sort((a, b) => b.startedAt.compareTo(a.startedAt));
    }
    final db = await _dbHelper.database;
    final maps = await db.query('study_sessions', orderBy: 'startedAt DESC');
    return maps.map((m) => StudySession.fromMap(m)).toList();
  }

  Future<List<StudySession>> getStudySessionsBetween(DateTime start, DateTime end) async {
    if (_dbHelper.isWeb) {
      return _sessionsInMemory
          .where((s) => !s.startedAt.isBefore(start) && !s.startedAt.isAfter(end))
          .toList()
        ..sort((a, b) => b.startedAt.compareTo(a.startedAt));
    }
    final db = await _dbHelper.database;
    final maps = await db.query(
      'study_sessions',
      where: 'startedAt >= ? AND startedAt <= ?',
      whereArgs: [start.toIso8601String(), end.toIso8601String()],
      orderBy: 'startedAt DESC',
    );
    return maps.map((m) => StudySession.fromMap(m)).toList();
  }

  Future<List<StudySession>> getStudySessionsByCourse(String courseId) async {
    if (_dbHelper.isWeb) {
      return _sessionsInMemory
          .where((s) => s.courseId == courseId)
          .toList()
        ..sort((a, b) => b.startedAt.compareTo(a.startedAt));
    }
    final db = await _dbHelper.database;
    final maps = await db.query(
      'study_sessions',
      where: 'courseId = ?',
      whereArgs: [courseId],
      orderBy: 'startedAt DESC',
    );
    return maps.map((m) => StudySession.fromMap(m)).toList();
  }

  Future<int> getTodayStudyMinutes() async {
    if (_dbHelper.isWeb) {
      final today = DateTime.now();
      final startOfDay = DateTime(today.year, today.month, today.day);
      return _sessionsInMemory
          .where((s) => s.sessionType == 'work' && !s.startedAt.isBefore(startOfDay))
          .fold<int>(0, (sum, s) => sum + s.durationMinutes);
    }
    final db = await _dbHelper.database;
    final today = DateTime.now();
    final startOfDay = DateTime(today.year, today.month, today.day);
    final result = await db.rawQuery(
      "SELECT SUM(durationMinutes) as total FROM study_sessions WHERE sessionType = 'work' AND startedAt >= ?",
      [startOfDay.toIso8601String()],
    );
    return (result.first['total'] as int?) ?? 0;
  }

  Future<int> getCount() async {
    if (_dbHelper.isWeb) return _sessionsInMemory.length;
    final db = await _dbHelper.database;
    final result = await db.rawQuery('SELECT COUNT(*) FROM study_sessions');
    return Sqflite.firstIntValue(result) ?? 0;
  }
}
