import 'package:sqflite/sqflite.dart';
import '../core/database/database_helper.dart';
import '../core/services/auto_sync_service.dart';
import '../models/grade.dart';

class GradeRepository {
  static final GradeRepository _instance = GradeRepository._internal();
  factory GradeRepository() => _instance;
  GradeRepository._internal() {
    DatabaseHelper().registerWebCacheClear(() {
      _gradesInMemory.clear();
    });
  }

  final DatabaseHelper _dbHelper = DatabaseHelper();
  final List<Grade> _gradesInMemory = [];

  // ==================== NOT (PUAN) İŞLEMLERİ ====================

  /// Derse göre notları (puanları) getir
  Future<List<Grade>> getGradesByCourse(String courseId) async {
    if (_dbHelper.isWeb) {
      return _gradesInMemory
          .where((g) => g.courseId == courseId)
          .toList()
        ..sort((a, b) => a.createdAt.compareTo(b.createdAt));
    }
    final db = await _dbHelper.database;
    final maps = await db.query(
      'grades',
      where: 'courseId = ?',
      whereArgs: [courseId],
      orderBy: 'createdAt ASC',
    );
    return maps.map((map) => Grade.fromMap(map)).toList();
  }

  /// Puan ekle
  Future<void> insertGrade(Grade grade) async {
    if (_dbHelper.isWeb) {
      _gradesInMemory.removeWhere((g) => g.id == grade.id);
      _gradesInMemory.add(grade);
      return;
    }
    final db = await _dbHelper.database;
    await db.insert(
      'grades',
      grade.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    AutoSyncService().triggerBackup();
  }

  /// Puan sil
  Future<void> deleteGrade(String id) async {
    if (_dbHelper.isWeb) {
      _gradesInMemory.removeWhere((g) => g.id == id);
      return;
    }
    final db = await _dbHelper.database;
    await db.delete(
      'grades',
      where: 'id = ?',
      whereArgs: [id],
    );
    AutoSyncService().triggerBackup();
  }

  /// Puan güncelle
  Future<void> updateGrade(Grade grade) async {
    if (_dbHelper.isWeb) {
      final index = _gradesInMemory.indexWhere((g) => g.id == grade.id);
      if (index != -1) {
        _gradesInMemory[index] = grade;
      }
      return;
    }
    final db = await _dbHelper.database;
    await db.update(
      'grades',
      grade.toMap(),
      where: 'id = ?',
      whereArgs: [grade.id],
    );
    AutoSyncService().triggerBackup();
  }

  Future<int> getCount() async {
    if (_dbHelper.isWeb) {
      return _gradesInMemory.length;
    }
    final db = await _dbHelper.database;
    final result = await db.rawQuery('SELECT COUNT(*) FROM grades');
    return Sqflite.firstIntValue(result) ?? 0;
  }
}
