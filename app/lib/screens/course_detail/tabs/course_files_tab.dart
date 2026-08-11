import 'package:flutter/material.dart';
import 'package:lesson_tracker/l10n/app_localizations.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../models/course.dart';
import '../../../../models/course_file.dart';
import 'widgets/file_list.dart';
import 'widgets/empty_files_state.dart';

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
      return EmptyFilesState(
        isDark: isDark,
        onAddFile: onAddFile,
        onAddLink: onAddLink,
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
