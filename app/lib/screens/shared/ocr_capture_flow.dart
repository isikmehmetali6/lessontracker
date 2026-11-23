import 'dart:io';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:lesson_tracker/l10n/app_localizations.dart';

import '../../core/theme/app_colors.dart';
import '../../core/utils/consent_utils.dart';
import '../../models/note.dart';
import '../../providers/note_provider.dart';
import '../../services/ocr_service.dart';

/// Ana ekran ("Not Tara") ve ders detayı (OCR düğmesi) için ortak akış
/// (docs/OCR_FIX_PLAN_2026-11-23.md O7):
/// platform kontrolü → KVKK rızası → kaynak (kamera/galeri) → [pickCourse]
/// (ders belli değilse) → metin tanıma → çevrilmiş sonuç mesajı.
///
/// [courseId] verilirse ders seçimi atlanır. Oluşan notu döndürür.
Future<Note?> runOcrCapture({
  required BuildContext context,
  String? courseId,
  Future<String?> Function(BuildContext context)? pickCourse,
  ImagePicker? imagePicker,
  @visibleForTesting bool? isSupportedPlatform,
}) async {
  assert(courseId != null || pickCourse != null);
  final l10n = AppLocalizations.of(context)!;
  final messenger = ScaffoldMessenger.of(context);

  void snack(String text, {Color? color, Duration? duration}) {
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(text),
          backgroundColor: color,
          behavior: SnackBarBehavior.floating,
          duration: duration ?? const Duration(seconds: 4),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
  }

  // O8: ML Kit yalnız iOS/Android'de var — kamerayı açmadan söyle.
  final supported = isSupportedPlatform ??
      (!kIsWeb && (Platform.isIOS || Platform.isAndroid));
  if (!supported) {
    snack(l10n.ocrUnavailable, color: AppColors.orange);
    return null;
  }

  // O3: kamera + OCR açık rızası
  final consent =
      await ConsentUtils.ensureCaptureConsent(context, kind: CaptureKind.ocr);
  if (!consent || !context.mounted) return null;

  // O2: kaynak seçimi
  final source = await showOcrSourceSheet(context);
  if (source == null || !context.mounted) return null;

  final XFile? image;
  try {
    image = await (imagePicker ?? ImagePicker()).pickImage(
      source: source,
      maxWidth: 1920,
      maxHeight: 1920,
      imageQuality: 85,
    );
  } on PlatformException catch (e) {
    debugPrint('OCR image pick failed: $e');
    snack(l10n.ocrFailed, color: AppColors.red);
    return null;
  }
  if (image == null || !context.mounted) return null;

  final targetCourse = courseId ?? await pickCourse!(context);
  if (targetCourse == null || !context.mounted) return null;

  snack(l10n.processingOcr, duration: const Duration(minutes: 1));

  final notes = context.read<NoteProvider>();
  final locale = Localizations.localeOf(context).toLanguageTag();
  final note = await notes.addOcrNote(
    courseId: targetCourse,
    imageFile: File(image.path),
    customTitle: l10n.ocrDefaultTitle(
      DateFormat.MMMd(locale).add_Hm().format(DateTime.now()),
    ),
  );

  messenger.hideCurrentSnackBar();
  if (note != null) {
    HapticFeedback.mediumImpact();
    snack(l10n.ocrNoteSaved);
    return note;
  }

  switch (notes.ocrErrorCode) {
    case OcrErrorCode.noText:
      snack(l10n.ocrNoText, color: AppColors.orange, duration: const Duration(seconds: 6));
    case OcrErrorCode.unavailable:
      snack(l10n.ocrUnavailable, color: AppColors.orange);
    case OcrErrorCode.failed:
    case null:
      snack(l10n.ocrFailed, color: AppColors.red);
  }
  return null;
}

/// Kamera / galeri seçimi. Vazgeçilirse `null`.
Future<ImageSource?> showOcrSourceSheet(BuildContext context) {
  final l10n = AppLocalizations.of(context)!;
  return showModalBottomSheet<ImageSource>(
    context: context,
    showDragHandle: true,
    builder: (ctx) => SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 8),
            child: Text(
              l10n.ocrSourceTitle,
              style: Theme.of(ctx).textTheme.titleMedium,
            ),
          ),
          ListTile(
            leading: const Icon(Icons.photo_camera_outlined),
            title: Text(l10n.ocrSourceCamera),
            onTap: () => Navigator.pop(ctx, ImageSource.camera),
          ),
          ListTile(
            leading: const Icon(Icons.photo_library_outlined),
            title: Text(l10n.ocrSourceGallery),
            onTap: () => Navigator.pop(ctx, ImageSource.gallery),
          ),
          const SizedBox(height: 8),
        ],
      ),
    ),
  );
}
