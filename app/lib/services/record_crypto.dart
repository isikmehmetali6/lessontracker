import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'e2e_crypto_service.dart';
import 'e2e_key_service.dart';
import 'sync_encryption.dart';

/// Bulut kaydı için yerel E2E anahtarı yok (giriş yapılmamış ya da anahtar
/// buluttan henüz açılmamış).
class RecordCryptoKeyMissing implements Exception {
  @override
  String toString() => 'RecordCryptoKeyMissing: E2E key is not available';
}

/// `user_records.data` zarfları.
///
/// - **v2:** `{"v": 2, "encryptedData": base64(nonce ‖ ct ‖ tag)}` — kullanıcının
///   E2E anahtarıyla AES-GCM. Her cihazda parola ile açılabilir.
/// - **legacy:** `{"encryptedData": ...}` — cihaza özel `backup_encryption_key`
///   + sabit IV ile CBC. Yalnızca o anahtarın bulunduğu cihazda açılabilir.
/// - **düz:** `encryptedData` alanı olmayan eski kayıtlar (ör. legacy
///   `absences`) olduğu gibi döner.
class RecordCrypto {
  RecordCrypto({
    E2EKeyService? keyService,
    E2ECryptoService? cryptoService,
    SyncEncryption? legacy,
  })  : _keyService = keyService ?? E2EKeyService(),
        _crypto = cryptoService ?? E2ECryptoService(),
        _legacy = legacy ?? SyncEncryption();

  static const int currentVersion = 2;

  final E2EKeyService _keyService;
  final E2ECryptoService _crypto;
  final SyncEncryption _legacy;

  Future<bool> get isReady async => await _keyService.getLocalKey() != null;

  Future<Uint8List> _key() async {
    final key = await _keyService.getLocalKey();
    if (key == null) throw RecordCryptoKeyMissing();
    return key;
  }

  Future<Map<String, dynamic>> seal(Map<String, dynamic> plain) async {
    final key = await _key();
    final sealed = _crypto.encryptString(jsonEncode(plain), key);
    return {'v': currentVersion, 'encryptedData': base64Encode(sealed)};
  }

  /// Anahtarı bir kez çözüp birçok kaydı şifrelemek için.
  Future<List<Map<String, dynamic>>> sealAll(
    List<Map<String, dynamic>> plains,
  ) async {
    final key = await _key();
    return plains
        .map(
          (p) => <String, dynamic>{
            'v': currentVersion,
            'encryptedData': base64Encode(
              _crypto.encryptString(jsonEncode(p), key),
            ),
          },
        )
        .toList();
  }

  /// Kayıt v2 biçiminde mi? (legacy kayıtların yeniden yazılması gerekir)
  static bool isCurrent(Map<String, dynamic> envelope) =>
      (envelope['v'] as num?)?.toInt() == currentVersion;

  Future<Map<String, dynamic>> open(Map<String, dynamic> envelope) async {
    final payload = envelope['encryptedData'];
    if (payload is! String) {
      return Map<String, dynamic>.from(envelope);
    }
    if (isCurrent(envelope)) {
      final key = await _key();
      final json = _crypto.decryptToString(base64Decode(payload), key);
      return jsonDecode(json) as Map<String, dynamic>;
    }
    return _legacy.decryptData(payload);
  }
}
