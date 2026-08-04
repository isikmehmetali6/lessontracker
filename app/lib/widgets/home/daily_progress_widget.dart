import 'package:flutter/material.dart';
import 'package:lesson_tracker/core/theme/app_colors.dart';
import 'package:lesson_tracker/widgets/common/common_widgets.dart';

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
          SizedBox(
            width: 100,
            height: 100,
            child: Stack(
              alignment: Alignment.center,
              children: [
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