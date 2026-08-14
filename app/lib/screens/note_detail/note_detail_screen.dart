import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_colors.dart';
import '../../models/note.dart';
import '../../models/course.dart';
import '../../providers/note_provider.dart';
import '../../providers/course_provider.dart';
import 'widgets/note_audio_player.dart';
import 'widgets/note_detail_app_bar.dart';
import 'widgets/note_drawing_display.dart';
import 'widgets/note_image_header.dart';
import 'widgets/note_meta_tags.dart';
import 'widgets/note_pdf_display.dart';
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

  /// PDF canvas modunda oluşturulmuş bir çizim notuysa, altına arka plan
  /// olarak render edilecek PDF yolu; aksi halde null.
  String? get _drawingPdfPath {
    final path = widget.note.filePath;
    if (widget.note.type != NoteType.drawing || path == null) return null;
    return path.toLowerCase().endsWith('.pdf') ? path : null;
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
          NoteDetailAppBar(
            isEditing: _isEditing,
            isBookmarked: _isBookmarked,
            hasImage: hasImage,
            isDark: isDark,
            onBack: () => Navigator.pop(context),
            onToggleEditing: _toggleEditing,
            onToggleBookmark: _onToggleBookmark,
            onPopupAction: _handlePopupAction,
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 24.0,
                vertical: 16.0,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (hasImage)
                    NoteImageHeader(
                      thumbnailPath: widget.note.thumbnailPath,
                      isDark: isDark,
                      onOpenFullScreen: (path) =>
                          openFullScreenImage(context, path),
                    ),
                  const SizedBox(height: 16),
                  NoteMetaTags(
                    courseName: widget.courseName,
                    noteTags: widget.note.tags,
                    isDark: isDark,
                  ),
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

                  // Drawing display (PDF annotasyonlarında sayfa arka
                  // planı olarak ilgili PDF'i çizimlerin altına render eder)
                  if (widget.note.type == NoteType.drawing &&
                      widget.note.drawingData != null &&
                      widget.note.drawingData!.isNotEmpty) ...[
                    NoteDrawingDisplay(
                      drawingData: widget.note.drawingData!,
                      isDark: isDark,
                      pdfPath: _drawingPdfPath,
                    ),
                    const SizedBox(height: 32),
                  ],

                  // PDF display — yalnızca yukarıdaki çizim zaten aynı
                  // PDF'i arka plan olarak göstermiyorsa (çift gösterimi
                  // önlemek için)
                  if (widget.note.filePath != null &&
                      widget.note.filePath!.toLowerCase().endsWith('.pdf') &&
                      _drawingPdfPath == null) ...[
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

  void _onToggleBookmark() {
    context.read<NoteProvider>().toggleBookmark(widget.note);
    setState(() {
      _isBookmarked = !_isBookmarked;
    });
  }

  Future<void> _handlePopupAction(String value) async {
    switch (value) {
      case 'move':
        await _moveNoteToCourse();
        break;
      case 'delete':
        await _deleteNote();
        break;
    }
  }

  Future<void> _moveNoteToCourse() async {
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

  Future<void> _deleteNote() async {
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
}