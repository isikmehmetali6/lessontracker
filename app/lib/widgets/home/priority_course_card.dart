import 'package:flutter/material.dart';
import 'package:lesson_tracker/core/theme/app_colors.dart';
import 'package:lesson_tracker/models/course.dart';

class PriorityCourseCard extends StatelessWidget {
  final Course course;
  final VoidCallback? onTap;

  const PriorityCourseCard({super.key, required this.course, this.onTap});  @override
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

    final semanticLabel = course.hasUpcomingExam
        ? '${course.name}, exam upcoming, ${course.progress.round()}% complete'
        : course.isBehind
            ? '${course.name}, behind schedule, ${course.progress.round()}% complete'
            : '${course.name}, ${course.progress.round()}% complete';

    return Semantics(
      button: onTap != null,
      label: semanticLabel,
      excludeSemantics: true,
      child: GestureDetector(
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
      ),
    );
  }
}
