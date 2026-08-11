import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../handwriting_canvas_screen.dart';

/// Blank/Photo/PDF mode picker row shown at the top of the handwriting
/// canvas screen.
class CanvasModeSelector extends StatelessWidget {
  final CanvasMode mode;
  final bool isDark;
  final String blankLabel;
  final String photoLabel;
  final String pdfLabel;
  final VoidCallback onBlankTap;
  final VoidCallback onPhotoTap;
  final VoidCallback onPdfTap;

  const CanvasModeSelector({
    super.key,
    required this.mode,
    required this.isDark,
    required this.blankLabel,
    required this.photoLabel,
    required this.pdfLabel,
    required this.onBlankTap,
    required this.onPhotoTap,
    required this.onPdfTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _ModeChip(
            icon: Icons.article_outlined,
            label: blankLabel,
            isSelected: mode == CanvasMode.blank,
            onTap: onBlankTap,
            isDark: isDark,
          ),
          const SizedBox(width: 12),
          _ModeChip(
            icon: Icons.image_outlined,
            label: photoLabel,
            isSelected: mode == CanvasMode.photo,
            onTap: onPhotoTap,
            isDark: isDark,
          ),
          const SizedBox(width: 12),
          _ModeChip(
            icon: Icons.picture_as_pdf_outlined,
            label: pdfLabel,
            isSelected: mode == CanvasMode.pdf,
            onTap: onPdfTap,
            isDark: isDark,
          ),
        ],
      ),
    );
  }
}

class _ModeChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final bool isDark;

  const _ModeChip({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary
              : (isDark ? AppColors.surfaceDarkElevated : Colors.grey[200]),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 18,
              color: isSelected
                  ? Colors.white
                  : (isDark ? Colors.white70 : Colors.black54),
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                color: isSelected
                    ? Colors.white
                    : (isDark ? Colors.white70 : Colors.black54),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
