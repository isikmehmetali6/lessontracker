import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/foundation.dart';

/// Moodle'dan gelen yeni ödev, not ve duyuru bildirimleri.
/// NotificationService altyapısını kullanır ancak Moodle'a özgü
/// kanallar ve mesaj formatları sağlar.
class MoodleNotificationService {
  static final MoodleNotificationService _instance =
      MoodleNotificationService._internal();
  factory MoodleNotificationService() => _instance;
  MoodleNotificationService._internal();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  // ────────── Bildirim Kanalları ──────────
  static const _assignmentChannel = AndroidNotificationDetails(
    'moodle_assignment_channel',
    'Moodle Ödevler',
    channelDescription: 'Yeni ödev ve ödev güncelleme bildirimleri',
    importance: Importance.high,
    priority: Priority.high,
    icon: '@mipmap/ic_launcher',
  );

  static const _gradeChannel = AndroidNotificationDetails(
    'moodle_grade_channel',
    'Moodle Notlar',
    channelDescription: 'Yeni not ve not güncelleme bildirimleri',
    importance: Importance.high,
    priority: Priority.high,
    icon: '@mipmap/ic_launcher',
  );

  static const _announcementChannel = AndroidNotificationDetails(
    'moodle_announcement_channel',
    'Moodle Duyurular',
    channelDescription: 'Yeni duyuru bildirimleri',
    importance: Importance.defaultImportance,
    priority: Priority.defaultPriority,
    icon: '@mipmap/ic_launcher',
  );

  static const _deadlineChannel = AndroidNotificationDetails(
    'moodle_deadline_channel',
    'Moodle Deadline Uyarıları',
    channelDescription: 'Ödev son teslim tarihi uyarıları',
    importance: Importance.max,
    priority: Priority.max,
    icon: '@mipmap/ic_launcher',
  );

  // ────────── Yeni Ödev Bildirimi ──────────
  Future<void> notifyNewAssignment({
    required int assignmentId,
    required String courseName,
    required String assignmentName,
    required DateTime dueDate,
  }) async {
    final id = 'moodle_assign_$assignmentId'.hashCode.abs() % 900000 + 100000;
    final dueDateStr = '${dueDate.day}.${dueDate.month}.${dueDate.year}';

    await _plugin.show(
      id,
      '📝 Yeni Ödev: $courseName',
      '$assignmentName — Son tarih: $dueDateStr',
      const NotificationDetails(
        android: _assignmentChannel,
        iOS: DarwinNotificationDetails(),
      ),
      payload: 'moodle_assignment_$assignmentId',
    );

    debugPrint('[MoodleNotification] Yeni ödev: $assignmentName ($courseName)');
  }

  // ────────── Not Güncelleme Bildirimi ──────────
  Future<void> notifyGradeUpdate({
    required String courseName,
    required String itemName,
    required double? grade,
    required double? maxGrade,
  }) async {
    final id = 'moodle_grade_${courseName}_$itemName'.hashCode.abs() % 900000 + 200000;
    final gradeStr = grade != null && maxGrade != null
        ? '${grade.toStringAsFixed(1)}/${maxGrade.toStringAsFixed(0)}'
        : 'Açıklandı';

    await _plugin.show(
      id,
      '📊 Not Açıklandı: $courseName',
      '$itemName — $gradeStr',
      const NotificationDetails(
        android: _gradeChannel,
        iOS: DarwinNotificationDetails(),
      ),
      payload: 'moodle_grade_$courseName',
    );

    debugPrint('[MoodleNotification] Not: $itemName ($courseName) → $gradeStr');
  }

  // ────────── Yeni Duyuru Bildirimi ──────────
  Future<void> notifyNewAnnouncement({
    required int announcementId,
    required String courseName,
    required String subject,
    required String authorName,
  }) async {
    final id = 'moodle_announce_$announcementId'.hashCode.abs() % 900000 + 300000;

    await _plugin.show(
      id,
      '📢 $courseName',
      '$authorName: $subject',
      const NotificationDetails(
        android: _announcementChannel,
        iOS: DarwinNotificationDetails(),
      ),
      payload: 'moodle_announcement_$announcementId',
    );

    debugPrint('[MoodleNotification] Duyuru: $subject ($courseName)');
  }

  // ────────── Deadline Uyarısı ──────────
  Future<void> notifyDeadlineApproaching({
    required int assignmentId,
    required String courseName,
    required String assignmentName,
    required int hoursRemaining,
  }) async {
    final id = 'moodle_deadline_${assignmentId}_$hoursRemaining'.hashCode.abs() % 900000 + 400000;

    String urgency;
    if (hoursRemaining <= 3) {
      urgency = '🚨 Son $hoursRemaining saat!';
    } else if (hoursRemaining <= 24) {
      urgency = '⚠️ Son $hoursRemaining saat kaldı';
    } else {
      final days = hoursRemaining ~/ 24;
      urgency = '⏰ $days gün kaldı';
    }

    await _plugin.show(
      id,
      '$urgency — $courseName',
      'Ödev: $assignmentName',
      const NotificationDetails(
        android: _deadlineChannel,
        iOS: DarwinNotificationDetails(),
      ),
      payload: 'moodle_deadline_$assignmentId',
    );

    debugPrint('[MoodleNotification] Deadline: $assignmentName → $hoursRemaining saat');
  }

  // ────────── Toplu Özet Bildirimi ──────────
  Future<void> notifySyncSummary({
    required int newAssignments,
    required int newGrades,
    required int newAnnouncements,
  }) async {
    if (newAssignments == 0 && newGrades == 0 && newAnnouncements == 0) return;

    final parts = <String>[];
    if (newAssignments > 0) parts.add('$newAssignments yeni ödev');
    if (newGrades > 0) parts.add('$newGrades yeni not');
    if (newAnnouncements > 0) parts.add('$newAnnouncements yeni duyuru');

    final id = DateTime.now().millisecondsSinceEpoch % 900000 + 500000;

    await _plugin.show(
      id,
      '🎓 Moodle Güncelleme',
      parts.join(' · '),
      const NotificationDetails(
        android: _assignmentChannel,
        iOS: DarwinNotificationDetails(),
      ),
      payload: 'moodle_sync_summary',
    );
  }
}
