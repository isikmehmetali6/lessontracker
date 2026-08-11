import 'package:flutter/material.dart';
import 'package:lesson_tracker/l10n/app_localizations.dart';

/// Maps an absence-reason key (e.g. 'unexcused', 'medical') to its
/// localized label. Extracted per plan 3.1.6 (P2).
String absenceReasonLabel(BuildContext context, String reason) {
  final l10n = AppLocalizations.of(context)!;
  switch (reason) {
    case 'unexcused':
      return l10n.absenceUnexcused;
    case 'medical':
      return l10n.absenceMedical;
    case 'excused':
      return l10n.absenceExcused;
    case 'personal':
      return l10n.absencePersonal;
    default:
      return reason;
  }
}