import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lesson_tracker/core/theme/app_colors.dart';
import 'package:lesson_tracker/l10n/app_localizations.dart';
import 'package:lesson_tracker/providers/course_provider.dart';

/// Shows the draggable course-selection modal used by Moodle flows
/// (transfer a downloaded file into a local course).
///
/// Extracted from `_MoodleCourseDetailScreenState._showCourseSelectionDialog`
/// per plan 3.1.3. Returns the selected course id, or null if the
/// user dismissed without choosing.
///
/// The host's [onCourseSelected] callback is fired when the user taps
/// a course row. The host owns the actual export logic.
Future<String?> showMoodleCourseSelectionSheet(
  BuildContext context, {
  required void Function(String courseId, String courseName) onCourseSelected,
}) {
  final courses = context.read<CourseProvider>().uniqueCourses;
  final l10n = AppLocalizations.of(context)!;

  return showModalBottomSheet<String>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Theme.of(context).colorScheme.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (sheetContext) {
      return DraggableScrollableSheet(
        initialChildSize: 0.6,
        maxChildSize: 0.9,
        minChildSize: 0.4,
        expand: false,
        builder: (innerContext, scrollController) {
          return Column(
            children: [
              const SizedBox(height: 8),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    const Icon(Icons.menu_book_rounded, color: AppColors.primary),
                    const SizedBox(width: 8),
                    Text(
                      l10n.moodleSelectCourse,
                      style: Theme.of(innerContext).textTheme.titleLarge
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: courses.isEmpty
                    ? Center(
                        child: Text(
                          l10n.moodleNoLocalCourses,
                          style: TextStyle(
                              color: Theme.of(innerContext)
                                  .colorScheme
                                  .onSurfaceVariant),
                        ),
                      )
                    : ListView.builder(
                        controller: scrollController,
                        itemCount: courses.length,
                        itemBuilder: (_, index) {
                          final course = courses[index];
                          return ListTile(
                            leading: CircleAvatar(
                              backgroundColor:
                                  course.color.withValues(alpha: 0.2),
                              child: Text(
                                course.name.substring(0, 1).toUpperCase(),
                                style: TextStyle(
                                    color: course.color,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                            title: Text(course.name,
                                style: const TextStyle(
                                    fontWeight: FontWeight.w500)),
                            subtitle: course.subtitle != null
                                ? Text(course.subtitle!)
                                : null,
                            onTap: () {
                              Navigator.pop(sheetContext);
                              onCourseSelected(course.id, course.name);
                            },
                          );
                        },
                      ),
              ),
            ],
          );
        },
      );
    },
  );
}