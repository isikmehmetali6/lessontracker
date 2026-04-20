/// Moodle'dan çekilen bir ödevi temsil eder.
class MoodleAssignment {
  /// Moodle assignment ID
  final int id;

  /// Hangi MoodleAccount'a ait
  final String accountId;

  /// Ödevin ait olduğu ders ID'si
  final int courseId;

  /// Ders adı — gösterim için denormalize
  final String courseName;

  /// Ödev adı
  final String name;

  /// HTML ödev açıklaması (nullable)
  final String? description;

  /// Son teslim tarihi
  final DateTime dueDate;

  /// Teslim edildi mi?
  final bool submitted;

  /// Varsa alınan not
  final double? grade;

  /// Maksimum not değeri
  final double? maxGrade;

  const MoodleAssignment({
    required this.id,
    required this.accountId,
    required this.courseId,
    required this.courseName,
    required this.name,
    this.description,
    required this.dueDate,
    this.submitted = false,
    this.grade,
    this.maxGrade,
  });

  /// Vadesi geçmiş mi ve teslim edilmemiş mi?
  bool get isOverdue =>
      !submitted && dueDate.isBefore(DateTime.now());

  /// Bugün son gün mü?
  bool get isDueToday {
    final now = DateTime.now();
    return dueDate.year == now.year &&
        dueDate.month == now.month &&
        dueDate.day == now.day;
  }

  /// Bu haftaki ödevler (bugün dahil, 7 gün içinde)
  bool get isDueThisWeek {
    final now = DateTime.now();
    final diff = dueDate.difference(now).inDays;
    return diff >= 0 && diff <= 7;
  }

  MoodleAssignment copyWith({
    bool? submitted,
    double? grade,
    double? maxGrade,
  }) {
    return MoodleAssignment(
      id: id,
      accountId: accountId,
      courseId: courseId,
      courseName: courseName,
      name: name,
      description: description,
      dueDate: dueDate,
      submitted: submitted ?? this.submitted,
      grade: grade ?? this.grade,
      maxGrade: maxGrade ?? this.maxGrade,
    );
  }

  /// Moodle API JSON'undan oluştur (mod_assign_get_assignments yanıtı)
  factory MoodleAssignment.fromApiJson(
    Map<String, dynamic> json,
    String accountId,
    int courseId,
    String courseName,
  ) {
    DateTime? parseTimestamp(dynamic value) {
      if (value == null) return null;
      final ts = value is int ? value : int.tryParse(value.toString());
      if (ts == null || ts == 0) return null;
      return DateTime.fromMillisecondsSinceEpoch(ts * 1000);
    }

    return MoodleAssignment(
      id: json['id'] as int,
      accountId: accountId,
      courseId: courseId,
      courseName: courseName,
      name: json['name'] as String? ?? '',
      description: json['intro'] as String?,
      dueDate: parseTimestamp(json['duedate']) ?? DateTime(2099),
      submitted: false, // submission durumu ayrı API çağrısıyla alınır
    );
  }

  @override
  String toString() =>
      'MoodleAssignment(id: $id, name: $name, dueDate: $dueDate)';
}
