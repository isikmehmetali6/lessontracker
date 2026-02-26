import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lesson_tracker/l10n/app_localizations.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../models/course.dart';
import '../../../../models/note.dart';
import '../../../../providers/note_provider.dart';
import '../../../../widgets/course/note_cards.dart';

class CourseNotesTab extends StatelessWidget {
  final Course course;
  final Function(Note) onShowNoteDetail;
  final Function(Note) onPlayAudio;
  final Function(Note) onToggleBookmark;

  const CourseNotesTab({
    super.key,
    required this.course,
    required this.onShowNoteDetail,
    required this.onPlayAudio,
    required this.onToggleBookmark,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final isLoading = context.select<NoteProvider, bool>((p) => p.isLoading);
    final notes = context.select<NoteProvider, List<Note>>((p) => p.courseNotes);

    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (notes.isEmpty) {
      return CustomScrollView(
        slivers: [
          SliverFillRemaining(
            hasScrollBody: false,
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.note_add_outlined,
                    size: 64,
                    color: isDark ? Colors.grey.shade700 : Colors.grey.shade300,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    AppLocalizations.of(context)!.noNotesYet, // Modified from hardcoded 'No notes yet' for i18n
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Use the tools below to capture your first note!',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 120),
      itemCount: notes.length,
      itemBuilder: (context, index) {
        final note = notes[index];
        return Dismissible(
          key: ValueKey(note.id),
          direction: DismissDirection.endToStart,
          background: Container(
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: AppColors.red,
              borderRadius: BorderRadius.circular(20),
            ),
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: 24),
            child: const Icon(Icons.delete_outline, color: Colors.white, size: 28),
          ),
          confirmDismiss: (direction) async {
             return await showDialog<bool>(
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
          },
          onDismissed: (direction) {
            context.read<NoteProvider>().deleteNote(note);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text('Note deleted'),
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              )
            );
          },
          child: Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: CourseNoteCard(
              note: note,
              onTap: () => onShowNoteDetail(note),
              onPlayTap: () => onPlayAudio(note),
              onBookmarkTap: () => onToggleBookmark(note),
            ),
          ),
        );
      },
    );
  }
}
