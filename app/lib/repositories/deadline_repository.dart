import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';
import '../core/database/database_helper.dart';
import '../services/auto_sync_service.dart';
import '../models/deadline.dart';

/// Singleton — preserves `_deadlinesInMemory`, this repo's in-memory web
/// fallback cache, across call sites (bkz. 4a.3, docs/REFACTORING_PLAN.md).
class DeadlineRepository {
  static final DeadlineRepository _instance = DeadlineRepository._internal();
  factory DeadlineRepository() => _instance;
  DeadlineRepository._internal() {
    DatabaseHelper().registerWebCacheClear(() {
      _deadlinesInMemory.clear();
    });
  }

  final DatabaseHelper _dbHelper = DatabaseHelper();
  final List<Deadline> _deadlinesInMemory = [];

  // ==================== DEADLINE İŞLEMLERİ ====================

  /// Tüm deadline'ları getir
  Future<List<Deadline>> getAllDeadlines() async {
    if (_dbHelper.isWeb) {
      return List.from(_deadlinesInMemory)
        ..sort((a, b) => a.date.compareTo(b.date));
    }
    final db = await _dbHelper.database;
    final maps = await db.query('deadlines', orderBy: 'date ASC');
    return maps.map((map) => Deadline.fromMap(map)).toList();
  }

  /// Derse göre deadline'ları getir
  Future<List<Deadline>> getDeadlinesByCourse(String courseId) async {
    if (_dbHelper.isWeb) {
      return _deadlinesInMemory.where((d) => d.courseId == courseId).toList()
        ..sort((a, b) => a.date.compareTo(b.date));
    }
    final db = await _dbHelper.database;
    final maps = await db.query(
      'deadlines',
      where: 'courseId = ?',
      whereArgs: [courseId],
      orderBy: 'date ASC',
    );
    return maps.map((map) => Deadline.fromMap(map)).toList();
  }

  /// Deadline ekle
  Future<void> insertDeadline(Deadline deadline) async {
    if (_dbHelper.isWeb) {
      _deadlinesInMemory.removeWhere((d) => d.id == deadline.id);
      _deadlinesInMemory.add(deadline);
      return;
    }
    final db = await _dbHelper.database;
    await db.insert(
      'deadlines',
      deadline.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    AutoSyncService().triggerBackup();
  }

  /// Deadline sil
  Future<void> deleteDeadline(String id) async {
    if (_dbHelper.isWeb) {
      _deadlinesInMemory.removeWhere((d) => d.id == id);
      return;
    }
    final db = await _dbHelper.database;
    await db.delete('deadlines', where: 'id = ?', whereArgs: [id]);
    AutoSyncService().triggerBackup();
  }

  /// Deadline güncelle
  Future<void> updateDeadline(Deadline deadline) async {
    if (_dbHelper.isWeb) {
      final index = _deadlinesInMemory.indexWhere((d) => d.id == deadline.id);
      if (index != -1) {
        _deadlinesInMemory[index] = deadline;
      }
      return;
    }
    final db = await _dbHelper.database;
    await db.update(
      'deadlines',
      deadline.toMap(),
      where: 'id = ?',
      whereArgs: [deadline.id],
    );
    AutoSyncService().triggerBackup();
  }

  /// Deadline getir
  Future<Deadline?> getDeadlineById(String id) async {
    if (_dbHelper.isWeb) {
      try {
        return _deadlinesInMemory.firstWhere((d) => d.id == id);
      } catch (e, stackTrace) {
        debugPrint(
          'Error finding deadline $id in memory: $e\nStack: $stackTrace',
        );
        return null;
      }
    }
    final db = await _dbHelper.database;
    final maps = await db.query(
      'deadlines',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (maps.isEmpty) return null;
    return Deadline.fromMap(maps.first);
  }

  Future<int> getCount() async {
    if (_dbHelper.isWeb) {
      return _deadlinesInMemory.length;
    }
    final db = await _dbHelper.database;
    final result = await db.rawQuery('SELECT COUNT(*) FROM deadlines');
    return Sqflite.firstIntValue(result) ?? 0;
  }
}
