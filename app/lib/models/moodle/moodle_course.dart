/// Moodle'dan çekilen bir dersi temsil eder.
/// Uygulamanın kendi Course modeline bağımlı değildir — tamamen izole.
class MoodleCourse {
  /// Moodle'ın kendi dahili ID'si
  final int id;

  /// Bu dersin ait olduğu MoodleAccount UUID'si
  final String accountId;

  /// Kısa ders kodu, örn. "MAT201"
  final String shortName;

  /// Tam ders adı, örn. "Matematik II — İntegral Hesabı"
  final String fullName;

  /// Ders açıklaması (HTML olabilir)
  final String? summary;

  /// Kategori adı, örn. "Mühendislik Fakültesi"
  final String? categoryName;

  /// Moodle'daki ders görseli URL'i
  final String? courseImageUrl;

  /// Ders başlangıç tarihi (Unix timestamp'ten çevrilmiş)
  final DateTime? startDate;

  /// Ders bitiş tarihi
  final DateTime? endDate;

  /// Öğrencinin bu derste tamamladığı aktivite yüzdesi (0-100)
  final int progress;

  /// Kullanıcının favori olarak işaretlediği mi?
  final bool isFavorite;

  const MoodleCourse({
    required this.id,
    required this.accountId,
    required this.shortName,
    required this.fullName,
    this.summary,
    this.categoryName,
    this.courseImageUrl,
    this.startDate,
    this.endDate,
    this.progress = 0,
    this.isFavorite = false,
  });

  MoodleCourse copyWith({
    int? id,
    String? accountId,
    String? shortName,
    String? fullName,
    String? summary,
    String? categoryName,
    String? courseImageUrl,
    DateTime? startDate,
    DateTime? endDate,
    int? progress,
    bool? isFavorite,
  }) {
    return MoodleCourse(
      id: id ?? this.id,
      accountId: accountId ?? this.accountId,
      shortName: shortName ?? this.shortName,
      fullName: fullName ?? this.fullName,
      summary: summary ?? this.summary,
      categoryName: categoryName ?? this.categoryName,
      courseImageUrl: courseImageUrl ?? this.courseImageUrl,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      progress: progress ?? this.progress,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }

  /// Moodle API JSON'undan oluştur (core_enrol_get_users_courses yanıtı)
  factory MoodleCourse.fromApiJson(Map<String, dynamic> json, String accountId) {
    // Moodle bazen Unix timestamp döner, bazen 0
    DateTime? parseTimestamp(dynamic value) {
      if (value == null) return null;
      final ts = value is int ? value : int.tryParse(value.toString());
      if (ts == null || ts == 0) return null;
      return DateTime.fromMillisecondsSinceEpoch(ts * 1000);
    }

    // Overviewfiles içinden ilk görseli al
    String? imageUrl;
    final overviewFiles = json['overviewfiles'] as List<dynamic>?;
    if (overviewFiles != null && overviewFiles.isNotEmpty) {
      imageUrl = overviewFiles.first['fileurl'] as String?;
    }

    return MoodleCourse(
      id: json['id'] as int,
      accountId: accountId,
      shortName: json['shortname'] as String? ?? '',
      fullName: json['fullname'] as String? ?? '',
      summary: json['summary'] as String?,
      categoryName: json['categoryname'] as String?,
      courseImageUrl: imageUrl,
      startDate: parseTimestamp(json['startdate']),
      endDate: parseTimestamp(json['enddate']),
      progress: (json['progress'] as num?)?.toInt() ?? 0,
    );
  }

  @override
  String toString() =>
      'MoodleCourse(id: $id, shortName: $shortName, accountId: $accountId)';
}
