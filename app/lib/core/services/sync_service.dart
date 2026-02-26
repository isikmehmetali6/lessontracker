import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import '../../repositories/course_repository.dart';
import '../../repositories/note_repository.dart';
import '../../repositories/deadline_repository.dart';
import '../../repositories/grade_repository.dart';
import '../../repositories/file_repository.dart';
import '../../models/course.dart';
import '../../models/note.dart';
import '../../models/deadline.dart';
import '../../models/grade.dart';
import '../../models/course_file.dart';
import 'file_service.dart';
import 'dart:async';

/// Birden çok batch'e bölme limiti (Firestore max 500)
const int _kBatchChunkSize = 400;

class SyncService {
  final CourseRepository _courseRepo = CourseRepository();
  final NoteRepository _noteRepo = NoteRepository();
  final DeadlineRepository _deadlineRepo = DeadlineRepository();
  final GradeRepository _gradeRepo = GradeRepository();
  final FileRepository _fileRepo = FileRepository();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FileService _fileService = FileService();

  // Progress callback
  Function(String message, double progress)? onProgress;

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

  Future<void> backupData() async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('User not logged in');
    
    // B3 fix: İnternet kontrolü
    if (!await _checkConnectivity()) {
      throw Exception('No internet connection. Please check your network and try again.');
    }
    
    final uid = user.uid;

    try {
      _reportProgress('Fetching local data...', 0.1);

      // 1. Fetch all local data
      final courses = await _courseRepo.getAllCourses();
      final notes = await _noteRepo.getAllNotes();
      final deadlines = await _deadlineRepo.getAllDeadlines();
      
      // We also need grades and files for each course
      List<Grade> allGrades = [];
      List<CourseFile> allFiles = [];

      for (var course in courses) {
        final grades = await _gradeRepo.getGradesByCourse(course.id);
        allGrades.addAll(grades);
        
        final files = await _fileRepo.getFilesByCourse(course.id);
        allFiles.addAll(files);
      }

      int totalItems = courses.length + notes.length + deadlines.length + allGrades.length + allFiles.length;
      int processedItems = 0;

      // 2. Backup Courses — B1 fix: batch chunking
      await _commitInChunks(
        items: courses,
        collectionPath: 'users/$uid/courses',
        toMap: (course) => course.toMap(),
        getId: (course) => course.id,
        onItem: (_) => processedItems++,
      );

      // 3. Backup Deadlines
      await _commitInChunks(
        items: deadlines,
        collectionPath: 'users/$uid/deadlines',
        toMap: (deadline) => deadline.toMap(),
        getId: (deadline) => deadline.id,
        onItem: (_) => processedItems++,
      );

      // 4. Backup Grades
      await _commitInChunks(
        items: allGrades,
        collectionPath: 'users/$uid/grades',
        toMap: (grade) => grade.toMap(),
        getId: (grade) => grade.id,
        onItem: (_) => processedItems++,
      );

      // 5. Backup Notes (Hardware Heavy - Files)
      for (var note in notes) {
        _reportProgress('Backing up note: ${note.title}', processedItems / totalItems);
        
        Map<String, dynamic> noteMap = note.toMap();
        
        // Handle File Upload if exists — resolve relative paths first
        if (note.filePath != null) {
          final resolvedPath = await _fileService.resolveFilePath(note.filePath);
          if (resolvedPath != null && File(resolvedPath).existsSync()) {
            final downloadUrl = await _uploadFile(
              uid, 
              'notes/${note.id}', 
              File(resolvedPath)
            );
            if (downloadUrl != null) {
              noteMap['storageUrl'] = downloadUrl;
            }
          }
        }
        
        if (note.thumbnailPath != null && note.thumbnailPath != note.filePath) {
          final resolvedThumbPath = await _fileService.resolveFilePath(note.thumbnailPath);
          if (resolvedThumbPath != null && File(resolvedThumbPath).existsSync()) {
            final downloadUrl = await _uploadFile(
              uid, 
              'notes/${note.id}_thumb', 
              File(resolvedThumbPath)
            );
            if (downloadUrl != null) {
              noteMap['storageThumbnailUrl'] = downloadUrl;
            }
          }
        }

        await _firestore.collection('users').doc(uid).collection('notes').doc(note.id).set(noteMap);
        processedItems++;
      }

      // 6. Backup Course Files
      for (var file in allFiles) {
        _reportProgress('Backing up file: ${file.name}', processedItems / totalItems);
        
        Map<String, dynamic> fileMap = file.toMap();
        
        final resolvedFilePath = await _fileService.resolveFilePath(file.path);
        if (resolvedFilePath != null && File(resolvedFilePath).existsSync()) {
            final downloadUrl = await _uploadFile(
               uid, 
               'course_files/${file.courseId}/${file.id}', 
               File(resolvedFilePath)
            );
             if (downloadUrl != null) {
               fileMap['storageUrl'] = downloadUrl;
             }
        }

        await _firestore.collection('users').doc(uid).collection('files').doc(file.id).set(fileMap);
        processedItems++;
      }

      // Save backup timestamp
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('last_backup_timestamp', DateTime.now().millisecondsSinceEpoch);
      
      _reportProgress('Backup Completed!', 1.0);

    } catch (e) {
      debugPrint('Backup Error: $e');
      rethrow;
    }
  }

  Future<void> restoreData() async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('User not logged in');
    
    // B3 fix: İnternet kontrolü
    if (!await _checkConnectivity()) {
      throw Exception('No internet connection. Please check your network and try again.');
    }
    
    final uid = user.uid;

    try {
      _reportProgress('Fetching cloud data...', 0.1);

      // Warning: This implies clearing local DB or Merging. 
      // For safety, let's implement MERGE (Upsert). SQLite 'INSERT OR REPLACE'.
      // But _db.insert... usually throws if exists or depends on implementation.
      // We'll assume strict ID matching and use update or insert.

      // 1. Restore Courses
      final courseSnaps = await _firestore.collection('users').doc(uid).collection('courses').get();
      for (var doc in courseSnaps.docs) {
        final course = Course.fromMap(doc.data());
        // Simple upsert logic: try update, if 0 rows, insert? 
        // Or delete and insert.
        // Let's rely on DB service having upsert or handle it manually.
        final exists = await _courseRepo.getCourseById(course.id);
        if (exists != null) {
          await _courseRepo.updateCourse(course);
        } else {
          await _courseRepo.insertCourse(course);
        }
      }

      // 2. Restore Deadlines
      final deadlineSnaps = await _firestore.collection('users').doc(uid).collection('deadlines').get();
      for (var doc in deadlineSnaps.docs) {
        final deadline = Deadline.fromMap(doc.data());
        // We lack 'getDeadlineById'. We might need to handle this.
        // Assuming insertDeadline handles conflict or we catch error.
        try {
           await _deadlineRepo.insertDeadline(deadline);
        } catch (e) {
           debugPrint('Error inserting deadline ${deadline.id}: $e');
        }
      }

      // 3. Restore Grades
       final gradeSnaps = await _firestore.collection('users').doc(uid).collection('grades').get();
      for (var doc in gradeSnaps.docs) {
        final grade = Grade.fromMap(doc.data());
        try {
          // Check existence manually if needed?
           await _gradeRepo.insertGrade(grade);
        } catch (e) {
           debugPrint('Error inserting grade ${grade.id}: $e');
        }
      }

      // 4. Restore Notes (Download Files)
      final noteSnaps = await _firestore.collection('users').doc(uid).collection('notes').get();
      int totalNotes = noteSnaps.docs.length;
      int processedNotes = 0;

      for (var doc in noteSnaps.docs) {
        // B5 fix: Map.from ile immutable map sorununu çöz
        final data = Map<String, dynamic>.from(doc.data());
        String? localPath = data['filePath'];
        String? storageUrl = data['storageUrl'];
        String? localThumbPath = data['thumbnailPath'];
        String? storageThumbUrl = data['storageThumbnailUrl'];
        
        _reportProgress('Restoring note: ${data['title']}', 0.3 + (processedNotes / totalNotes) * 0.4);

        // Download File if needed
        if (storageUrl != null) {
           final downloadedFile = await _downloadFile(storageUrl, 'restored_notes/${doc.id}_${p.basename(localPath ?? "file")}');
           if (downloadedFile != null) {
             localPath = downloadedFile.path;
           }
        }
        
        if (storageThumbUrl != null) {
           final downloadedFile = await _downloadFile(storageThumbUrl, 'restored_notes/${doc.id}_thumb_${p.basename(localThumbPath ?? "thumb")}');
           if (downloadedFile != null) {
             localThumbPath = downloadedFile.path;
           }
        }

        // Update map with new local paths
        data['filePath'] = localPath;
        data['thumbnailPath'] = localThumbPath;
        // Fix booleans if necessary (int vs bool)
        // Note.fromMap expects int 1/0 for isBookmarked?
        // Firestore stores bool 'true/false'.
        // We might need to convert.
        if (data['isBookmarked'] is bool) {
          data['isBookmarked'] = (data['isBookmarked'] as bool) ? 1 : 0;
        }

        final note = Note.fromMap(data);
        
        // Upsert
        // We don't have updateNote that takes ID easily check?
        // Note has ID.
        try {
           await _noteRepo.insertNote(note); 
        } catch (_) {
           await _noteRepo.updateNote(note);
        }
        processedNotes++;
      }

      // 5. Restore Course Files
      final fileSnaps = await _firestore.collection('users').doc(uid).collection('files').get();
       for (var doc in fileSnaps.docs) {
        // B5 fix: Map.from ile immutable map sorununu çöz
        final data = Map<String, dynamic>.from(doc.data());
        String? localPath = data['path'];
        String? storageUrl = data['storageUrl'];

        if (storageUrl != null) {
           // We need to put it in user documents/course_materials/...
           // We can guess extension or use original name?
           final name = data['name'] ?? 'unknown_file';
           final downloadedFile = await _downloadFile(storageUrl, 'course_materials/${data['courseId']}/$name');
           if (downloadedFile != null) {
             localPath = downloadedFile.path;
           }
        }
        data['path'] = localPath;

        final file = CourseFile.fromMap(data);
        try {
          await _fileRepo.insertFile(file);
        } catch (e) {
          debugPrint('Error inserting file ${file.id}: $e');
        }
      }

      _reportProgress('Restore Completed!', 1.0);

    } catch (e) {
      debugPrint('Restore Error: $e');
      rethrow;
    }
  }

  Future<String?> _uploadFile(String uid, String path, File file) async {
    try {
      final ref = _storage.ref().child('users/$uid/$path');
      await ref.putFile(file);
      return await ref.getDownloadURL();
    } catch (e) {
      debugPrint('Upload failed: $e');
      return null;
    }
  }

  Future<File?> _downloadFile(String url, String localRelativePath) async {
    try {
      final appDir = await getApplicationDocumentsDirectory();
      final localFile = File(p.join(appDir.path, localRelativePath));
      
      if (!await localFile.parent.exists()) {
        await localFile.parent.create(recursive: true);
      }

      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        await localFile.writeAsBytes(response.bodyBytes);
        return localFile;
      }
      return null;
    } catch (e) {
      debugPrint('Download failed: $e');
      return null;
    }
  }

  void _reportProgress(String msg, double val) {
    debugPrint(msg);
    if (onProgress != null) {
      onProgress!(msg, val);
    }
  }

  /// B1 fix: Firestore batch'lerini 400'lük parçalara bölerek commit et
  Future<void> _commitInChunks<T>({
    required List<T> items,
    required String collectionPath,
    required Map<String, dynamic> Function(T item) toMap,
    required String Function(T item) getId,
    Function(T item)? onItem,
  }) async {
    for (int i = 0; i < items.length; i += _kBatchChunkSize) {
      final chunk = items.sublist(i, (i + _kBatchChunkSize).clamp(0, items.length));
      final batch = _firestore.batch();
      for (var item in chunk) {
        final docRef = _firestore.collection(collectionPath).doc(getId(item));
        batch.set(docRef, toMap(item));
        onItem?.call(item);
      }
      await batch.commit();
    }
  }

  /// B3 fix: İnternet bağlantısı kontrolü
  Future<bool> _checkConnectivity() async {
    try {
      final result = await InternetAddress.lookup('google.com')
          .timeout(const Duration(seconds: 5));
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
}
