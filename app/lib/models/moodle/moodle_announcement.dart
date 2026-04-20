/// Moodle forum/duyuru gönderisini temsil eder.
/// mod_forum_get_forum_discussions API'sinden türetilir.
class MoodleAnnouncement {
  /// Moodle discussion ID
  final int id;

  /// Hangi MoodleAccount'a ait
  final String accountId;

  /// Ait olduğu Moodle ders ID'si
  final int courseId;

  /// Ders adı — gösterim için denormalize
  final String courseName;

  /// Duyuru başlığı / konu
  final String subject;

  /// Duyuru içeriği (HTML olabilir)
  final String message;

  /// Duyuruyu yapan kişinin adı (genellikle öğretim üyesi)
  final String authorName;

  /// Oluşturulma zamanı
  final DateTime created;

  /// Öğrenci tarafından okundu mu? (local state — API'den gelmiyor)
  final bool isRead;

  const MoodleAnnouncement({
    required this.id,
    required this.accountId,
    required this.courseId,
    required this.courseName,
    required this.subject,
    required this.message,
    required this.authorName,
    required this.created,
    this.isRead = false,
  });

  MoodleAnnouncement markAsRead() => MoodleAnnouncement(
        id: id,
        accountId: accountId,
        courseId: courseId,
        courseName: courseName,
        subject: subject,
        message: message,
        authorName: authorName,
        created: created,
        isRead: true,
      );

  /// HTML etiketlerini temizlenmiş sade metin önizlemesi
  String get plainTextPreview {
    return message
        .replaceAll(RegExp(r'<[^>]*>'), '')
        .replaceAll('&nbsp;', ' ')
        .replaceAll('&amp;', '&')
        .replaceAll('&lt;', '<')
        .replaceAll('&gt;', '>')
        .trim();
  }

  /// Moodle API JSON'undan oluştur (mod_forum_get_forum_discussions yanıtı)
  factory MoodleAnnouncement.fromApiJson(
    Map<String, dynamic> json,
    String accountId,
    int courseId,
    String courseName,
  ) {
    return MoodleAnnouncement(
      id: json['id'] as int,
      accountId: accountId,
      courseId: courseId,
      courseName: courseName,
      subject: json['subject'] as String? ?? '',
      message: json['message'] as String? ??
          json['firstpost']?['message'] as String? ??
          '',
      authorName: json['userfullname'] as String? ??
          json['author'] as String? ??
          'Öğretim Üyesi',
      created: DateTime.fromMillisecondsSinceEpoch(
        ((json['created'] ?? json['timemodified'] ?? 0) as int) * 1000,
      ),
    );
  }

  @override
  String toString() =>
      'MoodleAnnouncement(id: $id, subject: $subject, course: $courseName)';
}
