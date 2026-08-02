import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_colors.dart';
import '../../models/note.dart';
import '../../models/course.dart';
import '../../providers/note_provider.dart';
import '../../providers/course_provider.dart';
import '../../core/services/file_service.dart';
import 'widgets/note_audio_player.dart';
import 'widgets/note_drawing_display.dart';
import 'widgets/note_pdf_display.dart';
import 'widgets/full_screen_image_viewer.dart';
import 'widgets/move_note_sheet.dart';
import 'package:lesson_tracker/l10n/app_localizations.dart';

class NoteDetailScreen extends StatefulWidget {
  final Note note;
  final String? courseName;

  const NoteDetailScreen({super.key, required this.note, this.courseName});

  @override
  State<NoteDetailScreen> createState() => _NoteDetailScreenState();
}

class _NoteDetailScreenState extends State<NoteDetailScreen> {
  late TextEditingController _titleController;
  late TextEditingController _contentController;
  bool _isEditing = false;
  late bool _isBookmarked;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.note.title);
    _contentController = TextEditingController(text: widget.note.content);
    _isBookmarked = widget.note.isBookmarked;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final hasImage = widget.note.thumbnailPath != null;

    return Scaffold(
      backgroundColor: isDark
          ? AppColors.backgroundDark
          : AppColors.backgroundLight,
      body: CustomScrollView(
        slivers: [
          _buildSliverAppBar(isDark, hasImage),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 24.0,
                vertical: 16.0,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildMetaTags(isDark),
                  const SizedBox(height: 16),

                  // Title Editor
                  TextField(
                    controller: _titleController,
                    enabled: _isEditing,
                    maxLines: null,
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.5,
                      color: isDark
                          ? AppColors.textPrimaryDark
                          : AppColors.textPrimaryLight,
                    ),
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: AppLocalizations.of(context)!.title,
                      contentPadding: EdgeInsets.zero,
                      isDense: true,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Meta Info (Date)
                  Row(
                    children: [
                      Icon(
                        Icons.access_time_rounded,
                        size: 16,
                        color: isDark
                            ? AppColors.textSecondaryDark
                            : AppColors.textSecondaryLight,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        DateFormat(
                          'MMMM d, yyyy • h:mm a',
                          Localizations.localeOf(context).toString(),
                        ).format(widget.note.createdAt ?? DateTime.now()),
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: isDark
                              ? AppColors.textSecondaryDark
                              : AppColors.textSecondaryLight,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),

                  // Audio Player
                  if (widget.note.isAudio) ...[
                    NoteAudioPlayer(note: widget.note, isDark: isDark),
                    const SizedBox(height: 32),
                  ],

                  // Drawing display
                  if (widget.note.type == NoteType.drawing &&
                      widget.note.drawingData != null &&
                      widget.note.drawingData!.isNotEmpty) ...[
                    NoteDrawingDisplay(
                      drawingData: widget.note.drawingData!,
                      isDark: isDark,
                    ),
                    const SizedBox(height: 32),
                  ],

                  // PDF display
                  if (widget.note.filePath != null &&
                      widget.note.filePath!.toLowerCase().endsWith('.pdf')) ...[
                    NotePdfDisplay(
                      pdfPath: widget.note.filePath!,
                      isDark: isDark,
                    ),
                    const SizedBox(height: 32),
                  ],

                  // Content
                  if (_contentController.text.isNotEmpty || _isEditing) ...[
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 24,
                      ),
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.surfaceDarkBlue : AppColors.surfaceLight,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(
                              alpha: isDark ? 0.2 : 0.04,
                            ),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),
                        ],
                        border: Border.all(
                          color: _isEditing
                              ? AppColors.primary.withValues(alpha: 0.5)
                              : (isDark
                                    ? Colors.white.withValues(alpha: 0.05)
                                    : Colors.grey.shade100),
                          width: _isEditing ? 2 : 1,
                        ),
                      ),
                      child: TextField(
                        controller: _contentController,
                        enabled: _isEditing,
                        maxLines: null,
                        style: TextStyle(
                          fontSize: 16,
                          height: _isEditing ? 1.6 : 1.8,
                          letterSpacing: 0.2,
                          color: isDark
                              ? AppColors.textPrimaryDark.withValues(
                                  alpha: 0.95,
                                )
                              : AppColors.textPrimaryLight.withValues(
                                  alpha: 0.95,
                                ),
                        ),
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          hintText: AppLocalizations.of(context)!.writeYourNote,
                          hintStyle: TextStyle(
                            color: isDark
                                ? Colors.grey.shade600
                                : Colors.grey.shade400,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 80),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSliverAppBar(bool isDark, bool hasImage) {
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
              Icons.arrow_back_ios_new_rounded,
              size: 20,
              color: hasImage
                  ? Colors.white
                  : (isDark ? Colors.white : Colors.black),
            ),
            onPressed: () => Navigator.pop(context),
          ),
        ),
      ),
      actions: [
        _buildAppbarAction(
          icon: _isEditing ? Icons.check_rounded : Icons.edit_rounded,
          onPressed: _toggleEditing,
          hasImage: hasImage,
          isDark: isDark,
          color: _isEditing ? AppColors.primary : null,
        ),
        _buildAppbarAction(
          icon: _isBookmarked
              ? Icons.bookmark_rounded
              : Icons.bookmark_border_rounded,
          onPressed: () {
            context.read<NoteProvider>().toggleBookmark(widget.note);
            setState(() {
              _isBookmarked = !_isBookmarked;
            });
          },
          hasImage: hasImage,
          isDark: isDark,
          color: _isBookmarked ? AppColors.amber : null,
        ),
        _buildPopupMenu(hasImage, isDark),
        const SizedBox(width: 8),
      ],
      flexibleSpace: FlexibleSpaceBar(
        stretchModes: const [
          StretchMode.zoomBackground,
          StretchMode.blurBackground,
        ],
        background: hasImage ? _buildImageHeader(isDark) : null,
      ),
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

  Widget _buildPopupMenu(bool hasImage, bool isDark) {
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
              switch (value) {
                case 'move':
                  _moveNoteToCourse();
                  break;
                case 'delete':
                  _deleteNote();
                  break;
              }
            } catch (e) {
              if (mounted) {
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

  Widget _buildImageHeader(bool isDark) {
    return FutureBuilder<String?>(
      future: FileService().resolveFilePath(widget.note.thumbnailPath),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Container(
            color: isDark ? Colors.grey.shade900 : Colors.grey.shade200,
            child: const Center(child: CircularProgressIndicator()),
          );
        }
        final resolvedPath = snapshot.data;
        if (resolvedPath != null && File(resolvedPath).existsSync()) {
          return GestureDetector(
            onTap: () => _openFullScreenImage(context, resolvedPath),
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
                          isDark
                              ? AppColors.backgroundDark
                              : AppColors.backgroundLight,
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
        return _buildImageError(isDark);
      },
    );
  }

  void _openFullScreenImage(BuildContext context, String imagePath) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => FullScreenImageViewer(imagePath: imagePath),
      ),
    );
  }

  Widget _buildMetaTags(bool isDark) {
    return Wrap(
      spacing: 8,
      children: [
        if (widget.courseName != null && widget.courseName!.isNotEmpty)
          _buildTag(
            widget.courseName!,
            Icons.school_rounded,
            AppColors.primary,
            isDark,
          ),
        if (widget.note.tags.isNotEmpty)
          ...widget.note.tags.map(
            (tag) =>
                _buildTag('#$tag', Icons.tag_rounded, AppColors.amber, isDark),
          ),
      ],
    );
  }

  Widget _buildTag(String label, IconData icon, Color color, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  void _toggleEditing() async {
    if (_isEditing) {
      if (_titleController.text.isNotEmpty) {
        final updatedNote = widget.note.copyWith(
          title: _titleController.text,
          content: _contentController.text,
        );
        await context.read<NoteProvider>().updateNote(updatedNote);
      }
    }
    setState(() {
      _isEditing = !_isEditing;
    });
  }

  Widget _buildImageError(bool isDark) {
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
              AppLocalizations.of(context)!.imageUnavailable,
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

  void _deleteNote() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.deleteNoteTitle),
        content: Text(AppLocalizations.of(context)!.thisActionCannotBeUndone),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(AppLocalizations.of(context)!.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              AppLocalizations.of(context)!.delete,
              style: const TextStyle(color: AppColors.red),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      await context.read<NoteProvider>().deleteNote(widget.note);
      if (!mounted) return;
      Navigator.pop(context);
    }
  }

  void _moveNoteToCourse() async {
    final courses = context
        .read<CourseProvider>()
        .courses
        .where((c) => c.id != widget.note.courseId)
        .toList();

    if (courses.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.noOtherCourses),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
      return;
    }

    final selectedCourseId = await showMoveNoteSheet(
      context: context,
      candidates: courses,
    );

    if (selectedCourseId == null || !mounted) return;

    final success = await context.read<NoteProvider>().moveNoteToCourse(
      widget.note,
      selectedCourseId,
    );

    if (!mounted) return;
    if (success) {
      final courseName = context
          .read<CourseProvider>()
          .courses
          .firstWhere(
            (c) => c.id == selectedCourseId,
            orElse: () => Course(
              id: '',
              name: 'Unknown',
              color: AppColors.primary,
              scheduleDays: [],
              startTime: const TimeOfDay(hour: 0, minute: 0),
              endTime: const TimeOfDay(hour: 0, minute: 0),
            ),
          )
          .name;
      HapticFeedback.mediumImpact();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.movedTo(courseName)),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
      Navigator.pop(context); // Return to course detail
    }
  }
}




