import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';
import '../core/database/database_helper.dart';
import '../core/services/auto_sync_service.dart';
import '../core/services/sync_service.dart';
import '../models/course.dart';

class CourseRepository {
  static final CourseRepository _instance = CourseRepository._internal();
  factory CourseRepository() => _instance;
  CourseRepository._internal() {
    DatabaseHelper().registerWebCacheClear(() {
      _coursesInMemory.clear();
    });
  }

  final DatabaseHelper _dbHelper = DatabaseHelper();
  final List<Course> _coursesInMemory = [];

  // ==================== DERS İŞLEMLERİ ====================

  /// Tüm dersleri getir (paginated)
  Future<List<Course>> getAllCourses({int limit = 50, int offset = 0}) async {
    if (_dbHelper.isWeb) {
      final start = offset.clamp(0, _coursesInMemory.length);
      final end = (offset + limit).clamp(0, _coursesInMemory.length);
      return List<Course>.from(_coursesInMemory).sublist(start, end);
    }
    final db = await _dbHelper.database;
    final maps = await db.query(
      'courses',
      orderBy: 'createdAt DESC',
      limit: limit,
      offset: offset,
    );
    return maps.map((map) => Course.fromMap(map)).toList();
  }

  /// Aktif dersleri getir
  Future<List<Course>> getActiveCourses() async {
    if (_dbHelper.isWeb) {
      return _coursesInMemory.where((c) => c.status == 'active').toList();
    }
    final db = await _dbHelper.database;
    final maps = await db.query(
      'courses',
      where: 'status = ?',
      whereArgs: ['active'],
      orderBy: 'name ASC',
    );
    return maps.map((map) => Course.fromMap(map)).toList();
  }

  /// Bugünkü dersleri getir
  Future<List<Course>> getTodayCourses() async {
    final courses = await getActiveCourses();
    return courses.where((c) => c.isScheduledToday).toList();
  }

  /// Öncelikli dersleri getir (sınavı yaklaşan veya geride kalan)
  Future<List<Course>> getPriorityCourses() async {
    final courses = await getActiveCourses();
    return courses.where((c) => c.hasUpcomingExam || c.isBehind).toList();
  }

  /// Ders ekle
  Future<void> insertCourse(Course course) async {
    if (_dbHelper.isWeb) {
      _coursesInMemory.removeWhere((c) => c.id == course.id);
      _coursesInMemory.add(course);
      return;
    }
    final db = await _dbHelper.database;
    await db.insert('courses', {
      ...course.toMap(),
      'updatedAt': DateTime.now().toIso8601String(),
    }, conflictAlgorithm: ConflictAlgorithm.replace);
    AutoSyncService().triggerBackup();
  }

  /// Ders güncelle
  Future<void> updateCourse(Course course) async {
    if (_dbHelper.isWeb) {
      final index = _coursesInMemory.indexWhere((c) => c.id == course.id);
      if (index != -1) {
        _coursesInMemory[index] = course;
      }
      return;
    }
    final db = await _dbHelper.database;
    await db.update(
      'courses',
      {...course.toMap(), 'updatedAt': DateTime.now().toIso8601String()},
      where: 'id = ?',
      whereArgs: [course.id],
    );
    AutoSyncService().triggerBackup();
  }

  Future<void> deleteCourse(String id) async {
    if (_dbHelper.isWeb) {
      _coursesInMemory.removeWhere((c) => c.id == id);
      try {
        final syncService = SyncService();
        await syncService.deleteCourseCloud(id);
      } catch (e) {
        debugPrint('Error deleting course $id from cloud: $e');
      }
      return;
    }
    final db = await _dbHelper.database;
    await db.delete('courses', where: 'id = ?', whereArgs: [id]);
    AutoSyncService().triggerBackup();
  }

  /// Ders getir
  Future<Course?> getCourseById(String id) async {
    if (_dbHelper.isWeb) {
      try {
        return _coursesInMemory.firstWhere((c) => c.id == id);
      } catch (e, stackTrace) {
        debugPrint(
          'Error finding course $id in memory: $e\nStack: $stackTrace',
        );
        return null;
      }
    }
    final db = await _dbHelper.database;
    final maps = await db.query(
      'courses',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (maps.isEmpty) return null;
    return Course.fromMap(maps.first);
  }

  Future<int> getCourseCount() async {
    if (_dbHelper.isWeb) {
      return _coursesInMemory.length;
    }
    final db = await _dbHelper.database;
    final result = await db.rawQuery('SELECT COUNT(*) as count FROM courses');
    return Sqflite.firstIntValue(result) ?? 0;
  }
}
