import 'package:encrypt/encrypt.dart' as encrypt;
import 'package:crypto/crypto.dart' as crypto;
import 'package:flutter/foundation.dart';

class E2ECryptoService {
  static const int _pbkdf2Iterations = 100000;
  static const int _keyLength = 32;
  static const int _ivLength = 16;
  static const int _saltLength = 16;

  Uint8List deriveKey(String password, Uint8List salt) {
    final derived = _pbkdf2(password, salt, _pbkdf2Iterations, _keyLength);
    return Uint8List.fromList(derived);
  }

  Uint8List generateKey() {
    return Uint8List.fromList(encrypt.Key.fromSecureRandom(_keyLength).bytes);
  }

  Uint8List generateSalt() {
    return Uint8List.fromList(encrypt.IV.fromSecureRandom(_saltLength).bytes);
  }

  Uint8List generateIV() {
    return Uint8List.fromList(encrypt.IV.fromSecureRandom(_ivLength).bytes);
  }

  Uint8List encryptBytes(Uint8List data, Uint8List key) {
    final iv = generateIV();
    final encrypter = encrypt.Encrypter(
      encrypt.AES(encrypt.Key(key), mode: encrypt.AESMode.cbc),
    );
    final encrypted = encrypter.encryptBytes(data, iv: encrypt.IV(iv));
    final result = Uint8List(iv.length + encrypted.bytes.length);
    result.setRange(0, iv.length, iv);
    result.setRange(iv.length, result.length, encrypted.bytes);
    return result;
  }

  Uint8List decryptBytes(Uint8List encryptedData, Uint8List key) {
    if (encryptedData.length < _ivLength) {
      throw Exception('Invalid encrypted data: too short');
    }
    final iv = encryptedData.sublist(0, _ivLength);
    final data = encryptedData.sublist(_ivLength);
    final encrypter = encrypt.Encrypter(
      encrypt.AES(encrypt.Key(key), mode: encrypt.AESMode.cbc),
    );
    final decrypted = encrypter.decryptBytes(
      encrypt.Encrypted(data),
      iv: encrypt.IV(iv),
    );
    return Uint8List.fromList(decrypted);
  }

  Uint8List encryptFile(Uint8List data, Uint8List key) {
    return encryptBytes(data, key);
  }

  Uint8List decryptFile(Uint8List encryptedData, Uint8List key) {
    return decryptBytes(encryptedData, key);
  }

  Uint8List encryptString(String data, Uint8List key) {
    return encryptBytes(Uint8List.fromList(data.codeUnits), key);
  }

  String decryptToString(Uint8List encryptedData, Uint8List key) {
    final decrypted = decryptBytes(encryptedData, key);
    return String.fromCharCodes(decrypted);
  }

  List<int> _pbkdf2(
    String password,
    List<int> salt,
    int iterations,
    int keyLength,
  ) {
    final hmac = crypto.Hmac(crypto.sha256, password.codeUnits);

    var block = <int>[...salt];
    block.addAll([0, 0, 0, 1]);

    var u = hmac.convert(block).bytes;
    var output = List<int>.from(u);

    for (var i = 1; i < iterations; i++) {
      u = hmac.convert(u).bytes;
      for (var j = 0; j < output.length; j++) {
        output[j] ^= u[j];
      }
    }

    return output.sublist(0, keyLength);
  }

  bool verifyDecryption(Uint8List encryptedData, Uint8List key) {
    try {
      decryptBytes(encryptedData, key);
      return true;
    } catch (e) {
      debugPrint('E2ECryptoService: Decryption verification failed - $e');
      return false;
    }
  }
}
