import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/moodle_provider.dart';
import '../../../models/moodle/moodle_grade.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/moodle_utils.dart';
import '../../../../providers/language_provider.dart';
import '../widgets/academic_dashboard_widget.dart';

class MoodleGradesTab extends StatelessWidget {
  const MoodleGradesTab({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<MoodleProvider>();
    final grades = provider.allGrades;

    if (grades.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.grade_rounded,
                size: 56,
                color: Theme.of(context).colorScheme.outlineVariant),
            const SizedBox(height: 12),
            Text('Not bulunamadı',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant)),
          ],
        ),
      );
    }

    // Ders bazlı gruplama
    final grouped = <String, List<MoodleGrade>>{};
    for (final g in grades) {
      final key = '${g.accountId}_${g.courseId}';
      grouped.putIfAbsent(key, () => []).add(g);
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Akademik Dashboard üstte
        const AcademicDashboardWidget(),
        // Ders kartları
        ...grouped.entries
            .map((entry) => _GradeCard(grades: entry.value)),
      ],
    );
  }
}

class _GradeCard extends StatelessWidget {
  final List<MoodleGrade> grades;
  const _GradeCard({required this.grades});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final langCode = context.watch<LanguageProvider>().locale.languageCode;
    final courseName = grades.first.courseName;
    final avg = grades.isNotEmpty
        ? grades
                .map((g) => g.percentage)
                .reduce((a, b) => a + b) /
            grades.length
        : 0.0;

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? Colors.white.withValues(alpha: 0.1) : Colors.grey.shade200,
        ),
        boxShadow: [
          if (!isDark)
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                      MoodleUtils.parseMultilang(
                        courseName,
                        langCode,
                      ),
                      style: theme.textTheme.titleSmall
                          ?.copyWith(fontWeight: FontWeight.w700),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis),
                ),
                Text(
                  '${avg.toStringAsFixed(1)}%',
                  style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: _gradeColor(avg, theme)),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Horizontal bar chart
            ...grades.map((g) => _GradeBarRow(grade: g)),
          ],
        ),
      ),
    );
  }

  Color _gradeColor(double pct, ThemeData theme) {
    if (pct >= 85) return AppColors.green;
    if (pct >= 70) return AppColors.primary;
    if (pct >= 50) return AppColors.orange;
    return AppColors.red;
  }
}

class _GradeBarRow extends StatelessWidget {
  final MoodleGrade grade;
  const _GradeBarRow({required this.grade});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final langCode = context.watch<LanguageProvider>().locale.languageCode;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final pct = grade.percentage;
    final barColor = pct >= 85
        ? AppColors.green
        : pct >= 70
            ? AppColors.primary
            : pct >= 50
                ? AppColors.orange
                : AppColors.red;

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                    MoodleUtils.parseMultilang(
                      grade.itemName,
                      langCode,
                    ),
                    style: theme.textTheme.bodySmall,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis),
              ),
              const SizedBox(width: 8),
              Text(
                grade.isGraded
                    ? '${grade.gradeValue?.toStringAsFixed(1)} / ${grade.gradeMax.toStringAsFixed(0)}'
                    : '—',
                style: theme.textTheme.labelMedium
                    ?.copyWith(fontWeight: FontWeight.w600),
              ),
            ],
          ),
          const SizedBox(height: 4),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: pct / 100),
              duration: const Duration(milliseconds: 600),
              curve: Curves.easeOut,
              builder: (context, value, _) => LinearProgressIndicator(
                value: value,
                minHeight: 7,
                backgroundColor: isDark ? Colors.grey.shade800 : Colors.grey.shade200,
                valueColor: AlwaysStoppedAnimation<Color>(barColor),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
