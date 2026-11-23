import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lesson_tracker/models/course.dart';

Course _course({
  double progress = 80,
  int absences = 0,
  int limit = 4,
  DateTime? exam,
}) =>
    Course(
      id: 'c',
      name: 'C',
      color: Colors.blue,
      scheduleDays: const [0],
      startTime: const TimeOfDay(hour: 9, minute: 0),
      endTime: const TimeOfDay(hour: 10, minute: 0),
      progress: progress,
      currentAbsences: absences,
      absenceLimit: limit,
      nextExamDate: exam,
    );

void main() {
  test('sınavı yaklaşan, geride kalan ve devamsızlık riskli ders dikkat ister', () {
    expect(_course().needsAttention, isFalse);
    expect(
      _course(exam: DateTime.now().add(const Duration(days: 3))).needsAttention,
      isTrue,
    );
    expect(_course(progress: 40).needsAttention, isTrue);
    expect(_course(absences: 3, limit: 4).needsAttention, isTrue); // %75
    expect(_course(absences: 2, limit: 4).needsAttention, isFalse); // %50
    expect(_course(absences: 5, limit: 0).isAbsenceAtRisk, isFalse);
  });

  test('sıralama önceliği: sınav < geride < devamsızlık < diğer', () {
    final exam = _course(exam: DateTime.now().add(const Duration(days: 1)));
    final behind = _course(progress: 10);
    final absence = _course(absences: 3);
    final ok = _course();
    final sorted = [ok, absence, behind, exam]
      ..sort((a, b) => a.attentionRank.compareTo(b.attentionRank));
    expect(sorted, [exam, behind, absence, ok]);
  });
}
