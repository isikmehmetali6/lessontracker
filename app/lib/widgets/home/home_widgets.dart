import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../providers/course_provider.dart';
import '../../providers/deadline_provider.dart';


/// Home Stats Summary Widget (New)
class HomeStatsSummary extends StatelessWidget {
  const HomeStatsSummary({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Consumer2<CourseProvider, DeadlineProvider>(
      builder: (context, courseProvider, deadlineProvider, _) {
        final courses = courseProvider.courses;
        final uniqueCourses = courseProvider.uniqueCourses;

        // Count absence risks across all individual schedules
        final atRiskCount = courses.where((c) {
          return c.absenceLimit > 0 &&
              (c.currentAbsences / c.absenceLimit) >= 0.7;
        }).length;

        final upcomingDeadlines = deadlineProvider.deadlines.where((d) {
          final now = DateTime.now();
          return d.date.isAfter(now) && d.date.difference(now).inDays <= 7;
        }).length;

        // Simple stats row
        return Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Row(
            children: [
              // Courses Count
              Expanded(
                child: _buildStatItem(
                  context,
                  label: 'Courses',
                  value: uniqueCourses.length.toString(),
                  icon: Icons.book,
                  color: AppColors.blue,
                  isDark: isDark,
                ),
              ),
              const SizedBox(width: 12),
              // Upcoming Deadlines (7 days)
              Expanded(
                child: _buildStatItem(
                  context,
                  label: 'Deadlines',
                  value: upcomingDeadlines.toString(),
                  icon: Icons.access_time,
                  color: AppColors.orange,
                  isDark: isDark,
                ),
              ),
              const SizedBox(width: 12),
              // Absence Risks
              Expanded(
                child: _buildStatItem(
                  context,
                  label: 'At Risk',
                  value: atRiskCount.toString(),
                  icon: Icons.warning_amber_rounded,
                  color: atRiskCount > 0 ? AppColors.red : AppColors.green,
                  isDark: isDark,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatItem(
    BuildContext context, {
    required String label,
    required String value,
    required IconData icon,
    required Color color,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(color: color.withValues(alpha: 0.1), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: isDark
                  ? AppColors.textPrimaryDark
                  : AppColors.textPrimaryLight,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: isDark
                  ? AppColors.textSecondaryDark
                  : AppColors.textSecondaryLight,
            ),
          ),
        ],
      ),
    );
  }
}

/// Bugünkü program kartı
/// Hızlı yakalama butonları
