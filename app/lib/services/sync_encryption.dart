import 'dart:convert';
import 'package:encrypt/encrypt.dart' as encrypt;
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// **Legacy** yedek şifrelemesi — yalnızca eski kayıtları çözmek için.
///
/// Eski sürümler kayıtları cihaza özel `backup_encryption_key` ve tüm
/// kayıtlarda aynı IV ile AES-CBC şifreliyordu; bu anahtar buluta hiç
/// yazılmadığından yalnızca yedeği alan cihazda açılabilir. Yeni kayıtlar
/// [RecordCrypto] (v2) ile yazılır; restore sonrası backup tüm kayıtları v2'ye
/// taşır. Göç tamamlanınca bu sınıf kaldırılabilir.
class SyncEncryption {
  SyncEncryption({FlutterSecureStorage? secureStorage})
      : _secureStorage = secureStorage ?? const FlutterSecureStorage();

  static const String keyName = 'backup_encryption_key';
  static const String ivName = 'backup_encryption_iv';

  final FlutterSecureStorage _secureStorage;

  Future<Map<String, dynamic>> decryptData(String encryptedBase64) async {
    final keyBase64 = await _secureStorage.read(key: keyName);
    final ivBase64 = await _secureStorage.read(key: ivName);
    if (keyBase64 == null || ivBase64 == null) {
      throw const LegacyBackupKeyMissing();
    }
    final encrypter = encrypt.Encrypter(
      encrypt.AES(encrypt.Key.fromBase64(keyBase64), mode: encrypt.AESMode.cbc),
    );
    final decrypted = encrypter.decrypt64(
      encryptedBase64,
      iv: encrypt.IV.fromBase64(ivBase64),
    );
    return jsonDecode(decrypted) as Map<String, dynamic>;
  }

  /// Yalnızca testlerde legacy kayıt üretmek için.
  @visibleForTesting
  Future<String> encryptLegacyForTesting(Map<String, dynamic> data) async {
    final keyBase64 = await _secureStorage.read(key: keyName);
    final ivBase64 = await _secureStorage.read(key: ivName);
    final encrypter = encrypt.Encrypter(
      encrypt.AES(
        encrypt.Key.fromBase64(keyBase64!),
        mode: encrypt.AESMode.cbc,
      ),
    );
    return encrypter
        .encrypt(jsonEncode(data), iv: encrypt.IV.fromBase64(ivBase64!))
        .base64;
  }
}

/// Legacy kayıt bu cihazda çözülemez (yedek başka cihazda alınmış).
class LegacyBackupKeyMissing implements Exception {
  const LegacyBackupKeyMissing();
  @override
  String toString() =>
      'LegacyBackupKeyMissing: record was encrypted on another device';
}
