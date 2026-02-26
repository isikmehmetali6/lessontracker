import 'dart:io';
import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/services/file_service.dart';
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
                      _formatDate(note.createdAt!),
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
      return '${diff.inMinutes}m ago';
    } else if (diff.inHours < 24) {
      return '${diff.inHours}h ago';
    } else if (diff.inDays == 1) {
      return 'Yesterday';
    } else if (diff.inDays < 7) {
      return '${diff.inDays}d ago';
    } else {
      return DateFormat('MMM d').format(date);
    }
  }
}

/// Ders detay sayfası için not kartı (büyük)
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
      return _buildOcrCard(context, isDark);
    } else {
      return _buildTextCard(context, isDark);
    }
  }

  /// Ses kaydı kartı
  Widget _buildAudioCard(BuildContext context, bool isDark) {
    return GlassCard(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Üst kısım
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.mic,
                      color: AppColors.primary,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        note.title,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                        ),
                      ),
                      Text(
                        'Lecture 12 • ${DateFormat('MMM d').format(note.createdAt!)}',
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: isDark ? Colors.grey.shade800 : Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  note.formattedDuration,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Dalga formu görsel
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(17, (index) {
              final heights = [12.0, 20.0, 32.0, 24.0, 16.0, 12.0, 24.0, 8.0, 20.0, 12.0, 16.0, 8.0, 20.0, 12.0, 8.0, 8.0, 8.0];
              final isActive = index < 4;
              return Container(
                width: 4,
                height: heights[index % heights.length],
                decoration: BoxDecoration(
                  color: isActive 
                      ? AppColors.primary.withValues(alpha: index < 2 ? 1 : 0.7)
                      : (isDark ? Colors.grey.shade600 : Colors.grey.shade400).withValues(alpha: 0.6),
                  borderRadius: BorderRadius.circular(2),
                ),
              );
            }),
          ),
          const SizedBox(height: 16),
          // Butonlar
          Row(
            children: [
              Expanded(
                child: Container(
                  height: 44,
                  decoration: BoxDecoration(
                    color: isDark ? Colors.grey.shade800 : Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: TextButton(
                    onPressed: () {},
                    child: Text(
                      'Transcript',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.4),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: IconButton(
                  onPressed: onPlayTap,
                  icon: const Icon(Icons.play_arrow, color: Colors.white),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// OCR/Resim kartı
  Widget _buildOcrCard(BuildContext context, bool isDark) {
    return GlassCard(
      onTap: onTap,
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Resim
          Container(
            width: 96,
            height: 96,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              color: isDark ? Colors.grey.shade800 : Colors.grey.shade200,
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: note.thumbnailPath != null
                  ? FutureBuilder<String?>(
                      future: FileService().resolveFilePath(note.thumbnailPath),
                      builder: (context, snapshot) {
                        final resolvedPath = snapshot.data;
                        final fileExists = resolvedPath != null && File(resolvedPath).existsSync();
                        if (!fileExists) {
                          return Center(
                            child: Icon(
                              Icons.broken_image,
                              size: 32,
                              color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                            ),
                          );
                        }
                        return Stack(
                          fit: StackFit.expand,
                          children: [
                            Image.file(
                              File(resolvedPath),
                              fit: BoxFit.cover,
                            ),
                            Positioned(
                              bottom: 4,
                              right: 4,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: Colors.black.withValues(alpha: 0.6),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: const Text(
                                  'IMG',
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    )
                  : const Icon(Icons.image, size: 32),
            ),
          ),
          const SizedBox(width: 16),
          // Bilgiler
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
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
                      ),
                    ),
                    Text(
                      'TODAY',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.5,
                        color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                      ),
                    ),
                  ],
                ),
                Text(
                  DateFormat('MMM d • h:mm a').format(note.createdAt!),
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                  ),
                ),
                const SizedBox(height: 8),
                // OCR içerik önizleme
                if (note.content != null && note.content!.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: isDark ? Colors.grey.shade800.withValues(alpha: 0.5) : Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isDark ? Colors.grey.shade700 : Colors.grey.shade200,
                      ),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Text(
                            'OCR',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            note.content!,
                            style: TextStyle(
                              fontSize: 12,
                              fontFamily: 'monospace',
                              color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Metin notu kartı
  Widget _buildTextCard(BuildContext context, bool isDark) {
    return GlassCard(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.edit_note,
                    color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    note.title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                    ),
                  ),
                ],
              ),
              IconButton(
                onPressed: onBookmarkTap,
                icon: Icon(
                  note.isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                  color: note.isBookmarked 
                      ? AppColors.primary 
                      : (isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight),
                ),
              ),
            ],
          ),
          if (note.content != null && note.content!.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              note.content!,
              style: TextStyle(
                fontSize: 14,
                height: 1.5,
                color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
              ),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ],
          if (note.tags.isNotEmpty) ...[
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              children: note.tags.map((tag) => TagChip(
                label: '#$tag',
                color: tag.contains('exam') ? AppColors.amber : AppColors.textSecondaryLight,
              )).toList(),
            ),
          ],
        ],
      ),
    );
  }
}
