import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:workmanager/workmanager.dart';
import 'package:flutter/material.dart' show debugPrint;
import 'package:flutter/foundation.dart' show kIsWeb;

import '../../models/course.dart';
import '../../repositories/course_repository.dart';
import '../../repositories/absence_repository.dart';
import '../utils/absence_change_bus.dart';
import 'location_service.dart';

class AttendanceAutomationService {
  static final AttendanceAutomationService _instance =
      AttendanceAutomationService._internal();

  factory AttendanceAutomationService() => _instance;

  AttendanceAutomationService._internal();

  static const String taskName = 'attendance_check_task';
  static const String _prefLastCheckKeyPrefix = 'last_attendance_check_';

  // ──────────────────────────────────────────────
  // Workmanager Kaydı — Ayarlardan akıllı yoklama
  // açıldığında çağrılır.
  // ──────────────────────────────────────────────
  static Future<void> registerPeriodicTask() async {
    if (kIsWeb) return;
    await Workmanager().registerPeriodicTask(
      'smart_attendance_periodic',
      taskName,
      frequency: const Duration(minutes: 15),
      constraints: Constraints(networkType: NetworkType.notRequired),
      existingWorkPolicy: ExistingPeriodicWorkPolicy.update,
    );
    debugPrint('SmartAttendance: Periodic task registered.');
  }

  static Future<void> cancelPeriodicTask() async {
    if (kIsWeb) return;
    await Workmanager().cancelByUniqueName('smart_attendance_periodic');
    debugPrint('SmartAttendance: Periodic task cancelled.');
  }

  // ──────────────────────────────────────────────
  // Arka Plan Görevi — Workmanager tarafından
  // çağrılır (callbackDispatcher → executeTask)
  // ──────────────────────────────────────────────
  Future<void> executeBackgroundCheck() async {
    if (kIsWeb) return;
    try {
      // 1. Akıllı Yoklama açık mı?
      final prefs = await SharedPreferences.getInstance();
      final isEnabled = prefs.getBool('smart_attendance_enabled') ?? false;
      if (!isEnabled) return;

      // 2. Üniversite konumu ayarlı mı?
      final locationService = LocationService();
      final uniLoc = await locationService.getUniversityLocation();
      if (uniLoc == null) return;

      // 3. Bugünün derslerini getir
      final courseRepo = CourseRepository();
      final todayCourses = await courseRepo.getTodayCourses();
      if (todayCourses.isEmpty) return;

      final now = DateTime.now();
      final todayStr = '${now.year}-${now.month}-${now.day}';

      // Batch-load absences so we don't run N queries inside the loop.
      final absenceRepo = AbsenceRepository();
      final allAbsences = await absenceRepo.getAllAbsences();

      for (final course in todayCourses) {
        // 4. Ders şu an mı?
        if (!_isTimeWithinClass(course, now)) continue;

        // 5. Bugün bu ders için zaten işlem yapıldı mı?
        final checkKey = '$_prefLastCheckKeyPrefix${course.id}_$todayStr';
        if (prefs.getBool(checkKey) == true) continue;

        // 6. Kullanıcı üniversite kampüsünde mi?
        final isAtUni = await locationService.isAtUniversity();

        if (isAtUni) {
          // 7a. Kampüsteyse - DEVAMSIZLIK EKLEME (yoklama var)
          await prefs.setBool(checkKey, true);
          await _showAttendanceNotification(course.name);
          debugPrint(
            'SmartAttendance: ${course.name} — kampüste, devamsızlık eklenmedi.',
          );
        } else {
          // 7b. Kampüste DEĞİLSE - DEVAMSIZLIK EKLE
          final date = DateTime(now.year, now.month, now.day);
          final existingAbsences = allAbsences[course.id] ?? const <DateTime>[];
          final alreadyAbsent = existingAbsences.any(
            (a) =>
                a.year == date.year &&
                a.month == date.month &&
                a.day == date.day,
          );

          if (!alreadyAbsent) {
            // Check absence limit before adding
            if (course.absenceLimit > 0 &&
                existingAbsences.length >= course.absenceLimit) {
              debugPrint(
                'SmartAttendance: ${course.name} — absence limit reached, marking at risk.',
              );
              await prefs.setBool(checkKey, true);
              await _showAbsenceLimitWarningNotification(course.name, course.absenceLimit);
            } else {
              await absenceRepo.insertAbsence(
                '${course.id}_${date.toIso8601String().split('T')[0]}',
                course.id,
                date,
              );
              AbsenceChangeBus.instance.fire(course.id);
              await prefs.setBool(checkKey, true);
              await _showAbsenceNotification(course.name);
              debugPrint(
                'SmartAttendance: ${course.name} — kampüste değil, devamsızlık eklendi.',
              );
            }
          }
        }
      }
    } catch (e) {
      debugPrint('AttendanceAutomation Error: $e');
    }
  }

  // ──────────────────────────────────────────────
  // Ders saati kontrolü — 15dk öncesinden
  // bitiş saatine kadar
  // ──────────────────────────────────────────────
  bool _isTimeWithinClass(Course course, DateTime now) {
    final startMinutes = course.startTime.hour * 60 + course.startTime.minute;
    final endMinutes = course.endTime.hour * 60 + course.endTime.minute;
    final nowMinutes = now.hour * 60 + now.minute;

    return nowMinutes >= (startMinutes - 15) && nowMinutes <= endMinutes;
  }

  // ──────────────────────────────────────────────
  // Bildirim
  // ──────────────────────────────────────────────
  Future<void> _showSmartAttendanceNotification({
    required String courseName,
    required String idSuffix,
    required String title,
    required String body,
  }) async {
    const details = NotificationDetails(
      android: AndroidNotificationDetails(
        'smart_attendance_channel',
        'Akıllı Yoklama',
        channelDescription: 'Otomatik yoklama bildirimleri',
        importance: Importance.high,
        priority: Priority.high,
      ),
      iOS: DarwinNotificationDetails(),
    );

    final notifId = '$courseName$idSuffix${DateTime.now().day}'.hashCode;

    await FlutterLocalNotificationsPlugin().show(notifId, title, body, details);
  }

  Future<void> _showAttendanceNotification(String courseName) {
    return _showSmartAttendanceNotification(
      courseName: courseName,
      idSuffix: '',
      title: 'Yoklama Onaylandı ✔️',
      body: '$courseName dersi için okulda olduğunuz tespit edildi. '
          'Devamsızlık girilmedi. Değiştirmek isterseniz uygulamayı açın.',
    );
  }

  Future<void> _showAbsenceNotification(String courseName) {
    return _showSmartAttendanceNotification(
      courseName: courseName,
      idSuffix: 'absence',
      title: 'Devamsızlık Eklendi ⚠️',
      body: '$courseName dersi için okulda olmadığınız tespit edildi. '
          'Devamsızlık kaydı oluşturuldu. Değiştirmek isterseniz uygulamayı açın.',
    );
  }

  Future<void> _showAbsenceLimitWarningNotification(
    String courseName,
    int limit,
  ) {
    return _showSmartAttendanceNotification(
      courseName: courseName,
      idSuffix: 'risk',
      title: '⚠️ Devamsızlık Riski!',
      body: '$courseName dersi için devamsızlık limiti ($limit) aşılmak üzere! '
          'Bu dersi kaçırmamanız önemli.',
    );
  }
}
