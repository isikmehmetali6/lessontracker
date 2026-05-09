import 'dart:io';
import 'package:flutter/material.dart';
import 'package:lesson_tracker/l10n/app_localizations.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/services/file_service.dart';
import '../../../../models/course.dart';
import '../../../../models/course_file.dart';

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

    return ListView.builder(
      padding: const EdgeInsets.all(24),
      itemCount: files.length + 1, // +1 for Add button
      itemBuilder: (context, index) {
        if (index == files.length) {
          return Padding(
            padding: const EdgeInsets.only(top: 16),
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
          );
        }
        
        final file = files[index];
        IconData icon = Icons.insert_drive_file;
        Color color = Colors.grey;
        
        if (file.type == 'pdf') {
          icon = Icons.picture_as_pdf;
          color = AppColors.red;
        } else if (file.type == 'image') {
          icon = Icons.image;
          color = AppColors.blue;
        }

        if (file.url != null) {
          if (file.url!.contains('youtube') || file.url!.contains('vimeo')) {
            icon = Icons.videocam;
            color = AppColors.red;
          } else if (file.url!.endsWith('.pdf')) {
            icon = Icons.picture_as_pdf;
            color = AppColors.red;
          } else {
            icon = Icons.link;
            color = AppColors.primary;
          }
        }

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isDark ? Colors.grey.shade700 : Colors.grey.shade200,
            ),
          ),
          child: ListTile(
            leading: Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: file.type == 'image'
                  ? FutureBuilder<String?>(
                      future: FileService().resolveFilePath(file.path),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const Center(child: CircularProgressIndicator(strokeWidth: 2));
                        }
                        final resolvedPath = snapshot.data;
                        if (resolvedPath != null && File(resolvedPath).existsSync()) {
                          return ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.file(
                              File(resolvedPath),
                              fit: BoxFit.cover,
                              cacheWidth: 200, // Optimize memory footprint
                              errorBuilder: (_, _, _) => Icon(icon, color: color),
                            ),
                          );
                        }
                        return Icon(icon, color: color); // Fallback if file not found
                      },
                    )
                  : Icon(icon, color: color),
            ),
            title: Text(
              file.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
              ),
            ),
            subtitle: Text(
              file.url != null ? file.url! : 'Added ${file.createdAt.year}-${file.createdAt.month}-${file.createdAt.day}',
              style: TextStyle(
                fontSize: 12,
                color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
              ),
            ),
            trailing: IconButton(
              icon: const Icon(Icons.delete_outline, color: AppColors.red),
              onPressed: () => onDeleteFile(file),
            ),
            onTap: () => onOpenFile(file),
          ),
        );
      },
    );
  }
}
