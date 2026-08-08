import 'package:flutter/material.dart';
import 'package:lesson_tracker/core/theme/app_colors.dart';
import 'package:lesson_tracker/screens/course_detail/tabs/absence_reason.dart'
    show absenceReasonColors;

typedef ReasonLabelBuilder = String Function(String reason);

/// Builds the "absence reason color legend" chip row. Extracted from
/// `_AbsenceCalendarTabState._buildLegend` per plan 3.1.6.
class AbsenceLegend extends StatelessWidget {
  final bool isDark;
  final ReasonLabelBuilder reasonLabel;

  const AbsenceLegend({
    super.key,
    required this.isDark,
    required this.reasonLabel,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Wrap(
        spacing: 16,
        runSpacing: 8,
        children: absenceReasonColors.entries.map((e) {
          return Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: e.value,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                reasonLabel(e.key),
                style: TextStyle(
                  fontSize: 12,
                  color: isDark
                      ? AppColors.textSecondaryDark
                      : AppColors.textSecondaryLight,
                ),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }
}