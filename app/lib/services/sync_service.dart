import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:path/path.dart' as p;
import '../../core/backend/supabase_backend.dart';
import '../../core/database/database_helper.dart';
import '../../repositories/course_repository.dart';
import '../../repositories/note_repository.dart';
import '../../repositories/deadline_repository.dart';
import '../../repositories/grade_repository.dart';
import '../../repositories/file_repository.dart';
import '../../repositories/absence_repository.dart';
import '../../core/utils/absence_change_bus.dart';
import '../../models/course.dart';
import '../../models/note.dart';
import '../../models/deadline.dart';
import '../../models/grade.dart';
import '../../models/course_file.dart';
import '../../repositories/planner_event_repository.dart';
import '../../models/planner_event.dart';
import 'cloud_records_service.dart';
import 'file_service.dart';
import 'e2e_file_service.dart';
import 'e2e_key_service.dart';
import 'e2e_upload_service.dart';
import 'dart:async';
import 'package:path_provider/path_provider.dart';
import 'sync_encryption.dart';
import 'sync_batch_utils.dart';

/// Tek bir upsert isteğinde gönderilen en fazla kayıt sayısı
const int _kBatchChunkSize = kSyncBatchChunkSize;

Future<T> _withRetry<T>(
  Future<T> Function() operation,
  int maxAttempts,
) =>
    withSyncRetry(operation, maxAttempts: maxAttempts);

class SyncService {
  final CourseRepository _courseRepo = CourseRepository();
  final NoteRepository _noteRepo = NoteRepository();
  final DeadlineRepository _deadlineRepo = DeadlineRepository();
  final GradeRepository _gradeRepo = GradeRepository();
  final FileRepository _fileRepo = FileRepository();
  final AbsenceRepository _absenceRepo = AbsenceRepository();
  final PlannerEventRepository _plannerEventRepo = PlannerEventRepository();
  final CloudRecordsService _cloud = CloudRecordsService();
  final FileService _fileService = FileService();
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  final SyncEncryption _encryption;

  static const String _keyCloudBackupEnabled = 'cloud_backup_enabled';

  Function(String message, double progress)? onProgress;

  SyncService({SyncEncryption? encryption})
      : _encryption = encryption ?? SyncEncryption();

  Future<String> _encryptData(Map<String, dynamic> data) =>
      _encryption.encryptData(data);
  Future<Map<String, dynamic>> _decryptData(String encryptedBase64) =>
      _encryption.decryptData(encryptedBase64);

  Future<bool> isCloudBackupEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyCloudBackupEnabled) ?? false;
  }

  Future<void> setCloudBackupEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyCloudBackupEnabled, enabled);
    if (enabled) {
      await _encryption.ensureEncryptionKeyExists();
    }
  }

  /// Kullanıcının bulutta yedek verisi var mı kontrol et
  Future<bool> hasCloudBackup() async {
    if (SupabaseBackend.currentUser == null) return false;

    try {
      return await _cloud.count('courses') > 0;
    } catch (e) {
      debugPrint('Error checking cloud backup: $e');
      return false;
    }
  }

  /// Bulut yedek bilgisini getir (ders sayısı)
  Future<int> getCloudCourseCount() async {
    if (SupabaseBackend.currentUser == null) return 0;

    try {
      return await _cloud.count('courses');
    } catch (e) {
      return 0;
    }
  }

  /// Kullanıcının tüm bulut yedeklerini sil ("Sıfırdan Başla" seçeneği için)
  Future<void> clearCloudData() async {
    final user = SupabaseBackend.currentUser;
    if (user == null) return;

    if (!await _checkConnectivity()) {
      return; // İnternet yoksa sessizce başarısız olsun (veya hata fırlatabiliriz)
    }

    try {
      const collections = [
        'courses',
        'notes',
        'deadlines',
        'grades',
        'files',
        'absences',
        'planner_events',
      ];

      for (final collection in collections) {
        await _cloud.deleteCollection(collection);
      }
      debugPrint("Cloud data cleared successfully for user ${user.id}.");
    } catch (e) {
      debugPrint("Error clearing cloud data: $e");
    }
  }

  /// Belirli bir dersi buluttan sil
  Future<void> deleteCourseCloud(String courseId) async {
    if (SupabaseBackend.currentUser == null) {
      throw Exception('Kullanıcı giriş yapmamış');
    }

    if (!await _checkConnectivity()) {
      throw Exception('İnternet bağlantısı yok');
    }

    try {
      await _cloud.delete('courses', courseId);
      // Devamsızlık kaydı ders id'si ile tutulur
      await _cloud.delete('absences', courseId);

      // İlişkili kayıtlar düz metin `course_id` sütunuyla bulunur
      // (içerik şifreli olduğundan veri içinden sorgulanamaz).
      for (final collection in const ['notes', 'deadlines', 'grades', 'files']) {
        await _cloud.deleteByCourse(collection, courseId);
      }

      debugPrint(
        "Course $courseId and all related cloud data deleted successfully.",
      );
    } catch (e) {
      debugPrint("Error deleting course $courseId from cloud: $e");
      rethrow;
    }
  }

  Future<void> backupData() async {
    await _runBackup();
  }

  Future<void> _runBackup() async {
    if (SupabaseBackend.currentUser == null) {
      throw Exception('User not logged in');
    }

    if (!await isCloudBackupEnabled()) {
      throw Exception(
        'Cloud backup is disabled. Please enable it in Settings.',
      );
    }
    // B3 fix: İnternet kontrolü
    if (!await _checkConnectivity()) {
      throw Exception(
        'No internet connection. Please check your network and try again.',
      );
    }

    try {
      _reportProgress('Fetching local data...', 0.1);

      // 1. Fetch all local data
      final courses = await _courseRepo.getAllCourses();
      final notes = await _noteRepo.getAllNotes();
      final deadlines = await _deadlineRepo.getAllDeadlines();
      final plannerEvents = await _plannerEventRepo.getAllEvents();

      // We also need grades and files for each course
      List<Grade> allGrades = [];
      List<CourseFile> allFiles = [];

      for (var course in courses) {
        final grades = await _gradeRepo.getGradesByCourse(course.id);
        allGrades.addAll(grades);

        final files = await _fileRepo.getFilesByCourse(course.id);
        allFiles.addAll(files);
      }

      int totalItems =
          courses.length +
          notes.length +
          deadlines.length +
          allGrades.length +
          allFiles.length +
          plannerEvents.length;
      int processedItems = 0;

      // 2. Backup Courses — B1 fix: batch chunking with encryption
      await _commitInChunksEncrypted(
        items: courses,
        collection: 'courses',
        toMap: (course) => course.toMap(),
        getId: (course) => course.id,
        onItem: (_) => processedItems++,
      );

      // 3. Backup Deadlines
      await _commitInChunksEncrypted(
        items: deadlines,
        collection: 'deadlines',
        toMap: (deadline) => deadline.toMap(),
        getId: (deadline) => deadline.id,
        getCourseId: (deadline) => deadline.courseId,
        onItem: (_) => processedItems++,
      );

      // 3.5. Backup Planner Events
      await _commitInChunksEncrypted(
        items: plannerEvents,
        collection: 'planner_events',
        toMap: (event) => event.toMap(),
        getId: (event) => event.id,
        onItem: (_) => processedItems++,
      );

      // 4. Backup Grades
      await _commitInChunksEncrypted(
        items: allGrades,
        collection: 'grades',
        toMap: (grade) => grade.toMap(),
        getId: (grade) => grade.id,
        getCourseId: (grade) => grade.courseId,
        onItem: (_) => processedItems++,
      );

      // 5. Backup Notes (Hardware Heavy - Files) with encryption
      for (var note in notes) {
        _reportProgress(
          'Backing up note: ${note.title}',
          processedItems / totalItems,
        );

        Map<String, dynamic> noteMap = note.toMap();

        // Handle File Upload if exists — resolve relative paths first
        // E2E Storage - files are encrypted and uploaded to Supabase Storage
        if (await E2EKeyService().isE2EEnabled()) {
          try {
            final uploadService = E2EUploadService();
            if (note.filePath != null) {
              final resolvedPath = await _fileService.resolveFilePath(
                note.filePath,
              );
              if (resolvedPath != null && await File(resolvedPath).exists()) {
                final cloudPath = await _withRetry(
                  () => uploadService.uploadNoteFile(File(resolvedPath)),
                  3,
                );
                if (cloudPath != null) {
                  noteMap['cloudPath'] = cloudPath;
                }
              }
            }

            if (note.thumbnailPath != null &&
                note.thumbnailPath != note.filePath) {
              final resolvedThumbPath = await _fileService.resolveFilePath(
                note.thumbnailPath,
              );
              if (resolvedThumbPath != null &&
                  await File(resolvedThumbPath).exists()) {
                final cloudPath = await _withRetry(
                  () => uploadService.uploadNoteThumbnail(
                    File(resolvedThumbPath),
                  ),
                  3,
                );
                if (cloudPath != null) {
                  noteMap['thumbnailCloudPath'] = cloudPath;
                }
              }
            }
          } catch (e) {
            debugPrint('E2E file upload error for note ${note.id}: $e');
          }
        }

        final encryptedData = await _encryptData(noteMap);
        await _withRetry(
          () => _cloud.upsert(
            'notes',
            note.id,
            {'encryptedData': encryptedData},
            courseId: note.courseId,
          ),
          3,
        );
        processedItems++;
      }

      // 6. Backup Course Files with encryption
      for (var file in allFiles) {
        _reportProgress(
          'Backing up file: ${file.name}',
          processedItems / totalItems,
        );

        Map<String, dynamic> fileMap = file.toMap();

        // E2E Storage - files are encrypted and uploaded to Supabase Storage
        if (await E2EKeyService().isE2EEnabled()) {
          try {
            final uploadService = E2EUploadService();
            final resolvedFilePath = await _fileService.resolveFilePath(
              file.path,
            );
            if (resolvedFilePath != null &&
                await File(resolvedFilePath).exists()) {
              final cloudPath = await _withRetry(
                () => uploadService.uploadCourseFile(File(resolvedFilePath)),
                3,
              );
              if (cloudPath != null) {
                fileMap['cloudPath'] = cloudPath;
              }
            }
          } catch (e) {
            debugPrint('E2E file upload error for course file ${file.id}: $e');
          }
        }

        final encryptedData = await _encryptData(fileMap);
        await _withRetry(
          () => _cloud.upsert(
            'files',
            file.id,
            {'encryptedData': encryptedData},
            courseId: file.courseId,
          ),
          3,
        );
        processedItems++;
      }

      // 7. Backup Absences
      _reportProgress('Backing up absences...', 0.9);
      for (var course in courses) {
        final absenceDates = await _absenceRepo.getAbsencesByCourse(course.id);
        if (absenceDates.isNotEmpty) {
          await _cloud.upsert('absences', course.id, {
            'courseId': course.id,
            'dates': absenceDates.map((d) => d.toIso8601String()).toList(),
          }, courseId: course.id);
        }
      }

      // Save backup timestamp
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(
        'last_backup_timestamp',
        DateTime.now().millisecondsSinceEpoch,
      );

      _reportProgress('Backup Completed!', 1.0);
    } catch (e) {
      debugPrint('Backup Error: $e');
      rethrow;
    }
  }

  Future<void> restoreData() async {
    await _runRestore();
  }

  Future<void> _runRestore() async {
    if (SupabaseBackend.currentUser == null) {
      throw Exception('User not logged in');
    }

    if (!await isCloudBackupEnabled()) {
      throw Exception(
        'Cloud backup is disabled. Please enable it in Settings.',
      );
    }

    // B3 fix: İnternet kontrolü
    if (!await _checkConnectivity()) {
      throw Exception(
        'No internet connection. Please check your network and try again.',
      );
    }

    try {
      _reportProgress('Fetching cloud data...', 0.1);

      // Warning: This implies clearing local DB or Merging.
      // For safety, let's implement MERGE (Upsert). SQLite 'INSERT OR REPLACE'.
      // But _db.insert... usually throws if exists or depends on implementation.
      // We'll assume strict ID matching and use update or insert.

      // 1. Restore Courses
      final courseSnaps = await _cloud.getAll('courses');
      for (var doc in courseSnaps) {
        final decryptedData = await _withRetry(
          () => _decryptData(doc.data['encryptedData'] as String),
          3,
        );
        final course = Course.fromMap(decryptedData);
        final exists = await _courseRepo.getCourseById(course.id);
        if (exists != null) {
          await _courseRepo.updateCourse(course);
        } else {
          await _courseRepo.insertCourse(course);
        }
      }

      // 2. Restore Deadlines (insertDeadline uses ConflictAlgorithm.replace)
      final deadlineSnaps = await _cloud.getAll('deadlines');
      for (var doc in deadlineSnaps) {
        try {
          final decryptedData = await _withRetry(
            () => _decryptData(doc.data['encryptedData'] as String),
            3,
          );
          final deadline = Deadline.fromMap(decryptedData);
          await _deadlineRepo.insertDeadline(deadline);
        } catch (e) {
          debugPrint('Error restoring deadline ${doc.id}: $e');
        }
      }

      // 2.5. Restore Planner Events
      final plannerSnaps = await _cloud.getAll('planner_events');
      for (var doc in plannerSnaps) {
        try {
          final decryptedData = await _withRetry(
            () => _decryptData(doc.data['encryptedData'] as String),
            3,
          );
          final event = PlannerEvent.fromMap(decryptedData);
          final exists = await _plannerEventRepo.getEventById(event.id);
          if (exists != null) {
            await _plannerEventRepo.updateEvent(event);
          } else {
            await _plannerEventRepo.insertEvent(event);
          }
        } catch (e) {
          debugPrint('Error restoring planner_event ${doc.id}: $e');
        }
      }

      // 3. Restore Grades (insertGrade uses ConflictAlgorithm.replace)
      final gradeSnaps = await _cloud.getAll('grades');
      for (var doc in gradeSnaps) {
        try {
          final decryptedData = await _withRetry(
            () => _decryptData(doc.data['encryptedData'] as String),
            3,
          );
          final grade = Grade.fromMap(decryptedData);
          await _gradeRepo.insertGrade(grade);
        } catch (e) {
          debugPrint('Error restoring grade ${doc.id}: $e');
        }
      }

      // 4. Restore Notes (Download Files)
      final noteSnaps = await _cloud.getAll('notes');
      int totalNotes = noteSnaps.length;
      int processedNotes = 0;
      final isE2EEnabled = await E2EKeyService().isE2EEnabled();

      for (var doc in noteSnaps) {
        try {
          final decryptedData = await _withRetry(
            () => _decryptData(doc.data['encryptedData'] as String),
            3,
          );
          final data = Map<String, dynamic>.from(decryptedData);
          String? localPath = data['filePath'];
          String? localThumbPath = data['thumbnailPath'];

          _reportProgress(
            'Restoring note: ${data['title']}',
            0.3 + (processedNotes / totalNotes) * 0.4,
          );

          final cloudPath = data['cloudPath'] as String?;
          final thumbCloudPath = data['thumbnailCloudPath'] as String?;

          if (cloudPath != null && isE2EEnabled) {
            try {
              final e2eService = E2EFileService();
              final decryptedBytes = await e2eService.downloadFile(cloudPath);

              final extension = cloudPath.contains('.enc')
                  ? p.extension(cloudPath.replaceAll('.enc', ''))
                  : p.extension(localPath ?? '');
              final noteBasename = localPath != null
                  ? p.basename(localPath)
                  : '${doc.id}_note$extension';
              final relativeNotePath = 'restored_notes/$noteBasename';
              final localFilePath = await _saveDecryptedFile(
                decryptedBytes,
                relativeNotePath,
              );
              if (localFilePath != null) {
                localPath = localFilePath;
              }
            } catch (e) {
              debugPrint('Error downloading note file: $e');
            }
          }

          if (thumbCloudPath != null && isE2EEnabled) {
            try {
              final e2eService = E2EFileService();
              final decryptedBytes = await e2eService.downloadFile(
                thumbCloudPath,
              );

              final extension = thumbCloudPath.contains('.enc')
                  ? p.extension(thumbCloudPath.replaceAll('.enc', ''))
                  : p.extension(localThumbPath ?? '');
              final thumbBasename = localThumbPath != null
                  ? p.basename(localThumbPath)
                  : '${doc.id}_thumb$extension';
              final relativeThumbPath = 'restored_notes/$thumbBasename';
              final localThumbFilePath = await _saveDecryptedFile(
                decryptedBytes,
                relativeThumbPath,
              );
              if (localThumbFilePath != null) {
                localThumbPath = localThumbFilePath;
              }
            } catch (e) {
              debugPrint('Error downloading thumbnail: $e');
            }
          }

          data['filePath'] = localPath;
          data['thumbnailPath'] = localThumbPath;
          if (data['isBookmarked'] is bool) {
            data['isBookmarked'] = (data['isBookmarked'] as bool) ? 1 : 0;
          }

          final note = Note.fromMap(data);
          await _noteRepo.insertNote(note);
          processedNotes++;
        } catch (e) {
          debugPrint('Error restoring note ${doc.id}: $e');
          processedNotes++;
        }
      }

      // 5. Restore Course Files
      final fileSnaps = await _cloud.getAll('files');
      for (var doc in fileSnaps) {
        try {
          final decryptedData = await _withRetry(
            () => _decryptData(doc.data['encryptedData'] as String),
            3,
          );
          final data = Map<String, dynamic>.from(decryptedData);
          String? localPath = data['path'];
          final cloudPath = data['cloudPath'] as String?;

          if (cloudPath != null && isE2EEnabled) {
            try {
              final e2eService = E2EFileService();
              final decryptedBytes = await e2eService.downloadFile(cloudPath);

              final name = data['name'] ?? 'unknown_file';
              final courseId = data['courseId'] ?? 'unknown';
              final relativeCourseFilePath = 'course_materials/$courseId/$name';
              final savedPath = await _saveDecryptedFile(
                decryptedBytes,
                relativeCourseFilePath,
              );
              if (savedPath != null) {
                localPath = savedPath;
              }
            } catch (e) {
              debugPrint('Error downloading course file: $e');
            }
          }

          data['path'] = localPath;

          final file = CourseFile.fromMap(data);
          await _fileRepo.insertFile(file);
        } catch (e) {
          debugPrint('Error inserting file: $e');
        }
      }

      // 6. Restore Absences
      _reportProgress('Restoring absences...', 0.9);
      final absenceSnaps = await _cloud.getAll('absences');
      const uuid = Uuid();
      for (var doc in absenceSnaps) {
        try {
          final data = doc.data;
          final courseId = data['courseId'] as String;
          final dates = (data['dates'] as List<dynamic>?) ?? [];
          for (var dateStr in dates) {
            final date = DateTime.parse(dateStr as String);
            await _absenceRepo.insertAbsence(uuid.v4(), courseId, date);
          }
          AbsenceChangeBus.instance.fire(courseId);
        } catch (e) {
          debugPrint('Error restoring absences for ${doc.id}: $e');
        }
      }

      _reportProgress('Restore Completed!', 1.0);
    } catch (e) {
      debugPrint('Restore Error: $e');
      rethrow;
    }
  }

  void _reportProgress(String msg, double val) {
    debugPrint(msg);
    if (onProgress != null) {
      onProgress!(msg, val);
    }
  }

  Future<String?> _saveDecryptedFile(
    Uint8List decryptedBytes,
    String relativePath,
  ) async {
    try {
      final appDir = await getApplicationDocumentsDirectory();
      final filePath = p.join(appDir.path, relativePath);
      final file = File(filePath);

      final dir = file.parent;
      if (!await dir.exists()) {
        await dir.create(recursive: true);
      }

      await file.writeAsBytes(decryptedBytes);
      return relativePath;
    } catch (e) {
      debugPrint('Error saving decrypted file: $e');
      return null;
    }
  }

  Future<void> _commitInChunksEncrypted<T>({
    required List<T> items,
    required String collection,
    required Map<String, dynamic> Function(T item) toMap,
    required String Function(T item) getId,
    String? Function(T item)? getCourseId,
    Function(T item)? onItem,
  }) async {
    for (int i = 0; i < items.length; i += _kBatchChunkSize) {
      final chunk = items.sublist(
        i,
        (i + _kBatchChunkSize).clamp(0, items.length),
      );
      final records = <CloudRecord>[];
      for (var item in chunk) {
        final encryptedData = await _encryptData(toMap(item));
        records.add(
          CloudRecord(
            id: getId(item),
            courseId: getCourseId?.call(item),
            data: {'encryptedData': encryptedData},
          ),
        );
        onItem?.call(item);
      }
      await _withRetry(() => _cloud.upsertMany(collection, records), 3);
    }
  }

  /// B3 fix: İnternet bağlantısı kontrolü
  Future<bool> _checkConnectivity() async {
    try {
      final host = SupabaseBackend.host;
      if (host == null) return false;
      final result = await InternetAddress.lookup(
        host,
      ).timeout(const Duration(seconds: 5));
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } on SocketException catch (e) {
      debugPrint('Connectivity check failed (SocketException): $e');
      return false;
    } on TimeoutException catch (e) {
      debugPrint('Connectivity check failed (TimeoutException): $e');
      return false;
    } catch (e) {
      debugPrint('Connectivity check failed (Unknown): $e');
      return false;
    }
  }

  /// Tüm kullanıcı verilerini sil (KVKK Madde 7 - Silme Hakkı)
  Future<void> deleteAllUserData() async {
    await _runDeleteAllUserData();
  }

  Future<void> _runDeleteAllUserData() async {
    if (SupabaseBackend.currentUser == null) {
      throw Exception('Kullanıcı giriş yapmamış');
    }

    try {
      onProgress?.call('Veriler siliniyor...', 0.1);

      // 1. Storage'daki şifreli dosyaları sil (auth kaydı silinmeden önce —
      //    sonrasında RLS erişimi kalmaz)
      try {
        await E2EFileService().deleteAllUserFiles();
      } catch (e) {
        debugPrint('Error deleting storage files: $e');
      }
      onProgress?.call('Depolama alanı temizlendi', 0.3);

      // 2. Veritabanındaki tüm kullanıcı kayıtlarını sil
      await _cloud.deleteAll();
      onProgress?.call('Bulut verileri silindi', 0.5);

      // 3. Auth hesabını sil (profiles satırı cascade ile gider)
      await SupabaseBackend.deleteCurrentUser();
      onProgress?.call('Hesap silindi', 0.7);

      // 4. Local SQLite database'i temizle
      await DatabaseHelper().clearAllData();
      onProgress?.call('Yerel veriler temizlendi', 0.9);

      // 5. Secure storage'ı temizle
      await _secureStorage.deleteAll();

      // 6. SharedPreferences'ı temizle
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();

      onProgress?.call('Tamamlandı', 1.0);
    } catch (e) {
      debugPrint('Error deleting user data: $e');
      rethrow;
    }
  }

  // ==================== E2E FILE UPLOAD HELPERS ====================
}
