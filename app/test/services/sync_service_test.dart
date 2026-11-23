import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lesson_tracker/core/database/database_helper.dart';
import 'package:lesson_tracker/models/course.dart';
import 'package:lesson_tracker/models/course_file.dart';
import 'package:lesson_tracker/models/grade.dart';
import 'package:lesson_tracker/models/note.dart';
import 'package:lesson_tracker/repositories/absence_repository.dart';
import 'package:lesson_tracker/repositories/course_repository.dart';
import 'package:lesson_tracker/repositories/file_repository.dart';
import 'package:lesson_tracker/repositories/grade_repository.dart';
import 'package:lesson_tracker/repositories/note_repository.dart';
import 'package:lesson_tracker/services/auto_sync_service.dart';
import 'package:lesson_tracker/services/record_crypto.dart';
import 'package:lesson_tracker/services/sync_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../fakes/fakes.dart';
import '../test_helpers.dart';

Course _course(String id) => Course(
      id: id,
      name: 'Course $id',
      color: Colors.blue,
      scheduleDays: const [0],
      startTime: const TimeOfDay(hour: 9, minute: 0),
      endTime: const TimeOfDay(hour: 10, minute: 0),
      createdAt: DateTime(2026, 1, 1),
    );

Note _note(String id, String courseId, {String? filePath}) => Note(
      id: id,
      courseId: courseId,
      type: filePath == null ? NoteType.text : NoteType.image,
      title: 'Note $id',
      content: 'content $id',
      filePath: filePath,
      thumbnailPath: filePath,
      createdAt: DateTime(2026, 1, 1),
      updatedAt: DateTime(2026, 1, 1),
    );

void main() {
  late FakeCloudRecordsService cloud;
  late FakeE2EKeyService keys;
  late FakeE2EUploadService uploader;
  late FakeE2EFileService files;
  late File attachment;

  final courseRepo = CourseRepository();
  final noteRepo = NoteRepository();
  final gradeRepo = GradeRepository();
  final fileRepo = FileRepository();
  final absenceRepo = AbsenceRepository();

  SyncService makeService({FakeE2EKeyService? keyService}) {
    final k = keyService ?? keys;
    return SyncService(
      cloud: cloud,
      crypto: RecordCrypto(keyService: k),
      keyService: k,
      uploader: uploader,
      files: files,
      fileService: FakeFileService(attachment),
      connectivityCheck: () async => true,
      isSignedIn: () => true,
    );
  }

  setUpAll(() async {
    setupTestInfrastructure();
    setupSqlCipherMock();
    DatabaseHelper.dbName = 'test_sync_service.db';
    attachment = File('${Directory.systemTemp.path}/lt_sync_test.jpg')
      ..writeAsBytesSync([1, 2, 3, 4]);
  });

  setUp(() async {
    setupInMemorySecureStorage();
    SharedPreferences.setMockInitialValues({'cloud_backup_enabled': true});
    await DatabaseHelper().clearAllData();
    cloud = FakeCloudRecordsService();
    keys = FakeE2EKeyService();
    uploader = FakeE2EUploadService();
    files = FakeE2EFileService();
  });

  test('50\'den fazla ders ve not yedeklenir (B3) ve hepsi v2 zarfında', () async {
    for (var i = 0; i < 60; i++) {
      await courseRepo.insertCourse(_course('c$i'));
    }
    for (var i = 0; i < 120; i++) {
      await noteRepo.insertNote(_note('n$i', 'c${i % 60}'));
    }

    await makeService().backupData();

    expect(cloud.store['courses']!.length, 60);
    expect(cloud.store['notes']!.length, 120);
    expect(
      cloud.store['notes']!.values.every((r) => RecordCrypto.isCurrent(r.data)),
      isTrue,
    );
  });

  test('ekler yalnızca bir kez yüklenir ve cloudPath yerelde saklanır (B5)', () async {
    await courseRepo.insertCourse(_course('c1'));
    await noteRepo.insertNote(_note('n1', 'c1', filePath: 'images/a.jpg'));
    await fileRepo.insertFile(
      CourseFile(
        id: 'f1',
        courseId: 'c1',
        path: 'course_materials/c1/a.pdf',
        name: 'a.pdf',
        type: 'pdf',
        createdAt: DateTime(2026, 1, 1),
      ),
    );

    final service = makeService();
    await service.backupData();
    expect(uploader.uploaded.length, 2); // not dosyası + ders dosyası

    final local = await noteRepo.getNoteById('n1');
    expect(local!.cloudPath, isNotNull);

    await service.backupData();
    await service.backupData();
    expect(uploader.uploaded.length, 2, reason: 'tekrar yükleme olmamalı');
  });

  test('silinen not ve puan buluttan da silinir, restore geri getirmez (B4)', () async {
    await courseRepo.insertCourse(_course('c1'));
    await noteRepo.insertNote(_note('n1', 'c1', filePath: 'images/a.jpg'));
    await noteRepo.insertNote(_note('n2', 'c1'));
    await gradeRepo.insertGrade(
      Grade(
        id: 'g1',
        courseId: 'c1',
        name: 'Vize',
        score: 80,
        weight: 40,
        createdAt: DateTime(2026, 1, 1),
      ),
    );

    final service = makeService();
    await service.backupData();
    final uploadedPath = (await noteRepo.getNoteById('n1'))!.cloudPath;

    await noteRepo.deleteNote('n1');
    await gradeRepo.deleteGrade('g1');
    final applied = await AutoSyncService().processPendingDeletes(service);

    expect(applied, 2);
    expect(cloud.store['notes']!.containsKey('n1'), isFalse);
    expect(cloud.store['grades']!.containsKey('g1'), isFalse);
    expect(files.deleted, contains(uploadedPath));

    // Temiz cihazda restore → silinenler gelmez
    await DatabaseHelper().clearAllData();
    await service.restoreData();
    expect(await noteRepo.getNoteById('n1'), isNull);
    expect(await noteRepo.getNoteById('n2'), isNotNull);
    expect(await gradeRepo.getGradesByCourse('c1'), isEmpty);
  });

  test('bulut silmesi başarısızsa kuyruk satırı kalır (B7)', () async {
    await courseRepo.insertCourse(_course('c1'));
    await gradeRepo.insertGrade(
      Grade(
        id: 'g1',
        courseId: 'c1',
        name: 'Vize',
        score: 80,
        weight: 40,
        createdAt: DateTime(2026, 1, 1),
      ),
    );
    await gradeRepo.deleteGrade('g1');

    final offline = SyncService(
      cloud: cloud,
      crypto: RecordCrypto(keyService: keys),
      keyService: keys,
      uploader: uploader,
      files: files,
      connectivityCheck: () async => true,
      isSignedIn: () => false, // applyCloudDelete hata fırlatır
    );
    expect(await AutoSyncService().processPendingDeletes(offline), 0);

    final db = await DatabaseHelper().database;
    final rows = await db.query('pending_changes', where: "operation = 'delete'");
    expect(rows.length, 1);

    expect(await AutoSyncService().processPendingDeletes(makeService()), 1);
    expect(await db.query('pending_changes', where: "operation = 'delete'"), isEmpty);
  });

  test('yedek ayarı kapalı yeni cihazda restore çalışır (B6)', () async {
    await courseRepo.insertCourse(_course('c1'));
    await makeService().backupData();

    await DatabaseHelper().clearAllData();
    SharedPreferences.setMockInitialValues({}); // cloud_backup_enabled yok

    final result = await makeService().restoreData();
    expect(result.skippedRecords, 0);
    expect(await courseRepo.getCourseById('c1'), isNotNull);
  });

  test('devamsızlıklar şifreli yedeklenir, tekrar restore çoğaltmaz (B4, B12)', () async {
    await courseRepo.insertCourse(_course('c1'));
    await absenceRepo.insertAbsence('a1', 'c1', DateTime(2026, 3, 2),
        reason: 'excused');
    await absenceRepo.insertAbsence('a2', 'c1', DateTime(2026, 3, 9));

    final service = makeService();
    await service.backupData();
    final doc = cloud.store['absences']!['c1']!;
    expect(RecordCrypto.isCurrent(doc.data), isTrue);
    expect(doc.data.containsKey('dates'), isFalse);

    await DatabaseHelper().clearAllData();
    await service.restoreData();
    await service.restoreData();

    final rows = await absenceRepo.getAbsencesWithReasonByCourse('c1');
    expect(rows.length, 2);
    expect(rows.firstWhere((r) => r['id'] == 'a1')['reason'], 'excused');
  });

  test('legacy düz devamsızlık kaydı iki kez restore edilince çoğalmaz', () async {
    await courseRepo.insertCourse(_course('c1'));
    await makeService().backupData();
    cloud.store['absences'] = {};
    await cloud.upsert('absences', 'c1', {
      'courseId': 'c1',
      'dates': ['2026-03-02T00:00:00.000', '2026-03-09T00:00:00.000'],
    }, courseId: 'c1');

    await DatabaseHelper().clearAllData();
    final service = makeService();
    await service.restoreData();
    await service.restoreData();

    expect(await absenceRepo.getAbsencesByCourse('c1'), hasLength(2));
  });

  test('devamsızlığı kalmayan dersin bulut kaydı silinir', () async {
    await courseRepo.insertCourse(_course('c1'));
    await absenceRepo.insertAbsence('a1', 'c1', DateTime(2026, 3, 2));
    final service = makeService();
    await service.backupData();
    expect(cloud.store['absences']!.containsKey('c1'), isTrue);

    await absenceRepo.deleteLastAbsence('c1');
    await service.backupData();
    expect(cloud.store['absences']!.containsKey('c1'), isFalse);
  });

  test('anahtar yok ama bulutta sarılmış anahtar var → RestoreNeedsPassword', () async {
    final noKey = FakeE2EKeyService(cloudKey: true)..key = null;
    expect(
      () => makeService(keyService: noKey).restoreData(),
      throwsA(isA<RestoreNeedsPassword>()),
    );
  });

  test('anahtar yoksa backup RecordCryptoKeyMissing fırlatır', () async {
    final noKey = FakeE2EKeyService()..key = null;
    expect(
      () => makeService(keyService: noKey).backupData(),
      throwsA(isA<RecordCryptoKeyMissing>()),
    );
  });

  test('bu cihazda çözülemeyen legacy kayıtlar sayılıp atlanır', () async {
    await cloud.upsert('courses', 'legacy', {'encryptedData': 'AAAA'});
    final result = await makeService().restoreData();
    expect(result.skippedRecords, 1);
  });
  // ==================== Artımlı yedek (UI_FIX_PLAN U16) ====================

  test('ilk artımlı yedek tam yedeğe düşer', () async {
    await courseRepo.insertCourse(_course('c1'));
    await noteRepo.insertNote(_note('n1', 'c1'));
    await makeService().backupChanges();
    expect(cloud.store['courses']!.keys, ['c1']);
    expect(cloud.store['notes']!.keys, ['n1']);
  });

  test('sonraki yedek yalnızca değişen kaydı gönderir', () async {
    await courseRepo.insertCourse(_course('c1'));
    for (var i = 0; i < 5; i++) {
      await noteRepo.insertNote(_note('n$i', 'c1'));
    }
    final service = makeService();
    await service.backupData();
    cloud.upsertLog.clear();

    final note = await noteRepo.getNoteById('n2');
    await noteRepo.updateNote(note!.copyWith(title: 'Güncel'));
    await absenceRepo.insertAbsence('a1', 'c1', DateTime(2026, 3, 2));
    await service.backupChanges();

    expect(cloud.upsertLog, unorderedEquals(['notes/n2', 'absences/c1']));
    final db = await DatabaseHelper().database;
    expect(
      await db.query('pending_changes', where: "operation = 'upsert'"),
      isEmpty,
    );

    // Değişiklik yoksa hiçbir şey gönderilmez
    cloud.upsertLog.clear();
    await service.backupChanges();
    expect(cloud.upsertLog, isEmpty);
  });

  test('restore kendi eklemelerini yükleme kuyruğunda bırakmaz', () async {
    await courseRepo.insertCourse(_course('c1'));
    await noteRepo.insertNote(_note('n1', 'c1'));
    final service = makeService();
    await service.backupData();

    await DatabaseHelper().clearAllData();
    await service.restoreData();

    final db = await DatabaseHelper().database;
    expect(
      await db.query('pending_changes', where: "operation = 'upsert'"),
      isEmpty,
    );
  });
}
