import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lesson_tracker/l10n/app_localizations.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../models/course.dart';
import '../../../../models/note.dart';
import '../../../../providers/course_provider.dart';
import '../../../../providers/note_provider.dart';
import '../../../../widgets/course/note_cards.dart';

class RecentNotesList extends StatelessWidget {
  final Function(Course) onCourseTap;

  const RecentNotesList({super.key, required this.onCourseTap});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final notes = context.select<NoteProvider, List<Note>>((provider) => provider.recentNotes);
    final courses = context.select<CourseProvider, List<Course>>((provider) => provider.courses);

    if (notes.isEmpty) {
      return SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Center(
            child: Text(
              AppLocalizations.of(context)!.noNotesYet,
              style: TextStyle(
                color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
              ),
            ),
          ),
        ),
      );
    }

    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 100),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            final note = notes[index];
            final course = courses.firstWhere(
              (c) => c.id == note.courseId,
              orElse: () => Course(
                id: '',
                name: 'Unknown',
                color: AppColors.primary,
                scheduleDays: [],
                startTime: const TimeOfDay(hour: 0, minute: 0),
                endTime: const TimeOfDay(hour: 0, minute: 0),
              ),
            );

            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: NoteCard(
                note: note,
                courseName: course.name,
                courseColor: course.color,
                onTap: () => onCourseTap(course),
              ),
            );
          },
          childCount: notes.length,
        ),
      ),
    );
  }
}
