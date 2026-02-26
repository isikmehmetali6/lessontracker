import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';
import 'package:flutter/foundation.dart';
import '../core/database/database_helper.dart';

class AuthProvider extends ChangeNotifier {
  FirebaseAuth? _auth;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  User? _user;
  bool _isGuest = false;
  bool _isLoading = false;
  String? _error;

  User? get user => _user;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _user != null || _isGuest;
  bool get isGuest => _isGuest;

  AuthProvider() {
    _initializeAuth();
  }

  void _initializeAuth() {
    try {
      _auth = FirebaseAuth.instance;
      

      



      _auth?.authStateChanges().listen((User? user) {
        _user = user;
        if (_user != null) _isGuest = false;
        notifyListeners();
      });
    } catch (e) {
      debugPrint('AuthProvider Warning: Firebase Auth not available: $e');
      _auth = null;
    }
  }

  void loginAsGuest() {
    _isGuest = true;
    _error = null;
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
        _firestore.collection('users').doc(_auth!.currentUser!.uid).update({
          'lastLogin': FieldValue.serverTimestamp(),
        }).catchError((e) {
          debugPrint('Error updating lastLogin: $e');
        });
      }

      _isLoading = false;
      notifyListeners();
      return true;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'keychain-error' && !kIsWeb && Platform.isMacOS) {
         debugPrint('Caught Keychain Error on MacOS. Checking if user is actually logged in...');
         // Sometimes the auth succeeds in memory but fails to write to keychain.
         if (_auth?.currentUser != null) {
            debugPrint('User IS logged in specifically. Ignoring keychain error.');
             _isLoading = false;
             _user = _auth?.currentUser;
            notifyListeners();
            return true;
         }
         _error = 'MacOS Debug Keychain Error. Application is unsigned. Please use Guest Login or ignore this if you are developing.';
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
        password: password
      );
      
      if (credential.user != null) {
        // Update Display Name
        try {
          await credential.user!.updateDisplayName(name);
          
          // Create User Document
          await _firestore.collection('users').doc(credential.user!.uid).set({
            'name': name,
            'email': email,
            'createdAt': FieldValue.serverTimestamp(),
            'lastLogin': FieldValue.serverTimestamp(),
          });
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
         debugPrint('Caught Keychain Error during SignUp on MacOS. Checking if user is actually logged in...');
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

  /// Çıkış yapıldığında provider'ları sıfırlamak için callback'ler
  List<Future<void> Function()> onSignOutCallbacks = [];

  Future<void> signOut() async {
    // 0. known_user flag'ini sıfırla — sonraki girişte restore dialog tekrar açılsın
    try {
      final uid = _user?.uid;
      if (uid != null) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.remove('known_user_$uid');
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
    for (final callback in onSignOutCallbacks) {
      try {
        await callback();
      } catch (e) {
        debugPrint('Error resetting provider on sign out: $e');
      }
    }

    // 3. Firebase çıkışı
    await _auth?.signOut();
    _user = null;
    _isGuest = false;
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
      
      // Update Firestore
      await _firestore.collection('users').doc(_user!.uid).update({
        'email': newEmail,
        'updatedAt': FieldValue.serverTimestamp(),
      });

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

  Future<bool> updateUserPassword(String currentPassword, String newPassword) async {
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
