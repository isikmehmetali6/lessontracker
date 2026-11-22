import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Supabase istemcisinin tek giriş noktası.
///
/// `SUPABASE_URL` ve `SUPABASE_PUBLISHABLE_KEY` (eski projelerde
/// `SUPABASE_ANON_KEY`) `--dart-define-from-file=.env` ile verilmezse ya da
/// başlatma başarısız olursa [client] null döner ve uygulama çevrimdışı /
/// misafir modunda çalışmaya devam eder.
class SupabaseBackend {
  SupabaseBackend._();

  /// Şifreli dosyaların tutulduğu Storage bucket'ı.
  static const String filesBucket = 'user-files';

  /// Auth e-postalarındaki linklerin (kayıt onayı, şifre sıfırlama, e-posta
  /// değişikliği) dönüş adresi. iOS `CFBundleURLTypes` ve Android
  /// intent-filter ile uygulamayı açar; supabase_flutter linki yakalayıp
  /// oturuma çevirir. Supabase panelinde Auth → URL Configuration altındaki
  /// "Redirect URLs" listesinde de bulunmalıdır.
  static const String authRedirectUrl = 'lessontracker://auth-callback';

  static bool _ready = false;
  static String? _host;

  static bool get isReady => _ready;

  /// Bağlantı kontrolünde DNS çözümlemesi yapılacak host.
  static String? get host => _host;

  static SupabaseClient? get client =>
      _ready ? Supabase.instance.client : null;

  static User? get currentUser => client?.auth.currentUser;

  // `flutter run --dart-define-from-file=.env` ile derlemeye gömülen değerler.
  // `.env` asset olarak paketlenmediği için (bkz. CI) asıl kaynak budur;
  // flutter_dotenv yalnızca asset olarak eklendiği ortamlarda devreye girer.
  static const String _defineUrl = String.fromEnvironment('SUPABASE_URL');
  static const String _defineKey =
      String.fromEnvironment('SUPABASE_PUBLISHABLE_KEY');
  static const String _defineAnonKey =
      String.fromEnvironment('SUPABASE_ANON_KEY');

  static String _env(String name, String defined) {
    if (defined.isNotEmpty) return defined;
    return dotenv.isInitialized ? (dotenv.maybeGet(name) ?? '') : '';
  }

  static Future<bool> initialize() async {
    if (_ready) return true;
    final url = _env('SUPABASE_URL', _defineUrl);
    final key = _env('SUPABASE_PUBLISHABLE_KEY', _defineKey).isNotEmpty
        ? _env('SUPABASE_PUBLISHABLE_KEY', _defineKey)
        : _env('SUPABASE_ANON_KEY', _defineAnonKey);
    if (url.isEmpty || key.isEmpty) {
      debugPrint(
        'Supabase: SUPABASE_URL / SUPABASE_PUBLISHABLE_KEY missing in .env',
      );
      return false;
    }
    try {
      await Supabase.initialize(url: url, publishableKey: key);
      _host = Uri.parse(url).host;
      _ready = true;
    } catch (e) {
      debugPrint('Supabase Init Warning: $e');
    }
    return _ready;
  }

  /// Oturumdaki kullanıcının auth kaydını siler (bkz. `delete_current_user`
  /// SQL fonksiyonu). `user_records` ve `profiles` satırları FK cascade ile
  /// silinir; Storage dosyaları çağırandan önce ayrıca temizlenmelidir.
  static Future<void> deleteCurrentUser() async {
    final c = client;
    if (c == null) throw Exception('Supabase is not configured');
    await c.rpc('delete_current_user');
  }
}
