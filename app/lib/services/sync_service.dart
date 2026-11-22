import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/backend/supabase_backend.dart';
import '../core/database/database_helper.dart';
import '../core/utils/absence_change_bus.dart';
import '../models/course.dart';
import '../models/course_file.dart';
import '../models/deadline.dart';
import '../models/grade.dart';
import '../models/note.dart';
import '../models/planner_event.dart';
import '../repositories/absence_repository.dart';
import '../repositories/course_repository.dart';
import '../repositories/deadline_repository.dart';
import '../repositories/file_repository.dart';
import '../repositories/grade_repository.dart';
import '../repositories/note_repository.dart';
import '../repositories/planner_event_repository.dart';
import 'auto_sync_service.dart';
import 'cloud_records_service.dart';
import 'e2e_file_service.dart';
import 'e2e_key_service.dart';
import 'e2e_upload_service.dart';
import 'file_service.dart';
import 'record_crypto.dart';
import 'sync_batch_utils.dart';

const int _kBatchChunkSize = kSyncBatchChunkSize;

Future<T> _withRetry<T>(Future<T> Function() operation, int maxAttempts) =>
    withSyncRetry(operation, maxAttempts: maxAttempts);

/// Restore için E2E anahtarı gerekli; bulutta sarılmış anahtar var ama bu
/// cihazda açılmamış. UI parola isteyip [E2EKeyService.loadKeyFromCloud]
/// çağırmalı.
class RestoreNeedsPassword implements Exception {
  @override
  String toString() => 'RestoreNeedsPassword';
}

/// Restore özeti.
class RestoreResult {
  /// Bu cihazda çözülemediği için atlanan kayıt sayısı (legacy yedek başka
  /// cihazda alınmış).
  final int skippedRecords;
  const RestoreResult({this.skippedRecords = 0});
}

/// Bulut yedekleme / geri yükleme.
///
/// Kayıtlar [RecordCrypto] v2 zarfıyla (kullanıcının E2E anahtarı, AES-GCM)
/// yazılır; legacy kayıtlar okunurken çözülür ve bir sonraki backup'ta v2'ye
/// taşınır. Silmeler [AutoSyncService] kuyruğu üzerinden [applyCloudDelete]
/// ile uygulanır. Ayrıntılar: docs/FIX_PLAN_2026-11-23.md K1–K4.
class SyncService {
  SyncService({
    CloudRecordsService? cloud,
    RecordCrypto? crypto,
    E2EKeyService? keyService,
    E2EUploadService? uploader,
    E2EFileService? files,
    CourseRepository? courseRepo,
    NoteRepository? noteRepo,
    DeadlineRepository? deadlineRepo,
    GradeRepository? gradeRepo,
    FileRepository? fileRepo,
    AbsenceRepository? absenceRepo,
    PlannerEventRepository? plannerEventRepo,
    FileService? fileService,
    Future<bool> Function()? connectivityCheck,
    bool Function()? isSignedIn,
  })  : _cloud = cloud ?? CloudRecordsService(),
        _crypto = crypto ?? RecordCrypto(),
        _keyService = keyService ?? E2EKeyService(),
        _uploaderOverride = uploader,
        _filesOverride = files,
        _courseRepo = courseRepo ?? CourseRepository(),
        _noteRepo = noteRepo ?? NoteRepository(),
        _deadlineRepo = deadlineRepo ?? DeadlineRepository(),
        _gradeRepo = gradeRepo ?? GradeRepository(),
        _fileRepo = fileRepo ?? FileRepository(),
        _absenceRepo = absenceRepo ?? AbsenceRepository(),
        _plannerEventRepo = plannerEventRepo ?? PlannerEventRepository(),
        _fileService = fileService ?? FileService(),
        _connectivityCheckOverride = connectivityCheck,
        _isSignedIn =
            isSignedIn ?? (() => SupabaseBackend.currentUser != null);

  final CloudRecordsService _cloud;
  final RecordCrypto _crypto;
  final E2EKeyService _keyService;
  final E2EUploadService? _uploaderOverride;
  final E2EFileService? _filesOverride;
  final CourseRepository _courseRepo;
  final NoteRepository _noteRepo;
  final DeadlineRepository _deadlineRepo;
  final GradeRepository _gradeRepo;
  final FileRepository _fileRepo;
  final AbsenceRepository _absenceRepo;
  final PlannerEventRepository _plannerEventRepo;
  final FileService _fileService;
  final Future<bool> Function()? _connectivityCheckOverride;
  final bool Function() _isSignedIn;
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  // Supabase'e erişen singleton'lar yalnızca gerektiğinde oluşturulur.
  E2EUploadService get _uploader => _uploaderOverride ?? E2EUploadService();
  E2EFileService get _files => _filesOverride ?? E2EFileService();

  static const String _keyCloudBackupEnabled = 'cloud_backup_enabled';
  static const String _keyLastOrphanCleanup = 'last_orphan_cleanup_timestamp';

  /// Kayıtların tutulduğu koleksiyonlar (system/uploads hariç).
  static const List<String> dataCollections = [
    'courses',
    'notes',
    'deadlines',
    'grades',
    'files',
    'absences',
    'planner_events',
  ];

  Function(String message, double progress)? onProgress;

  // ==================== AYARLAR ====================

  Future<bool> isCloudBackupEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyCloudBackupEnabled) ?? false;
  }

  Future<void> setCloudBackupEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyCloudBackupEnabled, enabled);
  }

  Future<bool> hasCloudBackup() async {
    if (!_isSignedIn()) return false;
    try {
      return await _cloud.count('courses') > 0;
    } catch (e) {
      debugPrint('Error checking cloud backup: $e');
      return false;
    }
  }

  Future<int> getCloudCourseCount() async {
    if (!_isSignedIn()) return 0;
    try {
      return await _cloud.count('courses');
    } catch (e) {
      return 0;
    }
  }

  // ==================== SİLME ====================

  /// "Sıfırdan başla": tüm yedek kayıtları ve şifreli dosyaları siler.
  /// E2E anahtarı (`system`) korunur.
  Future<void> clearCloudData() async {
    if (!_isSignedIn()) return;
    if (!await _checkConnectivity()) return;

    try {
      for (final collection in dataCollections) {
        await _cloud.deleteCollection(collection);
      }
      try {
        await _files.deleteAllUserFiles();
        await _cloud.deleteCollection('uploads');
      } catch (e) {
        debugPrint('Error clearing cloud files: $e');
      }
      debugPrint('Cloud data cleared successfully.');
    } catch (e) {
      debugPrint('Error clearing cloud data: $e');
    }
  }

  Future<void> deleteCourseCloud(String courseId) async {
    if (!_isSignedIn()) {
      throw Exception('Kullanıcı giriş yapmamış');
    }
    if (!await _checkConnectivity()) {
      throw Exception('İnternet bağlantısı yok');
    }

    await _cloud.delete('courses', courseId);
    await _cloud.delete('absences', courseId);
    for (final collection in const ['notes', 'deadlines', 'grades', 'files']) {
      await _cloud.deleteByCourse(collection, courseId);
    }
    debugPrint('Course $courseId and related cloud data deleted.');
  }

  /// Silme kuyruğundaki tek bir satırı buluta uygular. Hata fırlatırsa
  /// satır kuyrukta kalır.
  Future<void> applyCloudDelete(
    String tableName,
    String recordId,
    Map<String, dynamic>? payload,
  ) async {
    if (!_isSignedIn()) throw Exception('User not logged in');

    switch (tableName) {
      case 'courses':
        await deleteCourseCloud(recordId);
        return;
      case 'notes':
        await _cloud.delete('notes', recordId);
        await _deleteStoragePaths([
          payload?['cloudPath'] as String?,
          payload?['thumbnailCloudPath'] as String?,
        ]);
        return;
      case 'course_files':
        await _cloud.delete('files', recordId);
        await _deleteStoragePaths([payload?['cloudPath'] as String?]);
        return;
      case 'grades':
      case 'deadlines':
      case 'planner_events':
        await _cloud.delete(tableName, recordId);
        return;
      default:
        debugPrint('SyncService: Unknown pending delete table $tableName');
    }
  }

  Future<void> _deleteStoragePaths(List<String?> paths) async {
    for (final path in paths.whereType<String>().toSet()) {
      await _files.deleteFile(path);
    }
  }

  // ==================== BACKUP ====================

  Future<void> backupData() async {
    if (!_isSignedIn()) {
      throw Exception('User not logged in');
    }
    if (!await isCloudBackupEnabled()) {
      throw Exception(
        'Cloud backup is disabled. Please enable it in Settings.',
      );
    }
    if (!await _checkConnectivity()) {
      throw Exception(
        'No internet connection. Please check your network and try again.',
      );
    }
    if (!await _crypto.isReady) {
      throw RecordCryptoKeyMissing();
    }

    _reportProgress('Fetching local data...', 0.1);

    final courses = await _courseRepo.getAllCoursesForSync();
    final notes = await _noteRepo.getAllNotesForSync();
    final deadlines = await _deadlineRepo.getAllDeadlines();
    final plannerEvents = await _plannerEventRepo.getAllEvents();
    final files = await _fileRepo.getAllFilesForSync();
    final grades = <Grade>[];
    for (final course in courses) {
      grades.addAll(await _gradeRepo.getGradesByCourse(course.id));
    }

    final totalItems = courses.length +
        notes.length +
        deadlines.length +
        grades.length +
        files.length +
        plannerEvents.length;
    var processedItems = 0;
    void tick(_) {
      processedItems++;
      _reportProgress(
        'Backing up...',
        totalItems == 0 ? 1.0 : 0.1 + 0.7 * processedItems / totalItems,
      );
    }

    await _commitInChunks<Course>(
      items: courses,
      collection: 'courses',
      toMap: (c) => c.toMap(),
      getId: (c) => c.id,
      onItem: tick,
    );
    await _commitInChunks<Deadline>(
      items: deadlines,
      collection: 'deadlines',
      toMap: (d) => d.toMap(),
      getId: (d) => d.id,
      getCourseId: (d) => d.courseId,
      onItem: tick,
    );
    await _commitInChunks<PlannerEvent>(
      items: plannerEvents,
      collection: 'planner_events',
      toMap: (e) => e.toMap(),
      getId: (e) => e.id,
      onItem: tick,
    );
    await _commitInChunks<Grade>(
      items: grades,
      collection: 'grades',
      toMap: (g) => g.toMap(),
      getId: (g) => g.id,
      getCourseId: (g) => g.courseId,
      onItem: tick,
    );

    // Ekler yalnızca henüz yüklenmemişse yüklenir (B5) ve bulut yolu yerel
    // DB'ye yazılır.
    final e2eEnabled = await _keyService.isE2EEnabled();
    final notesToSave = <Note>[];
    for (final note in notes) {
      notesToSave.add(e2eEnabled ? await _uploadNoteAttachments(note) : note);
    }
    await _commitInChunks<Note>(
      items: notesToSave,
      collection: 'notes',
      toMap: (n) => n.toMap(),
      getId: (n) => n.id,
      getCourseId: (n) => n.courseId,
      onItem: tick,
    );

    final filesToSave = <CourseFile>[];
    for (final file in files) {
      filesToSave.add(e2eEnabled ? await _uploadCourseFile(file) : file);
    }
    await _commitInChunks<CourseFile>(
      items: filesToSave,
      collection: 'files',
      toMap: (f) => f.toMap(),
      getId: (f) => f.id,
      getCourseId: (f) => f.courseId,
      onItem: tick,
    );

    _reportProgress('Backing up absences...', 0.9);
    await _backupAbsences(courses);

    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(
      'last_backup_timestamp',
      DateTime.now().millisecondsSinceEpoch,
    );

    _reportProgress('Backup Completed!', 1.0);

    unawaited(_maybeCleanupOrphanUploads());
  }

  Future<Note> _uploadNoteAttachments(Note note) async {
    var result = note;
    try {
      if (note.cloudPath == null && note.filePath != null) {
        final resolved = await _fileService.resolveFilePath(note.filePath);
        if (resolved != null && await File(resolved).exists()) {
          final cloudPath = await _withRetry(
            () => _uploader.uploadNoteFile(File(resolved)),
            3,
          );
          if (cloudPath != null) {
            result = result.copyWith(cloudPath: cloudPath);
            await _noteRepo.updateCloudPaths(note.id, cloudPath: cloudPath);
          }
        }
      }
      if (note.thumbnailCloudPath == null &&
          note.thumbnailPath != null &&
          note.thumbnailPath != note.filePath) {
        final resolved = await _fileService.resolveFilePath(note.thumbnailPath);
        if (resolved != null && await File(resolved).exists()) {
          final cloudPath = await _withRetry(
            () => _uploader.uploadNoteThumbnail(File(resolved)),
            3,
          );
          if (cloudPath != null) {
            result = result.copyWith(thumbnailCloudPath: cloudPath);
            await _noteRepo.updateCloudPaths(
              note.id,
              thumbnailCloudPath: cloudPath,
            );
          }
        }
      }
    } catch (e) {
      debugPrint('E2E file upload error for note ${note.id}: $e');
    }
    return result;
  }

  Future<CourseFile> _uploadCourseFile(CourseFile file) async {
    if (file.cloudPath != null || file.path.isEmpty) return file;
    try {
      final resolved = await _fileService.resolveFilePath(file.path);
      if (resolved != null && await File(resolved).exists()) {
        final cloudPath = await _withRetry(
          () => _uploader.uploadCourseFile(File(resolved)),
          3,
        );
        if (cloudPath != null) {
          await _fileRepo.updateCloudPath(file.id, cloudPath);
          return file.copyWith(cloudPath: cloudPath);
        }
      }
    } catch (e) {
      debugPrint('E2E file upload error for course file ${file.id}: $e');
    }
    return file;
  }

  /// Ders başına tek kayıt: `{courseId, items: [{id, date, reason}]}`.
  /// Yerelde devamsızlığı kalmayan dersin bulut kaydı silinir.
  Future<void> _backupAbsences(List<Course> courses) async {
    final cloudIds =
        (await _cloud.getAll('absences')).map((r) => r.id).toSet();
    final records = <CloudRecord>[];
    final plains = <Map<String, dynamic>>[];

    for (final course in courses) {
      final rows = await _absenceRepo.getAbsencesWithReasonByCourse(course.id);
      if (rows.isEmpty) {
        if (cloudIds.contains(course.id)) {
          await _withRetry(() => _cloud.delete('absences', course.id), 3);
        }
        continue;
      }
      plains.add({
        'courseId': course.id,
        'items': rows
            .map(
              (r) => {
                'id': r['id'],
                'date': r['date'] is DateTime
                    ? (r['date'] as DateTime).toIso8601String()
                    : r['date'],
                'reason': r['reason'] ?? 'unexcused',
              },
            )
            .toList(),
      });
    }

    final sealed = await _crypto.sealAll(plains);
    for (var i = 0; i < plains.length; i++) {
      final courseId = plains[i]['courseId'] as String;
      records.add(
        CloudRecord(id: courseId, courseId: courseId, data: sealed[i]),
      );
    }
    for (var i = 0; i < records.length; i += _kBatchChunkSize) {
      final chunk = records.sublist(
        i,
        (i + _kBatchChunkSize).clamp(0, records.length),
      );
      await _withRetry(() => _cloud.upsertMany('absences', chunk), 3);
    }
  }

  // ==================== RESTORE ====================

  /// Buluttaki yedeği yerel DB'ye yükler.
  ///
  /// Kullanıcı açıkça istediği için `cloud_backup_enabled` ayarına bakmaz
  /// (B6). E2E anahtarı bu cihazda yoksa ve bulutta sarılmış anahtar varsa
  /// [RestoreNeedsPassword] fırlatır.
  Future<RestoreResult> restoreData() async {
    if (!_isSignedIn()) {
      throw Exception('User not logged in');
    }
    if (!await _checkConnectivity()) {
      throw Exception(
        'No internet connection. Please check your network and try again.',
      );
    }
    if (!await _crypto.isReady && await _keyService.hasCloudKey()) {
      throw RestoreNeedsPassword();
    }

    var skipped = 0;
    var hasLegacy = false;

    Future<Map<String, dynamic>?> open(CloudRecord doc) async {
      if (!RecordCrypto.isCurrent(doc.data)) hasLegacy = true;
      try {
        return await _withRetry(() => _crypto.open(doc.data), 3);
      } catch (e) {
        skipped++;
        debugPrint('Restore: cannot decrypt ${doc.id}: $e');
        return null;
      }
    }

    _reportProgress('Fetching cloud data...', 0.1);

    // 1. Dersler (diğer tablolar FK ile bunlara bağlı — önce gelmeli)
    for (final doc in await _cloud.getAll('courses')) {
      final data = await open(doc);
      if (data == null) continue;
      try {
        final course = Course.fromMap(data);
        if (await _courseRepo.getCourseById(course.id) != null) {
          await _courseRepo.updateCourse(course);
        } else {
          await _courseRepo.insertCourse(course);
        }
      } catch (e) {
        debugPrint('Error restoring course ${doc.id}: $e');
      }
    }

    // 2. Deadline'lar
    for (final doc in await _cloud.getAll('deadlines')) {
      final data = await open(doc);
      if (data == null) continue;
      try {
        await _deadlineRepo.insertDeadline(Deadline.fromMap(data));
      } catch (e) {
        debugPrint('Error restoring deadline ${doc.id}: $e');
      }
    }

    // 3. Planner
    for (final doc in await _cloud.getAll('planner_events')) {
      final data = await open(doc);
      if (data == null) continue;
      try {
        final event = PlannerEvent.fromMap(data);
        if (await _plannerEventRepo.getEventById(event.id) != null) {
          await _plannerEventRepo.updateEvent(event);
        } else {
          await _plannerEventRepo.insertEvent(event);
        }
      } catch (e) {
        debugPrint('Error restoring planner_event ${doc.id}: $e');
      }
    }

    // 4. Puanlar
    for (final doc in await _cloud.getAll('grades')) {
      final data = await open(doc);
      if (data == null) continue;
      try {
        await _gradeRepo.insertGrade(Grade.fromMap(data));
      } catch (e) {
        debugPrint('Error restoring grade ${doc.id}: $e');
      }
    }

    // 5. Notlar (+ şifreli ekler)
    final hasKey = await _crypto.isReady;
    final noteSnaps = await _cloud.getAll('notes');
    var processedNotes = 0;
    for (final doc in noteSnaps) {
      processedNotes++;
      final decrypted = await open(doc);
      if (decrypted == null) continue;
      try {
        final data = Map<String, dynamic>.from(decrypted);
        _reportProgress(
          'Restoring note: ${data['title']}',
          0.3 + (processedNotes / noteSnaps.length) * 0.4,
        );
        await _restoreNoteFiles(doc.id, data, hasKey);
        if (data['isBookmarked'] is bool) {
          data['isBookmarked'] = (data['isBookmarked'] as bool) ? 1 : 0;
        }
        await _noteRepo.insertNote(Note.fromMap(data));
      } catch (e) {
        debugPrint('Error restoring note ${doc.id}: $e');
      }
    }

    // 6. Ders dosyaları
    for (final doc in await _cloud.getAll('files')) {
      final decrypted = await open(doc);
      if (decrypted == null) continue;
      try {
        final data = Map<String, dynamic>.from(decrypted);
        final cloudPath = data['cloudPath'] as String?;
        if (cloudPath != null && hasKey) {
          try {
            final bytes = await _files.downloadFile(cloudPath);
            final name = p.basename((data['name'] as String?) ?? 'file');
            final courseId = data['courseId'] ?? 'unknown';
            final saved = await _saveDecryptedFile(
              bytes,
              'course_materials/$courseId/${doc.id}_$name',
            );
            if (saved != null) data['path'] = saved;
          } catch (e) {
            debugPrint('Error downloading course file: $e');
          }
        }
        await _fileRepo.insertFile(CourseFile.fromMap(data));
      } catch (e) {
        debugPrint('Error restoring file ${doc.id}: $e');
      }
    }

    // 7. Devamsızlıklar
    _reportProgress('Restoring absences...', 0.9);
    for (final doc in await _cloud.getAll('absences')) {
      final data = await open(doc);
      if (data == null) continue;
      try {
        await _restoreAbsences(doc.id, data);
      } catch (e) {
        debugPrint('Error restoring absences for ${doc.id}: $e');
      }
    }

    _reportProgress('Restore Completed!', 1.0);

    // Legacy kayıtları v2'ye taşımak için backup (ayar açıksa).
    if (hasLegacy) AutoSyncService().triggerBackup();

    return RestoreResult(skippedRecords: skipped);
  }

  Future<void> _restoreNoteFiles(
    String noteId,
    Map<String, dynamic> data,
    bool hasKey,
  ) async {
    final originalFilePath = data['filePath'] as String?;
    final originalThumbPath = data['thumbnailPath'] as String?;
    final cloudPath = data['cloudPath'] as String?;
    final thumbCloudPath = data['thumbnailCloudPath'] as String?;
    if (!hasKey) return;

    if (cloudPath != null) {
      try {
        final bytes = await _files.downloadFile(cloudPath);
        final saved = await _saveDecryptedFile(
          bytes,
          'restored_notes/${_restoredName(noteId, originalFilePath, cloudPath, 'note')}',
        );
        if (saved != null) {
          data['filePath'] = saved;
          // Resim/OCR notlarında küçük resim ana dosyanın kendisidir.
          if (originalThumbPath != null &&
              originalThumbPath == originalFilePath) {
            data['thumbnailPath'] = saved;
          }
        }
      } catch (e) {
        debugPrint('Error downloading note file: $e');
      }
    }

    if (thumbCloudPath != null) {
      try {
        final bytes = await _files.downloadFile(thumbCloudPath);
        final saved = await _saveDecryptedFile(
          bytes,
          'restored_notes/${_restoredName(noteId, originalThumbPath, thumbCloudPath, 'thumb')}',
        );
        if (saved != null) data['thumbnailPath'] = saved;
      } catch (e) {
        debugPrint('Error downloading thumbnail: $e');
      }
    }
  }

  static String _restoredName(
    String noteId,
    String? originalPath,
    String cloudPath,
    String suffix,
  ) {
    if (originalPath != null) return p.basename(originalPath);
    final ext = p.extension(cloudPath.replaceAll('.enc', ''));
    return '${noteId}_$suffix$ext';
  }

  /// v2: `{courseId, items: [{id, date, reason}]}` — id'ler korunur.
  /// legacy: `{courseId, dates: [...]}` — aynı gün zaten varsa atlanır,
  /// yoksa deterministik id ile eklenir (tekrar restore çoğaltmaz).
  Future<void> _restoreAbsences(String docId, Map<String, dynamic> data) async {
    final courseId = (data['courseId'] as String?) ?? docId;
    final items = data['items'] as List<dynamic>?;

    if (items != null) {
      for (final raw in items) {
        final item = Map<String, dynamic>.from(raw as Map);
        await _absenceRepo.insertAbsence(
          item['id'] as String,
          courseId,
          DateTime.parse(item['date'] as String),
          reason: (item['reason'] as String?) ?? 'unexcused',
        );
      }
    } else {
      final existing = await _absenceRepo.getAbsencesByCourse(courseId);
      bool sameDay(DateTime a, DateTime b) =>
          a.year == b.year && a.month == b.month && a.day == b.day;
      for (final raw in (data['dates'] as List<dynamic>?) ?? const []) {
        final date = DateTime.parse(raw as String);
        if (existing.any((e) => sameDay(e, date))) continue;
        await _absenceRepo.insertAbsence(
          legacyAbsenceId(courseId, date),
          courseId,
          date,
        );
        existing.add(date);
      }
    }
    AbsenceChangeBus.instance.fire(courseId);
  }

  /// AttendanceProvider / AttendanceAutomationService ile aynı id şeması.
  static String legacyAbsenceId(String courseId, DateTime date) =>
      '${courseId}_${date.toIso8601String().split('T')[0]}';

  // ==================== YETİM DOSYA TEMİZLİĞİ ====================

  /// Buluttaki not/dosya kayıtlarının hiçbirinin göstermediği ve 24 saatten
  /// eski şifreli dosyaları siler (eski sürümlerin her backup'ta yeniden
  /// yüklediği kopyalar — B5). Herhangi bir kayıt çözülemezse güvenli tarafta
  /// kalıp hiçbir şey silmez. Silinen dosya sayısını döner.
  Future<int> cleanupOrphanUploads() async {
    if (!_isSignedIn()) return 0;
    if (!await _crypto.isReady) return 0;

    final referenced = <String>{};
    for (final collection in const ['notes', 'files']) {
      for (final doc in await _cloud.getAll(collection)) {
        final Map<String, dynamic> data;
        try {
          data = await _crypto.open(doc.data);
        } catch (e) {
          debugPrint('Orphan cleanup aborted: cannot decrypt ${doc.id}');
          return 0;
        }
        for (final key in const ['cloudPath', 'thumbnailCloudPath']) {
          final value = data[key];
          if (value is String) referenced.add(value);
        }
      }
    }

    final cutoff = DateTime.now().toUtc().subtract(const Duration(hours: 24));
    var removed = 0;
    for (final upload in await _cloud.getAll('uploads')) {
      final cloudPath = upload.data['cloudPath'] as String?;
      if (cloudPath == null || referenced.contains(cloudPath)) continue;
      final createdAt = DateTime.tryParse(
        (upload.data['createdAt'] as String?) ?? '',
      );
      if (createdAt == null || createdAt.isAfter(cutoff)) continue;
      await _files.deleteFile(cloudPath);
      removed++;
    }
    debugPrint('Orphan cleanup: removed $removed files');
    return removed;
  }

  Future<void> _maybeCleanupOrphanUploads() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final last = prefs.getInt(_keyLastOrphanCleanup) ?? 0;
      final now = DateTime.now().millisecondsSinceEpoch;
      if (now - last < const Duration(days: 7).inMilliseconds) return;
      await prefs.setInt(_keyLastOrphanCleanup, now);
      await cleanupOrphanUploads();
    } catch (e) {
      debugPrint('Orphan cleanup error: $e');
    }
  }

  // ==================== YARDIMCILAR ====================

  void _reportProgress(String msg, double val) {
    debugPrint(msg);
    onProgress?.call(msg, val);
  }

  Future<String?> _saveDecryptedFile(
    Uint8List decryptedBytes,
    String relativePath,
  ) async {
    try {
      final appDir = await getApplicationDocumentsDirectory();
      final file = File(p.join(appDir.path, relativePath));
      if (!await file.parent.exists()) {
        await file.parent.create(recursive: true);
      }
      await file.writeAsBytes(decryptedBytes);
      return relativePath;
    } catch (e) {
      debugPrint('Error saving decrypted file: $e');
      return null;
    }
  }

  Future<void> _commitInChunks<T>({
    required List<T> items,
    required String collection,
    required Map<String, dynamic> Function(T item) toMap,
    required String Function(T item) getId,
    String? Function(T item)? getCourseId,
    void Function(T item)? onItem,
  }) async {
    for (int i = 0; i < items.length; i += _kBatchChunkSize) {
      final chunk = items.sublist(
        i,
        (i + _kBatchChunkSize).clamp(0, items.length),
      );
      final sealed = await _crypto.sealAll(chunk.map(toMap).toList());
      final records = <CloudRecord>[];
      for (var j = 0; j < chunk.length; j++) {
        records.add(
          CloudRecord(
            id: getId(chunk[j]),
            courseId: getCourseId?.call(chunk[j]),
            data: sealed[j],
          ),
        );
        onItem?.call(chunk[j]);
      }
      await _withRetry(() => _cloud.upsertMany(collection, records), 3);
    }
  }

  Future<bool> _checkConnectivity() async {
    final override = _connectivityCheckOverride;
    if (override != null) return override();
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

  // ==================== HESAP SİLME ====================

  /// KVKK md. 7 — buluttaki tüm veri, dosyalar ve hesap.
  Future<void> deleteAllUserData() async {
    if (!_isSignedIn()) {
      throw Exception('Kullanıcı giriş yapmamış');
    }
    try {
      onProgress?.call('Veriler siliniyor...', 0.1);
      try {
        await _files.deleteAllUserFiles();
      } catch (e) {
        debugPrint('Error deleting storage files: $e');
      }
      onProgress?.call('Depolama alanı temizlendi', 0.3);

      await _cloud.deleteAll();
      onProgress?.call('Bulut verileri silindi', 0.5);

      await SupabaseBackend.deleteCurrentUser();
      onProgress?.call('Hesap silindi', 0.7);

      await DatabaseHelper().clearAllData();
      onProgress?.call('Yerel veriler temizlendi', 0.9);

      await _secureStorage.deleteAll();
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
      _keyService.clearCache();

      onProgress?.call('Tamamlandı', 1.0);
    } catch (e) {
      debugPrint('Error deleting user data: $e');
      rethrow;
    }
  }
}
