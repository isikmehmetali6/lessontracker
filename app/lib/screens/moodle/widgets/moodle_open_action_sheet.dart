import 'package:flutter/material.dart';

/// Result of the Moodle "what to do with this downloaded file?" sheet.
enum MoodleOpenAction { external, addAsNote }

/// Shows the modal asking the user whether to open the downloaded file
/// externally or save it as a note. Extracted from
/// `_MoodleCourseDetailScreenState._showOpenActionSheet` per plan
/// 3.1.3.
Future<MoodleOpenAction?> showMoodleOpenActionSheet(BuildContext context) {
  final locale = Localizations.localeOf(context).languageCode;
  final openLabel = locale == 'tr' ? 'Dışarıda aç' : 'Open externally';
  final addAsNoteLabel =
      locale == 'tr' ? 'Nota ekle' : 'Add as note';
  final addAsNoteHint =
      locale == 'tr' ? 'Derslerim notlarına kaydet' : 'Save to course notes';

  return showModalBottomSheet<MoodleOpenAction>(
    context: context,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (ctx) => SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.open_in_new),
            title: Text(openLabel),
            onTap: () => Navigator.pop(ctx, MoodleOpenAction.external),
          ),
          ListTile(
            leading: const Icon(Icons.note_add_outlined),
            title: Text(addAsNoteLabel),
            subtitle: Text(addAsNoteHint),
            onTap: () => Navigator.pop(ctx, MoodleOpenAction.addAsNote),
          ),
          const SizedBox(height: 8),
        ],
      ),
    ),
  );
}