import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lesson_tracker/providers/course_provider.dart';

/// Loads absences for the absence calendar tab. Extracted per plan
/// 3.1.6 (P2). Pure helper: returns the events map (keyed by
/// normalized date). State mutations (setState) stay on the host via
/// the [isMounted] callback.
Future<Map<DateTime, List<Map<String, dynamic>>>> loadAbsencesForTab({
  required BuildContext context,
  required String courseId,
  required bool Function() isMounted,
}) async {
  final absences =
      await context.read<CourseProvider>().loadAbsencesForCourse(courseId);
  final events = <DateTime, List<Map<String, dynamic>>>{};
  for (final a in absences) {
    final dateStr = a['date'];
    final date = dateStr is DateTime
        ? dateStr
        : DateTime.parse(dateStr as String);
    final normalized = DateTime(date.year, date.month, date.day);
    events.putIfAbsent(normalized, () => []).add(a);
  }
  return events;
}