import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lesson_tracker/l10n/app_localizations.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../models/course.dart';
import '../../../../models/note.dart';
import '../../../../providers/note_provider.dart';
import '../../../../widgets/course/note_cards.dart';
import '../widgets/confirm_action_dialog.dart';

class CourseNotesTab extends StatefulWidget {
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
  State<CourseNotesTab> createState() => _CourseNotesTabState();
}

class _CourseNotesTabState extends State<CourseNotesTab> {
  NoteType? _selectedFilter;
  String _searchQuery = '';
  bool _bookmarkedFirst = false;
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Note> _filterAndSort(List<Note> notes) {
    var filtered = notes.where((note) {
      // Type filter
      if (_selectedFilter != null && note.type != _selectedFilter) return false;
      // Search filter
      if (_searchQuery.isNotEmpty) {
        final q = _searchQuery.toLowerCase();
        final matchTitle = note.title.toLowerCase().contains(q);
        final matchContent = (note.content ?? '').toLowerCase().contains(q);
        final matchTags = note.tags.any((t) => t.toLowerCase().contains(q));
        if (!matchTitle && !matchContent && !matchTags) return false;
      }
      return true;
    }).toList();

    // Sort: bookmarked first if enabled, then by date
    filtered.sort((a, b) {
      if (_bookmarkedFirst) {
        if (a.isBookmarked && !b.isBookmarked) return -1;
        if (!a.isBookmarked && b.isBookmarked) return 1;
      }
      final dateA = a.createdAt ?? DateTime(2000);
      final dateB = b.createdAt ?? DateTime(2000);
      return dateB.compareTo(dateA); // newest first
    });

    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context)!;

    final isLoading = context.select<NoteProvider, bool>((p) => p.isLoading);
    final notes = context.select<NoteProvider, List<Note>>(
      (p) => p.courseNotes,
    );

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
                    l10n.noNotesYet,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: isDark
                          ? AppColors.textSecondaryDark
                          : AppColors.textSecondaryLight,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    l10n.noNotesDescription,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: isDark
                          ? AppColors.textSecondaryDark
                          : AppColors.textSecondaryLight,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      );
    }

    final filteredNotes = _filterAndSort(notes);

    return Column(
      children: [
        // Search bar
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
          child: TextField(
            controller: _searchController,
            onChanged: (v) => setState(() => _searchQuery = v),
            decoration: InputDecoration(
              hintText: l10n.searchHint,
              prefixIcon: const Icon(Icons.search, size: 20),
              suffixIcon: _searchQuery.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear, size: 18),
                      onPressed: () {
                        _searchController.clear();
                        setState(() => _searchQuery = '');
                      },
                    )
                  : null,
              filled: true,
              fillColor: isDark ? AppColors.surfaceDark : Colors.grey.shade50,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ),

        // Filter chips
        SizedBox(
          height: 44,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 24),
            children: [
              _buildFilterChip(null, l10n.viewAll, Icons.list, isDark),
              const SizedBox(width: 8),
              _buildFilterChip(
                NoteType.text,
                l10n.keyboard,
                Icons.text_snippet_outlined,
                isDark,
              ),
              const SizedBox(width: 8),
              _buildFilterChip(
                NoteType.image,
                l10n.camera,
                Icons.image_outlined,
                isDark,
              ),
              const SizedBox(width: 8),
              _buildFilterChip(
                NoteType.ocr,
                l10n.ocrLabel,
                Icons.document_scanner_outlined,
                isDark,
              ),
              const SizedBox(width: 8),
              _buildFilterChip(
                NoteType.drawing,
                l10n.drawingLabel,
                Icons.draw_outlined,
                isDark,
              ),
              const SizedBox(width: 8),
              // Bookmark sort toggle
              GestureDetector(
                onTap: () =>
                    setState(() => _bookmarkedFirst = !_bookmarkedFirst),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: _bookmarkedFirst
                        ? AppColors.amber.withValues(alpha: 0.15)
                        : (isDark
                              ? AppColors.surfaceDark
                              : Colors.grey.shade100),
                    borderRadius: BorderRadius.circular(10),
                    border: _bookmarkedFirst
                        ? Border.all(color: AppColors.amber, width: 1.5)
                        : null,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        _bookmarkedFirst
                            ? Icons.bookmark
                            : Icons.bookmark_border,
                        size: 16,
                        color: _bookmarkedFirst
                            ? AppColors.amber
                            : (isDark
                                  ? AppColors.textSecondaryDark
                                  : AppColors.textSecondaryLight),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '★',
                        style: TextStyle(
                          fontSize: 12,
                          color: _bookmarkedFirst
                              ? AppColors.amber
                              : (isDark
                                    ? AppColors.textSecondaryDark
                                    : AppColors.textSecondaryLight),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),

        // Results count
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 0),
          child: Row(
            children: [
              Icon(
                Icons.sticky_note_2_outlined,
                size: 14,
                color: isDark
                    ? AppColors.textSecondaryDark
                    : AppColors.textSecondaryLight,
              ),
              const SizedBox(width: 6),
              Text(
                _selectedFilter != null || _searchQuery.isNotEmpty
                    ? l10n.ofNotes(filteredNotes.length, notes.length)
                    : l10n.notesCount(notes.length),
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: isDark
                      ? AppColors.textSecondaryDark
                      : AppColors.textSecondaryLight,
                ),
              ),
            ],
          ),
        ),

        // Notes list
        Expanded(
          child: filteredNotes.isEmpty
              ? Center(
                  child: Text(
                    l10n.noResults,
                    style: TextStyle(
                      color: isDark
                          ? AppColors.textSecondaryDark
                          : AppColors.textSecondaryLight,
                    ),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.fromLTRB(24, 12, 24, 120),
                  itemCount: filteredNotes.length,
                  itemBuilder: (context, index) {
                    final note = filteredNotes[index];
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
                        child: const Icon(
                          Icons.delete_outline,
                          color: Colors.white,
                          size: 28,
                        ),
                      ),
                      confirmDismiss: (direction) async {
                        return await showConfirmActionDialog(
                          context,
                          title: l10n.deleteNoteTitle,
                        );
                      },
                      onDismissed: (direction) {
                        context.read<NoteProvider>().deleteNote(note);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(l10n.delete),
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        );
                      },
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: CourseNoteCard(
                          note: note,
                          onTap: () => widget.onShowNoteDetail(note),
                          onPlayTap: () => widget.onPlayAudio(note),
                          onBookmarkTap: () => widget.onToggleBookmark(note),
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildFilterChip(
    NoteType? type,
    String label,
    IconData icon,
    bool isDark,
  ) {
    final isSelected = _selectedFilter == type;
    return GestureDetector(
      onTap: () => setState(() => _selectedFilter = type),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withValues(alpha: 0.15)
              : (isDark ? AppColors.surfaceDark : Colors.grey.shade100),
          borderRadius: BorderRadius.circular(10),
          border: isSelected
              ? Border.all(color: AppColors.primary, width: 1.5)
              : Border.all(color: Colors.transparent, width: 1.5),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 16,
              color: isSelected
                  ? AppColors.primary
                  : (isDark
                        ? AppColors.textSecondaryDark
                        : AppColors.textSecondaryLight),
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                color: isSelected
                    ? AppColors.primary
                    : (isDark
                          ? AppColors.textSecondaryDark
                          : AppColors.textSecondaryLight),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
