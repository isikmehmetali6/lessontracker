import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
          'Rıza Yönetimi',
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
                    'Açık Rıza Tercihleriniz',
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
                    'KVKK Madde 5/1 kapsamında verdiğiniz açık rıza tercihlerini buradan yönetebilirsiniz.',
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
                            'Rızanızı istediğiniz zaman geri çekebilirsiniz. Rıza geri çekildiğinde ilgili özellik devre dışı kalacaktır.',
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
                    title: 'Kamera ile Fotoğraf Çekme',
                    description:
                        'Ders notlarınızı fotoğraflayarak kaydetmek için kamera erişimi.',
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
                    title: 'Ses Kaydı Alma',
                    description:
                        'Derslerin ses kaydını alarak notlarınızı zenginleştirmek için mikrofon erişimi.',
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
                    title: 'OCR ile Metin Tanıma',
                    description:
                        'Fotoğraflardaki metinleri tanımak için Google ML Kit kullanımı.',
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
                    title: 'Push Bildirimleri',
                    description:
                        'Hatırlatmalar ve ödev bildirimleri için bildirim gönderimi.',
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
                    title: 'Bulut Yedekleme',
                    description:
                        'Verilerinizi şifreli olarak bulutta yedeklemek için Firebase kullanımı.',
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
                              'Yasal Bilgi',
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
                          '6698 sayılı KVKK kapsamında açık rızanızı istediğiniz zaman geri çekme hakkına sahipsiniz. Rıza geri çekilmeden önce rızaya dayanılarak gerçekleştirilen işlemler hukuka uygun olmaya devam eder.',
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
