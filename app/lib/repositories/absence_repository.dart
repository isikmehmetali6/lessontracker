import 'package:sqflite/sqflite.dart';
import '../core/database/database_helper.dart';
import '../services/auto_sync_service.dart';

/// Singleton — preserves `_absencesInMemory`, this repo's in-memory web
/// fallback cache, across call sites (bkz. 4a.3, docs/REFACTORING_PLAN.md).
class AbsenceRepository {
  static final AbsenceRepository _instance = AbsenceRepository._internal();
  factory AbsenceRepository() => _instance;
  AbsenceRepository._internal() {
    DatabaseHelper().registerWebCacheClear(() {
      _absencesInMemory.clear();
    });
  }

  final DatabaseHelper _dbHelper = DatabaseHelper();
  final List<Map<String, dynamic>> _absencesInMemory = [];

  Future<List<DateTime>> getAbsencesByCourse(String courseId) async {
    if (_dbHelper.isWeb) {
      return _absencesInMemory
          .where((a) => a['courseId'] == courseId)
          .map((a) => a['date'] as DateTime)
          .toList()
        ..sort((a, b) => b.compareTo(a));
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

  Future<void> insertAbsence(
    String id,
    String courseId,
    DateTime date, {
    String reason = 'unexcused',
  }) async {
    if (_dbHelper.isWeb) {
      _absencesInMemory.add({
        'id': id,
        'courseId': courseId,
        'date': date,
        'reason': reason,
      });
      return;
    }
    final db = await _dbHelper.database;
    await db.insert('absences', {
      'id': id,
      'courseId': courseId,
      'date': date.toIso8601String(),
      'reason': reason,
    }, conflictAlgorithm: ConflictAlgorithm.replace);
    AutoSyncService().triggerBackup();
  }

  Future<void> deleteLastAbsence(String courseId) async {
    if (_dbHelper.isWeb) {
      final courseAbsences = _absencesInMemory
          .where((a) => a['courseId'] == courseId)
          .toList();
      if (courseAbsences.isNotEmpty) {
        courseAbsences.sort(
          (a, b) => (b['date'] as DateTime).compareTo(a['date'] as DateTime),
        );
        _absencesInMemory.remove(courseAbsences.first);
      }
      return;
    }
    final db = await _dbHelper.database;
    await db.transaction((txn) async {
      final maps = await txn.query(
        'absences',
        where: 'courseId = ?',
        whereArgs: [courseId],
        orderBy: 'date DESC',
        limit: 1,
      );
      if (maps.isNotEmpty) {
        final id = maps.first['id'] as String;
        await txn.delete('absences', where: 'id = ?', whereArgs: [id]);
      }
    });
  }

  Future<List<Map<String, dynamic>>> getAbsencesWithReasonByCourse(
    String courseId,
  ) async {
    if (_dbHelper.isWeb) {
      return _absencesInMemory.where((a) => a['courseId'] == courseId).toList()
        ..sort((a, b) => (b['date'] as String).compareTo(a['date'] as String));
    }
    final db = await _dbHelper.database;
    return db.query(
      'absences',
      where: 'courseId = ?',
      whereArgs: [courseId],
      orderBy: 'date DESC',
    );
  }

  Future<int> getCount() async {
    if (_dbHelper.isWeb) return _absencesInMemory.length;
    final db = await _dbHelper.database;
    final result = await db.rawQuery('SELECT COUNT(*) FROM absences');
    return Sqflite.firstIntValue(result) ?? 0;
  }

  Future<Map<String, List<DateTime>>> getAllAbsences() async {
    if (_dbHelper.isWeb) {
      final Map<String, List<DateTime>> result = {};
      for (var a in _absencesInMemory) {
        final courseId = a['courseId'] as String;
        final date = a['date'] as DateTime;
        result.putIfAbsent(courseId, () => []).add(date);
      }
      for (var list in result.values) {
        list.sort((a, b) => b.compareTo(a));
      }
      return result;
    }
    final db = await _dbHelper.database;
    final maps = await db.query(
      'absences',
      columns: ['courseId', 'date'],
      orderBy: 'date DESC',
    );
    final Map<String, List<DateTime>> result = {};
    for (var map in maps) {
      final courseId = map['courseId'] as String;
      final date = DateTime.parse(map['date'] as String);
      result.putIfAbsent(courseId, () => []).add(date);
    }
    return result;
  }

  Future<void> deleteAbsence(String id) async {
    if (_dbHelper.isWeb) {
      _absencesInMemory.removeWhere((a) => a['id'] == id);
      return;
    }
    final db = await _dbHelper.database;
    await db.delete('absences', where: 'id = ?', whereArgs: [id]);
    AutoSyncService().triggerBackup();
  }

  Future<void> updateAbsenceReason(String id, String reason) async {
    if (_dbHelper.isWeb) {
      final idx = _absencesInMemory.indexWhere((a) => a['id'] == id);
      if (idx != -1) {
        _absencesInMemory[idx] = {..._absencesInMemory[idx], 'reason': reason};
      }
      return;
    }
    final db = await _dbHelper.database;
    await db.update(
      'absences',
      {'reason': reason},
      where: 'id = ?',
      whereArgs: [id],
    );
    AutoSyncService().triggerBackup();
  }
}
