import 'package:flutter/material.dart';
import 'package:lesson_tracker/core/theme/app_colors.dart';
import 'package:lesson_tracker/core/utils/moodle_utils.dart';
import 'package:lesson_tracker/models/moodle/moodle_course_content.dart';
import 'moodle_module_icons.dart';

/// Pure rendering of a Moodle module row. Extracted from
/// `_MoodleCourseDetailScreenState.build` per plan 3.1.3.
///
/// The host owns all state (download progress, local path) and passes
/// those into the view via [isDownloaded], [isDownloading],
/// [progress], and the action callbacks ([onTileTap],
/// [onMoreActionsPressed]).
class MoodleModuleTileView extends StatelessWidget {
  final MoodleCourseModule module;
  final MoodleModuleFile? file;
  final bool isDark;
  final ThemeData theme;
  final String langCode;
  final bool isDownloaded;
  final bool isDownloading;
  final double progress;
  final VoidCallback onTileTap;
  final VoidCallback onMoreActionsPressed;

  const MoodleModuleTileView({
    super.key,
    required this.module,
    required this.file,
    required this.isDark,
    required this.theme,
    required this.langCode,
    required this.isDownloaded,
    required this.isDownloading,
    required this.progress,
    required this.onTileTap,
    required this.onMoreActionsPressed,
  });

  IconData get _icon => MoodleModuleIcons.iconFor(module, file);

  Color get _iconColor => MoodleModuleIcons.colorFor(module, file);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: onTileTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: isDark ? AppColors.surfaceDark : Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.1)
                    : Colors.grey.shade200,
              ),
              boxShadow: [
                if (!isDark)
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.03),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: _iconColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(_icon, color: _iconColor, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        MoodleUtils.parseMultilang(module.name, langCode),
                        style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: isDark
                                ? AppColors.textPrimaryDark
                                : AppColors.textPrimaryLight),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (file != null) ...[
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            Text(
                              '${file!.extension.toUpperCase()} · ${file!.readableSize}',
                              style: theme.textTheme.bodySmall?.copyWith(
                                  color: isDark
                                      ? AppColors.textSecondaryDark
                                      : AppColors.textSecondaryLight),
                            ),
                            if (isDownloaded) ...[
                              const SizedBox(width: 6),
                              Icon(Icons.check_circle_rounded,
                                  size: 14, color: AppColors.green),
                            ],
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
                _buildTrailing(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTrailing() {
    if (isDownloading) {
      return SizedBox(
        width: 24,
        height: 24,
        child: CircularProgressIndicator(
          value: progress,
          strokeWidth: 2,
          color: AppColors.primary,
        ),
      );
    }
    if (file != null) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: Icon(
              isDownloaded
                  ? Icons.folder_open_rounded
                  : Icons.download_rounded,
              size: 20,
              color: isDownloaded
                  ? AppColors.primary
                  : (isDark
                      ? AppColors.textSecondaryDark
                      : AppColors.textSecondaryLight),
            ),
            onPressed: onTileTap,
          ),
          if (isDownloaded)
            IconButton(
              icon: Icon(
                Icons.more_vert_rounded,
                size: 20,
                color: isDark
                    ? AppColors.textSecondaryDark
                    : AppColors.textSecondaryLight,
              ),
              onPressed: onMoreActionsPressed,
            ),
        ],
      );
    }
    return Icon(
      Icons.open_in_new_rounded,
      size: 16,
      color: isDark
          ? AppColors.textSecondaryDark
          : AppColors.textSecondaryLight,
    );
  }
}