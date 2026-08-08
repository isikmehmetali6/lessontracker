import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lesson_tracker/l10n/app_localizations.dart';
import 'package:lesson_tracker/providers/deadline_provider.dart';
import 'package:lesson_tracker/widgets/deadlines/add_deadline_dialog.dart';

/// Shows the "Add Deadline" bottom sheet for a course.
///
/// Extracted from CourseDetailScreen per plan 3.1.2 (P0).
Future<void> showCourseAddDeadlineDialog(
  BuildContext context, {
  required String courseId,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (sheetContext) => AddDeadlineDialog(
      onSave: (title, selectedCourseId, date, type, addToCalendar) {
        sheetContext.read<DeadlineProvider>().createDeadline(
              courseId: selectedCourseId,
              title: title,
              date: date,
              type: type,
              addToCalendar: addToCalendar,
            );
        if (sheetContext.mounted) {
          ScaffoldMessenger.of(sheetContext).showSnackBar(
            SnackBar(
              content: Text(
                AppLocalizations.of(sheetContext)!.deadlineAdded,
              ),
            ),
          );
        }
      },
    ),
  );
}