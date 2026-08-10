import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lesson_tracker/l10n/app_localizations.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../models/course.dart';
import '../../../../models/grade.dart';
import '../../../../providers/course_provider.dart';
import 'widgets/grade_card.dart';

class CourseGradesTab extends StatelessWidget {
  final Course course;
  final List<Grade> grades;
  final bool isLoading;
  final VoidCallback onAddGrade;
  final Function(String) onDeleteGrade;
  final Function(Grade)? onEditGrade;

  const CourseGradesTab({
    super.key,
    required this.course,
    required this.grades,
    required this.isLoading,
    required this.onAddGrade,
    required this.onDeleteGrade,
    this.onEditGrade,
  });

  Color _getScoreColor(double percentage) {
    if (percentage >= 85) return AppColors.emerald;
    if (percentage >= 70) return AppColors.primary;
    if (percentage >= 50) return AppColors.orange;
    return AppColors.red;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context)!;
    final weightedAvg = context.read<CourseProvider>().calculateWeightedAverage(grades);
    final totalWeight = grades.fold<double>(0, (sum, g) => sum + g.weight);

    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        // Average summary card
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppColors.primary.withValues(alpha: 0.12),
                AppColors.primary.withValues(alpha: 0.04),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.averageShort,
                        style: TextStyle(
                          fontSize: 13,
                          color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        grades.isEmpty ? '—' : '${weightedAvg.toStringAsFixed(1)}%',
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.w700,
                          color: grades.isEmpty
                              ? (isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight)
                              : _getScoreColor(weightedAvg),
                        ),
                      ),
                    ],
                  ),
                  // Total weight indicator
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: totalWeight > 100
                          ? AppColors.red.withValues(alpha: 0.15)
                          : (isDark ? AppColors.surfaceDark : AppColors.surfaceLight),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: totalWeight > 100
                            ? AppColors.red.withValues(alpha: 0.5)
                            : (isDark ? Colors.grey.shade700 : Colors.grey.shade300),
                      ),
                    ),
                    child: Column(
                      children: [
                        Text(
                          l10n.weight,
                          style: TextStyle(
                            fontSize: 10,
                            color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                          ),
                        ),
                        Text(
                          '${totalWeight.toStringAsFixed(0)}%',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: totalWeight > 100 ? AppColors.red : AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Visual progress bar
              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: LinearProgressIndicator(
                  value: grades.isEmpty ? 0 : (weightedAvg / 100).clamp(0.0, 1.0),
                  minHeight: 10,
                  backgroundColor: isDark ? Colors.grey.shade800 : Colors.grey.shade200,
                  color: grades.isEmpty ? Colors.grey : _getScoreColor(weightedAvg),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),

        // Grades header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              l10n.gradesTab,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
              ),
            ),
            Text(
              '${grades.length}',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Grade List
        if (isLoading)
          const Center(child: Padding(padding: EdgeInsets.all(20), child: CircularProgressIndicator()))
        else if (grades.isEmpty)
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                Icon(Icons.assessment_outlined, size: 48, color: isDark ? Colors.grey.shade700 : Colors.grey.shade300),
                const SizedBox(height: 12),
                Text(
                  l10n.noGradesYet,
                  style: TextStyle(
                    color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          )
        else
          ...grades.map((grade) {
            return GradeCard(
              grade: grade,
              isDark: isDark,
              percentageOf: (score, max) => max > 0 ? (score / max * 100) : 0.0,
              colorFor: _getScoreColor,
              onEdit: onEditGrade == null ? null : () => onEditGrade!(grade),
              onDelete: () => onDeleteGrade(grade.id),
            );
          }).toList(),

        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: onAddGrade,
            icon: const Icon(Icons.add),
            label: Text(l10n.addGrade),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.primary,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              side: BorderSide(color: AppColors.primary.withValues(alpha: 0.5)),
            ),
          ),
        ),

        const SizedBox(height: 8),
        if (course.nextExamDate != null)
          Text(
            l10n.nextExamIn(course.nextExamDate!.difference(DateTime.now()).inDays),
            style: TextStyle(
              fontSize: 12,
              color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
            ),
          ),
      ],
    );
  }
}
