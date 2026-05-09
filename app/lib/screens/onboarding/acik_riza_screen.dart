import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:lesson_tracker/l10n/app_localizations.dart';
import '../../../core/theme/app_colors.dart';

class AcikRizaScreen extends StatefulWidget {
  final VoidCallback onConsentGiven;
  final VoidCallback onSkip;

  const AcikRizaScreen({
    super.key,
    required this.onConsentGiven,
    required this.onSkip,
  });

  @override
  State<AcikRizaScreen> createState() => _AcikRizaScreenState();
}

class _AcikRizaScreenState extends State<AcikRizaScreen> {
  bool _cameraConsent = false;
  bool _audioConsent = false;
  bool _ocrConsent = false;
  bool _notificationsConsent = false;
  bool _cloudBackupConsent = false;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.amber.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Icon(
                        Icons.approval,
                        color: AppColors.amber,
                        size: 48,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      l10n.acikRizaTitle,
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        color: isDark
                            ? AppColors.textPrimaryDark
                            : AppColors.textPrimaryLight,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      l10n.acikRizaSubtitle,
                      style: TextStyle(
                        fontSize: 14,
                        height: 1.5,
                        color: isDark
                            ? AppColors.textSecondaryDark
                            : AppColors.textSecondaryLight,
                      ),
                    ),
                    const SizedBox(height: 32),
                    _buildConsentTile(
                      isDark: isDark,
                      icon: Icons.camera_alt,
                      iconColor: AppColors.orange,
                      title: l10n.consentCamera,
                      description: l10n.consentCameraDesc,
                      value: _cameraConsent,
                      onChanged: (v) =>
                          setState(() => _cameraConsent = v ?? false),
                      legalBasis: 'KVKK Madde 5/1 - Açık rıza',
                    ),
                    const SizedBox(height: 12),
                    _buildConsentTile(
                      isDark: isDark,
                      icon: Icons.mic,
                      iconColor: AppColors.purple,
                      title: l10n.consentAudio,
                      description: l10n.consentAudioDesc,
                      value: _audioConsent,
                      onChanged: (v) =>
                          setState(() => _audioConsent = v ?? false),
                      legalBasis: 'KVKK Madde 5/1 - Açık rıza',
                    ),
                    const SizedBox(height: 12),
                    _buildConsentTile(
                      isDark: isDark,
                      icon: Icons.document_scanner,
                      iconColor: AppColors.blue,
                      title: l10n.consentOcr,
                      description: l10n.consentOcrDesc,
                      value: _ocrConsent,
                      onChanged: (v) =>
                          setState(() => _ocrConsent = v ?? false),
                      legalBasis: 'KVKK Madde 5/1 - Açık rıza',
                    ),
                    const SizedBox(height: 12),
                    _buildConsentTile(
                      isDark: isDark,
                      icon: Icons.notifications,
                      iconColor: AppColors.red,
                      title: l10n.consentPush,
                      description: l10n.consentPushDesc,
                      value: _notificationsConsent,
                      onChanged: (v) =>
                          setState(() => _notificationsConsent = v ?? false),
                      legalBasis: 'KVKK Madde 5/1 - Açık rıza',
                    ),
                    const SizedBox(height: 12),
                    _buildConsentTile(
                      isDark: isDark,
                      icon: Icons.cloud_upload,
                      iconColor: AppColors.emerald,
                      title: l10n.consentCloud,
                      description: l10n.consentCloudDesc,
                      value: _cloudBackupConsent,
                      onChanged: (v) =>
                          setState(() => _cloudBackupConsent = v ?? false),
                      legalBasis: 'KVKK Madde 5/1 - Açık rıza',
                    ),
                    const SizedBox(height: 24),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: isDark
                            ? AppColors.surfaceDarkElevated
                            : Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isDark ? Colors.white10 : Colors.grey.shade200,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.info_outline,
                                size: 20,
                                color: isDark
                                    ? AppColors.textSecondaryDark
                                    : AppColors.textSecondaryLight,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                l10n.acikRizaImportant,
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: isDark
                                      ? AppColors.textPrimaryDark
                                      : AppColors.textPrimaryLight,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            l10n.acikRizaVoluntary,
                            style: TextStyle(
                              fontSize: 13,
                              height: 1.5,
                              color: isDark
                                  ? AppColors.textSecondaryDark
                                  : AppColors.textSecondaryLight,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: isDark ? AppColors.surfaceDark : Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _atLeastOneConsent
                          ? _saveConsentAndContinue
                          : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        disabledBackgroundColor: isDark ? Colors.grey.shade600 : Colors.grey.shade300,
                        disabledForegroundColor: isDark ? Colors.grey.shade400 : Colors.grey.shade500,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: Text(
                        l10n.acikRizaGiveAndContinue,
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  if (!_mandatoryConsentGiven) ...[
                    SizedBox(
                      width: double.infinity,
                      child: TextButton(
                        onPressed: () => _showSkipDialog(context),
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: Text(
                          l10n.acikRizaSkip,
                          style: TextStyle(
                            color: isDark
                                ? AppColors.textSecondaryDark
                                : AppColors.textSecondaryLight,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  bool get _atLeastOneConsent =>
      _cameraConsent ||
      _audioConsent ||
      _ocrConsent ||
      _notificationsConsent ||
      _cloudBackupConsent;

  bool get _mandatoryConsentGiven =>
      _cameraConsent && _audioConsent && _ocrConsent;

  Future<void> _saveConsentAndContinue() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(
      'acik_riza_timestamp',
      DateTime.now().millisecondsSinceEpoch,
    );
    await prefs.setBool('consent_camera', _cameraConsent);
    await prefs.setBool('consent_audio', _audioConsent);
    await prefs.setBool('consent_ocr', _ocrConsent);
    await prefs.setBool('consent_notifications', _notificationsConsent);
    await prefs.setBool('consent_cloud_backup', _cloudBackupConsent);
    await prefs.setBool('consent_mandatory_given', _mandatoryConsentGiven);

    HapticFeedback.mediumImpact();
    widget.onConsentGiven();
  }

  Future<void> _showSkipDialog(BuildContext context) async {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context)!;

    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? AppColors.surfaceDarkElevated : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          l10n.acikRizaWarning,
          style: TextStyle(
            color: isDark
                ? AppColors.textPrimaryDark
                : AppColors.textPrimaryLight,
            fontWeight: FontWeight.w700,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.acikRizaFeaturesDisabled,
              style: TextStyle(
                color: isDark
                    ? AppColors.textSecondaryDark
                    : AppColors.textSecondaryLight,
              ),
            ),
            const SizedBox(height: 12),
            _buildWarningItem(
              Icons.camera_alt,
              l10n.acikRizaFeatureCamera,
              isDark,
            ),
            _buildWarningItem(Icons.mic, l10n.acikRizaFeatureAudio, isDark),
            _buildWarningItem(
              Icons.document_scanner,
              l10n.acikRizaFeatureOcr,
              isDark,
            ),
            const SizedBox(height: 16),
            Text(
              l10n.acikRizaSettingsNote,
              style: TextStyle(
                fontSize: 12,
                color: isDark
                    ? AppColors.textSecondaryDark
                    : AppColors.textSecondaryLight,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.acikRizaCancel, style: TextStyle(color: AppColors.red)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.amber,
              foregroundColor: Colors.black,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(l10n.acikRizaLimitedMode),
          ),
        ],
      ),
    );

    if (result == true && mounted) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(
        'acik_riza_timestamp',
        DateTime.now().millisecondsSinceEpoch,
      );
      await prefs.setBool('consent_camera', false);
      await prefs.setBool('consent_audio', false);
      await prefs.setBool('consent_ocr', false);
      await prefs.setBool('consent_notifications', false);
      await prefs.setBool('consent_cloud_backup', false);
      await prefs.setBool('consent_mandatory_given', false);
      await prefs.setBool('consent_skipped', true);

      HapticFeedback.mediumImpact();
      widget.onSkip();
    }
  }

  Widget _buildWarningItem(IconData icon, String text, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 16, color: AppColors.amber),
          const SizedBox(width: 8),
          Text(
            text,
            style: TextStyle(
              fontSize: 13,
              color: isDark
                  ? AppColors.textPrimaryDark
                  : AppColors.textPrimaryLight,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConsentTile({
    required bool isDark,
    required IconData icon,
    required Color iconColor,
    required String title,
    required String description,
    required bool value,
    required ValueChanged<bool?> onChanged,
    required String legalBasis,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDarkElevated : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: value
              ? iconColor
              : (isDark ? Colors.white10 : Colors.grey.shade200),
          width: value ? 2 : 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => onChanged(!value),
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: iconColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: iconColor, size: 24),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              title,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: isDark
                                    ? AppColors.textPrimaryDark
                                    : AppColors.textPrimaryLight,
                              ),
                            ),
                          ),
                          Switch(
                            value: value,
                            onChanged: onChanged,
                            activeThumbColor: iconColor,
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        description,
                        style: TextStyle(
                          fontSize: 13,
                          height: 1.4,
                          color: isDark
                              ? AppColors.textSecondaryDark
                              : AppColors.textSecondaryLight,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        legalBasis,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: iconColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
