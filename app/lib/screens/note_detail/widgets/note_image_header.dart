import 'dart:io';

import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../l10n/app_localizations.dart';
import '../../../services/file_service.dart';
import 'full_screen_image_viewer.dart';

class NoteImageHeader extends StatelessWidget {
  final String? thumbnailPath;
  final bool isDark;
  final void Function(String imagePath) onOpenFullScreen;

  const NoteImageHeader({
    super.key,
    required this.thumbnailPath,
    required this.isDark,
    required this.onOpenFullScreen,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String?>(
      future: FileService().resolveFilePath(thumbnailPath),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _placeholder(isDark);
        }
        final resolvedPath = snapshot.data;
        if (resolvedPath != null && File(resolvedPath).existsSync()) {
          return _loaded(context, isDark, resolvedPath);
        }
        return _error(isDark, context);
      },
    );
  }

  Widget _placeholder(bool isDark) {
    return Container(
      color: isDark ? Colors.grey.shade900 : Colors.grey.shade200,
      child: const Center(child: CircularProgressIndicator()),
    );
  }

  Widget _loaded(BuildContext context, bool isDark, String resolvedPath) {
    return GestureDetector(
      onTap: () => onOpenFullScreen(resolvedPath),
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.file(File(resolvedPath), fit: BoxFit.cover),
          Positioned(
            bottom: -1,
            left: 0,
            right: 0,
            height: 120,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 16,
            right: 16,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.zoom_in,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _error(bool isDark, BuildContext context) {
    return Container(
      color: isDark ? Colors.grey.shade900 : Colors.grey.shade200,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.broken_image_rounded,
              size: 48,
              color: isDark
                  ? AppColors.textSecondaryDark
                  : AppColors.textSecondaryLight,
            ),
            const SizedBox(height: 12),
            Text(
              _imageUnavailableLabel(context),
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: isDark
                    ? AppColors.textSecondaryDark
                    : AppColors.textSecondaryLight,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _imageUnavailableLabel(BuildContext context) {
    return AppLocalizations.of(context)!.imageUnavailable;
  }
}

void openFullScreenImage(BuildContext context, String imagePath) {
  Navigator.of(context).push(
    MaterialPageRoute(
      builder: (context) => FullScreenImageViewer(imagePath: imagePath),
    ),
  );
}