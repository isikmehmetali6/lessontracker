import 'package:freezed_annotation/freezed_annotation.dart';

part 'deadline.freezed.dart';

enum DeadlineType {
  exam,
  assignment,
  project,
  other,
}

@freezed
abstract class Deadline with _$Deadline {
  const Deadline._();

  const factory Deadline({
    required String id,
    required String courseId,
    required String title,
    required DateTime date,
    required DeadlineType type,
    @Default(true) bool reminder,
  }) = _Deadline;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'courseId': courseId,
      'title': title,
      'date': date.toIso8601String(),
      'type': type.index,
      'reminder': reminder ? 1 : 0,
    };
  }

  factory Deadline.fromMap(Map<String, dynamic> map) {
    final typeValue = map['type'];
    DeadlineType deadlineType;
    if (typeValue is int && typeValue >= 0 && typeValue < DeadlineType.values.length) {
      deadlineType = DeadlineType.values[typeValue];
    } else {
      deadlineType = DeadlineType.other;
    }
    return Deadline(
      id: map['id'] as String,
      courseId: map['courseId'] as String,
      title: map['title'] as String,
      date: DateTime.parse(map['date'] as String),
      type: deadlineType,
      reminder: map['reminder'] == 1,
    );
  }
}
