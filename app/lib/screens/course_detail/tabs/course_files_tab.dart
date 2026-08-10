import 'package:flutter/material.dart';
import 'package:lesson_tracker/l10n/app_localizations.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../models/course.dart';
import '../../../../models/course_file.dart';
import 'widgets/file_list.dart';

class CourseFilesTab extends StatelessWidget {
  final Course course;
  final List<CourseFile> files;
  final bool isLoading;
  final VoidCallback onAddFile;
  final Function(CourseFile) onDeleteFile;
  final Function(CourseFile) onOpenFile;
  final VoidCallback? onAddLink;

  const CourseFilesTab({
    super.key,
    required this.course,
    required this.files,
    required this.isLoading,
    required this.onAddFile,
    required this.onDeleteFile,
    required this.onOpenFile,
    this.onAddLink,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    
    if (files.isEmpty) {
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
                AppLocalizations.of(context)!.noFilesYet,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                ),
              ),
              const SizedBox(height: 8),
              TextButton.icon(
                onPressed: onAddFile,
                icon: const Icon(Icons.upload_file),
                label: Text(AppLocalizations.of(context)!.uploadFile),
              ),
              const SizedBox(height: 8),
              TextButton.icon(
                onPressed: onAddLink,
                icon: const Icon(Icons.link),
                label: Text(AppLocalizations.of(context)!.addLink),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      children: [
        Expanded(
          child: FileList(
            files: files,
            isDark: isDark,
            onTap: onOpenFile,
            onDelete: onDeleteFile,
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 8),
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: onAddFile,
                  icon: const Icon(Icons.add),
                  label: Text(AppLocalizations.of(context)!.addFile),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: onAddLink,
                  icon: const Icon(Icons.link),
                  label: Text(AppLocalizations.of(context)!.addLink),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
