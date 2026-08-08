import 'package:flutter/material.dart';
import 'package:lesson_tracker/core/theme/app_colors.dart';
import 'package:lesson_tracker/l10n/app_localizations.dart';

/// Shows a generic "are you sure?" confirmation dialog used by
/// destructive actions (delete file / delete grade / delete course).
///
/// Extracted from CourseDetailScreen per plan 3.1.2.
Future<bool> showConfirmActionDialog(
  BuildContext context, {
  String? title,
  String? message,
  String? confirmLabel,
  String? cancelLabel,
}) async {
  final result = await showDialog<bool>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: Text(title ?? AppLocalizations.of(dialogContext)!.delete),
      content: Text(
        message ??
            AppLocalizations.of(dialogContext)!.thisActionCannotBeUndone,
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(dialogContext, false),
          child: Text(cancelLabel ?? AppLocalizations.of(dialogContext)!.cancel),
        ),
        TextButton(
          onPressed: () => Navigator.pop(dialogContext, true),
          child: Text(
            confirmLabel ?? AppLocalizations.of(dialogContext)!.delete,
            style: const TextStyle(color: AppColors.red),
          ),
        ),
      ],
    ),
  );
  return result == true;
}