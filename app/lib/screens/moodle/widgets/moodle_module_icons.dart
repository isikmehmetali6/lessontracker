import 'package:flutter/material.dart';
import 'package:lesson_tracker/core/theme/app_colors.dart';
import 'package:lesson_tracker/models/moodle/moodle_course_content.dart';

/// Maps a `MoodleCourseModule` (and optional `MoodleModuleFile`) to the
/// icon + color shown on the module row. Extracted from
/// `_MoodleCourseDetailScreenState._icon` / `_iconColor` per plan 3.1.3.
class MoodleModuleIcons {
  MoodleModuleIcons._();

  static IconData iconFor(
    MoodleCourseModule module,
    MoodleModuleFile? file,
  ) {
    if (file != null) {
      if (file.isPdf) return Icons.picture_as_pdf_rounded;
      if (file.isSlide) return Icons.slideshow_rounded;
      if (file.isDocument) return Icons.description_rounded;
      if (file.isSpreadsheet) return Icons.table_chart_rounded;
      if (file.isImage) return Icons.image_rounded;
      if (file.isVideo) return Icons.videocam_rounded;
      if (file.isAudio) return Icons.audiotrack_rounded;
    }
    if (module.isUrl) return Icons.link_rounded;
    if (module.isQuiz) return Icons.quiz_rounded;
    if (module.isAssignment) return Icons.assignment_rounded;
    if (module.isForum) return Icons.forum_rounded;
    if (module.isPage) return Icons.article_rounded;
    return Icons.insert_drive_file_rounded;
  }

  static Color colorFor(
    MoodleCourseModule module,
    MoodleModuleFile? file,
  ) {
    if (file != null) {
      if (file.isPdf) return AppColors.red;
      if (file.isSlide) return AppColors.orange;
      if (file.isDocument) return AppColors.blue;
      if (file.isSpreadsheet) return AppColors.green;
      if (file.isImage) return AppColors.purple;
      if (file.isVideo) return AppColors.emerald;
      if (file.isAudio) return AppColors.pink;
    }
    if (module.isUrl) return AppColors.sky;
    if (module.isQuiz) return AppColors.purple;
    return Colors.blueGrey;
  }
}