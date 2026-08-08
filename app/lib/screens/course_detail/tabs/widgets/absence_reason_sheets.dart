import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:lesson_tracker/core/theme/app_colors.dart';
import 'package:lesson_tracker/l10n/app_localizations.dart';
import 'package:lesson_tracker/providers/course_provider.dart';
import '../absence_reason.dart' show absenceReasonColors, absenceReasonIcons;

/// Builds the inline reason row used by the absence add/edit sheets.
class AbsenceReasonRow extends StatelessWidget {
  final String reason;
  final bool isSelected;
  final bool isDark;
  final String label;
  final VoidCallback onTap;

  const AbsenceReasonRow({
    super.key,
    required this.reason,
    required this.isSelected,
    required this.isDark,
    required this.label,
    required this.onTap,
  });

  Color get _color => absenceReasonColors[reason] ?? AppColors.red;

  IconData get _icon => absenceReasonIcons[reason] ?? Icons.cancel;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? _color.withValues(alpha: 0.15)
              : (isDark ? Colors.grey.shade800 : Colors.grey.shade50),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? _color : Colors.transparent,
            width: 2,
          ),
        ),
        child: Row(
          children: [
            Icon(_icon, color: _color, size: 22),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                  color: isDark
                      ? AppColors.textPrimaryDark
                      : AppColors.textPrimaryLight,
                ),
              ),
            ),
            if (isSelected) Icon(Icons.check_circle, color: _color, size: 22),
          ],
        ),
      ),
    );
  }
}

/// Shared reason picker for the absence add/edit sheets.
class AbsenceReasonPicker extends StatelessWidget {
  final String selectedReason;
  final bool isDark;
  final void Function(String reason) onChanged;
  final String Function(String reason) labelBuilder;

  const AbsenceReasonPicker({
    super.key,
    required this.selectedReason,
    required this.isDark,
    required this.onChanged,
    required this.labelBuilder,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: absenceReasonColors.entries.map((e) {
        return AbsenceReasonRow(
          reason: e.key,
          isSelected: selectedReason == e.key,
          isDark: isDark,
          label: labelBuilder(e.key),
          onTap: () => onChanged(e.key),
        );
      }).toList(),
    );
  }
}

/// Modal sheet for adding an absence on [selectedDate] for [courseId].
Future<void> showAbsenceAddSheet({
  required BuildContext context,
  required String courseId,
  required DateTime selectedDate,
  required bool isDark,
  required String Function(String reason) labelBuilder,
  required Future<void> Function() onSaved,
}) {
  return _showCommonReasonSheet(
    context: context,
    isDark: isDark,
    title: AppLocalizations.of(context)!.addAbsence,
    subtitle:
        '${selectedDate.day}/${selectedDate.month}/${selectedDate.year}',
    subtitleLabel: 'SelectReason',
    labelBuilder: labelBuilder,
    onSubmit: (reason) async {
      final provider = context.read<CourseProvider>();
      await provider.addAbsenceAt(
        courseId,
        selectedDate,
        reason: reason,
      );
      HapticFeedback.mediumImpact();
      onSaved();
    },
  );
}

/// Modal sheet for editing the reason of an existing absence.
Future<void> showAbsenceEditSheet({
  required BuildContext context,
  required String absenceId,
  required String currentReason,
  required bool isDark,
  required String Function(String reason) labelBuilder,
  required Future<void> Function() onSaved,
}) {
  return _showCommonReasonSheet(
    context: context,
    isDark: isDark,
    title: AppLocalizations.of(context)!.editAbsence,
    subtitle: null,
    subtitleLabel: null,
    initialReason: currentReason,
    labelBuilder: labelBuilder,
    onSubmit: (reason) async {
      final provider = context.read<CourseProvider>();
      await provider.updateAbsenceReasonById(absenceId, reason);
      HapticFeedback.mediumImpact();
      onSaved();
    },
  );
}

Future<void> _showCommonReasonSheet({
  required BuildContext context,
  required bool isDark,
  required String title,
  required String? subtitle,
  required String? subtitleLabel,
  String? initialReason,
  required String Function(String reason) labelBuilder,
  required Future<void> Function(String reason) onSubmit,
}) async {
  String selectedReason = initialReason ?? 'unexcused';
  final l10n = AppLocalizations.of(context)!;

  await showModalBottomSheet<void>(
    context: context,
    backgroundColor: Colors.transparent,
    builder: (sheetContext) {
      return StatefulBuilder(
        builder: (ctx, setSheetState) {
          return Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: isDark ? Colors.grey.shade600 : Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: isDark
                        ? AppColors.textPrimaryDark
                        : AppColors.textPrimaryLight,
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 14,
                      color: isDark
                          ? AppColors.textSecondaryDark
                          : AppColors.textSecondaryLight,
                    ),
                  ),
                ],
                const SizedBox(height: 20),
                if (subtitleLabel != null) ...[
                  Text(
                    l10n.selectReason,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: isDark
                          ? AppColors.textPrimaryDark
                          : AppColors.textPrimaryLight,
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
                AbsenceReasonPicker(
                  selectedReason: selectedReason,
                  isDark: isDark,
                  onChanged: (r) => setSheetState(() => selectedReason = r),
                  labelBuilder: labelBuilder,
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () async {
                      if (!ctx.mounted) return;
                      Navigator.pop(ctx);
                      await onSubmit(selectedReason);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(l10n.save),
                  ),
                ),
                const SizedBox(height: 8),
              ],
            ),
          );
        },
      );
    },
  );
}