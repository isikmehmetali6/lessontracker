import 'package:flutter/material.dart';
import 'package:lesson_tracker/core/theme/app_colors.dart';
import 'package:lesson_tracker/models/course.dart';
import 'package:lesson_tracker/widgets/common/common_widgets.dart';

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

    final timeRange =
        '${_formatTime(course.startTime)} - ${_formatTime(course.endTime)}';
    final semanticLabel = course.location != null
        ? '${course.name}, $timeRange, ${course.location}'
        : '${course.name}, $timeRange';

    return Semantics(
      button: onTap != null,
      label: semanticLabel,
      excludeSemantics: true,
      child: Opacity(
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
      ),
    );
  }

  String _formatTime(TimeOfDay time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }
}

