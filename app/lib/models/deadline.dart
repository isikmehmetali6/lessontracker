
enum DeadlineType {
  exam,
  assignment,
  project,
  other,
}

class Deadline {
  final String id;
  final String courseId;
  final String title;
  final DateTime date;
  final DeadlineType type;
  final bool reminder;

  Deadline({
    required this.id,
    required this.courseId,
    required this.title,
    required this.date,
    required this.type,
    this.reminder = true,
  });

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

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is Deadline && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;

  Deadline copyWith({
    String? id,
    String? courseId,
    String? title,
    DateTime? date,
    DeadlineType? type,
    bool? reminder,
  }) {
    return Deadline(
      id: id ?? this.id,
      courseId: courseId ?? this.courseId,
      title: title ?? this.title,
      date: date ?? this.date,
      type: type ?? this.type,
      reminder: reminder ?? this.reminder,
    );
  }
}
