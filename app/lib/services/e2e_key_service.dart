import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../core/backend/supabase_backend.dart';
import 'cloud_records_service.dart';
import 'e2e_crypto_service.dart';

/// Kullanıcının E2E anahtarı: rastgele 32 bayt, parolayla türetilen anahtarla
/// sarılıp `system/e2e_key` bulut kaydında saklanır.
///
/// Sarma sürümleri (`kdfVersion`):
/// - 2: PBKDF2(UTF-8 parola) + AES-GCM
/// - yok/1 (legacy): PBKDF2(`codeUnits`) + AES-CBC → açıldığında v2'ye yeniden sarılır
class E2EKeyService {
  static const String _keyE2EUserKey = 'e2e_user_key';
  static const String _keyE2EUserSalt = 'e2e_user_salt';
  static const String _keyE2EOwner = 'e2e_user_key_owner';
  static const String _keyE2EEnabled = 'e2e_enabled';
  static const String _keyBiometricEnabled = 'e2e_biometric_enabled';

  static const int currentKdfVersion = 2;

  final FlutterSecureStorage _secureStorage;
  final E2ECryptoService _cryptoService;
  final CloudRecordsService _cloud;
  final String? Function() _currentUserId;

  static const String _systemCollection = 'system';
  static const String _keyDocId = 'e2e_key';

  static E2EKeyService? _instance;
  factory E2EKeyService() => _instance ??= E2EKeyService._internal();

  E2EKeyService._internal({
    FlutterSecureStorage? secureStorage,
    E2ECryptoService? cryptoService,
    CloudRecordsService? cloud,
    String? Function()? currentUserId,
  })  : _secureStorage = secureStorage ?? const FlutterSecureStorage(),
        _cryptoService = cryptoService ?? E2ECryptoService(),
        _cloud = cloud ?? CloudRecordsService(),
        _currentUserId =
            currentUserId ?? (() => SupabaseBackend.currentUser?.id);

  /// Testlerde singleton'ı sahte bağımlılıklarla değiştirir.
  @visibleForTesting
  static E2EKeyService overrideForTesting({
    FlutterSecureStorage? secureStorage,
    E2ECryptoService? cryptoService,
    CloudRecordsService? cloud,
    String? Function()? currentUserId,
  }) {
    return _instance = E2EKeyService._internal(
      secureStorage: secureStorage,
      cryptoService: cryptoService,
      cloud: cloud,
      currentUserId: currentUserId,
    );
  }

  @visibleForTesting
  static void resetForTesting() => _instance = null;

  Uint8List? _cachedKey;
  String? _cachedOwner;

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

  /// Bulutta bu kullanıcı için sarmalanmış bir anahtar var mı?
  Future<bool> hasCloudKey() async {
    if (_currentUserId() == null) return false;
    return await _cloud.get(_systemCollection, _keyDocId) != null;
  }

  Future<Map<String, dynamic>> _wrap(
    Uint8List userKey,
    String password,
  ) async {
    final salt = _cryptoService.generateSalt();
    final derivedKey = await _cryptoService.deriveKeyAsync(password, salt);
    final encryptedKey = _cryptoService.encryptGcm(userKey, derivedKey);
    return {
      'encryptedKey': base64Encode(encryptedKey),
      'salt': base64Encode(salt),
      'kdfVersion': currentKdfVersion,
    };
  }

  /// Sarılmış anahtarı açar; parola yanlışsa `null`.
  Future<({Uint8List key, bool legacy})?> _unwrap(
    Map<String, dynamic> data,
    String password,
  ) async {
    final encryptedKey = base64Decode(data['encryptedKey'] as String);
    final salt = base64Decode(data['salt'] as String);
    final kdfVersion = (data['kdfVersion'] as num?)?.toInt() ?? 1;

    try {
      if (kdfVersion >= 2) {
        final derived = await _cryptoService.deriveKeyAsync(password, salt);
        return (
          key: _cryptoService.decryptGcm(encryptedKey, derived),
          legacy: false,
        );
      }
      final derived = await _cryptoService.deriveKeyLegacyAsync(password, salt);
      return (
        key: _cryptoService.decryptLegacyCbc(encryptedKey, derived),
        legacy: true,
      );
    } catch (e) {
      debugPrint('E2EKeyService: Failed to unwrap key - wrong password?');
      return null;
    }
  }

  Future<void> initializeUserKey(String password) async {
    final uid = _currentUserId();
    if (uid == null) {
      throw Exception('No authenticated user');
    }

    final userKey = _cryptoService.generateKey();
    final wrapped = await _wrap(userKey, password);

    await _cloud.upsert(_systemCollection, _keyDocId, {
      ...wrapped,
      'createdAt': DateTime.now().toUtc().toIso8601String(),
      'keyVersion': 1,
    });

    await _storeLocally(userKey, uid);
    await setE2EEnabled(true);
  }

  /// Bulut anahtarını parolayla açıp yerelde saklar. Legacy sarılmışsa v2
  /// ile yeniden sarıp buluta yazar.
  Future<bool> loadKeyFromCloud(String password) async {
    final uid = _currentUserId();
    if (uid == null) {
      throw Exception('No authenticated user');
    }

    try {
      final record = await _cloud.get(_systemCollection, _keyDocId);
      if (record == null) {
        debugPrint('E2EKeyService: No cloud key found for user');
        return false;
      }

      final unwrapped = await _unwrap(record.data, password);
      if (unwrapped == null) return false;

      if (unwrapped.legacy) {
        try {
          final rewrapped = await _wrap(unwrapped.key, password);
          await _cloud.upsert(_systemCollection, _keyDocId, {
            ...record.data,
            ...rewrapped,
            'lastKeyChange': DateTime.now().toUtc().toIso8601String(),
          });
          debugPrint('E2EKeyService: Legacy key re-wrapped as v2');
        } catch (e) {
          debugPrint('E2EKeyService: Re-wrap failed (kept legacy) - $e');
        }
      }

      await _storeLocally(unwrapped.key, uid);
      await setE2EEnabled(true);
      return true;
    } catch (e) {
      debugPrint('E2EKeyService: Error loading key from cloud - $e');
      return false;
    }
  }

  /// Oturumdaki kullanıcıya ait yerel anahtar. Başka bir kullanıcıya ait
  /// anahtar varsa `null` döner (aynı cihazda hesap değişimi).
  Future<Uint8List?> getLocalKey() async {
    final uid = _currentUserId();
    if (uid == null) return null;

    if (_cachedKey != null && _cachedOwner == uid) {
      return _cachedKey;
    }

    final keyBase64 = await _secureStorage.read(key: _keyE2EUserKey);
    if (keyBase64 == null) return null;

    final owner = await _secureStorage.read(key: _keyE2EOwner);
    if (owner == null) {
      // Sahip bilgisi eklenmeden önce kaydedilmiş anahtar: mevcut davranışı
      // korumak için oturumdaki kullanıcıya atanır.
      await _secureStorage.write(key: _keyE2EOwner, value: uid);
    } else if (owner != uid) {
      return null;
    }

    _cachedKey = Uint8List.fromList(base64Decode(keyBase64));
    _cachedOwner = uid;
    return _cachedKey;
  }

  Future<void> _storeLocally(Uint8List key, String uid) async {
    await _secureStorage.write(key: _keyE2EUserKey, value: base64Encode(key));
    await _secureStorage.write(key: _keyE2EOwner, value: uid);
    // Salt artık yerelde kullanılmıyor (parola değişiminde buluttan okunur).
    await _secureStorage.delete(key: _keyE2EUserSalt);
    _cachedKey = key;
    _cachedOwner = uid;
  }

  Future<bool> hasLocalKey() async {
    return await getLocalKey() != null;
  }

  Future<void> changePassword(String oldPassword, String newPassword) async {
    final uid = _currentUserId();
    if (uid == null) {
      throw Exception('No authenticated user');
    }

    final keyDoc = await _cloud.get(_systemCollection, _keyDocId);
    if (keyDoc == null) {
      throw Exception('No cloud key found');
    }

    final unwrapped = await _unwrap(keyDoc.data, oldPassword);
    if (unwrapped == null) {
      throw Exception('Invalid old password');
    }

    final rewrapped = await _wrap(unwrapped.key, newPassword);
    final keyVersion = (keyDoc.data['keyVersion'] as num?)?.toInt() ?? 1;
    await _cloud.upsert(_systemCollection, _keyDocId, {
      ...keyDoc.data,
      ...rewrapped,
      'lastKeyChange': DateTime.now().toUtc().toIso8601String(),
      'keyVersion': keyVersion + 1,
    });

    await _storeLocally(unwrapped.key, uid);
  }

  Future<void> deleteKey() async {
    if (_currentUserId() != null) {
      try {
        await _cloud.delete(_systemCollection, _keyDocId);
      } catch (e) {
        debugPrint('E2EKeyService: Error deleting cloud key - $e');
      }
    }

    await _secureStorage.delete(key: _keyE2EUserKey);
    await _secureStorage.delete(key: _keyE2EUserSalt);
    await _secureStorage.delete(key: _keyE2EOwner);
    await _secureStorage.delete(key: _keyE2EEnabled);
    await _secureStorage.delete(key: _keyBiometricEnabled);
    _cachedKey = null;
    _cachedOwner = null;
  }

  void clearCache() {
    _cachedKey = null;
    _cachedOwner = null;
  }
}
