import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lesson_tracker/core/theme/app_colors.dart';
import 'package:lesson_tracker/models/course.dart';
import 'package:lesson_tracker/providers/course_provider.dart';
import 'package:lesson_tracker/widgets/course/add_grade_dialog.dart';

/// Shows the "Add Grade" bottom sheet for a course.
///
/// Extracted from CourseDetailScreen per plan 3.1.2.
Future<void> showCourseAddGradeSheet({
  required BuildContext context,
  required Course course,
  required VoidCallback onGradesChanged,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (sheetContext) => AddGradeDialog(
      onSave: (name, score, maxScore, weight) async {
        final provider = sheetContext.read<CourseProvider>();
        await provider.addGrade(
          courseId: course.id,
          name: name,
          score: score,
          maxScore: maxScore,
          weight: weight,
        );
        onGradesChanged();

        if (provider.warning != null && sheetContext.mounted) {
          ScaffoldMessenger.of(sheetContext).showSnackBar(
            SnackBar(
              content: Text(provider.warning!),
              backgroundColor: AppColors.amber,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              duration: const Duration(seconds: 4),
            ),
          );
          provider.clearWarning();
        }
      },
    ),
  );
}