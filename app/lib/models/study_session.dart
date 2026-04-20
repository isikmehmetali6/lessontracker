/// Çalışma oturumu modeli — Pomodoro timer'dan kayıt
class StudySession {
  final String id;
  final String? courseId;
  final int durationMinutes; // Çalışılan süre (dakika)
  final DateTime startedAt;
  final DateTime endedAt;
  final String sessionType; // 'work' veya 'break'

  StudySession({
    required this.id,
    this.courseId,
    required this.durationMinutes,
    required this.startedAt,
    required this.endedAt,
    this.sessionType = 'work',
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'courseId': courseId,
      'durationMinutes': durationMinutes,
      'startedAt': startedAt.toIso8601String(),
      'endedAt': endedAt.toIso8601String(),
      'sessionType': sessionType,
    };
  }

  factory StudySession.fromMap(Map<String, dynamic> map) {
    return StudySession(
      id: map['id'] as String,
      courseId: map['courseId'] as String?,
      durationMinutes: map['durationMinutes'] as int,
      startedAt: DateTime.parse(map['startedAt'] as String),
      endedAt: DateTime.parse(map['endedAt'] as String),
      sessionType: map['sessionType'] as String? ?? 'work',
    );
  }

  /// Bugün mü?
  bool get isToday {
    final now = DateTime.now();
    return startedAt.year == now.year &&
        startedAt.month == now.month &&
        startedAt.day == now.day;
  }

  /// Bu hafta mı?
  bool get isThisWeek {
    final now = DateTime.now();
    final weekStart = DateTime(now.year, now.month, now.day)
        .subtract(Duration(days: now.weekday - 1));
    final weekEnd = weekStart.add(const Duration(days: 7));
    return !startedAt.isBefore(weekStart) && startedAt.isBefore(weekEnd);
  }
}
