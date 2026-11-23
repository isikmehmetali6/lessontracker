import 'dart:io';
import 'dart:ui';

import 'package:flutter/material.dart' show Colors, TimeOfDay;
import 'package:flutter_test/flutter_test.dart';
import 'package:lesson_tracker/core/database/database_helper.dart';
import 'package:lesson_tracker/models/course.dart';
import 'package:lesson_tracker/providers/note_provider.dart';
import 'package:lesson_tracker/repositories/course_repository.dart';
import 'package:lesson_tracker/services/audio_service.dart';
import 'package:lesson_tracker/services/file_service.dart';
import 'package:lesson_tracker/services/ocr_service.dart';

import '../test_helpers.dart';

class _FakeOcr extends Fake implements OcrService {
  _FakeOcr(this.result);
  OcrResult result;

  @override
  Future<OcrResult> recognizeText(String imagePath) async => result;
}

/// saveImage'i geçici klasöre kopyalar; silmeleri kaydeder.
class _FakeFiles extends Fake implements FileService {
  _FakeFiles(this.dir);
  final Directory dir;
  final List<String> deleted = [];
  var _n = 0;

  @override
  Future<String> saveImage(File sourceFile) async {
    final name = 'images/ocr_${_n++}.jpg';
    final dest = File('${dir.path}/$name')..createSync(recursive: true);
    dest.writeAsBytesSync(sourceFile.readAsBytesSync());
    return name;
  }

  @override
  Future<String?> resolveFilePath(String? storedPath) async =>
      storedPath == null ? null : '${dir.path}/$storedPath';

  @override
  Future<bool> deleteFile(String filePath) async {
    deleted.add(filePath);
    final f = File('${dir.path}/$filePath');
    if (f.existsSync()) f.deleteSync();
    return true;
  }
}

class _FakeAudio extends Fake implements AudioService {}

OcrResult _ok(String text) =>
    OcrResult(fullText: text, blocks: const [], success: true);

void main() {
  late Directory tmp;
  late File photo;
  late _FakeFiles files;

  setUpAll(() {
    setupTestInfrastructure();
    setupSecureStorageMock();
    setupSqlCipherMock();
    DatabaseHelper.dbName = 'test_ocr_note.db';
  });

  setUp(() async {
    await DatabaseHelper().clearAllData();
    await CourseRepository().insertCourse(
      Course(
        id: 'c1',
        name: 'Fizik',
        color: Colors.blue,
        scheduleDays: const [0],
        startTime: const TimeOfDay(hour: 9, minute: 0),
        endTime: const TimeOfDay(hour: 10, minute: 0),
      ),
    );
    tmp = Directory.systemTemp.createTempSync('ocr_test');
    photo = File('${tmp.path}/photo.jpg')..writeAsBytesSync([1, 2, 3]);
    files = _FakeFiles(tmp);
  });

  tearDown(() => tmp.deleteSync(recursive: true));

  NoteProvider provider(OcrResult result) =>
      NoteProvider(
        ocr: _FakeOcr(result),
        fileService: files,
        audioService: _FakeAudio(),
      );

  test('tanınan metin not içeriği olur; başlık UI\'dan gelir', () async {
    final notes = provider(_ok('  Newton\'un ikinci yasası: F = m·a  \n'));
    final note = await notes.addOcrNote(
      courseId: 'c1',
      imageFile: photo,
      customTitle: 'Tarama 23 Kas',
    );
    expect(note, isNotNull);
    expect(note!.content, "Newton'un ikinci yasası: F = m·a");
    expect(note.title, 'Tarama 23 Kas');
    expect(notes.ocrErrorCode, isNull);
    expect(files.deleted, isEmpty, reason: 'başarılı notun görseli kalmalı');
  });

  test('metin yoksa not oluşturulmaz, görsel silinir (O1, O5)', () async {
    final notes = provider(_ok('   \n  '));
    final note = await notes.addOcrNote(courseId: 'c1', imageFile: photo);
    expect(note, isNull);
    expect(notes.ocrErrorCode, OcrErrorCode.noText);
    expect(files.deleted, hasLength(1));
    expect(await notes.getNoteById('x'), isNull);
    await notes.loadCourseNotes('c1');
    expect(notes.courseNotes, isEmpty);
  });

  test('ML Kit yoksa "kullanılamıyor" kodu döner, görsel silinir', () async {
    final notes = provider(
      OcrResult(
        fullText: '',
        blocks: const [],
        success: false,
        error: 'UNAVAILABLE',
        errorCode: OcrErrorCode.unavailable,
      ),
    );
    expect(await notes.addOcrNote(courseId: 'c1', imageFile: photo), isNull);
    expect(notes.ocrErrorCode, OcrErrorCode.unavailable);
    expect(files.deleted, hasLength(1));
  });

  test('OcrResult.hasText boşlukları metin saymaz', () {
    expect(_ok(' \n\t').hasText, isFalse);
    expect(_ok('a').hasText, isTrue);
    expect(
      OcrResult(
        fullText: 'x',
        blocks: [OcrBlock(text: 'x', lines: const [], boundingBox: Rect.zero)],
        success: true,
      ).wordCount,
      1,
    );
  });
}
