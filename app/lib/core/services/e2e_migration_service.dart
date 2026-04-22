import 'dart:io';
import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'e2e_crypto_service.dart';
import 'e2e_file_service.dart';
import 'e2e_key_service.dart';
import 'file_service.dart';
import 'image_compressor_service.dart';

class E2EMigrationService {
  static const String _keyMigrationCompleted = 'e2e_migration_completed';
  static const String _keyMigrationProgress = 'e2e_migration_progress';

  final E2ECryptoService _cryptoService = E2ECryptoService();
  final E2EKeyService _keyService = E2EKeyService();
  final FileService _localFileService = FileService();
  final ImageCompressorService _imageCompressor = ImageCompressorService();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  static final E2EMigrationService _instance = E2EMigrationService._internal();
  factory E2EMigrationService() => _instance;
  E2EMigrationService._internal();

  Function(String message, double progress)? onProgress;

  Future<bool> isMigrationNeeded() async {
    if (!await _keyService.isE2EEnabled()) return false;

    final prefs = await SharedPreferences.getInstance();
    if (prefs.getBool(_keyMigrationCompleted) == true) return false;

    final legacyFiles = await _findLegacyFiles();
    return legacyFiles.isNotEmpty;
  }

  Future<bool> isMigrationCompleted() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyMigrationCompleted) ?? false;
  }

  Future<List<_LegacyFile>> _findLegacyFiles() async {
    final user = _auth.currentUser;
    if (user == null) return [];

    final legacyFiles = <_LegacyFile>[];

    try {
      final notesSnapshot = await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('notes')
          .get();

      for (final doc in notesSnapshot.docs) {
        final data = doc.data();
        final filePath = data['filePath'] as String?;
        final thumbnailPath = data['thumbnailPath'] as String?;

        if (filePath != null && !filePath.contains('.enc')) {
          final resolvedPath = await _localFileService.resolveFilePath(
            filePath,
          );
          if (resolvedPath != null && await File(resolvedPath).exists()) {
            legacyFiles.add(
              _LegacyFile(
                id: doc.id,
                type: _LegacyFileType.note,
                localPath: resolvedPath,
                cloudPath: filePath,
                fileType: _FileType.photo,
              ),
            );
          }
        }

        if (thumbnailPath != null &&
            !thumbnailPath.contains('.enc') &&
            thumbnailPath != filePath) {
          final resolvedPath = await _localFileService.resolveFilePath(
            thumbnailPath,
          );
          if (resolvedPath != null && await File(resolvedPath).exists()) {
            legacyFiles.add(
              _LegacyFile(
                id: '${doc.id}_thumb',
                type: _LegacyFileType.noteThumbnail,
                localPath: resolvedPath,
                cloudPath: thumbnailPath,
                fileType: _FileType.photo,
              ),
            );
          }
        }
      }

      final filesSnapshot = await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('files')
          .get();

      for (final doc in filesSnapshot.docs) {
        final data = doc.data();
        final filePath = data['path'] as String?;
        final fileType = data['type'] as String?;

        if (filePath != null && !filePath.contains('.enc')) {
          final resolvedPath = await _localFileService.resolveFilePath(
            filePath,
          );
          if (resolvedPath != null && await File(resolvedPath).exists()) {
            legacyFiles.add(
              _LegacyFile(
                id: doc.id,
                type: _LegacyFileType.courseFile,
                localPath: resolvedPath,
                cloudPath: filePath,
                fileType: _getFileTypeFromString(fileType),
              ),
            );
          }
        }
      }
    } catch (e) {
      debugPrint('E2EMigrationService: Error finding legacy files - $e');
    }

    return legacyFiles;
  }

  _FileType _getFileTypeFromString(String? type) {
    switch (type?.toLowerCase()) {
      case 'pdf':
        return _FileType.document;
      case 'image':
      case 'photo':
        return _FileType.photo;
      case 'audio':
      case 'sound':
        return _FileType.audio;
      default:
        return _FileType.document;
    }
  }

  Future<void> migrateLegacyFiles() async {
    if (!await _keyService.isE2EEnabled()) {
      debugPrint('E2EMigrationService: E2E not enabled, skipping migration');
      return;
    }

    final legacyFiles = await _findLegacyFiles();
    if (legacyFiles.isEmpty) {
      debugPrint('E2EMigrationService: No legacy files to migrate');
      await _markMigrationComplete();
      return;
    }

    debugPrint(
      'E2EMigrationService: Starting migration of ${legacyFiles.length} files',
    );

    final totalItems = legacyFiles.length;
    for (int i = 0; i < legacyFiles.length; i++) {
      final file = legacyFiles[i];

      _reportProgress('Migrating file ${i + 1}/$totalItems...', i / totalItems);

      try {
        await _migrateFile(file);
        await _updateFirestoreRecord(file);
      } catch (e) {
        debugPrint('E2EMigrationService: Error migrating file ${file.id} - $e');
      }
    }

    await _markMigrationComplete();
    _reportProgress('Migration completed', 1.0);
  }

  Future<void> _migrateFile(_LegacyFile file) async {
    final localFile = File(file.localPath);
    if (!await localFile.exists()) {
      debugPrint('E2EMigrationService: File not found at ${file.localPath}');
      return;
    }

    Uint8List fileBytes = await localFile.readAsBytes();

    if (file.fileType == _FileType.photo) {
      final compressed = await _imageCompressor.compressAndGetBytes(
        file.localPath,
      );
      if (compressed != null) {
        fileBytes = compressed;
      }
    }

    final key = await _keyService.getLocalKey();
    if (key == null) {
      throw Exception('E2E key not found');
    }

    final encryptedData = _cryptoService.encryptFile(fileBytes, key);

    final user = _auth.currentUser;
    if (user == null) {
      throw Exception('No authenticated user');
    }

    final extension = file.localPath.contains('.')
        ? file.localPath.substring(file.localPath.lastIndexOf('.'))
        : '';
    final cloudPath =
        'users/${user.uid}/${_getCloudPathPrefix(file.fileType)}/${file.id}$extension.enc';

    final ref = _storage.ref().child(cloudPath);
    await ref.putData(encryptedData);

    file.cloudPath = cloudPath;
  }

  String _getCloudPathPrefix(_FileType type) {
    switch (type) {
      case _FileType.photo:
        return 'photos';
      case _FileType.audio:
        return 'audio';
      case _FileType.document:
        return 'documents';
    }
  }

  Future<void> _updateFirestoreRecord(_LegacyFile file) async {
    final user = _auth.currentUser;
    if (user == null) return;

    switch (file.type) {
      case _LegacyFileType.note:
      case _LegacyFileType.noteThumbnail:
        final noteId = file.id.replaceAll('_thumb', '');
        await _firestore
            .collection('users')
            .doc(user.uid)
            .collection('notes')
            .doc(noteId)
            .update({
              'cloudPath': file.cloudPath,
              if (file.type == _LegacyFileType.noteThumbnail)
                'thumbnailCloudPath': file.cloudPath,
            });
        break;
      case _LegacyFileType.courseFile:
        await _firestore
            .collection('users')
            .doc(user.uid)
            .collection('files')
            .doc(file.id)
            .update({'cloudPath': file.cloudPath});
        break;
    }
  }

  Future<void> _markMigrationComplete() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyMigrationCompleted, true);
  }

  Future<void> resetMigrationStatus() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyMigrationCompleted);
    await prefs.remove(_keyMigrationProgress);
  }

  void _reportProgress(String message, double progress) {
    if (onProgress != null) {
      onProgress!(message, progress);
    }
    debugPrint(
      'E2EMigrationService: $message (${(progress * 100).toStringAsFixed(1)}%)',
    );
  }

  FirebaseStorage get _storage => FirebaseStorage.instance;
}

enum _LegacyFileType { note, noteThumbnail, courseFile }

enum _FileType { photo, audio, document }

class _LegacyFile {
  final String id;
  final _LegacyFileType type;
  final String localPath;
  String cloudPath;
  final _FileType fileType;

  _LegacyFile({
    required this.id,
    required this.type,
    required this.localPath,
    required this.cloudPath,
    required this.fileType,
  });
}
