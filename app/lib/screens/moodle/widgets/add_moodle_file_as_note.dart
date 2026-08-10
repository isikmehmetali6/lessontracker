import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:lesson_tracker/core/utils/error_handler.dart';
import 'package:lesson_tracker/l10n/app_localizations.dart';
import 'package:lesson_tracker/providers/course_provider.dart';
import 'package:lesson_tracker/providers/note_provider.dart';
import 'package:lesson_tracker/screens/moodle/widgets/moodle_course_picker.dart';

/// Performs the "save downloaded Moodle file as a note" flow used by
/// [MoodleCourseDetailScreen]. Shows the course picker, then calls
/// `NoteProvider.addPdfNote`, then refreshes [onNoteSaved] and shows
/// a snackbar.
///
/// Extracted from `_MoodleCourseDetailScreenState._addDownloadedFileAsNote`
/// per plan 3.1.3 (P0). Returns the new note id (or null on
/// failure/cancellation).
Future<dynamic> addMoodleFileAsNoteAction({
  required BuildContext context,
  required String localPath,
  required String fileName,
  required bool Function() isMounted,
  required Future<void> Function() onNoteSaved,
}) async {
  if (localPath.isEmpty) return null;
  if (!context.mounted) return null;

  final selected = await showMoodleCoursePicker(
    context,
    context.read<CourseProvider>().courses,
  );
  if (selected == null || !isMounted() || !context.mounted) return null;

  final result = await context.read<NoteProvider>().addPdfNote(
        courseId: selected,
        title: fileName,
        localPath: localPath,
      );

  if (!isMounted() || !context.mounted) return result;

  if (result != null) {
    HapticFeedback.mediumImpact();
    if (!context.mounted) return result;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(AppLocalizations.of(context)!.noteSaved),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
    await onNoteSaved();
  } else {
    if (!context.mounted) return result;
    ErrorHandler.handleError(
      context,
      context.read<NoteProvider>().error ?? 'Failed to add note',
    );
  }
  return result;
}