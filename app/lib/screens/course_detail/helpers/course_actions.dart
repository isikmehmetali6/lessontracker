import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:lesson_tracker/core/utils/consent_utils.dart';
import 'package:lesson_tracker/l10n/app_localizations.dart';
import 'package:lesson_tracker/models/course.dart';
import 'package:lesson_tracker/providers/note_provider.dart';

/// Capture/OCR actions extracted from CourseDetailScreen per plan
/// 3.1.2 ('actions helper: capture/OCR/image note'). The host is
/// stateful (State.mounted, snackbar helper, image-note dialog); the
/// helpers take callbacks so they don't depend on the host class.
class CourseActions {
  const CourseActions({
    required this.context,
    required this.isMounted,
    required this.showSnack,
    required this.onSingleImagePicked,
    required this.onMultipleImagesPicked,
    required this.handleError,
  });

  /// Build context for provider/ErrorHandler/showDialog operations.
  final BuildContext context;

  /// True iff the host State is still mounted.
  final bool Function() isMounted;

  /// Show a translated snackbar.
  final void Function(String message) showSnack;

  /// Single image picked (camera or single gallery item). The host
  /// opens the image-note dialog and saves the note.
  final void Function(File image, Course course) onSingleImagePicked;

  /// Multiple images picked (gallery multi-select). The host saves
  /// each via NoteProvider.
  final Future<void> Function(List<File> files, Course course)
      onMultipleImagesPicked;

  /// Native error surface (toast + log).
  final void Function(Object error, {String? customMessage}) handleError;

  static final ImagePicker _imagePicker = ImagePicker();

  Future<void> captureImage(ImageSource source, Course course) async {
    try {
      if (source == ImageSource.gallery) {
        final List<XFile> images = await _imagePicker.pickMultiImage(
          maxWidth: 1920,
          maxHeight: 1920,
          imageQuality: 85,
        );
        if (images.isEmpty || !isMounted()) return;
        if (images.length == 1) {
          onSingleImagePicked(File(images.first.path), course);
        } else {
          await onMultipleImagesPicked(
            images.map((x) => File(x.path)).toList(),
            course,
          );
        }
      } else {
        final consent = await ConsentUtils.showContentCaptureConsentDialog(
          context,
        );
        if (consent != true || !isMounted()) return;
        final XFile? image = await _imagePicker.pickImage(
          source: source,
          maxWidth: 1920,
          maxHeight: 1920,
          imageQuality: 85,
        );
        if (image != null && isMounted()) {
          onSingleImagePicked(File(image.path), course);
        }
      }
    } catch (e) {
      if (isMounted()) {
        handleError(e, customMessage: 'Failed to capture image');
      }
    }
  }

  Future<void> captureOcr(Course course) async {
    final consent = await ConsentUtils.showContentCaptureConsentDialog(context);
    if (consent != true || !isMounted()) return;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(
      'ocr_consent_timestamp',
      DateTime.now().millisecondsSinceEpoch,
    );

    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1920,
        maxHeight: 1920,
        imageQuality: 85,
      );
      if (image == null || !isMounted()) return;
      if (!context.mounted) return;
      showSnack(AppLocalizations.of(context)!.processingOcr);

      final note = await context.read<NoteProvider>().addOcrNote(
            courseId: course.id,
            imageFile: File(image.path),
            courseName: course.name,
            userName: 'User',
          );
      if (!isMounted()) return;
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      if (note != null) {
        showSnack(AppLocalizations.of(context)!.ocrNoteSaved);
      } else {
        handleError(
          context.read<NoteProvider>().error ?? 'OCR failed',
        );
      }
    } catch (e) {
      if (isMounted()) {
        handleError(e, customMessage: 'OCR failed: $e');
      }
    }
  }
}