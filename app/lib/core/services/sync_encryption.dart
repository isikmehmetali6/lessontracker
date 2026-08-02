import 'dart:convert';
import 'package:encrypt/encrypt.dart' as encrypt;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// AES-CBC encryption helpers for cloud backup payloads.
///
/// Extracted from SyncService as part of plan 2.2 (SyncService split
/// facade). The key and IV live in secure storage so the same value
/// round-trips across backup/restore.
class SyncEncryption {
  SyncEncryption({FlutterSecureStorage? secureStorage})
      : _secureStorage = secureStorage ?? const FlutterSecureStorage();

  static const String keyName = 'backup_encryption_key';
  static const String ivName = 'backup_encryption_iv';

  final FlutterSecureStorage _secureStorage;

  Future<encrypt.Key> getEncryptionKey() async {
    final keyBase64 = await _secureStorage.read(key: keyName);
    if (keyBase64 == null) {
      throw Exception(
        'Encryption key not found. Please enable cloud backup first.',
      );
    }
    return encrypt.Key.fromBase64(keyBase64);
  }

  Future<encrypt.IV> getOrCreateIV() async {
    String? ivBase64 = await _secureStorage.read(key: ivName);
    if (ivBase64 == null) {
      final iv = encrypt.IV.fromSecureRandom(16);
      await _secureStorage.write(key: ivName, value: iv.base64);
      return iv;
    }
    return encrypt.IV.fromBase64(ivBase64);
  }

  Future<void> ensureEncryptionKeyExists() async {
    String? key = await _secureStorage.read(key: keyName);
    if (key == null) {
      final generatedKey = encrypt.Key.fromSecureRandom(32);
      await _secureStorage.write(
        key: keyName,
        value: generatedKey.base64,
      );
    }
  }

  Future<String> encryptData(Map<String, dynamic> data) async {
    final key = await getEncryptionKey();
    final iv = await getOrCreateIV();
    final encrypter = encrypt.Encrypter(
      encrypt.AES(key, mode: encrypt.AESMode.cbc),
    );
    final encrypted = encrypter.encrypt(jsonEncode(data), iv: iv);
    return encrypted.base64;
  }

  Future<Map<String, dynamic>> decryptData(String encryptedBase64) async {
    final key = await getEncryptionKey();
    final ivBase64 = await _secureStorage.read(key: ivName);
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
}