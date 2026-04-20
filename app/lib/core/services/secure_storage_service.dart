import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorageService {
  static const _secureStorage = FlutterSecureStorage(
     aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );

  /// Sensitive Data (Tokens, Secrets)
  static Future<void> saveToken(String key, String value) async {
    await _secureStorage.write(key: key, value: value);
  }

  static Future<String?> getToken(String key) async {
    return await _secureStorage.read(key: key);
  }

  static Future<void> deleteToken(String key) async {
    await _secureStorage.delete(key: key);
  }
  
  static Future<void> setBool(String key, bool value) async {
    await _secureStorage.write(key: key, value: value.toString());
  }
  
  static Future<bool> getBool(String key, {bool defaultValue = false}) async {
    final value = await _secureStorage.read(key: key);
    if (value == null) return defaultValue;
    return value.toLowerCase() == 'true';
  }

  static Future<void> clearAllSensitiveData() async {
    await _secureStorage.deleteAll();
  }
}
