import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/theme/app_colors.dart';
import '../../models/course.dart';

import 'package:lesson_tracker/l10n/app_localizations.dart';

class AbsenceTrackerCard extends StatelessWidget {
  final Course course;
  final Function(int) onAbsenceChanged;
  final bool isDark;

  const AbsenceTrackerCard({
    super.key,
    required this.course,
    required this.onAbsenceChanged,
    required this.isDark,
  });

  Color _getStatusColor(double percentage) {
    if (percentage >= 0.85) return AppColors.red;
    if (percentage >= 0.50) return AppColors.orange;
    return AppColors.emerald;
  }

  String _getStatusMessage(BuildContext context, int remaining) {
    final l10n = AppLocalizations.of(context)!;
    if (remaining < 0) return l10n.absenceLimitExceeded((-remaining).toString());
    if (remaining == 0) return l10n.noAbsenceRightsLeft;
    return l10n.absenceRightsLeft(remaining.toString());
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final double percentage = course.absenceLimit > 0 ? (course.currentAbsences / course.absenceLimit).clamp(0.0, 1.0) : 0.0;
    final int remaining = course.absenceLimit - course.currentAbsences;
    final Color statusColor = _getStatusColor(percentage);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                l10n.absenceLabel,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  "${course.currentAbsences} / ${course.absenceLimit}",
                  style: TextStyle(
                    color: statusColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // Decrease Button
              _buildControlButton(
                icon: Icons.remove,
                color: isDark ? Colors.grey[700]! : Colors.grey[200]!,
                iconColor: isDark ? Colors.white : Colors.black,
                onPressed: () {
                  if (course.currentAbsences > 0) {
                    HapticFeedback.lightImpact();
                    // Assuming provider has new method removeLastAbsence, but passing callback for now. 
                    // Need to check how parent calls this. 
                    // Parent calls: context.read<CourseProvider>().updateCourse(...)
                    // This is OLD logic. We need parent to call removeLastAbsence.
                    // Or we let the parent handle the logic based on the callback.
                    // But wait, the parent callback `onAbsenceChanged` expects an int.
                    // This card needs to be refactored to call specific methods or let parent handle logic.
                    // Simple fix: Keep `onAbsenceChanged` for now, but really we should use the provider directly 
                    // or expose specific callbacks like `onAddAbsence` and `onRemoveAbsence`.
                    // For now, let's keep the UI change simple and rely on the parent logic if possible, 
                    // BUT the parent logic in CourseDetailScreen was:
                    // context.read<CourseProvider>().updateCourse(course.copyWith(currentAbsences: newAbsences));
                    // That logic is now insufficient as it doesn't remove the date entry from DB.
                    // We need to update CourseDetailScreen too.
                    onAbsenceChanged(course.currentAbsences - 1);
                  }
                },
              ),

              // Circular Progress Indicator & Text (Clickable for History)
              InkWell(
                onTap: () {
                   HapticFeedback.selectionClick();
                   _showHistoryDialog(context);
                },
                borderRadius: BorderRadius.circular(100),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      SizedBox(
                        width: 100,
                        height: 100,
                        child: CircularProgressIndicator(
                          value: percentage,
                          backgroundColor: isDark ? Colors.grey[800] : Colors.grey[100],
                          color: statusColor,
                          strokeWidth: 10,
                          strokeCap: StrokeCap.round,
                        ),
                      ),
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            remaining.toString(),
                            style: TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                            ),
                          ),
                          Text(
                            l10n.remainingLabel,
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

              // Increase Button
              _buildControlButton(
                icon: Icons.add,
                color: AppColors.primary,
                iconColor: Colors.white,
                onPressed: () {
                   HapticFeedback.mediumImpact();
                   onAbsenceChanged(course.currentAbsences + 1);
                },
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            _getStatusMessage(context, remaining),
            style: TextStyle(
              color: statusColor,
              fontWeight: FontWeight.w500,
              fontSize: 14,
            ),
          ),
          if (_buildPredictionWarning(context, remaining) != null)
            _buildPredictionWarning(context, remaining)!,
          if (course.absenceDates.isNotEmpty)
            GestureDetector(
               onTap: () {
                 HapticFeedback.selectionClick();
                 _showHistoryDialog(context);
               },
               child: Container(
                 margin: const EdgeInsets.only(top: 12),
                 padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                 decoration: BoxDecoration(
                   color: isDark ? const Color(0xFF2C3628) : const Color(0xFFF0F5ED), // Slightly different shade
                   borderRadius: BorderRadius.circular(12),
                   border: Border.all(
                     color: isDark ? Colors.white12 : Colors.black12,
                   ),
                 ),
                 child: Row(
                   mainAxisSize: MainAxisSize.min,
                   children: [
                     Icon(
                       Icons.history,
                       size: 16,
                       color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                     ),
                     const SizedBox(width: 8),
                     Text(
                       Localizations.localeOf(context).languageCode == 'tr' ? 'Geçmişi Görüntüle' : AppLocalizations.of(context)!.viewHistory,
                       style: TextStyle(
                         fontSize: 12,
                         fontWeight: FontWeight.w600,
                         color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                       ),
                     ),
                   ],
                 ),
               ),
            ),
        ],
      ),
    );
  }

  Widget? _buildPredictionWarning(BuildContext context, int remaining) {
    if (course.absenceDates.isEmpty || remaining <= 0) return null;

    final sortedDates = [...course.absenceDates]..sort();
    final firstAbsence = sortedDates.first;
    final weeksSinceFirst = DateTime.now().difference(firstAbsence).inDays / 7.0;
    if (weeksSinceFirst < 1) return null;

    final weeklyRate = course.currentAbsences / weeksSinceFirst;
    if (weeklyRate <= 0) return null;

    final weeksUntilLimit = remaining / weeklyRate;

    if (remaining > 3 || weeksUntilLimit > 12) return null;

    final locale = Localizations.localeOf(context).languageCode;
    final warningText = locale == 'tr'
        ? 'Bu hızla ${weeksUntilLimit.ceil()} hafta sonra limiti aşarsın'
        : 'At this rate, you\'ll exceed the limit in ${weeksUntilLimit.ceil()} weeks';

    return Container(
      margin: const EdgeInsets.only(top: 12),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.orange.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.orange.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.warning_amber_rounded, size: 18, color: AppColors.orange),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              warningText,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.orange,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showHistoryDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? AppColors.surfaceDark : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                AppLocalizations.of(context)!.absenceHistory,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                ),
              ),
              const SizedBox(height: 16),
              if (course.absenceDates.isEmpty)
                Text(
                  AppLocalizations.of(context)!.noAbsenceHistory,
                  style: TextStyle(
                     color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                  ),
                )
              else
                Flexible(
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: course.absenceDates.length,
                    itemBuilder: (context, index) {
                      final date = course.absenceDates[index];
                      // Simple formatting
                      // In real app use DateFormat
                      return ListTile(
                        leading: const Icon(Icons.event_busy, color: AppColors.red),
                        title: Text(
                           "${date.day}.${date.month}.${date.year}",
                           style: TextStyle(color: isDark ? Colors.white : Colors.black),
                        ),
                        subtitle: Text(
                          "${date.hour}:${date.minute}",
                          style: TextStyle(color: isDark ? Colors.grey : Colors.grey[600]),
                        ),
                      );
                    },
                  ),
                ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required Color color,
    required Color iconColor,
    required VoidCallback onPressed,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(50),
        child: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            color: iconColor,
            size: 28,
          ),
        ),
      ),
    );
  }
}
