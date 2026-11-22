import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';
import '../core/database/database_helper.dart';
import '../services/auto_sync_service.dart';
import '../services/e2e_file_service.dart';
import '../services/e2e_key_service.dart';
import '../services/e2e_upload_service.dart';
import '../models/course_file.dart';

/// Singleton — preserves `_filesInMemory`, this repo's in-memory web
/// fallback cache, across call sites (bkz. 4a.3, docs/REFACTORING_PLAN.md).
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
      return _filesInMemory.where((f) => f.courseId == courseId).toList()
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
      _filesInMemory.removeWhere((f) => f.id == file.id);
      _filesInMemory.add(file);
      return;
    }
    final db = await _dbHelper.database;
    await db.insert(
      'course_files',
      file.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    AutoSyncService().triggerBackup();
  }

  /// Dosya ekle (E2E yükleme ile)
  Future<void> insertFileWithUpload(CourseFile file, File localFile) async {
    String? cloudPath;

    if (await E2EKeyService().isE2EEnabled()) {
      try {
        final uploadService = E2EUploadService();
        cloudPath = await uploadService.uploadCourseFile(localFile);
        debugPrint('Course file uploaded to cloud: $cloudPath');
      } catch (e) {
        debugPrint('E2E upload error: $e');
      }
    }

    await insertFile(file.copyWith(cloudPath: cloudPath));
  }

  /// Yedekleme için tüm dosyalar.
  Future<List<CourseFile>> getAllFilesForSync() async {
    if (_dbHelper.isWeb) return List<CourseFile>.from(_filesInMemory);
    final db = await _dbHelper.database;
    final maps = await db.query('course_files', orderBy: 'createdAt DESC');
    return maps.map((map) => CourseFile.fromMap(map)).toList();
  }

  /// Bulut yolunu yazar. **Backup tetiklemez** (backup içinden çağrılır).
  Future<void> updateCloudPath(String fileId, String cloudPath) async {
    if (_dbHelper.isWeb) return;
    final db = await _dbHelper.database;
    await db.update(
      'course_files',
      {'cloudPath': cloudPath},
      where: 'id = ?',
      whereArgs: [fileId],
    );
  }

  /// Dosyayı cloud'dan indir
  Future<Uint8List?> downloadFile(String cloudPath) async {
    try {
      final e2eService = E2EFileService();
      return await e2eService.downloadDocument(cloudPath);
    } catch (e) {
      debugPrint('Error downloading file: $e');
      return null;
    }
  }

  /// Dosya sil (cloud dosyası silme kuyruğu üzerinden temizlenir).
  Future<void> deleteFileWithCloud(String id) => deleteFile(id);

  /// Dosya sil — buluttaki kayıt ve şifreli dosya silme kuyruğuyla temizlenir.
  Future<void> deleteFile(String id) async {
    if (_dbHelper.isWeb) {
      _filesInMemory.removeWhere((f) => f.id == id);
      return;
    }
    final db = await _dbHelper.database;
    final rows = await db.query(
      'course_files',
      columns: ['cloudPath'],
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    await db.delete('course_files', where: 'id = ?', whereArgs: [id]);
    if (rows.isNotEmpty) {
      await AutoSyncService().recordPendingChange(
        'course_files',
        id,
        'delete',
        payload: {'cloudPath': rows.first['cloudPath']},
      );
    }
    AutoSyncService().triggerBackup();
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
