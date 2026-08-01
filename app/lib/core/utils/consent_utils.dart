import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/services/kvkk_consent_service.dart';

class ConsentUtils {
  /// Shows a KVKK explicitly consent dialog before capturing content (audio/video)
  /// Returns [true] if user gives consent, [false] or [null] otherwise.
  /// If consent was previously granted, returns true without showing dialog.
  static Future<bool?> showContentCaptureConsentDialog(BuildContext context, {bool isAudio = false}) async {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final consentService = KvkkConsentService();
    final hasConsent = isAudio
        ? await consentService.hasAudioConsent()
        : await consentService.hasCameraConsent();

    if (!context.mounted) return null;
    if (hasConsent) return true;
    
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? AppColors.surfaceDark : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: (isAudio ? AppColors.purple : AppColors.orange).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(isAudio ? Icons.mic : Icons.camera_alt, color: isAudio ? AppColors.purple : AppColors.orange),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Ders İçeriği Kaydı',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: isDark
                      ? AppColors.textPrimaryDark
                      : AppColors.textPrimaryLight,
                ),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Ders içeriğini kaydetmek için öğretim görevlisinden sözlü izin aldığınızı beyan eder misiniz?',
              style: TextStyle(
                fontSize: 14,
                height: 1.5,
                color: isDark
                    ? AppColors.textSecondaryDark
                    : AppColors.textSecondaryLight,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isDark ? AppColors.surfaceDarkElevated : Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.info_outline,
                    color: AppColors.blue,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '5846 Sayılı FSK ve KVKK kapsamında içerikler kişisel kullanım amacıyla kaydedilmektedir.',
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark
                            ? AppColors.textSecondaryDark
                            : AppColors.textSecondaryLight,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              'İptal',
              style: TextStyle(
                color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              final consentService = KvkkConsentService();
              if (isAudio) {
                await consentService.updateConsent(KvkkConsentService.keyConsentAudio, true);
              } else {
                await consentService.updateConsent(KvkkConsentService.keyConsentCamera, true);
              }
              if (context.mounted) Navigator.pop(context, true);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text('İzin Aldım'),
          ),
        ],
      ),
    );
  }
}
