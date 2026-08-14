import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/theme/app_colors.dart';
import '../../../l10n/app_localizations.dart';

class NoteDetailAppBar extends StatelessWidget {
  final bool isEditing;
  final bool isBookmarked;
  final bool hasImage;
  final bool isDark;
  final VoidCallback onBack;
  final VoidCallback onToggleEditing;
  final VoidCallback onToggleBookmark;
  final Future<void> Function(String action) onPopupAction;

  const NoteDetailAppBar({
    super.key,
    required this.isEditing,
    required this.isBookmarked,
    required this.hasImage,
    required this.isDark,
    required this.onBack,
    required this.onToggleEditing,
    required this.onToggleBookmark,
    required this.onPopupAction,
  });

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      expandedHeight: hasImage ? 320.0 : 100.0,
      pinned: true,
      stretch: true,
      backgroundColor: isDark
          ? AppColors.backgroundDark
          : AppColors.backgroundLight,
      elevation: 0,
      systemOverlayStyle: hasImage
          ? SystemUiOverlayStyle.light
          : (isDark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark),
      leading: Padding(
        padding: const EdgeInsets.only(left: 12.0, top: 8.0, bottom: 8.0),
        child: _circle(
          context,
          color: hasImage
              ? Colors.black.withValues(alpha: 0.3)
              : (isDark
                    ? Colors.white.withValues(alpha: 0.1)
                    : Colors.black.withValues(alpha: 0.05)),
          child: IconButton(
            icon: Icon(
              Icons.arrow_back_ios_new_rounded,
              size: 20,
              color: hasImage
                  ? Colors.white
                  : (isDark ? Colors.white : Colors.black),
            ),
            onPressed: onBack,
          ),
        ),
      ),
      actions: [
        _buildAppbarAction(
          icon: isEditing ? Icons.check_rounded : Icons.edit_rounded,
          onPressed: onToggleEditing,
          hasImage: hasImage,
          isDark: isDark,
          color: isEditing ? AppColors.primary : null,
        ),
        _buildAppbarAction(
          icon: isBookmarked
              ? Icons.bookmark_rounded
              : Icons.bookmark_border_rounded,
          onPressed: onToggleBookmark,
          hasImage: hasImage,
          isDark: isDark,
          color: isBookmarked ? AppColors.amber : null,
        ),
        _buildPopupMenu(context),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _circle(BuildContext context, {required Color color, required Widget child}) {
    return Container(
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      child: child,
    );
  }

  Widget _buildAppbarAction({
    required IconData icon,
    required VoidCallback onPressed,
    required bool hasImage,
    required bool isDark,
    Color? color,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 8.0),
      child: Container(
        decoration: BoxDecoration(
          color: hasImage
              ? Colors.black.withValues(alpha: 0.3)
              : (isDark
                    ? Colors.white.withValues(alpha: 0.1)
                    : Colors.black.withValues(alpha: 0.05)),
          shape: BoxShape.circle,
        ),
        child: IconButton(
          icon: Icon(
            icon,
            size: 22,
            color:
                color ??
                (hasImage
                    ? Colors.white
                    : (isDark ? Colors.white : Colors.black)),
          ),
          onPressed: onPressed,
        ),
      ),
    );
  }

  Widget _buildPopupMenu(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 8.0),
      child: Container(
        decoration: BoxDecoration(
          color: hasImage
              ? Colors.black.withValues(alpha: 0.3)
              : (isDark
                    ? Colors.white.withValues(alpha: 0.1)
                    : Colors.black.withValues(alpha: 0.05)),
          shape: BoxShape.circle,
        ),
        child: PopupMenuButton<String>(
          icon: Icon(
            Icons.more_vert_rounded,
            size: 22,
            color: hasImage
                ? Colors.white
                : (isDark ? Colors.white : Colors.black),
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
          onSelected: (value) async {
            try {
              await onPopupAction(value);
            } catch (e) {
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Error: ${e.toString().replaceAll('Exception: ', '')}',
                    ),
                    behavior: SnackBarBehavior.floating,
                    backgroundColor: AppColors.red,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                );
              }
            }
          },
          itemBuilder: (context) => [
            PopupMenuItem(
              value: 'move',
              child: ListTile(
                leading: const Icon(Icons.drive_file_move_outline),
                title: Text(AppLocalizations.of(context)!.moveToCourse),
              ),
            ),
            PopupMenuItem(
              value: 'delete',
              child: ListTile(
                leading: const Icon(Icons.delete_outline, color: AppColors.red),
                title: Text(
                  AppLocalizations.of(context)!.deleteNote,
                  style: const TextStyle(color: AppColors.red),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}