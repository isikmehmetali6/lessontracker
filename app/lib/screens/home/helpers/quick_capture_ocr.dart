import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:lesson_tracker/core/utils/consent_utils.dart';
import 'package:lesson_tracker/core/utils/error_handler.dart';
import 'package:lesson_tracker/l10n/app_localizations.dart';
import 'package:lesson_tracker/providers/course_provider.dart';
import 'package:lesson_tracker/providers/note_provider.dart';

/// Runs the "quick capture OCR" flow on the home screen. The flow is:
/// consent → camera capture → course picker (via [pickCourse]) →
/// progress snackbar → NoteProvider.addOcrNote → result snackbar.
///
/// The caller supplies the [pickCourse] callback (e.g. via
/// `showCourseSelectionSheet`) so this helper does not depend on
/// any particular UI for course selection. [onLocalPath] and
/// [onSnack] are wired for testability / custom hosting.
Future<void> runQuickCaptureOcr({
  required BuildContext context,
  required Future<String?> Function(BuildContext) pickCourse,
  ImagePicker? imagePicker,
}) async {
  final picker = imagePicker ?? ImagePicker();
  try {
    final consent = await ConsentUtils.showContentCaptureConsentDialog(context);
    if (consent != true || !context.mounted) return;

    final XFile? image = await picker.pickImage(
      source: ImageSource.camera,
      maxWidth: 1920,
      maxHeight: 1920,
      imageQuality: 85,
    );
    if (image == null || !context.mounted) return;

    final courseId = await pickCourse(context);
    if (courseId == null || !context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.white,
              ),
            ),
            const SizedBox(width: 12),
            Text(AppLocalizations.of(context)!.processingOcr),
          ],
        ),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        duration: const Duration(seconds: 10),
      ),
    );

    final courseProvider = context.read<CourseProvider>();
    final course = await courseProvider.getCourseById(courseId);
    final userName = 'User';
    if (!context.mounted) return;
    final note = await context.read<NoteProvider>().addOcrNote(
          courseId: courseId,
          imageFile: File(image.path),
          courseName: course?.name,
          userName: userName,
        );

    if (!context.mounted) return;
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    if (note != null) {
      HapticFeedback.mediumImpact();
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.ocrNoteSaved),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
    } else {
      ErrorHandler.handleError(
        context,
        context.read<NoteProvider>().error ?? 'OCR failed',
      );
    }
  } catch (e) {
    if (context.mounted) {
      ErrorHandler.handleError(context, e, customMessage: 'Error: $e');
    }
  }
}