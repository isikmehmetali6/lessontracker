import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:lesson_tracker/models/course.dart';
import 'package:lesson_tracker/providers/note_provider.dart';
import 'package:lesson_tracker/widgets/course/add_media_note_dialog.dart';

/// Shows the bottom sheet for adding an image note to a course.
/// Extracted from CourseDetailScreen per plan 3.1.2.
Future<void> showCourseImageNoteSheet({
  required BuildContext context,
  required File imageFile,
  required Course course,
  required VoidCallback onSaved,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (sheetContext) => AddMediaNoteDialog(
      imageFile: imageFile,
      onSave: (title, content, tags) async {
        final noteProvider = context.read<NoteProvider>();
        Navigator.pop(sheetContext);

        final note = await noteProvider.addImageNote(
          courseId: course.id,
          imageFile: imageFile,
          customTitle: title.isNotEmpty ? title : null,
          content: content?.isNotEmpty == true ? content : null,
          tags: tags,
          courseName: course.name,
          userName: 'User',
        );

        if (!context.mounted) return;
        if (note != null) {
          HapticFeedback.mediumImpact();
          if (!context.mounted) return;
          onSaved();
        }
      },
    ),
  );
}