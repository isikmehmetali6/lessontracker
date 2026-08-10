import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lesson_tracker/l10n/app_localizations.dart';
import 'package:lesson_tracker/providers/course_provider.dart';

/// Performs the "delete grade" flow used by [CourseDetailScreen]:
/// - Calls `CourseProvider.deleteGrade`.
/// - On success and if the host is still mounted, refreshes
///   [onSuccess] (typically `_loadGrades`) and shows a snackbar.
///
/// Extracted from `_CourseDetailScreenState._deleteGrade` per plan
/// 3.1.2 (P0). Returns whether the delete succeeded.
Future<bool> deleteGradeAction({
  required BuildContext context,
  required String gradeId,
  required bool Function() isMounted,
  required Future<void> Function() onSuccess,
}) async {
  final success =
      await context.read<CourseProvider>().deleteGrade(gradeId);
  if (!isMounted()) return success;
  if (success) {
    await onSuccess();
    if (!isMounted() || !context.mounted) return success;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(AppLocalizations.of(context)!.gradeDeleted),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
  return success;
}