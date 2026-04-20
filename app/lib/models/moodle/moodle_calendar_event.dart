/// Moodle takvim etkinliğini temsil eder.
/// core_calendar_get_calendar_events API'sinden türetilir.
class MoodleCalendarEvent {
  /// Moodle event ID
  final int id;

  /// Hangi MoodleAccount'a ait
  final String accountId;

  /// Etkinlik adı
  final String name;

  /// Etkinlik açıklaması (HTML, nullable)
  final String? description;

  /// Başlangıç zamanı
  final DateTime timeStart;

  /// Süre (saniye cinsinden, 0 ise tüm gün etkinliği)
  final int durationSeconds;

  /// Etkinlik türü: 'course' | 'user' | 'site' | 'category'
  final String eventType;

  /// Ait olduğu ders ID'si (course event ise)
  final int? courseId;

  /// Ders adı — gösterim kolaylığı için denormalize
  final String? courseName;

  /// Moodle'daki etkinlik URL'i (url_launcher ile açılabilir)
  final String? eventUrl;

  const MoodleCalendarEvent({
    required this.id,
    required this.accountId,
    required this.name,
    this.description,
    required this.timeStart,
    this.durationSeconds = 0,
    required this.eventType,
    this.courseId,
    this.courseName,
    this.eventUrl,
  });

  /// Bitiş zamanı — durationSeconds 0 ise timeStart ile aynı
  DateTime get timeEnd => durationSeconds > 0
      ? timeStart.add(Duration(seconds: durationSeconds))
      : timeStart;

  /// Tüm gün etkinliği mi?
  bool get isAllDay => durationSeconds == 0;

  /// Bugün gerçekleşiyor mu?
  bool get isToday {
    final now = DateTime.now();
    return timeStart.year == now.year &&
        timeStart.month == now.month &&
        timeStart.day == now.day;
  }

  /// Moodle API JSON'undan oluştur
  factory MoodleCalendarEvent.fromApiJson(
    Map<String, dynamic> json,
    String accountId, {
    Map<int, String>? courseNameMap,
  }) {
    final courseId = json['courseid'] as int?;
    final courseName = courseId != null && courseNameMap != null
        ? courseNameMap[courseId]
        : null;

    return MoodleCalendarEvent(
      id: json['id'] as int,
      accountId: accountId,
      name: json['name'] as String? ?? '',
      description: json['description'] as String?,
      timeStart: DateTime.fromMillisecondsSinceEpoch(
        ((json['timestart'] ?? 0) as int) * 1000,
      ),
      durationSeconds: (json['timeduration'] ?? 0) as int,
      eventType: json['eventtype'] as String? ?? 'user',
      courseId: courseId,
      courseName: courseName,
      eventUrl: json['url'] as String?,
    );
  }

  @override
  String toString() =>
      'MoodleCalendarEvent(id: $id, name: $name, timeStart: $timeStart)';
}
