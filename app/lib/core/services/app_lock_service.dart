import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Biyometrik kilit servisi (Face ID / Touch ID / PIN)
class AppLockService {
  static final LocalAuthentication _auth = LocalAuthentication();
  static const String _lockEnabledKey = 'app_lock_enabled';

  /// Biyometrik doğrulama mevcut mu?
  static Future<bool> isBiometricAvailable() async {
    try {
      final canAuth = await _auth.canCheckBiometrics;
      final isDeviceSupported = await _auth.isDeviceSupported();
      return canAuth || isDeviceSupported;
    } catch (_) {
      return false;
    }
  }

  /// Kullanılabilir biyometrik türlerini getir
  static Future<List<BiometricType>> getAvailableBiometrics() async {
    try {
      return await _auth.getAvailableBiometrics();
    } catch (_) {
      return [];
    }
  }

  /// Kimlik doğrulama yap
  static Future<bool> authenticate({String reason = 'Authenticate to access the app'}) async {
    try {
      return await _auth.authenticate(
        localizedReason: reason,
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: false, // PIN/pattern de kabul et
        ),
      );
    } catch (_) {
      return false;
    }
  }

  /// Kilit etkin mi?
  static Future<bool> isLockEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_lockEnabledKey) ?? false;
  }

  /// Kilidi aç/kapat
  static Future<void> setLockEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_lockEnabledKey, enabled);
  }
}

/// Kilit ekranı — uygulama açıldığında gösterilir
class AppLockScreen extends StatelessWidget {
  final VoidCallback onUnlocked;

  const AppLockScreen({super.key, required this.onUnlocked});

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
            FilledButton.icon(
              onPressed: () async {
                final success = await AppLockService.authenticate();
                if (success) onUnlocked();
              },
              icon: const Icon(Icons.fingerprint),
              label: const Text('Unlock'),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
