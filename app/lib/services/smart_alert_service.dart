import '../../models/moodle/moodle_assignment.dart';
import '../../models/moodle/moodle_grade.dart';
import '../../models/moodle/moodle_calendar_event.dart';

/// Devamsızlık + Moodle verileri çapraz analiz ederek
/// akıllı risk uyarıları oluşturur.
class SmartAlertService {
  /// Tüm risk analizlerini çalıştır
  static List<SmartAlert> analyzeRisks({
    required List<MoodleAssignment> assignments,
    required List<MoodleGrade> grades,
    required List<MoodleCalendarEvent> events,
    Map<int, double> absencePercentages = const {}, // courseId → devamsızlık yüzdesi
  }) {
    final alerts = <SmartAlert>[];

    // 1. Çok ödevli hafta uyarısı
    final thisWeekAssignments = assignments
        .where((a) => !a.submitted && a.isDueThisWeek)
        .toList();
    if (thisWeekAssignments.length >= 3) {
      alerts.add(SmartAlert(
        type: SmartAlertType.heavyWeek,
        severity: AlertSeverity.medium,
        title: 'Yoğun Hafta!',
        message: 'Bu hafta ${thisWeekAssignments.length} ödev teslimin var. '
            'Zamanını iyi planla!',
        icon: '📋',
        relatedCourses: thisWeekAssignments.map((a) => a.courseName).toSet().toList(),
      ));
    }

    // 2. Devamsızlık limitine yaklaşma + yaklaşan sınav uyarısı
    for (final entry in absencePercentages.entries) {
      final courseId = entry.key;
      final pct = entry.value;

      if (pct >= 70) {
        // Bu derste yaklaşan etkinlik var mı?
        final courseEvents = events.where(
            (e) => e.courseId == courseId &&
                e.timeStart.isAfter(DateTime.now()) &&
                e.timeStart.isBefore(DateTime.now().add(const Duration(days: 14))));

        final courseName = courseEvents.isNotEmpty
            ? (courseEvents.first.courseName ?? 'Ders #$courseId')
            : 'Ders #$courseId';

        if (courseEvents.isNotEmpty) {
          alerts.add(SmartAlert(
            type: SmartAlertType.absenceRisk,
            severity: AlertSeverity.high,
            title: 'Devamsızlık Riski!',
            message: '$courseName: Devamsızlık limitindesin (${pct.toStringAsFixed(0)}%) '
                've ${courseEvents.first.name} yaklaşıyor!',
            icon: '⚠️',
            relatedCourses: [courseName],
          ));
        } else {
          alerts.add(SmartAlert(
            type: SmartAlertType.absenceRisk,
            severity: AlertSeverity.medium,
            title: 'Devamsızlık Uyarısı',
            message: '$courseName: Limitin ${pct.toStringAsFixed(0)}%\'ına ulaştın.',
            icon: '⚠️',
            relatedCourses: [courseName],
          ));
        }
      }
    }

    // 3. Düşük not + yaklaşan final uyarısı
    final courseGradeAvgs = <String, double>{};
    for (final grade in grades) {
      courseGradeAvgs.update(
        grade.courseName,
        (existing) => (existing + grade.percentage) / 2,
        ifAbsent: () => grade.percentage,
      );
    }

    for (final entry in courseGradeAvgs.entries) {
      if (entry.value < 50) {
        final upcomingExams = events.where(
            (e) => e.courseName == entry.key &&
                e.timeStart.isAfter(DateTime.now()) &&
                e.timeStart.isBefore(DateTime.now().add(const Duration(days: 30))));

        alerts.add(SmartAlert(
          type: SmartAlertType.lowGrade,
          severity: upcomingExams.isNotEmpty
              ? AlertSeverity.high
              : AlertSeverity.medium,
          title: 'Düşük Not Uyarısı',
          message:
              '${entry.key}: Ortalamanız ${entry.value.toStringAsFixed(1)}%'
              '${upcomingExams.isNotEmpty ? " ve yaklaşan sınav var!" : ""}',
          icon: '📉',
          relatedCourses: [entry.key],
        ));
      }
    }

    // 4. Gecikmiş (overdue) ödev
    final overdueAssignments = assignments.where((a) => a.isOverdue).toList();
    if (overdueAssignments.isNotEmpty) {
      alerts.add(SmartAlert(
        type: SmartAlertType.overdue,
        severity: AlertSeverity.high,
        title: '${overdueAssignments.length} Gecikmiş Ödev!',
        message: overdueAssignments
            .take(3)
            .map((a) => a.courseName)
            .toSet()
            .join(', '),
        icon: '🚨',
        relatedCourses:
            overdueAssignments.map((a) => a.courseName).toSet().toList(),
      ));
    }

    // Önem sırasına göre sırala
    alerts.sort((a, b) => b.severity.index.compareTo(a.severity.index));
    return alerts;
  }
}

// ──────────────────────────────────────────
// Veri Modelleri
// ──────────────────────────────────────────

enum SmartAlertType {
  absenceRisk,
  lowGrade,
  heavyWeek,
  overdue,
}

enum AlertSeverity {
  low,
  medium,
  high,
}

class SmartAlert {
  final SmartAlertType type;
  final AlertSeverity severity;
  final String title;
  final String message;
  final String icon;
  final List<String> relatedCourses;

  const SmartAlert({
    required this.type,
    required this.severity,
    required this.title,
    required this.message,
    required this.icon,
    required this.relatedCourses,
  });
}
