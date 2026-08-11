import 'package:flutter/material.dart';
import 'package:lesson_tracker/core/theme/app_colors.dart';
import 'package:lesson_tracker/l10n/app_localizations.dart';

/// Empty state shown on the files tab when there are no files yet.
/// Extracted per plan 3.1.5 (P1).
class EmptyFilesState extends StatelessWidget {
  final bool isDark;
  final VoidCallback onAddFile;
  final VoidCallback? onAddLink;

  const EmptyFilesState({
    super.key,
    required this.isDark,
    required this.onAddFile,
    this.onAddLink,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Center(
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.folder_open,
              size: 64,
              color: isDark ? Colors.grey.shade700 : Colors.grey.shade300,
            ),
            const SizedBox(height: 16),
            Text(
              l10n.noFilesYet,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: isDark
                    ? AppColors.textSecondaryDark
                    : AppColors.textSecondaryLight,
              ),
            ),
            const SizedBox(height: 8),
            TextButton.icon(
              onPressed: onAddFile,
              icon: const Icon(Icons.upload_file),
              label: Text(l10n.uploadFile),
            ),
            if (onAddLink != null) ...[
              const SizedBox(height: 8),
              TextButton.icon(
                onPressed: onAddLink,
                icon: const Icon(Icons.link),
                label: Text(l10n.addLink),
              ),
            ],
          ],
        ),
      ),
    );
  }
}