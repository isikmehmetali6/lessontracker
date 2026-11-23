import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lesson_tracker/screens/shared/ocr_capture_flow.dart';

/// Ana ekrandaki "Not Tara" hızlı yakalama. Asıl akış [runOcrCapture]'da
/// (ders detayındaki OCR düğmesiyle ortak); burada yalnızca ders seçimi
/// kullanıcıya bırakılır.
Future<void> runQuickCaptureOcr({
  required BuildContext context,
  required Future<String?> Function(BuildContext) pickCourse,
  ImagePicker? imagePicker,
}) async {
  await runOcrCapture(
    context: context,
    pickCourse: pickCourse,
    imagePicker: imagePicker,
  );
}
