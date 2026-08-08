import 'package:flutter/material.dart';
import 'package:lesson_tracker/core/theme/app_colors.dart';
import 'package:lesson_tracker/l10n/app_localizations.dart';
import 'package:lesson_tracker/screens/course_detail/tabs/absence_reason.dart'
    show absenceReasonIcons, absenceReasonColors;

typedef ReasonLabelBuilder = String Function(String reason);

/// Builds the "selected day details" panel (absence list with edit/delete
/// actions). Extracted from `_AbsenceCalendarTabState._buildSelectedDayDetails`
/// per plan 3.1.6.
class AbsenceDayDetails extends StatelessWidget {
  final bool isDark;
  final List<Map<String, dynamic>> events;
  final void Function(String absenceId, String currentReason) onEditReason;
  final void Function(String absenceId) onConfirmDelete;
  final ReasonLabelBuilder reasonLabel;

  const AbsenceDayDetails({
    super.key,
    required this.isDark,
    required this.events,
    required this.onEditReason,
    required this.onConfirmDelete,
    required this.reasonLabel,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    if (events.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          l10n.noAbsencesOnDay,
          style: TextStyle(
            color: isDark
                ? AppColors.textSecondaryDark
                : AppColors.textSecondaryLight,
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: events.map((a) {
          final reason = (a['reason'] as String?) ?? 'unexcused';
          final color = absenceReasonColors[reason] ?? AppColors.red;
          final icon = absenceReasonIcons[reason] ?? Icons.cancel;
          final id = a['id'] as String?;
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              children: [
                Icon(icon, color: color, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    reasonLabel(reason),
                    style: TextStyle(
                      color: isDark ? Colors.white : Colors.black,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                if (id != null) ...[
                  IconButton(
                    icon: Icon(
                      Icons.edit_outlined,
                      size: 18,
                      color: AppColors.primary,
                    ),
                    onPressed: () => onEditReason(id, reason),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(
                      Icons.delete_outline,
                      size: 18,
                      color: AppColors.red,
                    ),
                    onPressed: () => onConfirmDelete(id),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}