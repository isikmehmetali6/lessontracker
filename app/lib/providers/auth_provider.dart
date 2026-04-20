import 'dart:async';
import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/database/database_helper.dart';
import '../core/services/secure_storage_service.dart';
import '../core/services/e2e_key_service.dart';
import '../core/services/e2e_migration_service.dart';

class AuthProvider extends ChangeNotifier {
  FirebaseAuth? _auth;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  StreamSubscription<User?>? _authSubscription;

  User? _user;
  bool _isGuest = false;
  bool _isLoading = false;
  String? _error;

  User? get user => _user;
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
    try {
      _auth = FirebaseAuth.instance;

      _authSubscription = _auth?.authStateChanges().listen((User? user) {
        _user = user;
        if (_user != null) _isGuest = false;
        notifyListeners();
      });
    } catch (e) {
      debugPrint('AuthProvider Warning: Firebase Auth not available: $e');
      _auth = null;
    }
  }

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

  void loginAsGuest() {
    _isGuest = true;
    _error = null;
    SharedPreferences.getInstance().then(
      (prefs) => prefs.setBool(_keyIsGuest, true),
    );
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
      await _auth!.sendPasswordResetEmail(email: email.trim());
      _isLoading = false;
      notifyListeners();
      return true;
    } on FirebaseAuthException catch (e) {
      _error = _mapFirebaseError(e.code);
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
      await _user!.sendEmailVerification();
      _isLoading = false;
      notifyListeners();
      return true;
    } on FirebaseAuthException catch (e) {
      _error = _mapFirebaseError(e.code);
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
      await _user!.reload();
      _user = _auth?.currentUser;
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
      await _auth!.signInWithEmailAndPassword(email: email, password: password);

      // Update last login
      if (_auth!.currentUser != null) {
        // Run unawaited to not block UI
        _firestore
            .collection('users')
            .doc(_auth!.currentUser!.uid)
            .update({'lastLogin': FieldValue.serverTimestamp()})
            .catchError((e) {
              debugPrint('Error updating lastLogin: $e');
            });

        // Load E2E key from cloud if not available locally
        try {
          final keyService = E2EKeyService();
          final hasLocalKey = await keyService.hasLocalKey();
          if (!hasLocalKey) {
            debugPrint('No local E2E key found, loading from cloud...');
            final keyLoaded = await keyService.loadKeyFromCloud(password);
            if (keyLoaded) {
              debugPrint('E2E key loaded from cloud successfully');
              // Trigger background migration if needed
              E2EMigrationService().migrateLegacyFiles();
            } else {
              debugPrint(
                'Failed to load E2E key from cloud - may be first login',
              );
            }
          } else {
            debugPrint('Local E2E key found');
          }
        } catch (e) {
          debugPrint('E2E key loading error: $e');
        }
      }

      // Check email verification
      await _user!.reload();
      _user = _auth?.currentUser;
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
    } on FirebaseAuthException catch (e) {
      if (e.code == 'keychain-error' && !kIsWeb && Platform.isMacOS) {
        debugPrint(
          'Caught Keychain Error on MacOS. Checking if user is actually logged in...',
        );
        // Sometimes the auth succeeds in memory but fails to write to keychain.
        if (_auth?.currentUser != null) {
          debugPrint(
            'User IS logged in specifically. Ignoring keychain error.',
          );
          _isLoading = false;
          _user = _auth?.currentUser;
          notifyListeners();
          return true;
        }
        _error =
            'MacOS Debug Keychain Error. Application is unsigned. Please use Guest Login or ignore this if you are developing.';
      } else {
        _error = _mapFirebaseError(e.code);
      }
      debugPrint('SignIn FirebaseAuth Error: ${e.code} - ${e.message}');
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
      final credential = await _auth!.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (credential.user != null) {
        // Send email verification
        try {
          await credential.user!.sendEmailVerification();
        } catch (e) {
          debugPrint('Error sending verification email: $e');
        }

        // Update Display Name
        try {
          await credential.user!.updateDisplayName(name);

          // Create User Document
          await _firestore.collection('users').doc(credential.user!.uid).set({
            'name': name,
            'email': email,
            'createdAt': FieldValue.serverTimestamp(),
            'lastLogin': FieldValue.serverTimestamp(),
            'emailVerified': false,
          });

          // Initialize E2E encryption key
          try {
            await E2EKeyService().initializeUserKey(password);
            debugPrint('E2E key initialized for new user');
          } catch (e) {
            debugPrint('E2E key initialization error: $e');
          }
        } catch (e) {
          debugPrint('Firestore/Profile Update Error: $e');
          // Proceed even if profile save fails, as Auth is successful
        }
      }

      _isLoading = false;
      notifyListeners();
      return true;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'keychain-error' && !kIsWeb && Platform.isMacOS) {
        debugPrint(
          'Caught Keychain Error during SignUp on MacOS. Checking if user is actually logged in...',
        );
        if (_auth?.currentUser != null) {
          debugPrint('User IS logged in (SignUp). Ignoring keychain error.');
          _isLoading = false;
          _user = _auth?.currentUser;
          notifyListeners();
          return true;
        }
      }
      debugPrint('FirebaseAuth Error: ${e.code} - ${e.message}');
      _isLoading = false;
      _error = _mapFirebaseError(e.code);
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

    // 4. Firebase çıkışı
    await _auth?.signOut();
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
      // Update Firebase Auth Profile
      await _user!.updateDisplayName(name);

      // Update Firestore Document
      await _firestore.collection('users').doc(_user!.uid).update({
        'name': name,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // Reload user to get fresh data
      await _user!.reload();
      _user = _auth?.currentUser;

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
      await _user!.verifyBeforeUpdateEmail(newEmail);
      // Firestore email will be updated when user confirms via authStateChanges

      await _user!.reload();
      _user = _auth?.currentUser;

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
      // Re-authenticate first
      final credential = EmailAuthProvider.credential(
        email: _user!.email!,
        password: currentPassword,
      );
      await _user!.reauthenticateWithCredential(credential);

      // Update password
      await _user!.updatePassword(newPassword);

      _isLoading = false;
      notifyListeners();
      return true;
    } on FirebaseAuthException catch (e) {
      debugPrint('Error updating password: ${e.code}');
      _error = _mapFirebaseError(e.code);
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
  /// Not: Firebase verisi için SyncService.deleteAllUserData() ayrıca çağrılmalı
  Future<void> deleteAccount() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // 1. Local database'i temizle
      await DatabaseHelper().clearAllData();

      // 2. SharedPreferences'ı temizle
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();

      // 3. Auth state'i sıfırla
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

  String _mapFirebaseError(String code) {
    switch (code) {
      case 'user-not-found':
        return 'No user found with this email.';
      case 'wrong-password':
        return 'Incorrect password.';
      case 'email-already-in-use':
        return 'Email is already registered.';
      case 'invalid-email':
        return 'Invalid email address.';
      case 'weak-password':
        return 'Password is too weak. Use at least 6 characters.';
      case 'too-many-requests':
        return 'Too many attempts. Please try again later.';
      case 'network-request-failed':
        return 'Network error. Please check your internet connection.';
      default:
        return 'Authentication failed. Please try again. (Error: $code)';
    }
  }
}
