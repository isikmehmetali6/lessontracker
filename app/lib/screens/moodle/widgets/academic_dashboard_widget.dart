import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/moodle_provider.dart';
import '../../../../core/theme/app_colors.dart';

/// Akademik Dashboard widget — GPA, ders performansları, risk analizi.
/// MoodleGradesTab'ın üstüne eklenir.
class AcademicDashboardWidget extends StatelessWidget {
  const AcademicDashboardWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<MoodleProvider>();
    final grades = provider.allGrades.where((g) => g.isGraded).toList();
    final assignments = provider.allAssignments;

    if (grades.isEmpty) return const SizedBox.shrink();

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Genel ortalama
    final overallAvg = grades.isEmpty
        ? 0.0
        : grades.map((g) => g.percentage).reduce((a, b) => a + b) /
            grades.length;

    // Ders bazlı ortalamalar
    final courseAvgs = <String, _CourseStats>{};
    for (final g in grades) {
      courseAvgs.update(
        g.courseName,
        (existing) => _CourseStats(
          courseName: g.courseName,
          totalPct: existing.totalPct + g.percentage,
          count: existing.count + 1,
        ),
        ifAbsent: () => _CourseStats(
          courseName: g.courseName,
          totalPct: g.percentage,
          count: 1,
        ),
      );
    }

    final sortedCourses = courseAvgs.values.toList()
      ..sort((a, b) => b.avg.compareTo(a.avg));

    final bestCourse = sortedCourses.isNotEmpty ? sortedCourses.first : null;
    final worstCourse =
        sortedCourses.length > 1 ? sortedCourses.last : null;

    // Bu haftaki ödev sayısı
    final weekAssignments =
        assignments.where((a) => !a.submitted && a.isDueThisWeek).length;
    final overdueCount = assignments.where((a) => a.isOverdue).length;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? [
                  AppColors.primary.withValues(alpha: 0.2),
                  AppColors.surfaceDark,
                ]
              : [
                  AppColors.primary.withValues(alpha: 0.08),
                  Colors.white,
                ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.15),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Başlık
            Row(
              children: [
                const Icon(Icons.analytics_rounded,
                    color: AppColors.primary, size: 22),
                const SizedBox(width: 8),
                Text(
                  'Akademik Özet',
                  style: theme.textTheme.titleMedium
                      ?.copyWith(fontWeight: FontWeight.w700),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Büyük ortalama göstergesi
            Row(
              children: [
                // Dairesel puan göstergesi
                SizedBox(
                  width: 80,
                  height: 80,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      SizedBox(
                        width: 80,
                        height: 80,
                        child: TweenAnimationBuilder<double>(
                          tween: Tween(begin: 0, end: overallAvg / 100),
                          duration: const Duration(milliseconds: 800),
                          curve: Curves.easeOut,
                          builder: (context, value, _) =>
                              CircularProgressIndicator(
                            value: value,
                            strokeWidth: 8,
                            strokeCap: StrokeCap.round,
                            backgroundColor: isDark
                                ? Colors.grey.shade800
                                : Colors.grey.shade200,
                            valueColor: AlwaysStoppedAnimation(
                                _gradeColor(overallAvg)),
                          ),
                        ),
                      ),
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '${overallAvg.toStringAsFixed(0)}%',
                            style: theme.textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.w800,
                                color: _gradeColor(overallAvg)),
                          ),
                          Text(
                            'Ort.',
                            style: theme.textTheme.labelSmall?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 20),
                // Hafta istatistikleri
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _StatRow(
                        icon: Icons.assignment_rounded,
                        label: 'Bu hafta ödev',
                        value: '$weekAssignments',
                        color: AppColors.primary,
                      ),
                      const SizedBox(height: 6),
                      if (overdueCount > 0)
                        _StatRow(
                          icon: Icons.warning_rounded,
                          label: 'Gecikmiş',
                          value: '$overdueCount',
                          color: AppColors.red,
                        ),
                      if (overdueCount > 0) const SizedBox(height: 6),
                      _StatRow(
                        icon: Icons.school_rounded,
                        label: 'Ders sayısı',
                        value: '${courseAvgs.length}',
                        color: AppColors.green,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // En iyi ve en riskli ders
            if (bestCourse != null || worstCourse != null)
              Row(
                children: [
                  if (bestCourse != null)
                    Expanded(
                      child: _CoursePill(
                        emoji: '🏆',
                        label: 'En İyi',
                        courseName: bestCourse.courseName,
                        pct: bestCourse.avg,
                      ),
                    ),
                  if (bestCourse != null && worstCourse != null)
                    const SizedBox(width: 10),
                  if (worstCourse != null && worstCourse != bestCourse)
                    Expanded(
                      child: _CoursePill(
                        emoji: '⚠️',
                        label: 'En Riskli',
                        courseName: worstCourse.courseName,
                        pct: worstCourse.avg,
                      ),
                    ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Color _gradeColor(double pct) {
    if (pct >= 85) return AppColors.green;
    if (pct >= 70) return AppColors.primary;
    if (pct >= 50) return AppColors.orange;
    return AppColors.red;
  }
}

class _StatRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _StatRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 6),
        Text(label,
            style: theme.textTheme.bodySmall
                ?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
        const Spacer(),
        Text(value,
            style: theme.textTheme.bodySmall
                ?.copyWith(fontWeight: FontWeight.w700)),
      ],
    );
  }
}

class _CoursePill extends StatelessWidget {
  final String emoji;
  final String label;
  final String courseName;
  final double pct;

  const _CoursePill({
    required this.emoji,
    required this.label,
    required this.courseName,
    required this.pct,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withValues(alpha: 0.05)
            : Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(emoji, style: const TextStyle(fontSize: 14)),
              const SizedBox(width: 4),
              Text(label,
                  style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w600)),
            ],
          ),
          const SizedBox(height: 2),
          Text(
            courseName,
            style: theme.textTheme.bodySmall
                ?.copyWith(fontWeight: FontWeight.w600),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            '${pct.toStringAsFixed(1)}%',
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

class _CourseStats {
  final String courseName;
  final double totalPct;
  final int count;

  _CourseStats({
    required this.courseName,
    required this.totalPct,
    required this.count,
  });

  double get avg => count > 0 ? totalPct / count : 0;
}
