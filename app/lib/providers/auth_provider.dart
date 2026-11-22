import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../core/backend/supabase_backend.dart';
import '../core/database/database_helper.dart';
import '../models/app_user.dart';
import '../services/secure_storage_service.dart';
import '../services/e2e_key_service.dart';

class AuthProvider extends ChangeNotifier {
  GoTrueClient? _auth;
  StreamSubscription<AuthState>? _authSubscription;

  AppUser? _user;
  bool _isGuest = false;
  bool _isLoading = false;
  String? _error;

  AppUser? get user => _user;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _user != null || _isGuest;
  bool get isGuest => _isGuest;
  bool get isEmailVerified => _user?.emailVerified ?? false;

  AuthProvider() {
    _initializeAuth();
  }

  static const String _keyIsGuest = 'auth_is_guest';

  void _initializeAuth() {
    final client = SupabaseBackend.client;
    if (client == null) {
      debugPrint('AuthProvider Warning: Supabase Auth not available');
      return;
    }
    _auth = client.auth;
    _setUser(_auth!.currentUser);

    _authSubscription = _auth!.onAuthStateChange.listen((data) {
      _setUser(data.session?.user);
      notifyListeners();
    });
  }

  void _setUser(User? user) {
    _user = user == null ? null : AppUser.fromSupabase(user);
    if (_user != null) _isGuest = false;
  }

  /// Supabase oturumu varsa profil tablosunu günceller (hata yutulur).
  Future<void> _updateProfile(Map<String, dynamic> values) async {
    final uid = _auth?.currentUser?.id;
    final client = SupabaseBackend.client;
    if (uid == null || client == null) return;
    try {
      await client.from('profiles').update(values).eq('id', uid);
    } catch (e) {
      debugPrint('Error updating profile row: $e');
    }
  }

  String _nowIso() => DateTime.now().toUtc().toIso8601String();

  bool _guestRestored = false;

  /// Uygulama yeniden başlayınca misafir modunu geri yükle (persistence)
  Future<void> ensureGuestRestored() async {
    if (_guestRestored) return;
    _guestRestored = true;
    try {
      final prefs = await SharedPreferences.getInstance();
      if (prefs.getBool(_keyIsGuest) == true) {
        _isGuest = true;
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error restoring guest state: $e');
    }
  }

  Future<void> loginAsGuest() async {
    _isGuest = true;
    _error = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyIsGuest, true);
    notifyListeners();
  }

  /// Hata mesajını temizle — ekran geçişlerinde çağır
  void clearError() {
    if (_error != null) {
      _error = null;
      notifyListeners();
    }
  }

  /// Şifre sıfırlama emaili gönder
  Future<bool> resetPassword(String email) async {
    if (_auth == null) {
      _error = 'Authentication service unavailable.';
      notifyListeners();
      return false;
    }
    if (email.trim().isEmpty) {
      _error = 'Please enter your email address.';
      notifyListeners();
      return false;
    }
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _auth!.resetPasswordForEmail(email.trim());
      _isLoading = false;
      notifyListeners();
      return true;
    } on AuthException catch (e) {
      _error = _mapAuthError(e);
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Email doğrulama emaili gönder
  Future<bool> sendVerificationEmail() async {
    if (_user == null) {
      _error = 'No user logged in.';
      notifyListeners();
      return false;
    }
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final email = _user!.email;
      if (_auth == null || email == null) {
        throw Exception('Authentication service unavailable.');
      }
      await _auth!.resend(type: OtpType.signup, email: email);
      _isLoading = false;
      notifyListeners();
      return true;
    } on AuthException catch (e) {
      _error = _mapAuthError(e);
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Kullanıcı bilgilerini yenile (email verified durumu için)
  Future<bool> refreshUser() async {
    if (_user == null) return false;
    try {
      final response = await _auth?.getUser();
      _setUser(response?.user ?? _auth?.currentUser);
      notifyListeners();
      return _user?.emailVerified ?? false;
    } catch (e) {
      debugPrint('Error refreshing user: $e');
      return false;
    }
  }

  Future<bool> signIn(String email, String password) async {
    if (_auth == null) {
      _error = 'Authentication service unavailable. Try Guest mode.';
      notifyListeners();
      return false;
    }
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _auth!.signInWithPassword(
        email: email,
        password: password,
      );
      _setUser(response.user);

      if (_user != null) {
        // Update last login
        await _updateProfile({'last_login': _nowIso()});

        // Load E2E key from cloud if not available locally
        await _ensureE2EKey(password);
      }

      // Check email verification
      if (_user != null && !_user!.emailVerified) {
        _error =
            'Please verify your email before logging in. Check your inbox for the verification link.';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      _isLoading = false;
      notifyListeners();
      return true;
    } on AuthException catch (e) {
      debugPrint('SignIn Auth Error: ${e.code} - ${e.message}');
      _error = _mapAuthError(e);
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      debugPrint('SignIn General Error: $e');
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  /// Yerelde E2E anahtarı yoksa buluttan çözer; bulutta da yoksa (e-posta
  /// onayı açıkken kayıt sırasında oturum oluşmadığı için ilk girişte) yeni
  /// anahtar üretir.
  Future<void> _ensureE2EKey(String password) async {
    try {
      final keyService = E2EKeyService();
      if (await keyService.hasLocalKey()) {
        debugPrint('Local E2E key found');
        return;
      }
      if (await keyService.hasCloudKey()) {
        debugPrint('No local E2E key found, loading from cloud...');
        final keyLoaded = await keyService.loadKeyFromCloud(password);
        debugPrint(
          keyLoaded
              ? 'E2E key loaded from cloud successfully'
              : 'Failed to decrypt E2E key from cloud',
        );
      } else {
        await keyService.initializeUserKey(password);
        debugPrint('E2E key initialized on first login');
      }
    } catch (e) {
      debugPrint('E2E key loading error: $e');
    }
  }

  Future<bool> signUp(String email, String password, String name) async {
    if (_auth == null) {
      _error = 'Authentication service unavailable. Try Guest mode.';
      notifyListeners();
      return false;
    }
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // `name` metadata'sı `handle_new_user` trigger'ı ile profiles
      // tablosuna da yazılır. E-posta onayı açıksa Supabase doğrulama
      // e-postasını kendisi gönderir.
      final response = await _auth!.signUp(
        email: email,
        password: password,
        data: {'name': name},
      );

      // E-posta onayı kapalıysa oturum hemen açılır; açıksa anahtar ilk
      // girişte _ensureE2EKey ile üretilir.
      if (response.session != null) {
        try {
          await E2EKeyService().initializeUserKey(password);
          debugPrint('E2E key initialized for new user');
        } catch (e) {
          debugPrint('E2E key initialization error: $e');
        }
      }

      _isLoading = false;
      notifyListeners();
      return true;
    } on AuthException catch (e) {
      debugPrint('SignUp Auth Error: ${e.code} - ${e.message}');
      _isLoading = false;
      _error = _mapAuthError(e);
      notifyListeners();
      return false;
    } catch (e) {
      debugPrint('General SignUp Error: $e');
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  final List<Future<void> Function()> _onSignOutCallbacks = [];

  void addSignOutCallback(Future<void> Function() callback) {
    _onSignOutCallbacks.add(callback);
  }

  Future<void> signOut() async {
    // 0. known_user flag'ini sıfırla — sonraki girişte restore dialog tekrar açılsın
    try {
      final uid = _user?.uid;
      if (uid != null) {
        await SecureStorageService.deleteToken('known_user_$uid');
      }
    } catch (e) {
      debugPrint('Error clearing known_user flag: $e');
    }

    // 1. Yerel veritabanını temizle — kullanıcı verisi karışmasın
    try {
      await DatabaseHelper().clearAllData();
    } catch (e) {
      debugPrint('Error clearing data on sign out: $e');
    }

    // 2. Provider'ları sıfırla
    for (final callback in _onSignOutCallbacks) {
      try {
        await callback();
      } catch (e) {
        debugPrint('Error resetting provider on sign out: $e');
      }
    }

    // 3. Misafir flag'ini temizle
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_keyIsGuest);
    } catch (e) {
      debugPrint('Error clearing guest flag: $e');
    }

    // 4. Supabase çıkışı
    try {
      await _auth?.signOut();
    } catch (e) {
      debugPrint('Error signing out: $e');
    }

    // 5. E2E key cache temizle — RAM'deki şifre anahtarını sıfırla
    E2EKeyService().clearCache();

    _user = null;
    _isGuest = false;
    _error = null;
    _isLoading = false;
    notifyListeners();
  }

  Future<bool> updateUserProfile(String name) async {
    if (_user == null) return false;
    _isLoading = true;
    notifyListeners();

    try {
      // Update auth metadata (displayName kaynağı)
      final response = await _auth!.updateUser(
        UserAttributes(data: {'name': name}),
      );
      _setUser(response.user);

      // Update profile row
      await _updateProfile({'name': name, 'updated_at': _nowIso()});

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Error updating profile: $e');
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateUserEmail(String newEmail) async {
    if (_user == null) return false;
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Supabase yeni adrese onay bağlantısı gönderir; e-posta onaydan
      // sonra değişir.
      final response = await _auth!.updateUser(
        UserAttributes(email: newEmail),
      );
      _setUser(response.user);

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Error updating email: $e');
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateUserPassword(
    String currentPassword,
    String newPassword,
  ) async {
    if (_user == null || _user!.email == null) return false;
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Re-authenticate first (mevcut şifre doğrulaması)
      await _auth!.signInWithPassword(
        email: _user!.email!,
        password: currentPassword,
      );

      // Update password
      await _auth!.updateUser(UserAttributes(password: newPassword));

      _isLoading = false;
      notifyListeners();
      return true;
    } on AuthException catch (e) {
      debugPrint('Error updating password: ${e.code}');
      _error = _mapAuthError(e);
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      debugPrint('Error updating password: $e');
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Email format doğrula
  static bool isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    super.dispose();
  }

  /// Hesabı sil (KVKK Madde 7 - Silme Hakkı)
  /// Not: Bulut verisi için SyncService.deleteAllUserData() ayrıca çağrılmalı
  Future<void> deleteAccount() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // 1. Auth hesabını sil (SyncService.deleteAllUserData zaten sildiyse
      //    tekrar denemek zararsızdır) ve yerel oturumu kapat
      if (_auth?.currentUser != null) {
        try {
          await SupabaseBackend.deleteCurrentUser();
        } catch (e) {
          debugPrint('Error deleting auth user: $e');
        }
        try {
          await _auth!.signOut(scope: SignOutScope.local);
        } catch (e) {
          debugPrint('Error clearing local session: $e');
        }
      }

      // 2. Local database'i temizle
      await DatabaseHelper().clearAllData();

      // 2. SharedPreferences'ı temizle
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();

      // 3. E2E encryption key sil — KVKK gereği tüm kullanıcı verisi temizlenmeli
      await E2EKeyService().deleteKey();

      // 4. Auth state'i sıfırla
      _user = null;
      _isGuest = false;

      _isLoading = false;
      notifyListeners();

      debugPrint('AuthProvider: Account deleted locally');
    } catch (e) {
      debugPrint('Error deleting account: $e');
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  String _mapAuthError(AuthException e) {
    if (e is AuthRetryableFetchException) {
      return 'Network error. Please check your internet connection.';
    }
    switch (e.code) {
      case 'invalid_credentials':
        return 'Incorrect email or password.';
      case 'user_not_found':
        return 'No user found with this email.';
      case 'email_not_confirmed':
        return 'Please verify your email before logging in. Check your inbox for the verification link.';
      case 'user_already_exists':
      case 'email_exists':
        return 'Email is already registered.';
      case 'email_address_invalid':
      case 'validation_failed':
        return 'Invalid email address.';
      case 'weak_password':
        return 'Password is too weak. Use at least 6 characters.';
      case 'over_request_rate_limit':
      case 'over_email_send_rate_limit':
        return 'Too many attempts. Please try again later.';
      default:
        return 'Authentication failed. Please try again. (Error: ${e.code ?? e.message})';
    }
  }
}
