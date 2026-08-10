import 'package:flutter/material.dart';
import 'package:lesson_tracker/core/theme/app_colors.dart';
import 'package:lesson_tracker/l10n/app_localizations.dart';
import 'package:lesson_tracker/services/moodle_file_download_service.dart';

/// Exports a downloaded Moodle file into a local course via
/// [MoodleFileDownloadService.exportToAppCourse]. Surfaces the result
/// with a snackbar. Extracted from
/// `_MoodleCourseDetailScreenState._handleExportToCourse` per plan 3.1.3.
Future<void> exportMoodleFileToCourse({
  required BuildContext context,
  required MoodleFileDownloadService downloadService,
  required String localPath,
  required String courseId,
  required String fileName,
  required String courseName,
}) async {
  if (localPath.isEmpty) return;
  final l10n = AppLocalizations.of(context)!;
  final success = await downloadService.exportToAppCourse(
    moodleFilePath: localPath,
    courseId: courseId,
    fileName: fileName,
  );
  if (!context.mounted) return;
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(
        success ? l10n.moodleSavedToCourse(courseName) : l10n.moodleSaveError,
      ),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      backgroundColor: success ? AppColors.green : AppColors.red,
    ),
  );
}