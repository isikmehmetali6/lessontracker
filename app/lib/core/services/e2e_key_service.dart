import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'e2e_crypto_service.dart';

class E2EKeyService {
  static const String _keyE2EUserKey = 'e2e_user_key';
  static const String _keyE2EUserSalt = 'e2e_user_salt';
  static const String _keyE2EEnabled = 'e2e_enabled';
  static const String _keyBiometricEnabled = 'e2e_biometric_enabled';

  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  final E2ECryptoService _cryptoService = E2ECryptoService();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  static final E2EKeyService _instance = E2EKeyService._internal();
  factory E2EKeyService() => _instance;
  E2EKeyService._internal();

  Uint8List? _cachedKey;

  Future<bool> isE2EEnabled() async {
    final value = await _secureStorage.read(key: _keyE2EEnabled);
    return value == 'true';
  }

  Future<void> setE2EEnabled(bool enabled) async {
    await _secureStorage.write(key: _keyE2EEnabled, value: enabled.toString());
  }

  Future<bool> isBiometricEnabled() async {
    final value = await _secureStorage.read(key: _keyBiometricEnabled);
    return value == 'true';
  }

  Future<void> setBiometricEnabled(bool enabled) async {
    await _secureStorage.write(
      key: _keyBiometricEnabled,
      value: enabled.toString(),
    );
  }

  Future<void> initializeUserKey(String password) async {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception('No authenticated user');
    }

    final salt = _cryptoService.generateSalt();
    final derivedKey = _cryptoService.deriveKey(password, salt);
    final userKey = _cryptoService.generateKey();
    final encryptedKey = _cryptoService.encryptBytes(userKey, derivedKey);

    await _secureStorage.write(
      key: _keyE2EUserKey,
      value: base64Encode(userKey),
    );
    await _secureStorage.write(key: _keyE2EUserSalt, value: base64Encode(salt));

    await _firestore
        .collection('users')
        .doc(user.uid)
        .collection('system')
        .doc('e2e_key')
        .set({
          'encryptedKey': base64Encode(encryptedKey),
          'salt': base64Encode(salt),
          'createdAt': FieldValue.serverTimestamp(),
          'keyVersion': 1,
        });

    await setE2EEnabled(true);
    _cachedKey = userKey;
  }

  Future<bool> loadKeyFromCloud(String password) async {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception('No authenticated user');
    }

    try {
      final doc = await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('system')
          .doc('e2e_key')
          .get();

      if (!doc.exists || doc.data() == null) {
        debugPrint('E2EKeyService: No cloud key found for user');
        return false;
      }

      final data = doc.data()!;
      final encryptedKeyBase64 = data['encryptedKey'] as String;
      final saltBase64 = data['salt'] as String;

      final encryptedKey = base64Decode(encryptedKeyBase64);
      final salt = base64Decode(saltBase64);
      final derivedKey = _cryptoService.deriveKey(password, salt);

      Uint8List userKey;
      try {
        userKey = _cryptoService.decryptBytes(encryptedKey, derivedKey);
      } catch (e) {
        debugPrint('E2EKeyService: Failed to decrypt key - wrong password?');
        return false;
      }

      await _secureStorage.write(
        key: _keyE2EUserKey,
        value: base64Encode(userKey),
      );
      await _secureStorage.write(key: _keyE2EUserSalt, value: saltBase64);

      await setE2EEnabled(true);
      _cachedKey = userKey;
      return true;
    } catch (e) {
      debugPrint('E2EKeyService: Error loading key from cloud - $e');
      return false;
    }
  }

  Future<Uint8List?> getLocalKey() async {
    if (_cachedKey != null) {
      return _cachedKey;
    }

    final keyBase64 = await _secureStorage.read(key: _keyE2EUserKey);
    if (keyBase64 == null) {
      return null;
    }

    _cachedKey = Uint8List.fromList(base64Decode(keyBase64));
    return _cachedKey;
  }

  Future<void> storeKeyLocally(Uint8List key) async {
    await _secureStorage.write(key: _keyE2EUserKey, value: base64Encode(key));
    _cachedKey = key;
  }

  Future<bool> hasLocalKey() async {
    final key = await _secureStorage.read(key: _keyE2EUserKey);
    return key != null;
  }

  Future<void> changePassword(String oldPassword, String newPassword) async {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception('No authenticated user');
    }

    final currentKey = await getLocalKey();
    if (currentKey == null) {
      throw Exception('No local key found');
    }

    final oldSaltBase64 = await _secureStorage.read(key: _keyE2EUserSalt);
    if (oldSaltBase64 == null) {
      throw Exception('No salt found');
    }

    final oldSalt = base64Decode(oldSaltBase64);
    final oldDerivedKey = _cryptoService.deriveKey(oldPassword, oldSalt);

    final keyDoc = await _firestore
        .collection('users')
        .doc(user.uid)
        .collection('system')
        .doc('e2e_key')
        .get();

    if (keyDoc.data() == null) {
      throw Exception('No cloud key found');
    }

    Uint8List userKey;
    try {
      userKey = _cryptoService.decryptBytes(
        base64Decode(keyDoc.data()!['encryptedKey']),
        oldDerivedKey,
      );
    } catch (e) {
      throw Exception('Invalid old password');
    }

    final newSalt = _cryptoService.generateSalt();
    final newDerivedKey = _cryptoService.deriveKey(newPassword, newSalt);
    final newEncryptedKey = _cryptoService.encryptBytes(userKey, newDerivedKey);

    await _firestore
        .collection('users')
        .doc(user.uid)
        .collection('system')
        .doc('e2e_key')
        .update({
          'encryptedKey': base64Encode(newEncryptedKey),
          'salt': base64Encode(newSalt),
          'lastKeyChange': FieldValue.serverTimestamp(),
          'keyVersion': FieldValue.increment(1),
        });

    await _secureStorage.write(
      key: _keyE2EUserSalt,
      value: base64Encode(newSalt),
    );

    await storeKeyLocally(userKey);
  }

  Future<void> deleteKey() async {
    final user = _auth.currentUser;
    if (user != null) {
      try {
        await _firestore
            .collection('users')
            .doc(user.uid)
            .collection('system')
            .doc('e2e_key')
            .delete();
      } catch (e) {
        debugPrint('E2EKeyService: Error deleting cloud key - $e');
      }
    }

    await _secureStorage.delete(key: _keyE2EUserKey);
    await _secureStorage.delete(key: _keyE2EUserSalt);
    await _secureStorage.delete(key: _keyE2EEnabled);
    await _secureStorage.delete(key: _keyBiometricEnabled);
    _cachedKey = null;
  }

  void clearCache() {
    _cachedKey = null;
  }
}
