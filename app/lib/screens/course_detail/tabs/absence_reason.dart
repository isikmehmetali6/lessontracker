import 'package:flutter/material.dart';
import 'package:lesson_tracker/core/theme/app_colors.dart';

/// Reason → color mapping for absence calendar/picker UI.
const Map<String, Color> absenceReasonColors = {
  'unexcused': AppColors.red,
  'medical': Colors.blue,
  'excused': AppColors.emerald,
  'personal': AppColors.orange,
};

/// Reason → icon mapping for absence calendar/picker UI.
const Map<String, IconData> absenceReasonIcons = {
  'unexcused': Icons.cancel,
  'medical': Icons.local_hospital,
  'excused': Icons.check_circle,
  'personal': Icons.person,
};

/// Translates a reason key to a localized label. The label is provided
/// by the host via the [l10n] delegate so the helper stays free of
/// AppLocalizations.
typedef AbsenceReasonLabelBuilder = String Function(String reason);

String defaultReasonLabel(
  String reason, {
  required String unexcused,
  required String medical,
  required String excused,
  required String personal,
}) {
  switch (reason) {
    case 'unexcused':
      return unexcused;
    case 'medical':
      return medical;
    case 'excused':
      return excused;
    case 'personal':
      return personal;
    default:
      return reason;
  }
}