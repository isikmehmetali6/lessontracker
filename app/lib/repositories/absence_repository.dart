import 'package:sqflite/sqflite.dart';
import '../core/database/database_helper.dart';

class AbsenceRepository {
  static final AbsenceRepository _instance = AbsenceRepository._internal();
  factory AbsenceRepository() => _instance;
  AbsenceRepository._internal();

  final DatabaseHelper _dbHelper = DatabaseHelper();

  // ==================== DEVAMSIZLIK İŞLEMLERİ ====================

  /// Devamsızlıkları getir
  Future<List<DateTime>> getAbsencesByCourse(String courseId) async {
    if (_dbHelper.isWeb) {
       // In-memory web fallback is omitted.
      return [];
    }
    final db = await _dbHelper.database;
    final maps = await db.query(
      'absences',
      columns: ['date'],
      where: 'courseId = ?',
      whereArgs: [courseId],
      orderBy: 'date DESC',
    );
    return maps.map((map) => DateTime.parse(map['date'] as String)).toList();
  }

  /// Devamsızlık ekle
  Future<void> insertAbsence(String id, String courseId, DateTime date) async {
    if (_dbHelper.isWeb) return;
    final db = await _dbHelper.database;
    await db.insert(
      'absences',
      {
        'id': id,
        'courseId': courseId,
        'date': date.toIso8601String(),
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Son devamsızlığı sil (En yeniden eskiye doğru)
  Future<void> deleteLastAbsence(String courseId) async {
     if (_dbHelper.isWeb) return;
    final db = await _dbHelper.database;
    // Get the latest one
    final maps = await db.query(
      'absences',
      where: 'courseId = ?',
      whereArgs: [courseId],
      orderBy: 'date DESC',
      limit: 1,
    );
    
    if (maps.isNotEmpty) {
      final id = maps.first['id'] as String;
      await db.delete(
        'absences',
        where: 'id = ?',
        whereArgs: [id],
      );
    }
  }

  Future<int> getCount() async {
    if (_dbHelper.isWeb) return 0;
    final db = await _dbHelper.database;
    final result = await db.rawQuery('SELECT COUNT(*) FROM absences');
    return Sqflite.firstIntValue(result) ?? 0;
  }
}
