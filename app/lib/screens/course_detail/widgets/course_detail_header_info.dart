import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lesson_tracker/l10n/app_localizations.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../models/course.dart';
import '../../../../providers/course_provider.dart';
import '../../../../widgets/common/common_widgets.dart';
import '../../../../widgets/course/absence_tracker_card.dart';

class CourseDetailHeaderInfo extends StatelessWidget {
  final Course course;

  const CourseDetailHeaderInfo({
    super.key,
    required this.course,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      children: [
        // Meta bilgiler
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: isDark ? Colors.grey.shade800.withValues(alpha: 0.5) : Colors.grey.shade100,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '${AppLocalizations.of(context)!.semesterDefault} • ${course.professor ?? AppLocalizations.of(context)!.noProfessor}',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0.5,
                  color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                ),
              ),
            ),
          ),
        ),

        // İlerleme Çubuğu & Absence
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    AppLocalizations.of(context)!.courseProgress,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                    ),
                  ),
                  Text(
                    '${course.progress.round()}%',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              ProgressBar(
                progress: course.progress,
                height: 12,
              ),
              const SizedBox(height: 16),
              
              // Absence Tracking
              AbsenceTrackerCard(
                course: course,
                isDark: isDark,
                onAbsenceChanged: (newAbsences) {
                   if (newAbsences > course.currentAbsences) {
                     context.read<CourseProvider>().addAbsence(course.id);
                   } else {
                     context.read<CourseProvider>().removeLastAbsence(course.id);
                   }
                },
              ),
            ],
          ),
        ),
      ],
    );
  }
}
