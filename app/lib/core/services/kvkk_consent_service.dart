import 'package:shared_preferences/shared_preferences.dart';

/// KVKK Açık Rıza Yönetim Servisi
/// Kullanıcının verdiği rıza tercihlerini merkezi olarak kontrol eder.
class KvkkConsentService {
  static final KvkkConsentService _instance = KvkkConsentService._internal();
  factory KvkkConsentService() => _instance;
  KvkkConsentService._internal();

  // SharedPreferences keys
  static const String keyConsentCamera = 'consent_camera';
  static const String keyConsentAudio = 'consent_audio';
  static const String keyConsentOcr = 'consent_ocr';
  static const String keyConsentNotifications = 'consent_notifications';
  static const String keyConsentCloudBackup = 'consent_cloud_backup';
  static const String keyKvkkConsentTimestamp = 'kvkk_consent_timestamp';
  static const String keyAcikRizaTimestamp = 'acik_riza_timestamp';
  static const String keyConsentDeclined = 'consent_declined';

  /// Kamera rızası verilmiş mi?
  Future<bool> hasCameraConsent() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(keyConsentCamera) ?? false;
  }

  /// Ses kaydı rızası verilmiş mi?
  Future<bool> hasAudioConsent() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(keyConsentAudio) ?? false;
  }

  /// OCR rızası verilmiş mi?
  Future<bool> hasOcrConsent() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(keyConsentOcr) ?? false;
  }

  /// Bildirim rızası verilmiş mi?
  Future<bool> hasNotificationsConsent() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(keyConsentNotifications) ?? false;
  }

  /// Bulut yedekleme rızası verilmiş mi?
  Future<bool> hasCloudBackupConsent() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(keyConsentCloudBackup) ?? false;
  }

  /// Belirli bir rıza tercihini güncelle
  Future<void> updateConsent(String key, bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(key, value);
  }

  /// Tüm rıza tercihlerini getir
  Future<Map<String, bool>> getAllConsents() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      keyConsentCamera: prefs.getBool(keyConsentCamera) ?? false,
      keyConsentAudio: prefs.getBool(keyConsentAudio) ?? false,
      keyConsentOcr: prefs.getBool(keyConsentOcr) ?? false,
      keyConsentNotifications: prefs.getBool(keyConsentNotifications) ?? false,
      keyConsentCloudBackup: prefs.getBool(keyConsentCloudBackup) ?? false,
    };
  }

  /// KVKK aydınlatma onayı verilmiş mi?
  Future<bool> hasKvkkConsent() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(keyKvkkConsentTimestamp) != null;
  }

  /// Tüm rızaları sıfırla
  Future<void> resetAllConsents() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(keyConsentCamera);
    await prefs.remove(keyConsentAudio);
    await prefs.remove(keyConsentOcr);
    await prefs.remove(keyConsentNotifications);
    await prefs.remove(keyConsentCloudBackup);
    await prefs.remove(keyKvkkConsentTimestamp);
    await prefs.remove(keyAcikRizaTimestamp);
    await prefs.remove(keyConsentDeclined);
  }
}
