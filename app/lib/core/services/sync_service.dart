import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:encrypt/encrypt.dart' as encrypt;
import 'package:path/path.dart' as p;
import '../../core/database/database_helper.dart';
import '../../repositories/course_repository.dart';
import '../../repositories/note_repository.dart';
import '../../repositories/deadline_repository.dart';
import '../../repositories/grade_repository.dart';
import '../../repositories/file_repository.dart';
import '../../repositories/absence_repository.dart';
import '../utils/absence_change_bus.dart';
import '../../models/course.dart';
import '../../models/note.dart';
import '../../models/deadline.dart';
import '../../models/grade.dart';
import '../../models/course_file.dart';
import '../../repositories/planner_event_repository.dart';
import '../../models/planner_event.dart';
import 'file_service.dart';
import 'e2e_file_service.dart';
import 'e2e_key_service.dart';
import 'e2e_upload_service.dart';
import 'dart:async';
import 'dart:convert';
import 'package:path_provider/path_provider.dart';

/// Birden çok batch'e bölme limiti (Firestore max 500)
const int _kBatchChunkSize = 400;

bool _isNetworkError(Object error) {
  final msg = error.toString().toLowerCase();
  return msg.contains('socketexception') ||
      msg.contains('timeoutexception') ||
      msg.contains('handshakeexception') ||
      msg.contains('connection') ||
      msg.contains('network') ||
      msg.contains('clientexception') ||
      msg.contains('httpexception') ||
      msg.contains('cloud_firestore') ||
      msg.contains('firestore');
}

Future<T> _withRetry<T>(Future<T> Function() operation, int maxAttempts) async {
  int attempt = 0;
  while (true) {
    try {
      return await operation();
    } catch (e) {
      attempt++;
      if (attempt >= maxAttempts || !_isNetworkError(e)) {
        rethrow;
      }
      final delay = Duration(seconds: (1 << (attempt - 1)));
      debugPrint('Retry $attempt/$maxAttempts after ${delay.inSeconds}s: $e');
      await Future.delayed(delay);
    }
  }
}

class SyncService {
  final CourseRepository _courseRepo = CourseRepository();
  final NoteRepository _noteRepo = NoteRepository();
  final DeadlineRepository _deadlineRepo = DeadlineRepository();
  final GradeRepository _gradeRepo = GradeRepository();
  final FileRepository _fileRepo = FileRepository();
  final AbsenceRepository _absenceRepo = AbsenceRepository();
  final PlannerEventRepository _plannerEventRepo = PlannerEventRepository();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FileService _fileService = FileService();
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  static const String _keyCloudBackupEnabled = 'cloud_backup_enabled';
  static const String _keyEncryptionKey = 'backup_encryption_key';
  static const String _keyBackupIV = 'backup_encryption_iv';

  Function(String message, double progress)? onProgress;

  Future<encrypt.Key> _getEncryptionKey() async {
    final keyBase64 = await _secureStorage.read(key: _keyEncryptionKey);
    if (keyBase64 == null) {
      throw Exception(
        'Encryption key not found. Please enable cloud backup first.',
      );
    }
    return encrypt.Key.fromBase64(keyBase64);
  }

  Future<encrypt.IV> _getOrCreateIV() async {
    String? ivBase64 = await _secureStorage.read(key: _keyBackupIV);
    if (ivBase64 == null) {
      final iv = encrypt.IV.fromSecureRandom(16);
      await _secureStorage.write(key: _keyBackupIV, value: iv.base64);
      return iv;
    }
    return encrypt.IV.fromBase64(ivBase64);
  }

  Future<String> _encryptData(Map<String, dynamic> data) async {
    final key = await _getEncryptionKey();
    final iv = await _getOrCreateIV();
    final encrypter = encrypt.Encrypter(
      encrypt.AES(key, mode: encrypt.AESMode.cbc),
    );
    final jsonString = jsonEncode(data);
    final encrypted = encrypter.encrypt(jsonString, iv: iv);
    return encrypted.base64;
  }

  Future<Map<String, dynamic>> _decryptData(String encryptedBase64) async {
    final key = await _getEncryptionKey();
    final ivBase64 = await _secureStorage.read(key: _keyBackupIV);
    if (ivBase64 == null) {
      throw Exception('Backup IV not found. Cannot decrypt data.');
    }
    final iv = encrypt.IV.fromBase64(ivBase64);
    final encrypter = encrypt.Encrypter(
      encrypt.AES(key, mode: encrypt.AESMode.cbc),
    );
    final decrypted = encrypter.decrypt64(encryptedBase64, iv: iv);
    return jsonDecode(decrypted) as Map<String, dynamic>;
  }

  Future<bool> isCloudBackupEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyCloudBackupEnabled) ?? false;
  }

  Future<void> setCloudBackupEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyCloudBackupEnabled, enabled);
    if (enabled) {
      await _ensureEncryptionKeyExists();
    }
  }

  Future<void> _ensureEncryptionKeyExists() async {
    String? key = await _secureStorage.read(key: _keyEncryptionKey);
    if (key == null) {
      final generatedKey = encrypt.Key.fromSecureRandom(32);
      await _secureStorage.write(
        key: _keyEncryptionKey,
        value: generatedKey.base64,
      );
    }
  }

  /// Kullanıcının bulutta yedek verisi var mı kontrol et
  Future<bool> hasCloudBackup() async {
    final user = _auth.currentUser;
    if (user == null) return false;

    try {
      final snapshot = await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('courses')
          .limit(1)
          .get();
      return snapshot.docs.isNotEmpty;
    } catch (e) {
      debugPrint('Error checking cloud backup: $e');
      return false;
    }
  }

  /// Bulut yedek bilgisini getir (ders sayısı)
  Future<int> getCloudCourseCount() async {
    final user = _auth.currentUser;
    if (user == null) return 0;

    try {
      final snapshot = await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('courses')
          .get();
      return snapshot.docs.length;
    } catch (e) {
      return 0;
    }
  }

  /// Kullanıcının tüm bulut yedeklerini sil ("Sıfırdan Başla" seçeneği için)
  Future<void> clearCloudData() async {
    final user = _auth.currentUser;
    if (user == null) return;

    if (!await _checkConnectivity()) {
      return; // İnternet yoksa sessizce başarısız olsun (veya hata fırlatabiliriz)
    }

    final uid = user.uid;

    try {
      final collections = [
        'courses',
        'notes',
        'deadlines',
        'grades',
        'files',
        'absences',
        'planner_events',
      ];

      for (final collection in collections) {
        final snapshot = await _firestore
            .collection('users')
            .doc(uid)
            .collection(collection)
            .get();

        for (int i = 0; i < snapshot.docs.length; i += _kBatchChunkSize) {
          final chunk = snapshot.docs.sublist(
            i,
            (i + _kBatchChunkSize).clamp(0, snapshot.docs.length),
          );
          final batch = _firestore.batch();
          for (final doc in chunk) {
            batch.delete(doc.reference);
          }
          await batch.commit();
        }
      }
      debugPrint("Cloud data cleared successfully for user $uid.");
    } catch (e) {
      debugPrint("Error clearing cloud data: $e");
    }
  }

  /// Belirli bir dersi buluttan sil
  Future<void> deleteCourseCloud(String courseId) async {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception('Kullanıcı giriş yapmamış');
    }

    if (!await _checkConnectivity()) {
      throw Exception('İnternet bağlantısı yok');
    }

    final uid = user.uid;
    try {
      final batch = _firestore.batch();
      final userRef = _firestore.collection('users').doc(uid);

      // Course doc
      batch.delete(userRef.collection('courses').doc(courseId));

      // Absences doc (stored with courseId as docId)
      batch.delete(userRef.collection('absences').doc(courseId));

      // Queries for sub-collections
      final notesSnap = await userRef
          .collection('notes')
          .where('courseId', isEqualTo: courseId)
          .get();
      for (var doc in notesSnap.docs) {
        batch.delete(doc.reference);
      }

      final deadlinesSnap = await userRef
          .collection('deadlines')
          .where('courseId', isEqualTo: courseId)
          .get();
      for (var doc in deadlinesSnap.docs) {
        batch.delete(doc.reference);
      }

      final gradesSnap = await userRef
          .collection('grades')
          .where('courseId', isEqualTo: courseId)
          .get();
      for (var doc in gradesSnap.docs) {
        batch.delete(doc.reference);
      }

      final filesSnap = await userRef
          .collection('files')
          .where('courseId', isEqualTo: courseId)
          .get();
      for (var doc in filesSnap.docs) {
        batch.delete(doc.reference);
      }

      await batch.commit();

      debugPrint(
        "Course $courseId and all related cloud data deleted successfully.",
      );
    } catch (e) {
      debugPrint("Error deleting course $courseId from cloud: $e");
      rethrow;
    }
  }

  Future<void> backupData() async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('User not logged in');

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

    final uid = user.uid;

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
        collectionPath: 'users/$uid/courses',
        toMap: (course) => course.toMap(),
        getId: (course) => course.id,
        onItem: (_) => processedItems++,
      );

      // 3. Backup Deadlines
      await _commitInChunksEncrypted(
        items: deadlines,
        collectionPath: 'users/$uid/deadlines',
        toMap: (deadline) => deadline.toMap(),
        getId: (deadline) => deadline.id,
        onItem: (_) => processedItems++,
      );

      // 3.5. Backup Planner Events
      await _commitInChunksEncrypted(
        items: plannerEvents,
        collectionPath: 'users/$uid/planner_events',
        toMap: (event) => event.toMap(),
        getId: (event) => event.id,
        onItem: (_) => processedItems++,
      );

      // 4. Backup Grades
      await _commitInChunksEncrypted(
        items: allGrades,
        collectionPath: 'users/$uid/grades',
        toMap: (grade) => grade.toMap(),
        getId: (grade) => grade.id,
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
        // E2E Storage - files are encrypted and uploaded to Firebase Storage
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
        await _firestore
            .collection('users')
            .doc(uid)
            .collection('notes')
            .doc(note.id)
            .set({'encryptedData': encryptedData});
        processedItems++;
      }

      // 6. Backup Course Files with encryption
      for (var file in allFiles) {
        _reportProgress(
          'Backing up file: ${file.name}',
          processedItems / totalItems,
        );

        Map<String, dynamic> fileMap = file.toMap();

        // E2E Storage - files are encrypted and uploaded to Firebase Storage
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
        await _firestore
            .collection('users')
            .doc(uid)
            .collection('files')
            .doc(file.id)
            .set({'encryptedData': encryptedData});
        processedItems++;
      }

      // 7. Backup Absences
      _reportProgress('Backing up absences...', 0.9);
      for (var course in courses) {
        final absenceDates = await _absenceRepo.getAbsencesByCourse(course.id);
        if (absenceDates.isNotEmpty) {
          await _firestore
              .collection('users')
              .doc(uid)
              .collection('absences')
              .doc(course.id)
              .set({
                'courseId': course.id,
                'dates': absenceDates.map((d) => d.toIso8601String()).toList(),
              });
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
    final user = _auth.currentUser;
    if (user == null) throw Exception('User not logged in');

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

    final uid = user.uid;

    try {
      _reportProgress('Fetching cloud data...', 0.1);

      // Warning: This implies clearing local DB or Merging.
      // For safety, let's implement MERGE (Upsert). SQLite 'INSERT OR REPLACE'.
      // But _db.insert... usually throws if exists or depends on implementation.
      // We'll assume strict ID matching and use update or insert.

      // 1. Restore Courses
      final courseSnaps = await _firestore
          .collection('users')
          .doc(uid)
          .collection('courses')
          .get();
      for (var doc in courseSnaps.docs) {
        final decryptedData = await _withRetry(
          () => _decryptData(doc.data()['encryptedData'] as String),
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
      final deadlineSnaps = await _firestore
          .collection('users')
          .doc(uid)
          .collection('deadlines')
          .get();
      for (var doc in deadlineSnaps.docs) {
        try {
          final decryptedData = await _withRetry(
            () => _decryptData(doc.data()['encryptedData'] as String),
            3,
          );
          final deadline = Deadline.fromMap(decryptedData);
          await _deadlineRepo.insertDeadline(deadline);
        } catch (e) {
          debugPrint('Error restoring deadline ${doc.id}: $e');
        }
      }

      // 2.5. Restore Planner Events
      final plannerSnaps = await _firestore
          .collection('users')
          .doc(uid)
          .collection('planner_events')
          .get();
      for (var doc in plannerSnaps.docs) {
        try {
          final decryptedData = await _withRetry(
            () => _decryptData(doc.data()['encryptedData'] as String),
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
      final gradeSnaps = await _firestore
          .collection('users')
          .doc(uid)
          .collection('grades')
          .get();
      for (var doc in gradeSnaps.docs) {
        try {
          final decryptedData = await _withRetry(
            () => _decryptData(doc.data()['encryptedData'] as String),
            3,
          );
          final grade = Grade.fromMap(decryptedData);
          await _gradeRepo.insertGrade(grade);
        } catch (e) {
          debugPrint('Error restoring grade ${doc.id}: $e');
        }
      }

      // 4. Restore Notes (Download Files)
      final noteSnaps = await _firestore
          .collection('users')
          .doc(uid)
          .collection('notes')
          .get();
      int totalNotes = noteSnaps.docs.length;
      int processedNotes = 0;
      final isE2EEnabled = await E2EKeyService().isE2EEnabled();

      for (var doc in noteSnaps.docs) {
        try {
          final decryptedData = await _withRetry(
            () => _decryptData(doc.data()['encryptedData'] as String),
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
      final fileSnaps = await _firestore
          .collection('users')
          .doc(uid)
          .collection('files')
          .get();
      for (var doc in fileSnaps.docs) {
        try {
          final decryptedData = await _withRetry(
            () => _decryptData(doc.data()['encryptedData'] as String),
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
      final absenceSnaps = await _firestore
          .collection('users')
          .doc(uid)
          .collection('absences')
          .get();
      const uuid = Uuid();
      for (var doc in absenceSnaps.docs) {
        try {
          final data = doc.data();
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

  /// @nodoc
  // B1 fix: Firestore batch'lerini 400'lük parçalara bölerek commit et
  // NOT: Bu method şu anda kullanılmıyor ama gelecekte batch operations için gerekebilir
  // ignore: unused_element
  Future<void> _commitInChunks<T>({
    required List<T> items,
    required String collectionPath,
    required Map<String, dynamic> Function(T item) toMap,
    required String Function(T item) getId,
    Function(T item)? onItem,
  }) async {
    for (int i = 0; i < items.length; i += _kBatchChunkSize) {
      final chunk = items.sublist(
        i,
        (i + _kBatchChunkSize).clamp(0, items.length),
      );
      final batch = _firestore.batch();
      for (var item in chunk) {
        final docRef = _firestore.collection(collectionPath).doc(getId(item));
        batch.set(docRef, toMap(item));
        onItem?.call(item);
      }
      await _withRetry(() async => batch.commit(), 3);
    }
  }

  Future<void> _commitInChunksEncrypted<T>({
    required List<T> items,
    required String collectionPath,
    required Map<String, dynamic> Function(T item) toMap,
    required String Function(T item) getId,
    Function(T item)? onItem,
  }) async {
    for (int i = 0; i < items.length; i += _kBatchChunkSize) {
      final chunk = items.sublist(
        i,
        (i + _kBatchChunkSize).clamp(0, items.length),
      );
      final batch = _firestore.batch();
      for (var item in chunk) {
        final docRef = _firestore.collection(collectionPath).doc(getId(item));
        final encryptedData = await _encryptData(toMap(item));
        batch.set(docRef, {'encryptedData': encryptedData});
        onItem?.call(item);
      }
      await _withRetry(() async => batch.commit(), 3);
    }
  }

  /// B3 fix: İnternet bağlantısı kontrolü
  Future<bool> _checkConnectivity() async {
    try {
      final result = await InternetAddress.lookup(
        'firestore.googleapis.com',
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
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception('Kullanıcı giriş yapmamış');
    }

    try {
      onProgress?.call('Veriler siliniyor...', 0.1);

      // 1. Firestore'daki tüm kullanıcı verilerini sil
      final userDocRef = _firestore.collection('users').doc(user.uid);

      // Alt koleksiyonları temizle
      final collections = [
        'courses',
        'notes',
        'deadlines',
        'grades',
        'files',
        'absences',
        'planner_events',
        'study_sessions',
      ];
      for (final collection in collections) {
        try {
          final snapshot = await userDocRef.collection(collection).get();
          if (snapshot.docs.isNotEmpty) {
            final batch = _firestore.batch();
            for (final doc in snapshot.docs) {
              batch.delete(doc.reference);
            }
            await batch.commit();
          }
        } catch (e) {
          debugPrint('Error deleting $collection: $e');
        }
      }

      // Ana kullanıcı dokümanını sil
      await userDocRef.delete();
      onProgress?.call('Bulut verileri silindi', 0.3);

      // 2. Firebase Storage'daki dosyaları sil
      try {
        final storageRef = FirebaseStorage.instance.ref('users/${user.uid}');
        await storageRef.delete();
      } catch (e) {
        debugPrint('Error deleting storage files: $e');
      }
      onProgress?.call('Depolama alanı temizlendi', 0.5);

      // 3. Firebase Auth hesabını sil
      await user.delete();
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
