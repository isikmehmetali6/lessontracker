import 'package:sqflite/sqflite.dart';
import '../core/database/database_helper.dart';
import '../models/study_session.dart';

class StudySessionRepository {
  static final StudySessionRepository _instance = StudySessionRepository._internal();
  factory StudySessionRepository() => _instance;
  StudySessionRepository._internal();

  final DatabaseHelper _dbHelper = DatabaseHelper();

  // ==================== STUDY SESSIONS ====================

  /// Çalışma oturumu kaydet
  Future<void> insertStudySession(StudySession session) async {
    if (_dbHelper.isWeb) return;
    final db = await _dbHelper.database;
    await db.insert(
      'study_sessions',
      session.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Tüm çalışma oturumlarını getir
  Future<List<StudySession>> getAllStudySessions() async {
    if (_dbHelper.isWeb) return [];
    final db = await _dbHelper.database;
    final maps = await db.query('study_sessions', orderBy: 'startedAt DESC');
    return maps.map((m) => StudySession.fromMap(m)).toList();
  }

  /// Belirli bir tarih aralığındaki oturumları getir
  Future<List<StudySession>> getStudySessionsBetween(DateTime start, DateTime end) async {
    if (_dbHelper.isWeb) return [];
    final db = await _dbHelper.database;
    final maps = await db.query(
      'study_sessions',
      where: 'startedAt >= ? AND startedAt <= ?',
      whereArgs: [start.toIso8601String(), end.toIso8601String()],
      orderBy: 'startedAt DESC',
    );
    return maps.map((m) => StudySession.fromMap(m)).toList();
  }

  /// Derse göre çalışma oturumlarını getir
  Future<List<StudySession>> getStudySessionsByCourse(String courseId) async {
    if (_dbHelper.isWeb) return [];
    final db = await _dbHelper.database;
    final maps = await db.query(
      'study_sessions',
      where: 'courseId = ?',
      whereArgs: [courseId],
      orderBy: 'startedAt DESC',
    );
    return maps.map((m) => StudySession.fromMap(m)).toList();
  }

  /// Bugünkü toplam çalışma süresi (dakika)
  Future<int> getTodayStudyMinutes() async {
    if (_dbHelper.isWeb) return 0;
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
    if (_dbHelper.isWeb) return 0;
    final db = await _dbHelper.database;
    final result = await db.rawQuery('SELECT COUNT(*) FROM study_sessions');
    return Sqflite.firstIntValue(result) ?? 0;
  }
}
