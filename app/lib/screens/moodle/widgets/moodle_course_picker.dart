import 'package:flutter/material.dart';
import 'package:lesson_tracker/l10n/app_localizations.dart';
import 'package:lesson_tracker/models/course.dart';

/// Shows the "pick a course" modal used by Moodle flows when exporting
/// a downloaded file to an existing local course. Returns the
/// selected course id, or null if the user cancelled.
///
/// Extracted from `_MoodleCourseDetailScreenState` per plan 3.1.3.
Future<String?> showMoodleCoursePicker(
  BuildContext context,
  List<Course> courses,
) {
  final l10n = AppLocalizations.of(context)!;
  if (courses.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(l10n.noCoursesAvailable)),
    );
    return Future.value(null);
  }

  return showModalBottomSheet<String>(
    context: context,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (ctx) => SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              l10n.selectCourseTitle,
              style: Theme.of(ctx).textTheme.titleMedium,
            ),
          ),
          Flexible(
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: courses.length,
              itemBuilder: (ctx, i) {
                final c = courses[i];
                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Color(c.color.toARGB32()),
                    child: Text(
                      c.name.isNotEmpty ? c.name[0].toUpperCase() : '?',
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                  title: Text(c.name),
                  onTap: () => Navigator.pop(ctx, c.id),
                );
              },
            ),
          ),
        ],
      ),
    ),
  );
}