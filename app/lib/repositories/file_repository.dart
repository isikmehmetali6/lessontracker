import 'package:sqflite/sqflite.dart';
import '../core/database/database_helper.dart';
import '../models/course_file.dart';

class FileRepository {
  static final FileRepository _instance = FileRepository._internal();
  factory FileRepository() => _instance;
  FileRepository._internal() {
    DatabaseHelper().registerWebCacheClear(() {
      _filesInMemory.clear();
    });
  }

  final DatabaseHelper _dbHelper = DatabaseHelper();
  final List<CourseFile> _filesInMemory = [];

  // ==================== DOSYA İŞLEMLERİ ====================

  /// Derse ait dosyaları getir
  Future<List<CourseFile>> getFilesByCourse(String courseId) async {
    if (_dbHelper.isWeb) {
      return _filesInMemory
          .where((f) => f.courseId == courseId)
          .toList()
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    }
    final db = await _dbHelper.database;
    final maps = await db.query(
      'course_files',
      where: 'courseId = ?',
      whereArgs: [courseId],
      orderBy: 'createdAt DESC',
    );
    return maps.map((map) => CourseFile.fromMap(map)).toList();
  }

  /// Dosya ekle
  Future<void> insertFile(CourseFile file) async {
    if (_dbHelper.isWeb) {
      _filesInMemory.add(file);
      return;
    }
    final db = await _dbHelper.database;
    await db.insert(
      'course_files',
      file.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Dosya sil
  Future<void> deleteFile(String id) async {
    if (_dbHelper.isWeb) {
      _filesInMemory.removeWhere((f) => f.id == id);
      return;
    }
    final db = await _dbHelper.database;
    await db.delete(
      'course_files',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> getCount() async {
    if (_dbHelper.isWeb) {
      return _filesInMemory.length;
    }
    final db = await _dbHelper.database;
    final result = await db.rawQuery('SELECT COUNT(*) FROM course_files');
    return Sqflite.firstIntValue(result) ?? 0;
  }
}
