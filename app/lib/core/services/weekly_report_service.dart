import 'package:flutter/foundation.dart';
import '../../repositories/study_session_repository.dart';
import '../../repositories/course_repository.dart';
import '../../repositories/absence_repository.dart';
import 'notification_service.dart';

/// Haftalık rapor verileri toplayıp bildirim gönderen servis
class WeeklyReportService {
  static final WeeklyReportService _instance = WeeklyReportService._internal();
  factory WeeklyReportService() => _instance;
  WeeklyReportService._internal();

  final StudySessionRepository _sessionRepo = StudySessionRepository();
  final CourseRepository _courseRepo = CourseRepository();
  final AbsenceRepository _absenceRepo = AbsenceRepository();

  /// Haftalık rapor verilerini topla ve bildirim gönder
  /// Bu metod Pazar günü uygulama açıldığında veya background'da çağrılır
  Future<void> checkAndSendReport() async {
    final now = DateTime.now();

    // Sadece Pazar günü gönder (veya test için her gün)
    // if (now.weekday != DateTime.sunday) return;

    try {
      // 1. Bu haftanın çalışma verileri
      final weekStart = DateTime(now.year, now.month, now.day)
          .subtract(Duration(days: now.weekday)); // Pazartesi
      final sessions = await _sessionRepo.getStudySessionsBetween(weekStart, now);
      final workSessions = sessions.where((s) => s.sessionType == 'work').toList();
      final totalMinutes = workSessions.fold<int>(0, (sum, s) => sum + s.durationMinutes);

      // 2. Devamsızlık verileri
      final courses = await _courseRepo.getAllCourses();
      int totalWeekAbsences = 0;
      int coursesAtRisk = 0;
      final List<String> riskyCourseNames = [];

      for (final course in courses) {
         final absences = await _absenceRepo.getAbsencesByCourse(course.id);
        
        // Bu haftaki devamsızlıklar
        final weekAbsences = absences.where((date) =>
            date.isAfter(weekStart.subtract(const Duration(days: 1))) &&
            date.isBefore(now.add(const Duration(days: 1)))).length;
        totalWeekAbsences += weekAbsences;

        // Limit riski kontrolü (%80+ dolmuş)
        final totalAbsenceCount = absences.length;
        final limit = course.absenceLimit;
        if (limit > 0 && totalAbsenceCount >= (limit * 0.8)) {
          coursesAtRisk++;
          riskyCourseNames.add('${course.name} ($totalAbsenceCount/$limit)');
        }
      }

      // 3. Bildirimi gönder
      await NotificationService().sendWeeklyReportNow(
        totalStudyMinutes: totalMinutes,
        sessionCount: workSessions.length,
        totalAbsences: totalWeekAbsences,
        coursesAtRisk: coursesAtRisk,
        riskyCourseNames: riskyCourseNames,
      );

      debugPrint('WeeklyReportService: Report sent — '
          'Study: ${totalMinutes}m, '
          'Absences: $totalWeekAbsences, '
          'At risk: $coursesAtRisk');
    } catch (e) {
      debugPrint('WeeklyReportService: Error: $e');
    }
  }
}
