import 'dart:io';
import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path/path.dart' as path;
import 'package:uuid/uuid.dart';
import 'e2e_crypto_service.dart';
import 'e2e_key_service.dart';
import 'package:flutter/foundation.dart';

class E2EFileService {
  final E2ECryptoService _cryptoService = E2ECryptoService();
  final E2EKeyService _keyService = E2EKeyService();
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final Uuid _uuid = const Uuid();

  static final E2EFileService _instance = E2EFileService._internal();
  factory E2EFileService() => _instance;
  E2EFileService._internal();

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
    final user = _auth.currentUser;
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
    final cloudPath = 'users/${user.uid}/$type/$fileId$extension.enc';

    final ref = _storage.ref().child(cloudPath);
    final metadata = SettableMetadata(
      contentType: 'application/octet-stream',
      customMetadata: {'encrypted': 'true', 'type': type},
    );

    await ref.putData(encryptedData, metadata);

    await _firestore
        .collection('users')
        .doc(user.uid)
        .collection('files')
        .doc(fileId)
        .set({
          'cloudPath': cloudPath,
          'type': type,
          'originalName': path.basename(localFile.path),
          'size': fileBytes.length,
          'encryptedSize': encryptedData.length,
          'createdAt': FieldValue.serverTimestamp(),
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

    final ref = _storage.ref().child(cloudPath);
    final bytes = await ref.getData();
    if (bytes == null) {
      throw Exception('File not found at $cloudPath');
    }
    if (bytes.length > 50 * 1024 * 1024) {
      debugPrint(
        'E2EFileService: Warning - Large file (${bytes.length}) may cause memory issues. Consider chunked download.',
      );
    }
    return _cryptoService.decryptFile(bytes, key);
  }

  Future<void> deleteFile(String cloudPath) async {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception('No authenticated user');
    }

    try {
      final ref = _storage.ref().child(cloudPath);
      await ref.delete();

      final fileId = path.basename(cloudPath).replaceAll('.enc', '');
      await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('files')
          .doc(fileId)
          .delete();
    } catch (e) {
      debugPrint('E2EFileService: Error deleting file - $e');
    }
  }

  Future<String?> getDownloadUrl(String cloudPath) async {
    try {
      final ref = _storage.ref().child(cloudPath);
      return await ref.getDownloadURL();
    } catch (e) {
      debugPrint('E2EFileService: Error getting download URL - $e');
      return null;
    }
  }

  Future<int> getFileSize(String cloudPath) async {
    try {
      final ref = _storage.ref().child(cloudPath);
      final metadata = await ref.getMetadata();
      return metadata.size ?? 0;
    } catch (e) {
      debugPrint('E2EFileService: Error getting file size - $e');
      return 0;
    }
  }

  Future<List<String>> listUserFiles() async {
    final user = _auth.currentUser;
    if (user == null) return [];

    try {
      final snapshot = await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('files')
          .get();

      return snapshot.docs
          .map((doc) => doc.data()['cloudPath'] as String)
          .toList();
    } catch (e) {
      debugPrint('E2EFileService: Error listing files - $e');
      return [];
    }
  }
}
