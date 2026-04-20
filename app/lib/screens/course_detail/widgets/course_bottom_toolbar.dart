import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../providers/note_provider.dart';

class CourseBottomToolbar extends StatelessWidget {
  final VoidCallback onAddBookmark;
  final VoidCallback onCaptureImageCamera;
  final VoidCallback onCaptureImageGallery;
  final VoidCallback onToggleRecording;
  final VoidCallback onShowTextNoteDialog;
  final VoidCallback onCaptureOcr;
  final VoidCallback onOpenDrawingCanvas;

  const CourseBottomToolbar({
    super.key,
    required this.onAddBookmark,
    required this.onCaptureImageCamera,
    required this.onCaptureImageGallery,
    required this.onToggleRecording,
    required this.onShowTextNoteDialog,
    required this.onCaptureOcr,
    required this.onOpenDrawingCanvas,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
      child: Builder(
        builder: (context) {
          final isRecording = context.select<NoteProvider, bool>(
            (p) => p.isRecording,
          );
          return Container(
            height: 64,
            decoration: BoxDecoration(
              color: isDark
                  ? const Color(0xFF1E1E2E).withValues(alpha: 0.95)
                  : Colors.white.withValues(alpha: 0.9),
              borderRadius: BorderRadius.circular(32),
              border: Border.all(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.1)
                    : Colors.grey.shade200,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 20,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(32),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    // Kamera (Kaydedilmiyorsa) / Yer İmi (Kaydediliyorsa)
                    if (isRecording)
                      _ToolbarButton(
                        icon: Icons.flag, // Bookmark icon
                        onTap: onAddBookmark,
                        isDark: isDark,
                      )
                    else
                      _ToolbarButton(
                        icon: Icons.photo_camera,
                        onTap: onCaptureImageCamera,
                        isDark: isDark,
                      ),

                    VerticalDivider(
                      width: 1,
                      indent: 16,
                      endIndent: 16,
                      color: isDark
                          ? Colors.grey.shade700
                          : Colors.grey.shade200,
                    ),

                    // Mikrofon / Stop (Ana buton)
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: isRecording ? AppColors.red : AppColors.primary,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color:
                                (isRecording
                                        ? AppColors.red
                                        : AppColors.primary)
                                    .withValues(alpha: 0.4),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: IconButton(
                        onPressed: onToggleRecording,
                        icon: Icon(
                          isRecording ? Icons.stop : Icons.mic,
                          color: Colors.white,
                          size: 28,
                        ),
                      ),
                    ),
                    VerticalDivider(
                      width: 1,
                      indent: 16,
                      endIndent: 16,
                      color: isDark
                          ? Colors.grey.shade700
                          : Colors.grey.shade200,
                    ),
                    // Klavye
                    _ToolbarButton(
                      icon: Icons.keyboard,
                      onTap: onShowTextNoteDialog,
                      isDark: isDark,
                    ),
                    // OCR Scanner
                    _ToolbarButton(
                      icon: Icons.document_scanner,
                      onTap: onCaptureOcr,
                      isDark: isDark,
                    ),
                    // Galeri
                    _ToolbarButton(
                      icon: Icons.photo_library,
                      onTap: onCaptureImageGallery,
                      isDark: isDark,
                    ),
                    // Drawing Canvas (iPad Pencil)
                    _ToolbarButton(
                      icon: Icons.draw_outlined,
                      onTap: onOpenDrawingCanvas,
                      isDark: isDark,
                      isHighlight: true,
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _ToolbarButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final bool isDark;
  final bool isHighlight;

  const _ToolbarButton({
    required this.icon,
    required this.onTap,
    required this.isDark,
    this.isHighlight = false,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          HapticFeedback.lightImpact();
          onTap();
        },
        borderRadius: BorderRadius.circular(20),
        child: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: isHighlight
                ? AppColors.primary.withValues(alpha: 0.15)
                : Colors.transparent,
          ),
          child: Icon(
            icon,
            color: isHighlight
                ? AppColors.primary
                : (isDark
                      ? AppColors.textSecondaryDark
                      : AppColors.textSecondaryLight),
            size: 24,
          ),
        ),
      ),
    );
  }
}
