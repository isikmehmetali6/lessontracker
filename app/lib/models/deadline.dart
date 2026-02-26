
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
    return Deadline(
      id: map['id'],
      courseId: map['courseId'],
      title: map['title'],
      date: DateTime.parse(map['date']),
      type: DeadlineType.values[map['type']],
      reminder: map['reminder'] == 1,
    );
  }

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
