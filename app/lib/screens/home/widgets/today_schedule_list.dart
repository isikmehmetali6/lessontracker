import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lesson_tracker/l10n/app_localizations.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../models/course.dart';
import '../../../../providers/course_provider.dart';
import '../../../../widgets/home/schedule_card.dart';

class TodayScheduleList extends StatelessWidget {
  final Function(Course) onCourseTap;

  const TodayScheduleList({super.key, required this.onCourseTap});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Sadece bugünün dersleri değiştiğinde rebuild olur
    final todayCourses = context.select<CourseProvider, List<Course>>(
      (provider) => provider.todayCourses,
    );

    if (todayCourses.isEmpty) {
      return SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                Icon(Icons.sunny, color: AppColors.amber, size: 28),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    AppLocalizations.of(context)!.noClassesToday,
                    style: TextStyle(
                      fontSize: 14,
                      color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    // Sort by start time
    final sorted = List<Course>.from(todayCourses)
      ..sort((a, b) {
        final aMin = a.startTime.hour * 60 + a.startTime.minute;
        final bMin = b.startTime.hour * 60 + b.startTime.minute;
        return aMin.compareTo(bMin);
      });

    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: SizedBox(
                height: 200,
                child: ScheduleCard(
                  course: sorted[index],
                  onTap: () => onCourseTap(sorted[index]),
                ),
              ),
            );
          },
          childCount: sorted.length,
        ),
      ),
    );
  }
}
