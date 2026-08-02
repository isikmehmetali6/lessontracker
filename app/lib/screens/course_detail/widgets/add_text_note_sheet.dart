import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:lesson_tracker/core/theme/app_colors.dart';
import 'package:lesson_tracker/core/utils/note_templates.dart';
import 'package:lesson_tracker/l10n/app_localizations.dart';
import 'package:lesson_tracker/models/course.dart';
import 'package:lesson_tracker/providers/note_provider.dart';
import 'package:lesson_tracker/widgets/common/common_widgets.dart';

/// Shows the bottom sheet for adding a plain text note to [course].
/// Returns when the sheet is dismissed (success or cancel).
Future<void> showAddTextNoteSheet({
  required BuildContext context,
  required Course course,
  required void Function() onSaved,
}) async {
  final titleController = TextEditingController();
  final contentController = TextEditingController();
  final isDark = Theme.of(context).brightness == Brightness.dark;
  final l10n = AppLocalizations.of(context)!;

  await showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (sheetContext) {
      return Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(sheetContext).viewInsets.bottom,
        ),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(28),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: isDark ? Colors.grey.shade600 : Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                l10n.newNote,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: isDark
                      ? AppColors.textPrimaryDark
                      : AppColors.textPrimaryLight,
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: titleController,
                decoration: InputDecoration(
                  hintText: l10n.title,
                  filled: true,
                  fillColor: isDark ? Colors.grey.shade800 : Colors.grey.shade100,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: contentController,
                maxLines: 4,
                decoration: InputDecoration(
                  hintText: l10n.writeYourNote,
                  filled: true,
                  fillColor: isDark ? Colors.grey.shade800 : Colors.grey.shade100,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 40,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: NoteTemplates.templates.length,
                  itemBuilder: (_, index) {
                    final template = NoteTemplates.templates[index];
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ActionChip(
                        avatar: Text(template.icon),
                        label: Text(
                          template.name,
                          style: const TextStyle(fontSize: 12),
                        ),
                        onPressed: () {
                          contentController.text = template.content;
                          if (titleController.text.isEmpty) {
                            titleController.text = template.name;
                          }
                        },
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 12),
              PrimaryButton(
                text: l10n.saveNote,
                icon: Icons.check,
                onPressed: () async {
                  if (titleController.text.isNotEmpty) {
                    await sheetContext.read<NoteProvider>().addTextNote(
                          courseId: course.id,
                          title: titleController.text,
                          content: contentController.text,
                        );
                    if (!sheetContext.mounted) return;
                    Navigator.pop(sheetContext);
                    HapticFeedback.mediumImpact();
                    onSaved();
                  }
                },
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      );
    },
  );

  titleController.dispose();
  contentController.dispose();
}