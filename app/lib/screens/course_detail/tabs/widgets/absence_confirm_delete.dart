import 'package:flutter/material.dart';
import 'package:lesson_tracker/core/theme/app_colors.dart';
import 'package:lesson_tracker/l10n/app_localizations.dart';

/// Shows the "delete this absence?" confirmation dialog. Returns true if
/// the user confirmed. Extracted from
/// `_AbsenceCalendarTabState._confirmDelete` per plan 3.1.6.
Future<bool> confirmAbsenceDelete(BuildContext context) async {
  final l10n = AppLocalizations.of(context)!;
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text(l10n.deleteAbsence),
      content: Text(l10n.thisActionCannotBeUndone),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx, false),
          child: Text(l10n.cancel),
        ),
        TextButton(
          onPressed: () => Navigator.pop(ctx, true),
          child: Text(
            l10n.delete,
            style: const TextStyle(color: AppColors.red),
          ),
        ),
      ],
    ),
  );
  return confirmed == true;
}