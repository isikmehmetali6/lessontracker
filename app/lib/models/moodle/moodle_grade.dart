/// Moodle'dan çekilen bir ders notunu temsil eder.
/// gradereport_overview_get_course_grades veya gradereport_user_get_grade_items
/// API'lerinden türetilir.
class MoodleGrade {
  /// Hangi MoodleAccount'a ait
  final String accountId;

  /// Moodle ders ID'si
  final int courseId;

  /// Ders adı — gösterim için denormalize
  final String courseName;

  /// Not kalemi adı, örn. "Vize 1", "Final", "Ödev 3"
  final String itemName;

  /// Alınan not (null = henüz notlandırılmamış)
  final double? gradeValue;

  /// Maksimum not değeri
  final double gradeMax;

  /// Yüzde hesabı (0-100). gradeValue null ise 0.
  final double percentage;

  /// Harf notu varsa, örn. "AA", "BA", "CC"
  final String? letterGrade;

  const MoodleGrade({
    required this.accountId,
    required this.courseId,
    required this.courseName,
    required this.itemName,
    this.gradeValue,
    required this.gradeMax,
    required this.percentage,
    this.letterGrade,
  });

  /// Notlandırıldı mı?
  bool get isGraded => gradeValue != null;

  /// Moodle API JSON'undan oluştur (gradereport_overview_get_course_grades yanıtı)
  factory MoodleGrade.fromApiJson(
    Map<String, dynamic> json,
    String accountId,
    int courseId,
    String courseName,
  ) {
    const double defaultMax = 100.0;

    final rawGrade = json['grade'] as String?;
    double? gradeValue;
    if (rawGrade != null && rawGrade.isNotEmpty && rawGrade != '-') {
      gradeValue = double.tryParse(rawGrade.replaceAll(',', '.'));
    }

    final max = double.tryParse(
          ((json['grademax'] ?? json['rawgrademax'] ?? defaultMax)
                  .toString()
                  .replaceAll(',', '.')),
        ) ??
        defaultMax;

    final pct = gradeValue != null && max > 0
        ? (gradeValue / max * 100).clamp(0.0, 100.0)
        : 0.0;

    return MoodleGrade(
      accountId: accountId,
      courseId: courseId,
      courseName: courseName,
      itemName: json['itemname'] as String? ??
          json['name'] as String? ??
          'Genel Not',
      gradeValue: gradeValue,
      gradeMax: max,
      percentage: pct,
      letterGrade: json['lettergrade'] as String?,
    );
  }

  @override
  String toString() =>
      'MoodleGrade(course: $courseName, item: $itemName, pct: $percentage%)';
}
