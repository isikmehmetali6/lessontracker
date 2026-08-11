import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lesson_tracker/l10n/app_localizations.dart';
import 'package:lesson_tracker/models/course.dart';
import 'package:lesson_tracker/providers/course_provider.dart';
import '../widgets/confirm_action_dialog.dart';

/// Performs the "delete course" flow used by [CourseDetailScreen]:
/// shows a confirm dialog, deletes the course, and pops the screen.
/// Extracted from `_CourseDetailScreenState._deleteCourse` per plan
/// 3.1.2 (P0).
Future<void> deleteCourseAction({
  required BuildContext context,
  required Course course,
  required bool Function() isMounted,
}) async {
  final confirmed = await showConfirmActionDialog(
    context,
    title: AppLocalizations.of(context)!.deleteCourse,
    message: AppLocalizations.of(context)!.deleteCourseConfirmation,
  );
  if (!confirmed || !isMounted()) return;
  if (!context.mounted) return;
  // ignore: use_build_context_synchronously
  await context.read<CourseProvider>().deleteCourse(course.id);
  if (!isMounted() || !context.mounted) return;
  // ignore: use_build_context_synchronously
  Navigator.pop(context);
}