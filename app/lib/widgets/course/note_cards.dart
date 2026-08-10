import 'dart:io';
import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../services/file_service.dart';
import '../../models/note.dart';
import '../common/common_widgets.dart';
import 'package:intl/intl.dart';

/// Not kartı (Son notlar için)
class NoteCard extends StatelessWidget {
  final Note note;
  final String? courseName;
  final Color? courseColor;
  final VoidCallback? onTap;

  const NoteCard({
    super.key,
    required this.note,
    this.courseName,
    this.courseColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GlassCard(
      onTap: onTap,
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          // Sol - Önizleme
          _buildPreview(isDark),
          const SizedBox(width: 16),
          // Sağ - Bilgiler
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        note.title,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Text(
                      _formatDate(note.createdAt ?? DateTime.now()),
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                // İçerik önizleme veya ses durumu
                if (note.isAudio)
                  _buildAudioInfo(isDark)
                else if (note.content != null && note.content!.isNotEmpty)
                  Text(
                    note.content!,
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                const SizedBox(height: 8),
                // Etiket
                if (courseName != null)
                  TagChip(
                    label: courseName!.toUpperCase(),
                    color: courseColor ?? AppColors.primary,
                    isSmall: true,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPreview(bool isDark) {
    // Ses notu
    if (note.isAudio) {
      return Container(
        width: 80,
        height: 80,
        decoration: BoxDecoration(
          color: isDark ? Colors.grey.shade800 : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(5, (index) {
              final heights = [12.0, 20.0, 32.0, 16.0, 8.0];
              return Container(
                width: 4,
                height: heights[index],
                margin: const EdgeInsets.symmetric(horizontal: 1),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.4 + (index * 0.15)),
                  borderRadius: BorderRadius.circular(2),
                ),
              );
            }),
          ),
        ),
      );
    }

    // OCR veya resim notu
    if ((note.isOcr || note.isImage) && note.thumbnailPath != null) {
      return FutureBuilder<String?>(
        future: FileService().resolveFilePath(note.thumbnailPath),
        builder: (context, snapshot) {
          final resolvedPath = snapshot.data;
          final fileExists = resolvedPath != null && File(resolvedPath).existsSync();
          return Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              color: isDark ? Colors.grey.shade800 : Colors.grey.shade200,
              image: fileExists
                  ? DecorationImage(
                      image: FileImage(File(resolvedPath)),
                      fit: BoxFit.cover,
                    )
                  : null,
            ),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                color: Colors.black.withValues(alpha: 0.1),
              ),
              child: Center(
                child: Icon(
                  fileExists ? Icons.document_scanner : Icons.broken_image,
                  color: fileExists
                      ? Colors.white.withValues(alpha: 0.9)
                      : (isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight),
                  size: 24,
                ),
              ),
            ),
          );
        },
      );
    }

    // Metin notu
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        color: isDark ? Colors.grey.shade800 : Colors.grey.shade100,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Center(
        child: Icon(
          Icons.edit_note,
          color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
          size: 32,
        ),
      ),
    );
  }

  Widget _buildAudioInfo(bool isDark) {
    return Row(
      children: [
        Container(
          height: 4,
          width: 80,
          decoration: BoxDecoration(
            color: isDark ? Colors.grey.shade700 : Colors.grey.shade200,
            borderRadius: BorderRadius.circular(2),
          ),
          child: FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: 0.33,
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          note.formattedDuration,
          style: TextStyle(
            fontSize: 12,
            fontFamily: 'monospace',
            color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
          ),
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);
    if (diff.inMinutes < 60) {
      return '${diff.inMinutes}m';
    } else if (diff.inHours < 24) {
      return '${diff.inHours}h';
    } else if (diff.inDays < 7) {
      return '${diff.inDays}d';
    } else {
      return DateFormat('MMM d').format(date);
    }
  }
}

/// Ders detay sayfası için not kartı (büyük) — Premium Redesign
class CourseNoteCard extends StatelessWidget {
  final Note note;
  final VoidCallback? onTap;
  final VoidCallback? onPlayTap;
  final VoidCallback? onBookmarkTap;

  const CourseNoteCard({
    super.key,
    required this.note,
    this.onTap,
    this.onPlayTap,
    this.onBookmarkTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (note.isAudio) {
      return _buildAudioCard(context, isDark);
    } else if (note.isOcr || note.isImage) {
      return _buildImageCard(context, isDark);
    } else {
      return _buildTextCard(context, isDark);
    }
  }

  // ───────────────────── COMMON HELPERS ─────────────────────

  Widget _buildTypeBadge(String label, IconData icon, Color color, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.5,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBookmarkButton(bool isDark) {
    return GestureDetector(
      onTap: onBookmarkTap,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: note.isBookmarked
              ? AppColors.amber.withValues(alpha: 0.15)
              : (isDark ? Colors.white.withValues(alpha: 0.06) : Colors.grey.shade100),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(
          note.isBookmarked ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
          size: 18,
          color: note.isBookmarked
              ? AppColors.amber
              : (isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight),
        ),
      ),
    );
  }

  String _formatSmartDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays == 1) return 'Yesterday';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return DateFormat('MMM d, yyyy').format(date);
  }

  // ───────────────────── AUDIO CARD ─────────────────────

  Widget _buildAudioCard(BuildContext context, bool isDark) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [AppColors.gradientAudioDarkStart, AppColors.gradientAudioDarkEnd]
              : [AppColors.gradientAudioLightStart, AppColors.gradientAudioLightEnd],
        ),
        boxShadow: [
          BoxShadow(
            color: (isDark ? AppColors.primary : AppColors.blue).withValues(alpha: 0.12),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(24),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top row: badge + duration + bookmark
                Row(
                  children: [
                    _buildTypeBadge('Voice Memo', Icons.mic_rounded, AppColors.primary, isDark),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: isDark ? Colors.white.withValues(alpha: 0.08) : Colors.white.withValues(alpha: 0.7),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        note.formattedDuration.isNotEmpty ? note.formattedDuration : '--:--',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          fontFeatures: const [FontFeature.tabularFigures()],
                          color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    _buildBookmarkButton(isDark),
                  ],
                ),
                const SizedBox(height: 16),
                // Title
                Text(
                  note.title,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  _formatSmartDate(note.createdAt ?? DateTime.now()),
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                  ),
                ),
                const SizedBox(height: 20),
                // Waveform
                SizedBox(
                  height: 40,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: List.generate(28, (index) {
                      final heights = [8, 14, 24, 18, 10, 6, 20, 32, 26, 12, 8, 18, 28, 14, 10, 22, 16, 8, 12, 20, 30, 18, 10, 14, 22, 8, 16, 12];
                      final h = heights[index % heights.length].toDouble();
                      final isActive = index < 7;
                      return Expanded(
                        child: Container(
                          margin: const EdgeInsets.symmetric(horizontal: 1),
                          height: h,
                          decoration: BoxDecoration(
                            color: isActive
                                ? AppColors.primary.withValues(alpha: 0.5 + (index * 0.07).clamp(0, 0.5))
                                : (isDark ? Colors.white.withValues(alpha: 0.12) : Colors.black.withValues(alpha: 0.08)),
                            borderRadius: BorderRadius.circular(3),
                          ),
                        ),
                      );
                    }),
                  ),
                ),
                const SizedBox(height: 20),
                // Play button row
                Row(
                  children: [
                    // Play button
                    GestureDetector(
                      onTap: onPlayTap,
                      child: Container(
                        width: 52,
                        height: 52,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [AppColors.primary, AppColors.primary.withValues(alpha: 0.8)],
                          ),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primary.withValues(alpha: 0.4),
                              blurRadius: 16,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: const Icon(Icons.play_arrow_rounded, color: Colors.white, size: 28),
                      ),
                    ),
                    const SizedBox(width: 16),
                    // Transcript button
                    Expanded(
                      child: Container(
                        height: 44,
                        decoration: BoxDecoration(
                          color: isDark ? Colors.white.withValues(alpha: 0.06) : Colors.white.withValues(alpha: 0.7),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: isDark ? Colors.white.withValues(alpha: 0.08) : Colors.black.withValues(alpha: 0.05),
                          ),
                        ),
                        child: TextButton.icon(
                          onPressed: onTap,
                          icon: Icon(Icons.text_snippet_outlined, size: 16,
                              color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight),
                          label: Text(
                            'View Details',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                              color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ───────────────────── IMAGE / OCR CARD ─────────────────────

  Widget _buildImageCard(BuildContext context, bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.06),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Full-width image preview
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                child: SizedBox(
                  height: 160,
                  width: double.infinity,
                  child: note.thumbnailPath != null
                      ? FutureBuilder<String?>(
                          future: FileService().resolveFilePath(note.thumbnailPath),
                          builder: (context, snapshot) {
                            final resolvedPath = snapshot.data;
                            final fileExists = resolvedPath != null && File(resolvedPath).existsSync();
                            if (!fileExists) {
                              return Container(
                                color: isDark ? Colors.grey.shade800 : Colors.grey.shade200,
                                child: Center(
                                  child: Icon(
                                    Icons.broken_image_rounded,
                                    size: 40,
                                    color: isDark ? Colors.grey.shade600 : Colors.grey.shade400,
                                  ),
                                ),
                              );
                            }
                            return Stack(
                              fit: StackFit.expand,
                              children: [
                                Image.file(
                                  File(resolvedPath),
                                  fit: BoxFit.cover,
                                  cacheWidth: 800,
                                ),
                                // Gradient overlay
                                Positioned.fill(
                                  child: DecoratedBox(
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        begin: Alignment.topCenter,
                                        end: Alignment.bottomCenter,
                                        colors: [
                                          Colors.transparent,
                                          Colors.black.withValues(alpha: 0.5),
                                        ],
                                        stops: const [0.4, 1.0],
                                      ),
                                    ),
                                  ),
                                ),
                                // Type badge — top left
                                Positioned(
                                  top: 12,
                                  left: 12,
                                  child: _buildTypeBadge(
                                    note.isOcr ? 'OCR Scan' : 'Photo',
                                    note.isOcr ? Icons.document_scanner_rounded : Icons.camera_alt_rounded,
                                    Colors.white,
                                    true,
                                  ),
                                ),
                                // Bookmark — top right
                                Positioned(
                                  top: 12,
                                  right: 12,
                                  child: _buildBookmarkButton(true),
                                ),
                                // Title overlay — bottom
                                Positioned(
                                  bottom: 12,
                                  left: 16,
                                  right: 16,
                                  child: Text(
                                    note.title,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.white,
                                      shadows: [
                                        Shadow(blurRadius: 8, color: Colors.black54),
                                      ],
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            );
                          },
                        )
                      : Container(
                          color: isDark ? Colors.grey.shade800 : Colors.grey.shade200,
                          child: Center(
                            child: Icon(
                              Icons.image_rounded,
                              size: 40,
                              color: isDark ? Colors.grey.shade600 : Colors.grey.shade400,
                            ),
                          ),
                        ),
                ),
              ),
              // Bottom info section
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Date
                    Text(
                      _formatSmartDate(note.createdAt ?? DateTime.now()),
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                      ),
                    ),
                    // OCR content preview
                    if (note.content != null && note.content!.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: isDark ? Colors.white.withValues(alpha: 0.04) : Colors.grey.shade50,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isDark ? Colors.white.withValues(alpha: 0.06) : Colors.grey.shade200,
                          ),
                        ),
                        child: Text(
                          note.content!,
                          style: TextStyle(
                            fontSize: 13,
                            height: 1.5,
                            color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                    // Tags
                    if (note.tags.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 6,
                        runSpacing: 4,
                        children: note.tags.map((tag) => TagChip(
                          label: '#$tag',
                          color: AppColors.primary,
                          isSmall: true,
                        )).toList(),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ───────────────────── TEXT CARD ─────────────────────

  Widget _buildTextCard(BuildContext context, bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.05),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: IntrinsicHeight(
            child: Row(
              children: [
                // Left accent stripe
                Container(
                  width: 4,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: const BorderRadius.horizontal(left: Radius.circular(20)),
                  ),
                ),
                // Content
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Top row: badge + date + bookmark
                        Row(
                          children: [
                            _buildTypeBadge('Note', Icons.edit_note_rounded, AppColors.primary, isDark),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                _formatSmartDate(note.createdAt ?? DateTime.now()),
                                style: TextStyle(
                                  fontSize: 11,
                                  color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                                ),
                                textAlign: TextAlign.right,
                              ),
                            ),
                            const SizedBox(width: 8),
                            _buildBookmarkButton(isDark),
                          ],
                        ),
                        const SizedBox(height: 12),
                        // Title
                        Text(
                          note.title,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        // Content preview
                        if (note.content != null && note.content!.isNotEmpty) ...[
                          const SizedBox(height: 8),
                          Text(
                            note.content!,
                            style: TextStyle(
                              fontSize: 14,
                              height: 1.6,
                              color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                            ),
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                        // Tags
                        if (note.tags.isNotEmpty) ...[
                          const SizedBox(height: 12),
                          Wrap(
                            spacing: 6,
                            runSpacing: 4,
                            children: note.tags.map((tag) => TagChip(
                              label: '#$tag',
                              color: tag.contains('exam') ? AppColors.amber : AppColors.primary,
                              isSmall: true,
                            )).toList(),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
