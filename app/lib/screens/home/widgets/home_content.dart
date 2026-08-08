import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lesson_tracker/core/theme/app_colors.dart';
import 'package:lesson_tracker/l10n/app_localizations.dart';
import 'package:lesson_tracker/models/course.dart';
import 'package:lesson_tracker/providers/course_provider.dart';
import 'package:lesson_tracker/providers/note_provider.dart';
import 'package:lesson_tracker/screens/gpa/gpa_calculator_screen.dart';
import 'package:lesson_tracker/screens/study_timer/study_timer_screen.dart';
import 'attendance_overview_list.dart';
import 'home_header.dart';
import 'home_search_bar.dart';
import 'priority_courses_list.dart';
import 'quick_action_card.dart';
import 'package:lesson_tracker/widgets/home/home_stats_summary.dart';
import 'package:lesson_tracker/widgets/home/quick_capture_buttons.dart';
import 'recent_notes_list.dart';
import 'today_schedule_list.dart';

class HomeContent extends StatelessWidget {
  final VoidCallback onScanTap;
  final void Function(Course) onCourseTap;

  const HomeContent({
    super.key,
    required this.onScanTap,
    required this.onCourseTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return RefreshIndicator(
      onRefresh: () async {
        await context.read<CourseProvider>().loadCourses();
        if (!context.mounted) return;
        await context.read<NoteProvider>().loadNotes();
      },
      child: CustomScrollView(
        slivers: [
          const SliverToBoxAdapter(child: HomeHeader()),
          const SliverToBoxAdapter(child: HomeSearchBar()),
          const SliverPadding(
            padding: EdgeInsets.symmetric(horizontal: 24),
            sliver: SliverToBoxAdapter(child: HomeStatsSummary()),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 12),
              child: Text(
                AppLocalizations.of(context)!.todaySchedule,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: isDark
                      ? AppColors.textPrimaryDark
                      : AppColors.textPrimaryLight,
                ),
              ),
            ),
          ),
          TodayScheduleList(onCourseTap: onCourseTap),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 12),
              child: Text(
                AppLocalizations.of(context)!.priorityFocus,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: isDark
                      ? AppColors.textPrimaryDark
                      : AppColors.textPrimaryLight,
                ),
              ),
            ),
          ),
          PriorityCoursesList(onCourseTap: onCourseTap),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 12),
              child: Text(
                AppLocalizations.of(context)!.quickCapture,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: isDark
                      ? AppColors.textPrimaryDark
                      : AppColors.textPrimaryLight,
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: QuickCaptureButtons(onScanTap: onScanTap),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 12),
              child: Text(
                AppLocalizations.of(context)!.quickActions,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: isDark
                      ? AppColors.textPrimaryDark
                      : AppColors.textPrimaryLight,
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                children: [
                  Expanded(
                    child: QuickActionCard(
                      icon: Icons.timer,
                      title: AppLocalizations.of(context)!.studyTimer,
                      subtitle: AppLocalizations.of(context)!.studyTimerDesc,
                      color: AppColors.orange,
                      isDark: isDark,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const StudyTimerScreen(),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: QuickActionCard(
                      icon: Icons.analytics,
                      title: AppLocalizations.of(context)!.gpaCalculator,
                      subtitle: AppLocalizations.of(context)!.gpaCalcDesc,
                      color: AppColors.purple,
                      isDark: isDark,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const GPACalculatorScreen(),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 32, 24, 12),
              child: Text(
                AppLocalizations.of(context)!.attendanceStatus,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: isDark
                      ? AppColors.textPrimaryDark
                      : AppColors.textPrimaryLight,
                ),
              ),
            ),
          ),
          const AttendanceOverviewList(),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 32, 24, 12),
              child: Text(
                AppLocalizations.of(context)!.recentNotes,
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
              ),
            ),
          ),
          RecentNotesList(onCourseTap: onCourseTap),
        ],
      ),
    );
  }
}