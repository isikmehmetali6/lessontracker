import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'secure_storage_service.dart';

/// Biyometrik kilit servisi (Face ID / Touch ID / PIN)
class AppLockService {
  static final LocalAuthentication _auth = LocalAuthentication();
  static const String _lockEnabledKey = 'app_lock_enabled';

  /// Biyometrik doğrulama mevcut mu?
  static Future<bool> isBiometricAvailable() async {
    if (kIsWeb) return false;
    try {
      final canAuth = await _auth.canCheckBiometrics;
      final isDeviceSupported = await _auth.isDeviceSupported();
      return canAuth || isDeviceSupported;
    } catch (e, stackTrace) {
      debugPrint(
        'Error checking biometric availability: $e\nStack: $stackTrace',
      );
      return false;
    }
  }

  /// Kullanılabilir biyometrik türlerini getir
  static Future<List<BiometricType>> getAvailableBiometrics() async {
    if (kIsWeb) return [];
    try {
      return await _auth.getAvailableBiometrics();
    } catch (e, stackTrace) {
      debugPrint('Error getting available biometrics: $e\nStack: $stackTrace');
      return [];
    }
  }

  /// Kimlik doğrulama yap
  static Future<bool> authenticate({
    String reason = 'Authenticate to access the app',
  }) async {
    if (kIsWeb) return false;
    try {
      return await _auth.authenticate(
        localizedReason: reason,
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: false, // PIN/pattern de kabul et
        ),
      );
    } catch (e, stackTrace) {
      debugPrint('Error authenticating: $e\nStack: $stackTrace');
      return false;
    }
  }

  static Future<bool> isLockEnabled() async {
    return await SecureStorageService.getBool(
      _lockEnabledKey,
      defaultValue: false,
    );
  }

  /// Kilidi aç/kapat
  static Future<void> setLockEnabled(bool enabled) async {
    await SecureStorageService.setBool(_lockEnabledKey, enabled);
  }
}

/// Kilit ekranı — uygulama açıldığında gösterilir
class AppLockScreen extends StatefulWidget {
  final VoidCallback onUnlocked;

  const AppLockScreen({super.key, required this.onUnlocked});

  @override
  State<AppLockScreen> createState() => _AppLockScreenState();
}

class _AppLockScreenState extends State<AppLockScreen> {
  bool _isAuthenticating = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _tryAuthenticate());
  }

  Future<void> _tryAuthenticate() async {
    if (_isAuthenticating) return;
    setState(() => _isAuthenticating = true);
    try {
      final available = await AppLockService.isBiometricAvailable();
      if (!available) {
        widget.onUnlocked();
        return;
      }
      final success = await AppLockService.authenticate();
      if (success) {
        widget.onUnlocked();
      }
    } finally {
      if (mounted) setState(() => _isAuthenticating = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.lock_outline,
              size: 64,
              color: isDark ? Colors.white70 : Colors.grey.shade600,
            ),
            const SizedBox(height: 24),
            Text(
              'Lesson Tracker',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: isDark ? Colors.white : Colors.grey.shade800,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Authenticate to continue',
              style: TextStyle(
                fontSize: 14,
                color: isDark ? Colors.white54 : Colors.grey.shade500,
              ),
            ),
            const SizedBox(height: 40),
            if (_isAuthenticating)
              const CircularProgressIndicator()
            else
              FilledButton.icon(
                onPressed: _tryAuthenticate,
                icon: const Icon(Icons.fingerprint),
                label: const Text('Unlock'),
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 16,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}