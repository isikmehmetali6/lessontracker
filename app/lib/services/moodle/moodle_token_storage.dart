import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../core/constants/app_constants.dart';

/// Moodle token'larını güvenli şekilde saklar.
/// Her hesap için ayrı bir token kaydı tutulur.
/// ASLA şifre saklamaz — yalnızca Moodle REST token'ı.
class MoodleTokenStorage {
  static const _prefix = 'moodle_token_';
  static const _expiryPrefix = 'moodle_token_expiry_';
  static const _usernamePrefix = 'moodle_username_';
  static const _passwordPrefix = 'moodle_password_';

  static const _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
    iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock),
  );

  /// Belirli bir hesap için token kaydet
  Future<void> saveToken(String accountId, String token) async {
    await _storage.write(key: '$_prefix$accountId', value: token);
    await _storage.write(
      key: '$_expiryPrefix$accountId',
      value: DateTime.now().add(const Duration(days: 30)).toIso8601String(),
    );
  }

  /// Belirli bir hesabın token'ını oku
  Future<String?> getToken(String accountId) async {
    return _storage.read(key: '$_prefix$accountId');
  }

  /// Token'ın süresi dolmuş mu?
  Future<bool> isTokenExpired(String accountId) async {
    final expiryStr = await _storage.read(key: '$_expiryPrefix$accountId');
    if (expiryStr == null) return true;
    final expiry = DateTime.parse(expiryStr);
    return DateTime.now().isAfter(
      expiry.subtract(
        Duration(minutes: AppConstants.TOKEN_REFRESH_BEFORE_MINUTES),
      ),
    );
  }

  /// Token expiry süresini al
  Future<DateTime?> getTokenExpiry(String accountId) async {
    final expiryStr = await _storage.read(key: '$_expiryPrefix$accountId');
    if (expiryStr == null) return null;
    return DateTime.parse(expiryStr);
  }

  /// Kullanıcı credentials kaydet (token yenileme için)
  Future<void> saveCredentials(
    String accountId,
    String username,
    String password,
  ) async {
    await _storage.write(key: '$_usernamePrefix$accountId', value: username);
    await _storage.write(key: '$_passwordPrefix$accountId', value: password);
  }

  /// Kullanıcı credentials al
  Future<Map<String, String>?> getCredentials(String accountId) async {
    final username = await _storage.read(key: '$_usernamePrefix$accountId');
    final password = await _storage.read(key: '$_passwordPrefix$accountId');
    if (username == null || password == null) return null;
    return {'username': username, 'password': password};
  }

  /// Belirli bir hesabın token'ını sil
  Future<void> deleteToken(String accountId) async {
    await _storage.delete(key: '$_prefix$accountId');
    await _storage.delete(key: '$_expiryPrefix$accountId');
    await _storage.delete(key: '$_usernamePrefix$accountId');
    await _storage.delete(key: '$_passwordPrefix$accountId');
  }

  /// Tüm Moodle token'larını sil (hesap kapatma veya uygulama sıfırlama)
  Future<void> deleteAllTokens() async {
    final all = await _storage.readAll();
    for (final key in all.keys) {
      if (key.startsWith(_prefix) ||
          key.startsWith(_expiryPrefix) ||
          key.startsWith(_usernamePrefix) ||
          key.startsWith(_passwordPrefix)) {
        await _storage.delete(key: key);
      }
    }
  }
}
