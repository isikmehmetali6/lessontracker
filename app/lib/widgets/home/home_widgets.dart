import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../models/course.dart';
import '../../providers/course_provider.dart';
import '../../providers/deadline_provider.dart';
import '../common/common_widgets.dart';

/// Günlük ilerleme widget'ı (Donut chart)
class DailyProgressWidget extends StatelessWidget {
  final double hoursCompleted;
  final double totalHours;

  const DailyProgressWidget({
    super.key,
    required this.hoursCompleted,
    required this.totalHours,
  });

  double get progress =>
      totalHours > 0 ? (hoursCompleted / totalHours * 100) : 0;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GlassCard(
      child: Row(
        children: [
          // Sol taraf - Metin
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Daily Progress',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: isDark
                        ? AppColors.textPrimaryDark
                        : AppColors.textPrimaryLight,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      hoursCompleted.toStringAsFixed(1),
                      style: const TextStyle(
                        fontSize: 40,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
                      ),
                    ),
                    Text(
                      ' / ${totalHours.toStringAsFixed(0)}h',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                        color: isDark
                            ? AppColors.textSecondaryDark
                            : AppColors.textSecondaryLight,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  progress >= 75
                      ? 'Great job! Almost there! 🔥'
                      : progress >= 50
                      ? 'Keep up the momentum!'
                      : 'Let\'s get productive!',
                  style: TextStyle(
                    fontSize: 14,
                    color: isDark
                        ? AppColors.textSecondaryDark
                        : AppColors.textSecondaryLight,
                  ),
                ),
              ],
            ),
          ),
          // Sağ taraf - Çember grafik
          SizedBox(
            width: 100,
            height: 100,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Arka plan çemberi
                SizedBox(
                  width: 100,
                  height: 100,
                  child: CircularProgressIndicator(
                    value: 1,
                    strokeWidth: 10,
                    backgroundColor: Colors.transparent,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      isDark ? Colors.grey.shade800 : Colors.grey.shade200,
                    ),
                  ),
                ),
                // İlerleme çemberi
                SizedBox(
                  width: 100,
                  height: 100,
                  child: CircularProgressIndicator(
                    value: progress / 100,
                    strokeWidth: 10,
                    backgroundColor: Colors.transparent,
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      AppColors.primary,
                    ),
                    strokeCap: StrokeCap.round,
                  ),
                ),
                // Ortadaki ikon
                const Icon(
                  Icons.local_fire_department,
                  color: AppColors.primary,
                  size: 32,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

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
class ScheduleCard extends StatelessWidget {
  final Course course;
  final VoidCallback? onTap;

  const ScheduleCard({super.key, required this.course, this.onTap});

  IconData get _courseIcon {
    final name = course.name.toLowerCase();
    if (name.contains('math') ||
        name.contains('calculus') ||
        name.contains('algebra')) {
      return Icons.calculate;
    } else if (name.contains('history') || name.contains('art')) {
      return Icons.palette;
    } else if (name.contains('science') ||
        name.contains('chemistry') ||
        name.contains('physics')) {
      return Icons.science;
    } else if (name.contains('biology')) {
      return Icons.biotech;
    } else if (name.contains('english') ||
        name.contains('literature') ||
        name.contains('language')) {
      return Icons.menu_book;
    } else if (name.contains('music')) {
      return Icons.music_note;
    } else if (name.contains('computer') ||
        name.contains('programming') ||
        name.contains('software')) {
      return Icons.computer;
    } else if (name.contains('law') || name.contains('legal')) {
      return Icons.gavel;
    } else if (name.contains('economy') ||
        name.contains('economics') ||
        name.contains('finance')) {
      return Icons.attach_money;
    } else if (name.contains('sport') || name.contains('physical')) {
      return Icons.sports;
    } else {
      return Icons.school;
    }
  }

  bool get _isClassEnded {
    final now = TimeOfDay.fromDateTime(DateTime.now());
    final endMin = course.endTime.hour * 60 + course.endTime.minute;
    final nowMin = now.hour * 60 + now.minute;
    return nowMin > endMin;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isEnded = _isClassEnded;

    return Opacity(
      opacity: isEnded ? 0.65 : 1,
      child: GlassCard(
        onTap: onTap,
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Üst kısım - Saat ve İkon
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Sol - Saat Bloğu (Daha büyük ve net)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: course.color.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: course.color.withValues(alpha: 0.4),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.schedule, color: course.color, size: 16),
                      const SizedBox(width: 8),
                      Text(
                        '${_formatTime(course.startTime)} - ${_formatTime(course.endTime)}',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: course.color,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
                // Sağ - Ders Kategorisini belirten İkon
                Icon(
                  _courseIcon,
                  color: isDark ? Colors.grey.shade600 : Colors.grey.shade400,
                  size: 28,
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Ders adı
            Text(
              course.name,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: isDark
                    ? AppColors.textPrimaryDark
                    : AppColors.textPrimaryLight,
                height: 1.2,
              ),
            ),
            const SizedBox(height: 8),
            // Konum ve Profesör
            Row(
              children: [
                if (course.location != null) ...[
                  Icon(
                    Icons.location_on,
                    size: 16,
                    color: isDark
                        ? AppColors.textSecondaryDark
                        : AppColors.textSecondaryLight,
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      course.location!,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: isDark
                            ? AppColors.textSecondaryDark
                            : AppColors.textSecondaryLight,
                      ),
                    ),
                  ),
                ],
              ],
            ),
            const Spacer(),
            // Alt kısım - Yoklama Bilgisi (İşlevsel Bilgi)
            if (course.absenceLimit > 0)
              Container(
                padding: const EdgeInsets.only(top: 12),
                decoration: BoxDecoration(
                  border: Border(
                    top: BorderSide(
                      color: isDark
                          ? Colors.grey.shade800
                          : Colors.grey.shade200,
                    ),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      course.currentAbsences >= course.absenceLimit
                          ? Icons.warning_rounded
                          : Icons.check_circle_outline,
                      color: course.currentAbsences >= course.absenceLimit
                          ? AppColors.red
                          : (isDark
                                ? AppColors.textSecondaryDark
                                : AppColors.textSecondaryLight),
                      size: 16,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Absences: ${course.currentAbsences} / ${course.absenceLimit}',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: course.currentAbsences >= course.absenceLimit
                            ? AppColors.red
                            : (isDark
                                  ? AppColors.textSecondaryDark
                                  : AppColors.textSecondaryLight),
                      ),
                    ),
                  ],
                ),
              )
            else
              Container(
                padding: const EdgeInsets.only(top: 12),
                decoration: BoxDecoration(
                  border: Border(
                    top: BorderSide(
                      color: isDark
                          ? Colors.grey.shade800
                          : Colors.grey.shade200,
                    ),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: isDark
                          ? AppColors.textSecondaryDark
                          : AppColors.textSecondaryLight,
                      size: 16,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'No absence limit set',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: isDark
                            ? AppColors.textSecondaryDark
                            : AppColors.textSecondaryLight,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  String _formatTime(TimeOfDay time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }
}

/// Öncelikli ders kartı
class PriorityCourseCard extends StatelessWidget {
  final Course course;
  final VoidCallback? onTap;

  const PriorityCourseCard({super.key, required this.course, this.onTap});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Determine background color based on priority
    Color bgColor;
    if (course.hasUpcomingExam || course.isBehind) {
      bgColor = AppColors.red.withValues(alpha: isDark ? 0.3 : 0.8);
    } else {
      bgColor = course.color.withValues(alpha: isDark ? 0.2 : 0.7);
    }

    Color textColor;
    Color secondaryTextColor;
    if (isDark) {
      textColor = course.hasUpcomingExam || course.isBehind
          ? Colors.white
          : (course.color.computeLuminance() > 0.5
                ? Colors.black
                : Colors.white);
      secondaryTextColor = Colors.white70;
    } else {
      textColor = Colors.white;
      secondaryTextColor = Colors.white70;
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: bgColor.withValues(alpha: 0.3),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // Sol - İkon
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(Icons.school, color: Colors.white, size: 32),
            ),
            const SizedBox(width: 16),
            // Sağ - Bilgiler
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          course.name,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: textColor,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (course.hasUpcomingExam)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    'EXAM',
                            style: TextStyle(
                              color: AppColors.red,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        )
                      else if (course.isBehind)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    'BEHIND',
                            style: TextStyle(
                              color: AppColors.red,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                    ],
                  ),
                  if (course.subtitle != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      course.subtitle!,
                      style: TextStyle(fontSize: 14, color: secondaryTextColor),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                  const SizedBox(height: 12),
                  // İlerleme çubuğu
                  Row(
                    children: [
                      Text(
                        '${course.progress.round()}% Complete',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: textColor,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Container(
                    height: 8,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: FractionallySizedBox(
                      alignment: Alignment.centerLeft,
                      widthFactor: (course.progress / 100).clamp(0.0, 1.0),
                      child: Container(
                          decoration: BoxDecoration(
                             color: isDark ? AppColors.surfaceDarkElevated : AppColors.surfaceLight,
                            borderRadius: BorderRadius.circular(4),
                          ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Hızlı yakalama butonları
