import 'package:flutter/material.dart';
import 'package:lesson_tracker/core/theme/app_colors.dart';
import 'package:lesson_tracker/l10n/app_localizations.dart';
import 'package:lesson_tracker/models/course.dart';
import 'option_tile.dart';

/// Shows the bottom sheet with course-level actions (edit / archive /
/// add deadline / toggle notifications / delete).
///
/// Callbacks are passed in so this helper stays free of state mutations
/// from the host screen.
Future<void> showCourseOptionsSheet({
  required BuildContext context,
  required Course course,
  required void Function(Course course) onEdit,
  required Future<void> Function(Course updated) onArchive,
  required VoidCallback onAddDeadline,
  required void Function(bool newState) onToggleNotifications,
  required void Function(bool previousState) showSnack,
  required VoidCallback onDelete,
  required bool Function() notificationsEnabled,
}) async {
  final isDark = Theme.of(context).brightness == Brightness.dark;
  final l10n = AppLocalizations.of(context);

  await showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (sheetContext) {
      return DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.4,
        maxChildSize: 0.9,
        builder: (_, scrollController) => Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(28),
            ),
          ),
          child: Column(
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: isDark ? Colors.grey.shade600 : Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 24),
              Expanded(
                child: ListView(
                  controller: scrollController,
                  children: [
                    OptionTile(
                      icon: Icons.edit,
                      title: l10n?.editCourse ?? 'Edit Course',
                      onTap: () {
                        Navigator.pop(sheetContext);
                        onEdit(course);
                      },
                    ),
                    OptionTile(
                      icon: Icons.archive,
                      title: l10n?.archiveCourse ?? 'Archive Course',
                      onTap: () async {
                        Navigator.pop(sheetContext);
                        final updated = course.copyWith(status: 'archived');
                        await onArchive(updated);
                      },
                    ),
                    OptionTile(
                      icon: Icons.event_available,
                      title: l10n?.addDeadlineTitle ?? 'Add Deadline',
                      color: AppColors.primary,
                      onTap: () {
                        Navigator.pop(sheetContext);
                        onAddDeadline();
                      },
                    ),
                    OptionTile(
                      icon: Icons.notifications,
                      title: l10n?.notifications ?? 'Notifications',
                      onTap: () {
                        Navigator.pop(sheetContext);
                        final enabled = notificationsEnabled();
                        onToggleNotifications(!enabled);
                        showSnack(enabled);
                      },
                    ),
                    OptionTile(
                      icon: Icons.delete_outline,
                      title: l10n?.deleteCourse ?? 'Delete Course',
                      color: AppColors.red,
                      onTap: () {
                        Navigator.pop(sheetContext);
                        onDelete();
                      },
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}