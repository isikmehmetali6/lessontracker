import 'dart:io';

import 'package:flutter/material.dart';
import 'package:lesson_tracker/core/theme/app_colors.dart';
import 'package:lesson_tracker/models/course_file.dart';
import 'package:lesson_tracker/services/file_service.dart';

/// Renders the file list inside [CourseFilesTab]. Extracted per plan
/// 3.1.5 (P1).
class FileList extends StatelessWidget {
  final List<CourseFile> files;
  final bool isDark;
  final void Function(CourseFile) onTap;
  final void Function(CourseFile) onDelete;
  final Future<String?> Function(String path)? resolveFilePath;

  const FileList({
    super.key,
    required this.files,
    required this.isDark,
    required this.onTap,
    required this.onDelete,
    this.resolveFilePath,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: files.length + 1,
      itemBuilder: (context, index) {
        if (index == files.length) return const SizedBox.shrink();

        final file = files[index];
        final style = _iconStyleFor(file);

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
            leading: _buildLeading(file, style.icon, style.color),
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
              file.url != null
                  ? file.url!
                  : 'Added ${file.createdAt.year}-${file.createdAt.month}-${file.createdAt.day}',
              style: TextStyle(
                fontSize: 12,
                color: isDark
                    ? AppColors.textSecondaryDark
                    : AppColors.textSecondaryLight,
              ),
            ),
            trailing: IconButton(
              icon: const Icon(Icons.delete_outline, color: AppColors.red),
              onPressed: () => onDelete(file),
            ),
            onTap: () => onTap(file),
          ),
        );
      },
    );
  }

  _IconStyle _iconStyleFor(CourseFile file) {
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
    return _IconStyle(icon, color);
  }

  Widget _buildLeading(CourseFile file, IconData icon, Color color) {
    if (file.type == 'image') {
      return Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: FutureBuilder<String?>(
          future: (resolveFilePath ?? FileService().resolveFilePath)(file.path),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(strokeWidth: 2),
              );
            }
            final resolvedPath = snapshot.data;
            if (resolvedPath != null && File(resolvedPath).existsSync()) {
              return ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.file(
                  File(resolvedPath),
                  fit: BoxFit.cover,
                  cacheWidth: 200,
                  errorBuilder: (_, __, ___) => Icon(icon, color: color),
                ),
              );
            }
            return Icon(icon, color: color);
          },
        ),
      );
    }
    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(icon, color: color),
    );
  }
}

class _IconStyle {
  final IconData icon;
  final Color color;
  _IconStyle(this.icon, this.color);
}