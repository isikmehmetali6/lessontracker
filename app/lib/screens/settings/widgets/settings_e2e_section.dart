import 'package:flutter/material.dart';
import 'package:lesson_tracker/l10n/app_localizations.dart';
import '../../../core/theme/app_colors.dart';
import '../../../services/e2e_key_service.dart';
import '../../../services/biometric_service.dart';
import 'settings_shared.dart';
import 'security_questions_sheet.dart';

class SettingsE2ESection extends StatefulWidget {
  const SettingsE2ESection({super.key});

  @override
  State<SettingsE2ESection> createState() => _SettingsE2ESectionState();
}

class _SettingsE2ESectionState extends State<SettingsE2ESection> {
  bool _isE2EEnabled = false;
  bool _isBiometricEnabled = false;
  bool _biometricAvailable = false;
  String _biometricType = 'Biometric';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadStatus();
  }

  Future<void> _loadStatus() async {
    final keyService = E2EKeyService();
    final biometricService = BiometricService();

    final e2eEnabled = await keyService.isE2EEnabled();
    final biometricEnabled = await keyService.isBiometricEnabled();
    final biometricAvailable = await biometricService.isAvailable();
    final biometricType = await biometricService.getBiometricTypeName();

    if (mounted) {
      setState(() {
        _isE2EEnabled = e2eEnabled;
        _isBiometricEnabled = biometricEnabled;
        _biometricAvailable = biometricAvailable;
        _biometricType = biometricType;
        _isLoading = false;
      });
    }
  }

  Future<void> _toggleBiometric(bool value) async {
    final l10n = AppLocalizations.of(context)!;
    if (value) {
      final biometricService = BiometricService();
      final authenticated = await biometricService.authenticate(
        reason: l10n.biometricAuthReason(_biometricType),
      );

      if (authenticated) {
        await E2EKeyService().setBiometricEnabled(true);
        setState(() => _isBiometricEnabled = true);
        if (mounted) {
          _showSnackBar(l10n.biometricEnabled(_biometricType), Colors.green);
        }
      }
    } else {
      await E2EKeyService().setBiometricEnabled(false);
      setState(() => _isBiometricEnabled = false);
      if (mounted) {
        _showSnackBar(l10n.biometricDisabled(_biometricType), Colors.orange);
      }
    }
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: AppColors.emerald.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.lock_outline,
                    color: AppColors.emerald,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'Security & Encryption',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: isDark
                        ? AppColors.textPrimaryDark
                        : AppColors.textPrimaryLight,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),

          if (_isLoading)
            const Padding(
              padding: EdgeInsets.all(20),
              child: Center(child: CircularProgressIndicator()),
            )
          else ...[
            _buildE2EStatusTile(isDark),
            SettingsDivider(isDark: isDark),
            if (_isE2EEnabled) ...[
              _buildBiometricTile(isDark),
              SettingsDivider(isDark: isDark),
              _buildSecurityQuestionsTile(isDark),
            ],
          ],
        ],
      ),
    );
  }

  Widget _buildE2EStatusTile(bool isDark) {
    final l10n = AppLocalizations.of(context)!;
    return SettingsTile(
      icon: Icons.shield_outlined,
      iconColor: _isE2EEnabled ? AppColors.emerald : AppColors.orange,
      title: l10n.e2eEncryption,
      subtitle: _isE2EEnabled
          ? l10n.e2eDescription
          : l10n.e2eDescription,
      isDark: isDark,
      trailing: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: _isE2EEnabled
              ? AppColors.emerald.withValues(alpha: 0.15)
              : AppColors.orange.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              _isE2EEnabled ? Icons.check_circle : Icons.warning_amber,
              size: 16,
              color: _isE2EEnabled ? AppColors.emerald : AppColors.orange,
            ),
            const SizedBox(width: 4),
            Text(
              _isE2EEnabled ? l10n.active : l10n.inactive,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: _isE2EEnabled ? AppColors.emerald : AppColors.orange,
              ),
            ),
          ],
        ),
      ),
      onTap: () => _showE2EInfoDialog(isDark),
    );
  }

  Widget _buildBiometricTile(bool isDark) {
    final l10n = AppLocalizations.of(context)!;
    return SettingsTile(
      icon: Icons.fingerprint,
      iconColor: AppColors.blue,
      title: _biometricType,
      subtitle: _biometricAvailable
          ? (_isBiometricEnabled ? l10n.enabled : l10n.faceIdSubtitle)
          : l10n.notAvailableOnDevice,
      isDark: isDark,
      trailing: Switch(
        value: _isBiometricEnabled,
        onChanged: _biometricAvailable ? _toggleBiometric : null,
        activeThumbColor: AppColors.blue,
      ),
    );
  }

  Widget _buildSecurityQuestionsTile(bool isDark) {
    final l10n = AppLocalizations.of(context)!;
    return SettingsTile(
      icon: Icons.help_outline,
      iconColor: AppColors.purple,
      title: l10n.securityQuestions,
      subtitle: l10n.setUpSecurityQuestions,
      isDark: isDark,
      trailing: Icon(
        Icons.chevron_right,
        color: isDark ? Colors.grey.shade600 : Colors.grey.shade400,
      ),
      onTap: () => _showSecurityQuestionsDialog(isDark),
    );
  }

  void _showE2EInfoDialog(bool isDark) {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? AppColors.surfaceDark : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            const Icon(Icons.shield_outlined, color: AppColors.emerald),
            const SizedBox(width: 8),
            Text(
              l10n.e2eEncryption,
              style: TextStyle(
                color: isDark ? Colors.white : AppColors.textHeadingLight,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.e2eDescription,
              style: TextStyle(
                color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 16),
            _buildInfoRow(Icons.key, l10n.encryptionKey, l10n.aes256, isDark),
            const SizedBox(height: 8),
            _buildInfoRow(Icons.lock, l10n.keyStorage, l10n.deviceKeychain, isDark),
            const SizedBox(height: 8),
            _buildInfoRow(
              Icons.cloud_off,
              l10n.cloudAccess,
              l10n.encryptedOnly,
              isDark,
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.emerald.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.info_outline,
                    color: AppColors.emerald,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      l10n.evenDevCantAccess,
                      style: TextStyle(fontSize: 12, color: AppColors.emerald),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.close),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value, bool isDark) {
    return Row(
      children: [
        Icon(
          icon,
          size: 16,
          color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
        ),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: TextStyle(
            fontSize: 13,
            color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
          ),
        ),
        Text(
          value,
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }

  void _showSecurityQuestionsDialog(bool isDark) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => SecurityQuestionsSheet(isDark: isDark),
    );
  }
}
