import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:workmanager/workmanager.dart';
import 'package:flutter/foundation.dart' show debugPrint, kIsWeb, visibleForTesting;

import '../../models/course.dart';
import '../../repositories/course_repository.dart';
import '../../repositories/absence_repository.dart';
import '../../core/utils/absence_change_bus.dart';
import 'location_service.dart';

/// (dersAdı, idSoneki, başlık, gövde) — testlerde bildirim yerine sahte.
typedef AttendanceNotifier = Future<void> Function(
  String courseName,
  String idSuffix,
  String title,
  String body,
);

class AttendanceAutomationService {
  static final AttendanceAutomationService _instance =
      AttendanceAutomationService._internal();

  factory AttendanceAutomationService() => _instance;

  AttendanceAutomationService._internal({
    LocationService? location,
    CourseRepository? courseRepo,
    AbsenceRepository? absenceRepo,
    DateTime Function()? now,
    AttendanceNotifier? notify,
  })  : _location = location ?? LocationService(),
        _courseRepo = courseRepo ?? CourseRepository(),
        _absenceRepo = absenceRepo ?? AbsenceRepository(),
        _now = now ?? DateTime.now,
        _notify = notify ?? _showSmartAttendanceNotification;

  /// Testler için bağımlılıkları değiştirilmiş örnek.
  @visibleForTesting
  factory AttendanceAutomationService.forTesting({
    LocationService? location,
    CourseRepository? courseRepo,
    AbsenceRepository? absenceRepo,
    DateTime Function()? now,
    AttendanceNotifier? notify,
  }) =>
      AttendanceAutomationService._internal(
        location: location,
        courseRepo: courseRepo,
        absenceRepo: absenceRepo,
        now: now,
        notify: notify,
      );

  final LocationService _location;
  final CourseRepository _courseRepo;
  final AbsenceRepository _absenceRepo;
  final DateTime Function() _now;
  final AttendanceNotifier _notify;

  static const String taskName = 'attendance_check_task';
  static const String _prefLastCheckKeyPrefix = 'last_attendance_check_';
  static const String _prefLocationUnknownKeyPrefix =
      'attendance_location_unknown_';

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
      final uniLoc = await _location.getUniversityLocation();
      if (uniLoc == null) return;

      // 3. Bugünün derslerini getir
      final todayCourses = await _courseRepo.getTodayCourses();
      if (todayCourses.isEmpty) return;

      final now = _now();
      final todayStr = '${now.year}-${now.month}-${now.day}';

      // Batch-load absences so we don't run N queries inside the loop.
      final allAbsences = await _absenceRepo.getAllAbsences();

      // Konum en fazla bir kez okunur (aynı anda birden çok ders olabilir).
      bool? isAtUni;
      var locationRead = false;

      for (final course in todayCourses) {
        // 4. Ders şu an mı?
        if (!_isTimeWithinClass(course, now)) continue;

        // 5. Bugün bu ders için zaten işlem yapıldı mı?
        final checkKey = '$_prefLastCheckKeyPrefix${course.id}_$todayStr';
        if (prefs.getBool(checkKey) == true) continue;

        // 6. Kullanıcı üniversite kampüsünde mi?
        if (!locationRead) {
          isAtUni = await _location.isAtUniversity();
          locationRead = true;
        }

        if (isAtUni == null) {
          // 7. Konum bilinmiyor — devamsızlık EKLEME (B9). checkKey yazılmaz;
          // 15 dk sonra tekrar denenir. Ders bitmek üzereyse kullanıcıya bir
          // kez haber ver.
          final unknownKey = '$_prefLocationUnknownKeyPrefix${course.id}_$todayStr';
          if (_isNearClassEnd(course, now) && prefs.getBool(unknownKey) != true) {
            await prefs.setBool(unknownKey, true);
            await _notify(
              course.name,
              'location',
              'Konum Alınamadı 📍',
              '${course.name} dersi için konumunuz alınamadı; devamsızlık '
                  'girilmedi. Yoklamayı uygulamadan kontrol edin.',
            );
          }
          debugPrint(
            'SmartAttendance: ${course.name} — konum bilinmiyor, işlem yapılmadı.',
          );
          continue;
        }

        if (isAtUni) {
          // 8a. Kampüsteyse - DEVAMSIZLIK EKLEME (yoklama var)
          await prefs.setBool(checkKey, true);
          await _notify(
            course.name,
            '',
            'Yoklama Onaylandı ✔️',
            '${course.name} dersi için okulda olduğunuz tespit edildi. '
                'Devamsızlık girilmedi. Değiştirmek isterseniz uygulamayı açın.',
          );
          debugPrint(
            'SmartAttendance: ${course.name} — kampüste, devamsızlık eklenmedi.',
          );
          continue;
        }

        // 8b. Kampüste DEĞİLSE - DEVAMSIZLIK EKLE
        final date = DateTime(now.year, now.month, now.day);
        final existingAbsences = allAbsences[course.id] ?? const <DateTime>[];
        final alreadyAbsent = existingAbsences.any(
          (a) =>
              a.year == date.year && a.month == date.month && a.day == date.day,
        );
        if (alreadyAbsent) continue;

        if (course.absenceLimit > 0 &&
            existingAbsences.length >= course.absenceLimit) {
          debugPrint(
            'SmartAttendance: ${course.name} — absence limit reached, marking at risk.',
          );
          await prefs.setBool(checkKey, true);
          await _notify(
            course.name,
            'risk',
            '⚠️ Devamsızlık Riski!',
            '${course.name} dersi için devamsızlık limiti '
                '(${course.absenceLimit}) aşılmak üzere! '
                'Bu dersi kaçırmamanız önemli.',
          );
          continue;
        }

        await _absenceRepo.insertAbsence(
          '${course.id}_${date.toIso8601String().split('T')[0]}',
          course.id,
          date,
        );
        AbsenceChangeBus.instance.fire(course.id);
        await prefs.setBool(checkKey, true);
        await _notify(
          course.name,
          'absence',
          'Devamsızlık Eklendi ⚠️',
          '${course.name} dersi için okulda olmadığınız tespit edildi. '
              'Devamsızlık kaydı oluşturuldu. Değiştirmek isterseniz uygulamayı açın.',
        );
        debugPrint(
          'SmartAttendance: ${course.name} — kampüste değil, devamsızlık eklendi.',
        );
      }
    } catch (e) {
      debugPrint('AttendanceAutomation Error: $e');
    }
  }

  /// Ders bitimine 20 dakikadan az kaldı mı? (15 dk'lık periyodik görevde
  /// son çalışmayı yakalamak için)
  bool _isNearClassEnd(Course course, DateTime now) {
    final endMinutes = course.endTime.hour * 60 + course.endTime.minute;
    final nowMinutes = now.hour * 60 + now.minute;
    return endMinutes - nowMinutes <= 20;
  }

  bool _isTimeWithinClass(Course course, DateTime now) {
    final startMinutes = course.startTime.hour * 60 + course.startTime.minute;
    final endMinutes = course.endTime.hour * 60 + course.endTime.minute;
    final nowMinutes = now.hour * 60 + now.minute;

    return nowMinutes >= (startMinutes - 15) && nowMinutes <= endMinutes;
  }

  // ──────────────────────────────────────────────
  // Bildirim
  // ──────────────────────────────────────────────
  static Future<void> _showSmartAttendanceNotification(
    String courseName,
    String idSuffix,
    String title,
    String body,
  ) async {
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
}
