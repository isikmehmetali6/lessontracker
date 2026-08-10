import 'package:flutter/material.dart';
import 'package:lesson_tracker/core/theme/app_colors.dart';
import 'package:lesson_tracker/l10n/app_localizations.dart';

/// Top "weighted average + total weight" summary card shown on the
/// grades tab. Extracted per plan 3.1.5 (P1).
class GradesSummaryCard extends StatelessWidget {
  final double weightedAvg;
  final double totalWeight;
  final bool isDark;
  final Color Function(double score) scoreColor;

  const GradesSummaryCard({
    super.key,
    required this.weightedAvg,
    required this.totalWeight,
    required this.isDark,
    required this.scoreColor,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final hasGrades = totalWeight > 0;

    return Container(
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
                      color: isDark
                          ? AppColors.textSecondaryDark
                          : AppColors.textSecondaryLight,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    hasGrades
                        ? '${weightedAvg.toStringAsFixed(1)}%'
                        : '—',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w700,
                      color: hasGrades
                          ? scoreColor(weightedAvg)
                          : (isDark
                              ? AppColors.textSecondaryDark
                              : AppColors.textSecondaryLight),
                    ),
                  ),
                ],
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: totalWeight > 100
                      ? AppColors.red.withValues(alpha: 0.15)
                      : (isDark
                          ? AppColors.surfaceDark
                          : AppColors.surfaceLight),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: totalWeight > 100
                        ? AppColors.red.withValues(alpha: 0.5)
                        : (isDark
                            ? Colors.grey.shade700
                            : Colors.grey.shade300),
                  ),
                ),
                child: Column(
                  children: [
                    Text(
                      l10n.weight,
                      style: TextStyle(
                        fontSize: 10,
                        color: isDark
                            ? AppColors.textSecondaryDark
                            : AppColors.textSecondaryLight,
                      ),
                    ),
                    Text(
                      '${totalWeight.toStringAsFixed(0)}%',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: totalWeight > 100
                            ? AppColors.red
                            : AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: hasGrades
                  ? (weightedAvg / 100).clamp(0.0, 1.0)
                  : 0,
              minHeight: 10,
              backgroundColor:
                  isDark ? Colors.grey.shade800 : Colors.grey.shade200,
              color: hasGrades
                  ? scoreColor(weightedAvg)
                  : Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
}