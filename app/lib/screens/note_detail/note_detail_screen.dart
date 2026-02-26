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
import '../../core/services/export_service.dart';
import '../../core/services/file_service.dart';
import 'package:lesson_tracker/l10n/app_localizations.dart';

class NoteDetailScreen extends StatefulWidget {
  final Note note;
  final String? courseName;

  const NoteDetailScreen({
    super.key,
    required this.note,
    this.courseName,
  });

  @override
  State<NoteDetailScreen> createState() => _NoteDetailScreenState();
}

class _NoteDetailScreenState extends State<NoteDetailScreen> {
  late TextEditingController _titleController;
  late TextEditingController _contentController;
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.note.title);
    _contentController = TextEditingController(text: widget.note.content);
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

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new,
            color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: Icon(
              _isEditing ? Icons.check : Icons.edit,
              color: AppColors.primary,
            ),
            onPressed: _toggleEditing,
          ),
          // Share/Export menüsü
          PopupMenuButton<String>(
            icon: Icon(
              Icons.more_vert,
              color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
            ),
            onSelected: (value) async {
              try {
                switch (value) {
                  case 'text':
                    await ExportService.shareNoteAsText(widget.note, courseName: widget.courseName);
                    break;
                  case 'pdf_share':
                    await ExportService.shareNoteAsPdf(widget.note, courseName: widget.courseName);
                    break;
                  case 'pdf_print':
                    await ExportService.exportNoteToPdf(widget.note, courseName: widget.courseName);
                    break;
                  case 'share_file':
                    await ExportService.shareNoteFile(widget.note);
                    break;
                  case 'move':
                    _moveNoteToCourse();
                  break;
              }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error: ${e.toString().replaceAll('Exception: ', '')}'),
                      behavior: SnackBarBehavior.floating,
                      backgroundColor: AppColors.red,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  );
                }
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'text', child: ListTile(leading: Icon(Icons.text_snippet), title: Text('Share as Text'))),
              const PopupMenuItem(value: 'pdf_share', child: ListTile(leading: Icon(Icons.picture_as_pdf), title: Text('Share as PDF'))),
              const PopupMenuItem(value: 'pdf_print', child: ListTile(leading: Icon(Icons.print), title: Text('Print / Export PDF'))),
              // Show share file option for image/audio notes
              if (widget.note.filePath != null && (widget.note.type == NoteType.image || widget.note.type == NoteType.ocr))
                const PopupMenuItem(value: 'share_file', child: ListTile(leading: Icon(Icons.image), title: Text('Share Image'))),
              if (widget.note.filePath != null && widget.note.type == NoteType.audio)
                const PopupMenuItem(value: 'share_file', child: ListTile(leading: Icon(Icons.audiotrack), title: Text('Share Audio File'))),
              const PopupMenuDivider(),
              const PopupMenuItem(value: 'move', child: ListTile(leading: Icon(Icons.drive_file_move_outline), title: Text('Move to Course'))),
            ],
          ),
          IconButton(
            icon: Icon(
              widget.note.isBookmarked ? Icons.bookmark : Icons.bookmark_border,
              color: widget.note.isBookmarked 
                  ? AppColors.primary 
                  : (isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight),
            ),
            onPressed: () {
              context.read<NoteProvider>().toggleBookmark(widget.note);
              setState(() {}); // Rebuild for icon update
            },
          ),
          IconButton(
            icon: Icon(
              Icons.delete_outline,
              color: AppColors.red,
            ),
            onPressed: _deleteNote,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title
            TextField(
              controller: _titleController,
              enabled: _isEditing,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
              ),
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: AppLocalizations.of(context)!.title,
              ),
            ),
            const SizedBox(height: 8),
            
            // Meta Info
            Text(
              // Using DateFormat from intl directly but locale should be passed
              DateFormat('MMMM d, yyyy • h:mm a', Localizations.localeOf(context).toString()).format(widget.note.createdAt!),
              style: TextStyle(
                fontSize: 14,
                color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
              ),
            ),
            const SizedBox(height: 24),

            // Image Preview (if any)
            if (widget.note.thumbnailPath != null) ...[
              FutureBuilder<String?>(
                future: FileService().resolveFilePath(widget.note.thumbnailPath),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Container(
                      height: 200,
                      decoration: BoxDecoration(
                        color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Center(child: CircularProgressIndicator()),
                    );
                  }
                  final resolvedPath = snapshot.data;
                  if (resolvedPath != null && File(resolvedPath).existsSync()) {
                    return ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Image.file(
                        File(resolvedPath),
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => _buildImageError(isDark),
                      ),
                    );
                  }
                  return _buildImageError(isDark);
                },
              ),
              const SizedBox(height: 24),
            ],

            // Audio Player
            if (widget.note.isAudio) ...[
              _AudioPlayerWidget(
                note: widget.note,
                isDark: isDark,
              ),
              const SizedBox(height: 24),
            ],

            // Content
            if (_contentController.text.isNotEmpty || _isEditing) ...[
              Text(
                AppLocalizations.of(context)!.notesHeader,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _contentController,
                enabled: _isEditing,
                maxLines: null,
                style: TextStyle(
                  fontSize: 16,
                  height: 1.6,
                  color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                ),
                decoration: InputDecoration(
                  border: InputBorder.none,
                  hintText: AppLocalizations.of(context)!.writeYourNote,
                  hintStyle: TextStyle(
                    color: isDark ? Colors.grey.shade600 : Colors.grey.shade400,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _toggleEditing() async {
    if (_isEditing) {
      // Save changes
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
      height: 200,
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.grey.shade100,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.broken_image, size: 48,
              color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight),
            const SizedBox(height: 8),
            Text('Image unavailable',
              style: TextStyle(
                color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
              )),
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
            child: Text(AppLocalizations.of(context)!.delete, style: const TextStyle(color: AppColors.red)),
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
    final courses = context.read<CourseProvider>().courses
        .where((c) => c.id != widget.note.courseId)
        .toList();

    if (courses.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('No other courses available'),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
      return;
    }

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final selectedCourseId = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: isDark ? AppColors.surfaceDark : Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40, height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Move to Course',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Select destination course',
                style: TextStyle(
                  fontSize: 14,
                  color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                ),
              ),
              const SizedBox(height: 16),
              ConstrainedBox(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(ctx).size.height * 0.4,
                ),
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: courses.length,
                  itemBuilder: (_, i) {
                    final course = courses[i];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      decoration: BoxDecoration(
                        color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isDark ? Colors.white.withValues(alpha: 0.1) : Colors.grey.shade200,
                        ),
                      ),
                      child: ListTile(
                        leading: Container(
                          width: 40, height: 40,
                          decoration: BoxDecoration(
                            color: course.color.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(Icons.school, color: course.color, size: 20),
                        ),
                        title: Text(
                          course.name,
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                          ),
                        ),
                        trailing: Icon(Icons.chevron_right,
                          color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight),
                        onTap: () => Navigator.pop(ctx, course.id),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );

    if (selectedCourseId == null || !mounted) return;

    final success = await context.read<NoteProvider>().moveNoteToCourse(
      widget.note,
      selectedCourseId,
    );

    if (!mounted) return;
    if (success) {
      final courseName = context.read<CourseProvider>().courses
          .firstWhere((c) => c.id == selectedCourseId,
            orElse: () => Course(
              id: '', name: 'Unknown', color: AppColors.primary,
              scheduleDays: [],
              startTime: const TimeOfDay(hour: 0, minute: 0),
              endTime: const TimeOfDay(hour: 0, minute: 0),
            ),
          ).name;
      HapticFeedback.mediumImpact();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Moved to $courseName'),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
      Navigator.pop(context); // Return to course detail
    }
  }
}

class _AudioPlayerWidget extends StatefulWidget {
  final Note note;
  final bool isDark;

  const _AudioPlayerWidget({
    required this.note,
    required this.isDark,
  });

  @override
  State<_AudioPlayerWidget> createState() => _AudioPlayerWidgetState();
}

class _AudioPlayerWidgetState extends State<_AudioPlayerWidget> {
  bool _isPlaying = false;
  final Duration _position = Duration.zero;
  Duration _duration = Duration.zero;

  @override
  void initState() {
    super.initState();
    _duration = Duration(seconds: widget.note.audioDuration ?? 0);
    
    // Listen to streams
    // Note: We should probably manage player state better in a real app
    // e.g. checking if THIS note is the one playing.
    // For MVP we assume one player.
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: widget.isDark ? Colors.grey.shade800 : Colors.grey.shade100,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Row(
            children: [
              IconButton(
                icon: Icon(_isPlaying ? Icons.pause : Icons.play_arrow),
                color: AppColors.primary,
                iconSize: 32,
                onPressed: () {
                  final provider = context.read<NoteProvider>();
                  if (_isPlaying) {
                    provider.pauseAudio();
                    setState(() => _isPlaying = false);
                  } else {
                    if (widget.note.filePath != null) {
                      provider.playAudio(widget.note.filePath!);
                      setState(() => _isPlaying = true);
                    }
                  }
                },
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppLocalizations.of(context)!.voiceMemo,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: widget.isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                      ),
                    ),
                    StreamBuilder<Duration>(
                      stream: context.read<NoteProvider>().onPositionChanged,
                      builder: (context, snapshot) {
                        final pos = snapshot.data ?? Duration.zero;
                         // Hacky update for local state to sync slider
                         // Ideally use a better state management for player
                        if (_isPlaying && pos.inSeconds != _position.inSeconds) {
                           // Use microtask to avoid build error or just rely on rebuild
                           // _position = pos; 
                        }
                        return Text(
                          '${_formatDuration(pos)} / ${widget.note.formattedDuration}',
                          style: TextStyle(
                            fontSize: 12,
                            color: widget.isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Slider with Bookmarks
          StreamBuilder<Duration>(
            stream: context.read<NoteProvider>().onPositionChanged,
            builder: (context, snapshot) {
              final pos = snapshot.data ?? Duration.zero;
              final max = _duration.inMilliseconds.toDouble();
              final value = pos.inMilliseconds.toDouble().clamp(0.0, max);
              
              return Column(
                children: [
                   SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
                      overlayShape: const RoundSliderOverlayShape(overlayRadius: 12),
                      trackHeight: 4,
                    ),
                    child: Slider(
                      value: value,
                      max: max > 0 ? max : 1.0,
                      activeColor: AppColors.primary,
                      inactiveColor: Colors.grey.shade300,
                      onChanged: (val) {
                         context.read<NoteProvider>().seekAudio(Duration(milliseconds: val.toInt()));
                      },
                    ),
                  ),

                   // Bookmark List Chips
                   if (widget.note.bookmarks.isNotEmpty)
                     Wrap(
                       spacing: 8,
                       children: widget.note.bookmarks.asMap().entries.map((entry) {
                         final index = entry.key;
                         final bm = entry.value;
                         return ActionChip(
                           label: Text(
                             '#${index + 1} ${_formatDuration(bm)}',
                             style: const TextStyle(fontSize: 12),
                           ),
                           avatar: const Icon(Icons.flag, size: 14, color: AppColors.primary),
                           onPressed: () {
                             context.read<NoteProvider>().seekAudio(bm);
                           },
                           backgroundColor: widget.isDark ? Colors.grey.shade700 : Colors.white,
                           side: BorderSide(color: Colors.grey.shade300),
                         );
                       }).toList(),
                     ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  String _formatDuration(Duration d) {
    final minutes = d.inMinutes;
    final seconds = d.inSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }
}
