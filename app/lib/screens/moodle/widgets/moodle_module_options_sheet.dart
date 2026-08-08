import 'package:flutter/material.dart';
import 'package:lesson_tracker/core/theme/app_colors.dart';
import 'package:lesson_tracker/l10n/app_localizations.dart';

/// Builds the "Moodle module options" bottom sheet. The user picks
/// "Transfer to course" which opens the course selection flow via
/// [onTransferToCourse]. Extracted from
/// `_MoodleCourseDetailScreenState._showOptionsBottomSheet` per plan
/// 3.1.3.
Future<void> showMoodleModuleOptionsSheet({
  required BuildContext context,
  required VoidCallback onTransferToCourse,
}) {
  return showModalBottomSheet<void>(
    context: context,
    backgroundColor: Theme.of(context).colorScheme.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (sheetContext) {
      return SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.drive_file_move_rounded,
                  color: AppColors.primary,
                ),
              ),
              title: Text(AppLocalizations.of(sheetContext)!.moodleTransferToCourse),
              subtitle: Text(AppLocalizations.of(sheetContext)!.moodleTransferDesc),
              onTap: () {
                Navigator.pop(sheetContext);
                onTransferToCourse();
              },
            ),
            const SizedBox(height: 16),
          ],
        ),
      );
    },
  );
}