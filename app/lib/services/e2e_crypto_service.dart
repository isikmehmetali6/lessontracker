import 'dart:convert';

import 'package:encrypt/encrypt.dart' as encrypt;
import 'package:crypto/crypto.dart' as crypto;
import 'package:flutter/foundation.dart';

/// Düşük seviye şifreleme yardımcıları.
///
/// İki nesil biçim vardır:
/// - **v2 (güncel):** AES-256-GCM, her mesaj için rastgele 12 baytlık nonce,
///   çıktı `nonce ‖ ciphertext ‖ tag[16]`. PBKDF2 girdisi UTF-8.
/// - **legacy:** AES-256-CBC (MAC yok), çıktı `iv[16] ‖ ciphertext`. PBKDF2
///   girdisi `String.codeUnits`. Yalnızca eski verileri **çözmek** için tutulur;
///   yeni veri asla bu biçimde yazılmaz.
class E2ECryptoService {
  static const int pbkdf2Iterations = 100000;
  static const int _keyLength = 32;
  static const int _cbcIvLength = 16;
  static const int _gcmNonceLength = 12;
  static const int _gcmTagLength = 16;
  static const int _saltLength = 16;

  /// v2 şifreli dosyaların başındaki sihirli önek ("LTG2").
  static final Uint8List fileMagicV2 = Uint8List.fromList([0x4C, 0x54, 0x47, 0x32]);

  // ==================== ANAHTAR TÜRETME ====================

  /// v2 PBKDF2-HMAC-SHA256 (UTF-8 parola). Ana thread'i bloklar — UI'dan
  /// [deriveKeyAsync] kullanın.
  Uint8List deriveKey(String password, Uint8List salt) {
    return Uint8List.fromList(
      pbkdf2HmacSha256(utf8.encode(password), salt, pbkdf2Iterations, _keyLength),
    );
  }

  /// [deriveKey]'in isolate'te çalışan sürümü.
  Future<Uint8List> deriveKeyAsync(String password, Uint8List salt) {
    return compute(_deriveKeyEntry, _KdfArgs(utf8.encode(password), salt));
  }

  /// Legacy PBKDF2 (`codeUnits`). Yalnızca eski sarılmış anahtarları açmak için.
  Future<Uint8List> deriveKeyLegacyAsync(String password, Uint8List salt) {
    return compute(_deriveKeyEntry, _KdfArgs(password.codeUnits, salt));
  }

  Uint8List generateKey() {
    return Uint8List.fromList(encrypt.Key.fromSecureRandom(_keyLength).bytes);
  }

  Uint8List generateSalt() {
    return Uint8List.fromList(encrypt.IV.fromSecureRandom(_saltLength).bytes);
  }

  // ==================== v2: AES-GCM ====================

  Uint8List encryptGcm(Uint8List data, Uint8List key) {
    final nonce = encrypt.IV.fromSecureRandom(_gcmNonceLength);
    final encrypter = encrypt.Encrypter(
      encrypt.AES(encrypt.Key(key), mode: encrypt.AESMode.gcm),
    );
    final sealed = encrypter.encryptBytes(data, iv: nonce).bytes;
    final result = Uint8List(_gcmNonceLength + sealed.length);
    result.setRange(0, _gcmNonceLength, nonce.bytes);
    result.setRange(_gcmNonceLength, result.length, sealed);
    return result;
  }

  /// Tag doğrulanamazsa (yanlış anahtar / bozulmuş veri) istisna fırlatır.
  Uint8List decryptGcm(Uint8List sealed, Uint8List key) {
    if (sealed.length < _gcmNonceLength + _gcmTagLength) {
      throw const FormatException('Invalid encrypted data: too short');
    }
    final nonce = sealed.sublist(0, _gcmNonceLength);
    final body = sealed.sublist(_gcmNonceLength);
    final encrypter = encrypt.Encrypter(
      encrypt.AES(encrypt.Key(key), mode: encrypt.AESMode.gcm),
    );
    return Uint8List.fromList(
      encrypter.decryptBytes(encrypt.Encrypted(body), iv: encrypt.IV(nonce)),
    );
  }

  Uint8List encryptString(String data, Uint8List key) {
    return encryptGcm(Uint8List.fromList(utf8.encode(data)), key);
  }

  String decryptToString(Uint8List encryptedData, Uint8List key) {
    return utf8.decode(decryptGcm(encryptedData, key));
  }

  // ==================== DOSYALAR ====================

  /// Dosyaları v2 biçiminde şifreler: `LTG2 ‖ nonce ‖ ciphertext ‖ tag`.
  Uint8List encryptFile(Uint8List data, Uint8List key) {
    final sealed = encryptGcm(data, key);
    final result = Uint8List(fileMagicV2.length + sealed.length);
    result.setRange(0, fileMagicV2.length, fileMagicV2);
    result.setRange(fileMagicV2.length, result.length, sealed);
    return result;
  }

  /// v2 öneki varsa GCM, yoksa legacy CBC ile çözer.
  Uint8List decryptFile(Uint8List encryptedData, Uint8List key) {
    if (_hasPrefix(encryptedData, fileMagicV2)) {
      return decryptGcm(encryptedData.sublist(fileMagicV2.length), key);
    }
    return decryptLegacyCbc(encryptedData, key);
  }

  // ==================== LEGACY: AES-CBC ====================

  /// Eski biçim `iv[16] ‖ ciphertext`. Yalnızca okuma için.
  Uint8List decryptLegacyCbc(Uint8List encryptedData, Uint8List key) {
    if (encryptedData.length < _cbcIvLength) {
      throw const FormatException('Invalid encrypted data: too short');
    }
    final iv = encryptedData.sublist(0, _cbcIvLength);
    final data = encryptedData.sublist(_cbcIvLength);
    final encrypter = encrypt.Encrypter(
      encrypt.AES(encrypt.Key(key), mode: encrypt.AESMode.cbc),
    );
    return Uint8List.fromList(
      encrypter.decryptBytes(encrypt.Encrypted(data), iv: encrypt.IV(iv)),
    );
  }

  /// Yalnızca testlerde legacy veri üretmek için.
  @visibleForTesting
  Uint8List encryptLegacyCbc(Uint8List data, Uint8List key) {
    final iv = encrypt.IV.fromSecureRandom(_cbcIvLength);
    final encrypter = encrypt.Encrypter(
      encrypt.AES(encrypt.Key(key), mode: encrypt.AESMode.cbc),
    );
    final encrypted = encrypter.encryptBytes(data, iv: iv).bytes;
    final result = Uint8List(_cbcIvLength + encrypted.length);
    result.setRange(0, _cbcIvLength, iv.bytes);
    result.setRange(_cbcIvLength, result.length, encrypted);
    return result;
  }

  static bool _hasPrefix(Uint8List data, Uint8List prefix) {
    if (data.length < prefix.length) return false;
    for (var i = 0; i < prefix.length; i++) {
      if (data[i] != prefix[i]) return false;
    }
    return true;
  }
}

class _KdfArgs {
  final List<int> password;
  final Uint8List salt;
  const _KdfArgs(this.password, this.salt);
}

Uint8List _deriveKeyEntry(_KdfArgs args) {
  return Uint8List.fromList(
    pbkdf2HmacSha256(
      args.password,
      args.salt,
      E2ECryptoService.pbkdf2Iterations,
      E2ECryptoService._keyLength,
    ),
  );
}

/// PBKDF2-HMAC-SHA256 (RFC 8018). `keyLength` ≤ 32 için tek blok yeterli.
@visibleForTesting
List<int> pbkdf2HmacSha256(
  List<int> password,
  List<int> salt,
  int iterations,
  int keyLength,
) {
  assert(keyLength <= 32);
  final hmac = crypto.Hmac(crypto.sha256, password);

  final block = <int>[...salt, 0, 0, 0, 1];
  var u = hmac.convert(block).bytes;
  final output = List<int>.from(u);

  for (var i = 1; i < iterations; i++) {
    u = hmac.convert(u).bytes;
    for (var j = 0; j < output.length; j++) {
      output[j] ^= u[j];
    }
  }

  return output.sublist(0, keyLength);
}
