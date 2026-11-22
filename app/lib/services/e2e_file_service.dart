import 'dart:io';
import 'package:path/path.dart' as path;
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';
import '../core/backend/supabase_backend.dart';
import 'cloud_records_service.dart';
import 'e2e_crypto_service.dart';
import 'e2e_key_service.dart';
import 'package:flutter/foundation.dart';

class E2EFileService {
  final E2ECryptoService _cryptoService = E2ECryptoService();
  final E2EKeyService _keyService = E2EKeyService();
  final CloudRecordsService _cloud = CloudRecordsService();
  final Uuid _uuid = const Uuid();

  /// Yüklenen şifreli dosyaların meta kayıtları (sync yedeklerindeki
  /// `files` koleksiyonuyla karışmasın diye ayrı tutulur).
  static const String _uploadsCollection = 'uploads';

  /// Storage klasör adları — `deleteAllUserFiles` bunları dolaşır.
  static const List<String> fileTypes = ['photos', 'audio', 'documents'];

  static final E2EFileService _instance = E2EFileService._internal();
  factory E2EFileService() => _instance;
  E2EFileService._internal();

  StorageFileApi get _bucket {
    final client = SupabaseBackend.client;
    if (client == null) throw Exception('Supabase is not configured');
    return client.storage.from(SupabaseBackend.filesBucket);
  }

  Future<String> uploadPhoto(File localFile) async {
    return uploadFile(localFile, 'photos');
  }

  Future<String> uploadAudio(File localFile) async {
    return uploadFile(localFile, 'audio');
  }

  Future<String> uploadDocument(File localFile) async {
    return uploadFile(localFile, 'documents');
  }

  Future<String> uploadFile(File localFile, String type) async {
    final user = SupabaseBackend.currentUser;
    if (user == null) {
      throw Exception('No authenticated user');
    }

    final key = await _keyService.getLocalKey();
    if (key == null) {
      throw Exception('E2E key not found');
    }

    final fileBytes = await localFile.readAsBytes();
    if (fileBytes.length > 50 * 1024 * 1024) {
      debugPrint(
        'E2EFileService: Warning - Large file (${fileBytes.length}) may cause memory issues. Consider chunked upload.',
      );
    }
    final encryptedData = _cryptoService.encryptFile(fileBytes, key);

    final fileId = _uuid.v4();
    final extension = path.extension(localFile.path);
    // İlk klasör kullanıcı id'si olmalı — Storage RLS politikası buna bakar.
    final cloudPath = '${user.id}/$type/$fileId$extension.enc';

    await _bucket.uploadBinary(
      cloudPath,
      encryptedData,
      fileOptions: const FileOptions(
        contentType: 'application/octet-stream',
        upsert: true,
      ),
    );

    await _cloud.upsert(_uploadsCollection, fileId, {
      'cloudPath': cloudPath,
      'type': type,
      'originalName': path.basename(localFile.path),
      'size': fileBytes.length,
      'encryptedSize': encryptedData.length,
      'createdAt': DateTime.now().toUtc().toIso8601String(),
    });

    return cloudPath;
  }

  Future<Uint8List> downloadPhoto(String cloudPath) async {
    return downloadFile(cloudPath);
  }

  Future<Uint8List> downloadAudio(String cloudPath) async {
    return downloadFile(cloudPath);
  }

  Future<Uint8List> downloadDocument(String cloudPath) async {
    return downloadFile(cloudPath);
  }

  Future<Uint8List> downloadFile(String cloudPath) async {
    final key = await _keyService.getLocalKey();
    if (key == null) {
      throw Exception('E2E key not found');
    }

    final bytes = await _bucket.download(cloudPath);
    if (bytes.length > 50 * 1024 * 1024) {
      debugPrint(
        'E2EFileService: Warning - Large file (${bytes.length}) may cause memory issues. Consider chunked download.',
      );
    }
    return _cryptoService.decryptFile(bytes, key);
  }

  Future<void> deleteFile(String cloudPath) async {
    if (SupabaseBackend.currentUser == null) {
      throw Exception('No authenticated user');
    }

    try {
      await _bucket.remove([cloudPath]);

      // `{uid}/{type}/{fileId}{ext}.enc` → fileId
      final fileId = path.basenameWithoutExtension(
        path.withoutExtension(cloudPath),
      );
      await _cloud.delete(_uploadsCollection, fileId);
    } catch (e) {
      debugPrint('E2EFileService: Error deleting file - $e');
    }
  }

  /// Kullanıcının Storage'daki tüm dosyalarını siler (hesap silme).
  Future<void> deleteAllUserFiles() async {
    final user = SupabaseBackend.currentUser;
    if (user == null) return;

    for (final type in fileTypes) {
      final folder = '${user.id}/$type';
      while (true) {
        final objects = await _bucket.list(
          path: folder,
          searchOptions: const SearchOptions(limit: 1000),
        );
        if (objects.isEmpty) break;
        await _bucket.remove(objects.map((o) => '$folder/${o.name}').toList());
        if (objects.length < 1000) break;
      }
    }
  }

  Future<List<String>> listUserFiles() async {
    if (SupabaseBackend.currentUser == null) return [];

    try {
      final records = await _cloud.getAll(_uploadsCollection);
      return records.map((r) => r.data['cloudPath'] as String).toList();
    } catch (e) {
      debugPrint('E2EFileService: Error listing files - $e');
      return [];
    }
  }
}
