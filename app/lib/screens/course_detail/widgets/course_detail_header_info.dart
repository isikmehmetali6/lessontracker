import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lesson_tracker/l10n/app_localizations.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../models/course.dart';
import '../../../../providers/course_provider.dart';
import '../../../../widgets/common/common_widgets.dart';
import '../../../../widgets/course/absence_tracker_card.dart';
import '../../../../widgets/course/professor_card.dart';
import '../tabs/absence_calendar_tab.dart';

class CourseDetailHeaderInfo extends StatelessWidget {
  final Course course;

  const CourseDetailHeaderInfo({
    super.key,
    required this.course,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
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
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
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
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => Scaffold(
                          appBar: AppBar(
                            title: Text(l10n.absenceCalendar),
                            backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
                            foregroundColor: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                          ),
                          body: AbsenceCalendarTab(
                            courseId: course.id,
                            isDark: isDark,
                            course: course,
                          ),
                        ),
                      ),
                    );
                  },
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF2C2C2E) : Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isDark ? Colors.white10 : Colors.grey.shade200,
                        width: 1,
                      ),
                      boxShadow: isDark ? [] : [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.02),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(Icons.calendar_month_outlined, color: AppColors.primary, size: 20),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Text(
                            l10n.viewAbsenceCalendar,
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: isDark ? Colors.white : AppColors.textPrimaryLight,
                            ),
                          ),
                        ),
                        Icon(
                          Icons.arrow_forward_ios,
                          size: 14,
                          color: isDark ? Colors.grey.shade600 : Colors.grey.shade400,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        ProfessorCard(course: course, isDark: isDark),
      ],
    );
  }
}
