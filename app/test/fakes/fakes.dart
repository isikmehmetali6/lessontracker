import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:lesson_tracker/services/cloud_records_service.dart';
import 'package:lesson_tracker/services/e2e_crypto_service.dart';
import 'package:lesson_tracker/services/e2e_file_service.dart';
import 'package:lesson_tracker/services/e2e_key_service.dart';
import 'package:lesson_tracker/services/e2e_upload_service.dart';
import 'package:lesson_tracker/services/file_service.dart';

/// `user_records` tablosunun bellek içi karşılığı.
class FakeCloudRecordsService extends Fake implements CloudRecordsService {
  /// collection → id → record
  final Map<String, Map<String, CloudRecord>> store = {};

  Map<String, CloudRecord> _col(String c) => store.putIfAbsent(c, () => {});

  @override
  Future<void> upsert(
    String collection,
    String id,
    Map<String, dynamic> data, {
    String? courseId,
  }) =>
      upsertMany(collection, [
        CloudRecord(id: id, courseId: courseId, data: data),
      ]);

  @override
  Future<void> upsertMany(String collection, List<CloudRecord> records) async {
    for (final r in records) {
      _col(collection)[r.id] = CloudRecord(
        id: r.id,
        courseId: r.courseId,
        data: Map<String, dynamic>.from(r.data),
      );
    }
  }

  @override
  Future<CloudRecord?> get(String collection, String id) async =>
      store[collection]?[id];

  @override
  Future<List<CloudRecord>> getAll(String collection) async =>
      List.of(store[collection]?.values ?? const <CloudRecord>[]);

  @override
  Future<int> count(String collection) async => store[collection]?.length ?? 0;

  @override
  Future<void> delete(String collection, String id) async {
    store[collection]?.remove(id);
  }

  @override
  Future<void> deleteByCourse(String collection, String courseId) async {
    store[collection]?.removeWhere((_, r) => r.courseId == courseId);
  }

  @override
  Future<void> deleteCollection(String collection) async {
    store.remove(collection);
  }

  @override
  Future<void> deleteAll() async => store.clear();
}

/// Sabit anahtarlı E2E anahtar servisi.
class FakeE2EKeyService extends Fake implements E2EKeyService {
  FakeE2EKeyService({Uint8List? key, this.cloudKey = false, this.e2e = true})
      : key = key ?? E2ECryptoService().generateKey();

  Uint8List? key;
  bool cloudKey;
  bool e2e;

  @override
  Future<Uint8List?> getLocalKey() async => key;

  @override
  Future<bool> hasLocalKey() async => key != null;

  @override
  Future<bool> hasCloudKey() async => cloudKey;

  @override
  Future<bool> isE2EEnabled() async => e2e;

  @override
  void clearCache() {}
}

/// Yüklemeleri sayan sahte yükleyici.
class FakeE2EUploadService extends Fake implements E2EUploadService {
  final List<String> uploaded = [];
  var _n = 0;

  String _next(String type) {
    final path = 'uid/$type/${_n++}.enc';
    uploaded.add(path);
    return path;
  }

  @override
  Future<String?> uploadNoteFile(File file) async => _next('photos');

  @override
  Future<String?> uploadNoteThumbnail(File file) async => _next('photos');

  @override
  Future<String?> uploadCourseFile(File file) async => _next('documents');
}

/// Silinen ve indirilen Storage yollarını kaydeder.
class FakeE2EFileService extends Fake implements E2EFileService {
  final List<String> deleted = [];
  final Map<String, Uint8List> blobs = {};

  @override
  Future<void> deleteFile(String cloudPath) async => deleted.add(cloudPath);

  @override
  Future<Uint8List> downloadFile(String cloudPath) async =>
      blobs[cloudPath] ?? Uint8List.fromList([1, 2, 3]);

  @override
  Future<void> deleteAllUserFiles() async {}
}

/// Tüm göreli yolları verilen gerçek dosyaya çözer.
class FakeFileService extends Fake implements FileService {
  FakeFileService(this.existingFile);

  final File existingFile;

  @override
  Future<String?> resolveFilePath(String? storedPath) async =>
      storedPath == null ? null : existingFile.path;
}
