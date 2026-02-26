import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import 'package:flutter/foundation.dart';

class NotificationService {
  static NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  @visibleForTesting
  static set instance(NotificationService mockInstance) {
    _instance = mockInstance;
  }

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  bool _isInitialized = false;

  Future<void> init() async {
    if (_isInitialized) return;

    tz.initializeTimeZones();

    // Android Init
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    // iOS/macOS Init
    final DarwinInitializationSettings initializationSettingsDarwin =
        DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    final InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsDarwin,
      macOS: initializationSettingsDarwin,
    );

    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (details) {
        // Handle notification tap
        if (kDebugMode) {
          print('Notification payload: ${details.payload}');
        }
      },
    );

    _isInitialized = true;
  }

  Future<bool> requestPermissions() async {
    bool? granted = false;
    
    // Android 13+
    final androidImplementation = flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
    if (androidImplementation != null) {
      granted = await androidImplementation.requestNotificationsPermission();
    }

    // iOS
    final iosImplementation = flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>();
    if (iosImplementation != null) {
      await iosImplementation.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );
    }
    
    // macOS
    final macosImplementation = flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            MacOSFlutterLocalNotificationsPlugin>();
    if (macosImplementation != null) {
      await macosImplementation.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );
    }
    
    return granted ?? false;
  }

  /// Schedule a notification 1 hour before the class start time
  Future<void> scheduleClassNotification({
    required String courseId,
    required String courseName,
    required String? location,
    required int dayOfWeek, // 0 = Mon, 6 = Sun
    required int hour,
    required int minute,
  }) async {
    // Unique ID based on course and day
    final int notificationId = (courseId + dayOfWeek.toString()).hashCode;
    
    // Calculate notification time (1 hour before)
    // We want it to repeat weekly
    
    await flutterLocalNotificationsPlugin.zonedSchedule(
      notificationId,
      'Upcoming Class: $courseName',
      'Starts in 1 hour${location != null ? ' at $location' : ''}',
      _nextInstanceOfTime(dayOfWeek, hour, minute),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'class_channel',
          'Class Reminders',
          channelDescription: 'Notifications for upcoming classes',
          importance: Importance.max,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
        macOS: DarwinNotificationDetails(),
      ),

      matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    );
  }

  Future<void> cancelClassNotification(String courseId, int dayOfWeek) async {
    final int notificationId = (courseId + dayOfWeek.toString()).hashCode;
    await flutterLocalNotificationsPlugin.cancel(notificationId);
  }

  Future<void> cancelAllNotifications() async {
    await flutterLocalNotificationsPlugin.cancelAll();
  }

  /// Her Pazar 20:00'da haftalık çalışma raporu bildirimi planla
  /// Not: zonedSchedule statik mesaj kullanır. Dinamik veriler için
  /// [sendWeeklyReportNow] metodunu kullanın.
  Future<void> scheduleWeeklyReport() async {
    const int weeklyReportId = 999999;

    // Pazar = 7 (DateTime), saat 20:00
    final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
    tz.TZDateTime scheduledDate = tz.TZDateTime(tz.local, now.year, now.month, now.day, 20, 0);

    // Önce pazar gününü bul
    while (scheduledDate.weekday != DateTime.sunday) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 7));
    }

    await flutterLocalNotificationsPlugin.zonedSchedule(
      weeklyReportId,
      '📊 Weekly Study Report',
      'Tap to view your study time & attendance this week!',
      scheduledDate,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'weekly_report_channel',
          'Weekly Reports',
          channelDescription: 'Weekly study summary notifications',
          importance: Importance.defaultImportance,
          priority: Priority.defaultPriority,
          styleInformation: BigTextStyleInformation(''),
        ),
        iOS: DarwinNotificationDetails(),
        macOS: DarwinNotificationDetails(),
      ),
      matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    );

    debugPrint('NotificationService: Weekly report scheduled for Sunday 20:00');
  }

  /// DB'den veri çekip detaylı haftalık rapor bildirimi gönder
  /// Çalışma süresi + devamsızlık bilgisi içerir
  Future<void> sendWeeklyReportNow({
    required int totalStudyMinutes,
    required int sessionCount,
    required int totalAbsences,
    required int coursesAtRisk, // Devamsızlık limiti %80+ dolmuş dersler
    required List<String> riskyCourseNames,
  }) async {
    const int reportId = 999998;

    final hours = totalStudyMinutes ~/ 60;
    final mins = totalStudyMinutes % 60;

    // Rapor mesajını oluştur
    final buffer = StringBuffer();
    buffer.write('📚 Study: ${hours}h ${mins}m ($sessionCount sessions)');

    if (totalAbsences > 0) {
      buffer.write('\n⚠️ Absences this week: $totalAbsences');
    } else {
      buffer.write('\n✅ No absences this week!');
    }

    if (coursesAtRisk > 0 && riskyCourseNames.isNotEmpty) {
      buffer.write('\n🚨 At risk: ${riskyCourseNames.join(", ")}');
    }

    if (totalStudyMinutes >= 300) {
      buffer.write('\n🏆 Great job! Keep it up!');
    } else if (totalStudyMinutes >= 120) {
      buffer.write('\n💪 Good progress! You can do more!');
    } else {
      buffer.write('\n📖 Try to study more next week!');
    }

    await flutterLocalNotificationsPlugin.show(
      reportId,
      '📊 Weekly Report',
      buffer.toString(),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'weekly_report_channel',
          'Weekly Reports',
          channelDescription: 'Weekly study summary notifications',
          importance: Importance.high,
          priority: Priority.high,
          styleInformation: BigTextStyleInformation(''),
        ),
        iOS: DarwinNotificationDetails(),
        macOS: DarwinNotificationDetails(),
      ),
      payload: 'weekly_report',
    );

    debugPrint('NotificationService: Weekly report sent — ${buffer.toString()}');
  }

  tz.TZDateTime _nextInstanceOfTime(int dayOfWeek, int hour, int minute) {
    // 0 = Monday in our app model, but DateTime.monday = 1.
    // Our app: 0=Mon, 6=Sun
    // DateTime: 1=Mon, 7=Sun
    // timezone may vary, usually standard DateTime.
    
    // Map our 0-6 to DateTime 1-7
    final int targetWeekday = dayOfWeek + 1;

    final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
    

    
    // Logic to find next instance
    // We calculate "Class Time" first, then subtract 1 hour.
    
    tz.TZDateTime scheduledDate = _nextInstanceOfWeekday(targetWeekday, hour, minute, now);
    scheduledDate = scheduledDate.subtract(const Duration(hours: 1));
    
    return scheduledDate;
  }
  
  tz.TZDateTime _nextInstanceOfWeekday(int weekday, int hour, int minute, tz.TZDateTime now) {
      tz.TZDateTime scheduledDate = tz.TZDateTime(
        tz.local, 
        now.year, 
        now.month, 
        now.day, 
        hour, 
        minute
      );
      
      while (scheduledDate.weekday != weekday) {
        scheduledDate = scheduledDate.add(const Duration(days: 1));
      }
      
      if (scheduledDate.isBefore(now)) {
        scheduledDate = scheduledDate.add(const Duration(days: 7));
      }
      return scheduledDate;
  }
}
