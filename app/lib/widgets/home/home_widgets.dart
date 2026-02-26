import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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

  double get progress => totalHours > 0 ? (hoursCompleted / totalHours * 100) : 0;

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
                    color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
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
                        color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
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
                    color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
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
                    valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
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
        // Count absence risks
        final atRiskCount = courses.where((c) {
           return c.absenceLimit > 0 && (c.currentAbsences / c.absenceLimit) >= 0.7;
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
                  value: courses.length.toString(), 
                  icon: Icons.book,
                  color: AppColors.blue,
                  isDark: isDark
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
                  isDark: isDark
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
                  isDark: isDark
                ),
              ),
            ],
          ),
        );
      }
    );
  }

  Widget _buildStatItem(BuildContext context, {
    required String label, 
    required String value, 
    required IconData icon, 
    required Color color,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          )
        ],
        border: Border.all(
          color: color.withValues(alpha: 0.1),
          width: 1,
        )
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
              color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
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

  const ScheduleCard({
    super.key,
    required this.course,
    this.onTap,
  });

  IconData get _courseIcon {
    final name = course.name.toLowerCase();
    if (name.contains('math') || name.contains('calculus') || name.contains('algebra')) {
      return Icons.calculate;
    } else if (name.contains('history') || name.contains('art')) {
      return Icons.palette;
    } else if (name.contains('science') || name.contains('chemistry') || name.contains('physics')) {
      return Icons.science;
    } else if (name.contains('biology')) {
      return Icons.biotech;
    } else if (name.contains('english') || name.contains('literature')) {
      return Icons.menu_book;
    } else if (name.contains('music')) {
      return Icons.music_note;
    } else if (name.contains('computer') || name.contains('programming')) {
      return Icons.computer;
    }
    return Icons.school;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GlassCard(
      onTap: onTap,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Üst kısım - İkon ve Konum
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: course.color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  _courseIcon,
                  color: course.color,
                  size: 24,
                ),
              ),
              if (course.location != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: isDark ? Colors.grey.shade800 : Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    course.location!,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          // Ders adı
          Text(
            course.name,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
            ),
          ),
          if (course.subtitle != null) ...[
            const SizedBox(height: 4),
            Text(
              course.subtitle!,
              style: TextStyle(
                fontSize: 14,
                color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
              ),
            ),
          ],
          const Spacer(),
          // Saat
          Container(
            padding: const EdgeInsets.only(top: 12),
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(
                  color: isDark ? Colors.grey.shade800 : Colors.grey.shade200,
                ),
              ),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.schedule,
                  color: AppColors.primary,
                  size: 18,
                ),
                const SizedBox(width: 8),
                Text(
                  '${_formatTime(course.startTime)} - ${_formatTime(course.endTime)}',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatTime(TimeOfDay time) {
    final hour = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
    final period = time.period == DayPeriod.am ? 'AM' : 'PM';
    return '${hour.toString()}:${time.minute.toString().padLeft(2, '0')} $period';
  }
}

/// Öncelikli ders kartı
class PriorityCourseCard extends StatelessWidget {
  final Course course;
  final VoidCallback? onTap;

  const PriorityCourseCard({
    super.key,
    required this.course,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GlassCard(
      onTap: onTap,
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          // Sol - Resim/İkon
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: course.color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              Icons.school,
              color: course.color,
              size: 36,
            ),
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
                          color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                        ),
                      ),
                    ),
                    if (course.hasUpcomingExam)
                      const TagChip(
                        label: 'EXAM',
                        color: AppColors.orange,
                        isSmall: true,
                      )
                    else if (course.isBehind)
                      const TagChip(
                        label: 'BEHIND',
                        color: AppColors.red,
                        isSmall: true,
                      ),
                  ],
                ),
                if (course.subtitle != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    course.subtitle!,
                    style: TextStyle(
                      fontSize: 14,
                      color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                    ),
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
                        color: course.progress >= 50 
                            ? AppColors.primary 
                            : (isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ProgressBar(
                  progress: course.progress,
                  color: course.progress >= 50 ? AppColors.primary : AppColors.textSecondaryLight,
                  height: 8,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Hızlı yakalama butonları
class QuickCaptureButtons extends StatelessWidget {
  final VoidCallback onScanTap;
  final VoidCallback onVoiceTap;

  const QuickCaptureButtons({
    super.key,
    required this.onScanTap,
    required this.onVoiceTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Row(
      children: [
        // Scan Notes
        Expanded(
          child: _QuickCaptureButton(
            icon: Icons.document_scanner,
            title: 'Scan Notes',
            subtitle: 'OCR Import',
            color: AppColors.primary,
            isHighlighted: true,
            onTap: onScanTap,
            isDark: isDark,
          ),
        ),
        const SizedBox(width: 16),
        // Voice Memo
        Expanded(
          child: _QuickCaptureButton(
            icon: Icons.mic,
            title: 'Voice Memo',
            subtitle: 'Record Audio',
            color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
            isHighlighted: false,
            onTap: onVoiceTap,
            isDark: isDark,
          ),
        ),
      ],
    );
  }
}

class _QuickCaptureButton extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final bool isHighlighted;
  final VoidCallback onTap;
  final bool isDark;

  const _QuickCaptureButton({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.isHighlighted,
    required this.onTap,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: isHighlighted
          ? AppColors.primary.withValues(alpha: 0.15)
          : (isDark ? AppColors.surfaceDark : Colors.grey.shade100),
      borderRadius: BorderRadius.circular(24),
      child: InkWell(
        onTap: () {
          HapticFeedback.lightImpact();
          onTap();
        },
        borderRadius: BorderRadius.circular(24),
        child: Container(
          height: 140,
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: isDark ? AppColors.backgroundDark : Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Icon(
                  icon,
                  color: isHighlighted ? AppColors.primaryDark : color,
                  size: 28,
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
