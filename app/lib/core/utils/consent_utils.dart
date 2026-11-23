import 'package:flutter/material.dart';
import 'package:lesson_tracker/l10n/app_localizations.dart';
import '../../core/theme/app_colors.dart';
import '../../services/kvkk_consent_service.dart';

/// Ders içeriği yakalama türü — hangi KVKK açık rızalarının gerektiğini
/// belirler.
enum CaptureKind {
  /// Fotoğraf/görsel not: kamera rızası.
  camera,

  /// Ses kaydı: ses rızası.
  audio,

  /// Fotoğraftan metin tanıma: kamera **ve** OCR rızası.
  ocr,
}

class ConsentUtils {
  static List<String> requiredConsentKeys(CaptureKind kind) => switch (kind) {
        CaptureKind.camera => [KvkkConsentService.keyConsentCamera],
        CaptureKind.audio => [KvkkConsentService.keyConsentAudio],
        CaptureKind.ocr => [
            KvkkConsentService.keyConsentCamera,
            KvkkConsentService.keyConsentOcr,
          ],
      };

  /// Yakalamadan önceki tek rıza kapısı. Gereken KVKK rızalarının hepsi
  /// verilmişse diyalog göstermeden `true` döner; aksi halde amacı açıkça
  /// yazan bir diyalog gösterir. Kullanıcı onaylarsa **yalnızca** bu türün
  /// gerektirdiği rızalar kaydedilir.
  ///
  /// Önceki sürüm OCR rızasını hiç kontrol etmiyordu ve "İzin Aldım" ile
  /// kullanıcının reddettiği kamera rızasını sessizce açıyordu
  /// (docs/OCR_FIX_PLAN_2026-11-23.md O3).
  static Future<bool> ensureCaptureConsent(
    BuildContext context, {
    required CaptureKind kind,
    KvkkConsentService? consentService,
  }) async {
    final service = consentService ?? KvkkConsentService();
    final keys = requiredConsentKeys(kind);
    final consents = await service.getAllConsents();
    if (keys.every((k) => consents[k] ?? false)) return true;
    if (!context.mounted) return false;

    final accepted = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => _CaptureConsentDialog(kind: kind),
    );
    if (accepted != true) return false;

    for (final key in keys) {
      await service.updateConsent(key, true);
    }
    return true;
  }

  /// Geriye dönük uyumluluk için. Yeni kod [ensureCaptureConsent] kullanmalı.
  static Future<bool?> showContentCaptureConsentDialog(
    BuildContext context, {
    bool isAudio = false,
  }) {
    return ensureCaptureConsent(
      context,
      kind: isAudio ? CaptureKind.audio : CaptureKind.camera,
    );
  }
}

class _CaptureConsentDialog extends StatelessWidget {
  const _CaptureConsentDialog({required this.kind});

  final CaptureKind kind;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isAudio = kind == CaptureKind.audio;
    final accent = isAudio ? AppColors.purple : AppColors.orange;
    final icon = switch (kind) {
      CaptureKind.audio => Icons.mic,
      CaptureKind.ocr => Icons.document_scanner,
      CaptureKind.camera => Icons.camera_alt,
    };
    final kvkkText = switch (kind) {
      CaptureKind.audio => l10n.captureConsentKvkkAudio,
      CaptureKind.ocr => l10n.captureConsentKvkkOcr,
      CaptureKind.camera => l10n.captureConsentKvkkCamera,
    };
    final secondary =
        isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;

    return AlertDialog(
      backgroundColor: isDark ? AppColors.surfaceDark : Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: accent),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              l10n.captureConsentTitle,
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
            l10n.captureConsentBody,
            style: TextStyle(fontSize: 14, height: 1.5, color: secondary),
          ),
          const SizedBox(height: 12),
          Text(
            kvkkText,
            style: TextStyle(fontSize: 13, height: 1.5, color: secondary),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isDark
                  ? AppColors.surfaceDarkElevated
                  : Colors.grey.shade100,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Icon(Icons.info_outline, color: AppColors.blue, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    l10n.captureConsentLegal,
                    style: TextStyle(fontSize: 12, color: secondary),
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
          child: Text(l10n.cancel),
        ),
        ElevatedButton(
          onPressed: () => Navigator.pop(context, true),
          child: Text(l10n.captureConsentAccept),
        ),
      ],
    );
  }
}
