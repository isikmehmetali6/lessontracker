import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lesson_tracker/l10n/app_localizations.dart';
import '../../core/theme/app_colors.dart';
import '../../core/services/kvkk_consent_service.dart';

/// KVKK Rıza Yönetimi Ekranı
/// Kullanıcı açık rıza tercihlerini buradan değiştirebilir (geri çekme hakkı).
class ConsentManagementScreen extends StatefulWidget {
  const ConsentManagementScreen({super.key});

  @override
  State<ConsentManagementScreen> createState() =>
      _ConsentManagementScreenState();
}

class _ConsentManagementScreenState extends State<ConsentManagementScreen> {
  final KvkkConsentService _consentService = KvkkConsentService();

  bool _cameraConsent = false;
  bool _audioConsent = false;
  bool _ocrConsent = false;
  bool _notificationsConsent = false;
  bool _cloudBackupConsent = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadConsents();
  }

  Future<void> _loadConsents() async {
    final consents = await _consentService.getAllConsents();
    if (mounted) {
      setState(() {
        _cameraConsent =
            consents[KvkkConsentService.keyConsentCamera] ?? false;
        _audioConsent =
            consents[KvkkConsentService.keyConsentAudio] ?? false;
        _ocrConsent =
            consents[KvkkConsentService.keyConsentOcr] ?? false;
        _notificationsConsent =
            consents[KvkkConsentService.keyConsentNotifications] ?? false;
        _cloudBackupConsent =
            consents[KvkkConsentService.keyConsentCloudBackup] ?? false;
        _isLoading = false;
      });
    }
  }

  Future<void> _updateConsent(String key, bool value) async {
    await _consentService.updateConsent(key, value);
    HapticFeedback.lightImpact();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        backgroundColor:
            isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: isDark
                ? AppColors.textPrimaryDark
                : AppColors.textPrimaryLight,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          l10n.consentManagementTitle,
          style: TextStyle(
            color: isDark
                ? AppColors.textPrimaryDark
                : AppColors.textPrimaryLight,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.consentManagementSubtitle,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      color: isDark
                          ? AppColors.textPrimaryDark
                          : AppColors.textPrimaryLight,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    l10n.consentManagementDesc,
                    style: TextStyle(
                      fontSize: 14,
                      height: 1.5,
                      color: isDark
                          ? AppColors.textSecondaryDark
                          : AppColors.textSecondaryLight,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Info Box
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.blue.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: AppColors.blue.withValues(alpha: 0.2),
                      ),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(
                          Icons.info_outline,
                          color: AppColors.blue,
                          size: 20,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            l10n.consentWithdrawInfo,
                            style: TextStyle(
                              fontSize: 13,
                              height: 1.5,
                              color: isDark
                                  ? AppColors.textPrimaryDark
                                  : AppColors.textPrimaryLight,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  _buildConsentToggle(
                    isDark: isDark,
                    icon: Icons.camera_alt,
                    iconColor: AppColors.orange,
                    title: l10n.consentCamera,
                    description: l10n.consentCameraDesc,
                    legalBasis: 'KVKK Madde 5/1 - Açık rıza',
                    value: _cameraConsent,
                    onChanged: (v) {
                      setState(() => _cameraConsent = v);
                      _updateConsent(
                          KvkkConsentService.keyConsentCamera, v);
                    },
                  ),
                  const SizedBox(height: 12),

                  _buildConsentToggle(
                    isDark: isDark,
                    icon: Icons.mic,
                    iconColor: AppColors.purple,
                    title: l10n.consentAudio,
                    description: l10n.consentAudioDesc,
                    legalBasis: 'KVKK Madde 5/1 - Açık rıza',
                    value: _audioConsent,
                    onChanged: (v) {
                      setState(() => _audioConsent = v);
                      _updateConsent(
                          KvkkConsentService.keyConsentAudio, v);
                    },
                  ),
                  const SizedBox(height: 12),

                  _buildConsentToggle(
                    isDark: isDark,
                    icon: Icons.document_scanner,
                    iconColor: AppColors.blue,
                    title: l10n.consentOcr,
                    description: l10n.consentOcrDesc,
                    legalBasis: 'KVKK Madde 5/1 - Açık rıza',
                    value: _ocrConsent,
                    onChanged: (v) {
                      setState(() => _ocrConsent = v);
                      _updateConsent(
                          KvkkConsentService.keyConsentOcr, v);
                    },
                  ),
                  const SizedBox(height: 12),

                  _buildConsentToggle(
                    isDark: isDark,
                    icon: Icons.notifications,
                    iconColor: AppColors.red,
                    title: l10n.consentPush,
                    description: l10n.consentPushDesc,
                    legalBasis: 'KVKK Madde 5/1 - Açık rıza',
                    value: _notificationsConsent,
                    onChanged: (v) {
                      setState(() => _notificationsConsent = v);
                      _updateConsent(
                          KvkkConsentService.keyConsentNotifications, v);
                    },
                  ),
                  const SizedBox(height: 12),

                  _buildConsentToggle(
                    isDark: isDark,
                    icon: Icons.cloud_upload,
                    iconColor: AppColors.emerald,
                    title: l10n.consentCloud,
                    description: l10n.consentCloudDesc,
                    legalBasis: 'KVKK Madde 5/1 - Açık rıza',
                    value: _cloudBackupConsent,
                    onChanged: (v) {
                      setState(() => _cloudBackupConsent = v);
                      _updateConsent(
                          KvkkConsentService.keyConsentCloudBackup, v);
                    },
                  ),

                  const SizedBox(height: 32),

                  // Legal Notice
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isDark
                          ? const Color(0xFF2C2C2E)
                          : Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.gavel,
                              size: 20,
                              color: isDark
                                  ? AppColors.textSecondaryDark
                                  : AppColors.textSecondaryLight,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              l10n.consentLegalInfo,
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
                          l10n.consentLegalDesc,
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
    );
  }

  Widget _buildConsentToggle({
    required bool isDark,
    required IconData icon,
    required Color iconColor,
    required String title,
    required String description,
    required String legalBasis,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF2C2C2E) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: value
              ? iconColor
              : (isDark ? Colors.white10 : Colors.grey.shade200),
          width: value ? 2 : 1,
        ),
      ),
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
                        onChanged: (v) => onChanged(v),
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
    );
  }
}
