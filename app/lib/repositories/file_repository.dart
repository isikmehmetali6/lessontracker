import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';
import '../core/database/database_helper.dart';
import '../core/services/auto_sync_service.dart';
import '../core/services/e2e_file_service.dart';
import '../core/services/e2e_key_service.dart';
import '../core/services/image_compressor_service.dart';
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
        final e2eService = E2EFileService();
        cloudPath = await _uploadFileToCloud(localFile, file.type, e2eService);
        debugPrint('Course file uploaded to cloud: $cloudPath');
      } catch (e) {
        debugPrint('E2E upload error: $e');
      }
    }

    final fileWithCloudPath = CourseFile(
      id: file.id,
      courseId: file.courseId,
      path: file.path,
      name: file.name,
      type: file.type,
      createdAt: file.createdAt,
      url: file.url,
      cloudPath: cloudPath,
    );

    await insertFile(fileWithCloudPath);

    if (cloudPath != null) {
      await _updateFileCloudPath(file.id, cloudPath);
    }
  }

  Future<String> _uploadFileToCloud(
    File file,
    String type,
    E2EFileService e2eService,
  ) async {
    final extension = file.path.toLowerCase();
    if (extension.contains('.jpg') ||
        extension.contains('.jpeg') ||
        extension.contains('.png') ||
        extension.contains('.heic')) {
      final compressor = ImageCompressorService();
      final compressedBytes = await compressor.compressAndGetBytes(file.path);
      if (compressedBytes != null) {
        final tempPath = '${file.path}_compressed.jpg';
        final tempFile = File(tempPath);
        await tempFile.writeAsBytes(compressedBytes);
        final cloudPath = await e2eService.uploadPhoto(tempFile);
        await tempFile.delete();
        return cloudPath;
      }
    }
    return await e2eService.uploadDocument(file);
  }

  Future<void> _updateFileCloudPath(String fileId, String cloudPath) async {
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

  /// Dosya sil (cloud dosyasını da siler)
  Future<void> deleteFileWithCloud(String id) async {
    final cloudPath = await _getFileCloudPath(id);
    if (cloudPath != null) {
      try {
        final e2eService = E2EFileService();
        await e2eService.deleteFile(cloudPath);
      } catch (e) {
        debugPrint('Error deleting cloud file: $e');
      }
    }
    await deleteFile(id);
  }

  Future<String?> _getFileCloudPath(String fileId) async {
    if (_dbHelper.isWeb) return null;
    final db = await _dbHelper.database;
    final result = await db.query(
      'course_files',
      columns: ['cloudPath'],
      where: 'id = ?',
      whereArgs: [fileId],
      limit: 1,
    );
    if (result.isNotEmpty && result.first['cloudPath'] != null) {
      return result.first['cloudPath'] as String;
    }
    return null;
  }

  /// Dosya sil
  Future<void> deleteFile(String id) async {
    if (_dbHelper.isWeb) {
      _filesInMemory.removeWhere((f) => f.id == id);
      return;
    }
    final db = await _dbHelper.database;
    await db.delete('course_files', where: 'id = ?', whereArgs: [id]);
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
