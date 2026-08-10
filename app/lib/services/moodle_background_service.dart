import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:workmanager/workmanager.dart';

import '../../models/moodle/moodle_account.dart';
import '../../models/moodle/moodle_announcement.dart';
import '../../models/moodle/moodle_assignment.dart';
import '../../models/moodle/moodle_grade.dart';
import '../../repositories/moodle_account_repository.dart';
import '../../repositories/moodle_cache_repository.dart';
import '../../services/moodle/moodle_api_service.dart';
import '../../services/moodle/moodle_sync_service.dart';
import '../../services/moodle/moodle_token_storage.dart';
import 'moodle_notification_service.dart';
import '../../core/utils/moodle_utils.dart';

/// Moodle arka plan senkronizasyon servisi.
///
/// Workmanager üzerinden periyodik olarak çalışır.
/// Yeni ödev, not ve duyurular tespit edildiğinde bildirim gönderir.
/// Yaklaşan deadline'lar için kademeli uyarılar oluşturur.
class MoodleBackgroundService {
  static const String taskName = 'moodle_sync_task';
  static const String _prefKeyEnabled = 'moodle_bg_sync_enabled';
  static const String _prefKeySentAssignments = 'moodle_notified_assignment_ids';
  static const String _prefKeySentGrades = 'moodle_notified_grade_keys';
  static const String _prefKeySentAnnouncements = 'moodle_notified_announcement_ids';
  static const String _prefKeyDeadlineAlerts = 'moodle_deadline_alerts_sent';

  final MoodleAccountRepository _accountRepo = MoodleAccountRepository();
  final MoodleTokenStorage _tokenStorage = MoodleTokenStorage();
  final MoodleApiService _api = MoodleApiService();
  final MoodleCacheRepository _cacheRepo = MoodleCacheRepository();
  final MoodleNotificationService _notifier = MoodleNotificationService();

  // ──────────────────────────────────────────
  // Workmanager Kaydı
  // ──────────────────────────────────────────

  /// Periyodik arka plan görevini kaydet (her ~1 saat)
  static Future<void> registerPeriodicSync() async {
    await Workmanager().registerPeriodicTask(
      'moodle_periodic_sync',
      taskName,
      frequency: const Duration(hours: 1),
      constraints: Constraints(
        networkType: NetworkType.connected, // İnternet gerekli
      ),
      existingWorkPolicy: ExistingPeriodicWorkPolicy.update,
    );
    debugPrint('[MoodleBG] Periodic sync task registered (1h interval)');
  }

  /// Periyodik görevi iptal et
  static Future<void> cancelPeriodicSync() async {
    await Workmanager().cancelByUniqueName('moodle_periodic_sync');
    debugPrint('[MoodleBG] Periodic sync task cancelled');
  }

  /// Özellik aktif mi?
  static Future<bool> isEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_prefKeyEnabled) ?? false;
  }

  /// Özelliği aç/kapat
  static Future<void> setEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_prefKeyEnabled, enabled);
    if (enabled) {
      await registerPeriodicSync();
    } else {
      await cancelPeriodicSync();
    }
  }

  // ──────────────────────────────────────────
  // Arka Plan Görevi — Ana Mantık
  // ──────────────────────────────────────────

  /// Workmanager tarafından çağrılır.
  /// Tüm kayıtlı hesapları sync eder, yeni veriler varsa bildirim atar.
  Future<void> executeBackgroundSync() async {
    debugPrint('[MoodleBG] Background sync started');

    try {
      // 1. Özellik aktif mi kontrol et
      final enabled = await isEnabled();
      if (!enabled) {
        debugPrint('[MoodleBG] Sync disabled, skipping');
        return;
      }

      // 2. Tüm kayıtlı hesapları al
      final accounts = await _accountRepo.getAll();
      if (accounts.isEmpty) {
        debugPrint('[MoodleBG] No accounts, skipping');
        return;
      }

      int totalNewAssignments = 0;
      int totalNewGrades = 0;
      int totalNewAnnouncements = 0;

      // 3. Her hesap için sync + karşılaştırma
      for (final account in accounts) {
        final result = await _syncAndCompare(account);
        totalNewAssignments += result.newAssignments;
        totalNewGrades += result.newGrades;
        totalNewAnnouncements += result.newAnnouncements;
      }

      // 4. Deadline uyarılarını kontrol et
      await _checkDeadlineAlerts();

      debugPrint('[MoodleBG] Sync completed — '
          '$totalNewAssignments new assignments, '
          '$totalNewGrades new grades, '
          '$totalNewAnnouncements new announcements');
    } catch (e) {
      debugPrint('[MoodleBG] Background sync error: $e');
    }
  }

  // ──────────────────────────────────────────
  // Sync + Karşılaştırma
  // ──────────────────────────────────────────

  Future<_SyncDiff> _syncAndCompare(MoodleAccount account) async {
    final prefs = await SharedPreferences.getInstance();
    final langCode = prefs.getString('language_code') ?? 'tr';
    int newAssignments = 0;
    int newGrades = 0;
    int newAnnouncements = 0;

    try {
      final token = await _tokenStorage.getToken(account.id);
      if (token == null) return _SyncDiff.empty;

      // Site bilgisi ve userId
      final siteInfo = await _api.getSiteInfo(
        baseUrl: account.baseUrl,
        token: token,
      );
      final userId = siteInfo['userid'] as int;

      // Dersler
      final courses = await _api.getEnrolledCourses(
        account: account,
        token: token,
        userId: userId,
      );

      // Paralel veri çekimi
      final results = await Future.wait([
        _api.getAssignments(account: account, token: token, courses: courses),
        _api.getGrades(
          account: account,
          token: token,
          userId: userId,
          courses: courses,
        ),
        _api.getAnnouncements(
          account: account,
          token: token,
          courses: courses,
        ),
      ]);

      final assignments = results[0] as List<MoodleAssignment>;
      final grades = results[1] as List<MoodleGrade>;
      final announcements = results[2] as List<MoodleAnnouncement>;

      // ── Yeni Ödevleri Tespit Et ──
      final sentAssignmentIds = _getStringSet(prefs, _prefKeySentAssignments);
      for (final assignment in assignments) {
        final key = '${account.id}_${assignment.id}';
        if (!sentAssignmentIds.contains(key)) {
          await _notifier.notifyNewAssignment(
            assignmentId: assignment.id,
            courseName: MoodleUtils.parseMultilang(assignment.courseName, langCode),
            assignmentName: MoodleUtils.parseMultilang(assignment.name, langCode),
            dueDate: assignment.dueDate,
          );
          sentAssignmentIds.add(key);
          newAssignments++;
        }
      }
      await prefs.setStringList(
          _prefKeySentAssignments, sentAssignmentIds.toList());

      // ── Yeni/Güncellenen Notları Tespit Et ──
      final sentGradeKeys = _getStringSet(prefs, _prefKeySentGrades);
      for (final grade in grades) {
        if (grade.gradeValue == null) continue; // Not girilmemiş
        final key =
            '${account.id}_${grade.courseId}_${grade.itemName}_${grade.gradeValue}';
        if (!sentGradeKeys.contains(key)) {
          await _notifier.notifyGradeUpdate(
            courseName: MoodleUtils.parseMultilang(grade.courseName, langCode),
            itemName: MoodleUtils.parseMultilang(grade.itemName, langCode),
            grade: grade.gradeValue,
            maxGrade: grade.gradeMax,
          );
          sentGradeKeys.add(key);
          newGrades++;
        }
      }
      await prefs.setStringList(_prefKeySentGrades, sentGradeKeys.toList());

      // ── Yeni Duyuruları Tespit Et ──
      final sentAnnouncementIds =
          _getStringSet(prefs, _prefKeySentAnnouncements);
      for (final announcement in announcements) {
        final key = '${account.id}_${announcement.id}';
        if (!sentAnnouncementIds.contains(key)) {
          await _notifier.notifyNewAnnouncement(
            announcementId: announcement.id,
            courseName: MoodleUtils.parseMultilang(announcement.courseName, langCode),
            subject: MoodleUtils.parseMultilang(announcement.subject, langCode),
            authorName: announcement.authorName,
          );
          sentAnnouncementIds.add(key);
          newAnnouncements++;
        }
      }
      await prefs.setStringList(
          _prefKeySentAnnouncements, sentAnnouncementIds.toList());

      // ── Cache Güncelle (MoodleSyncService ile aynı mantık) ──
      final syncService = MoodleSyncService();
      await syncService.syncAccount(account);
    } catch (e) {
      debugPrint('[MoodleBG] Sync error for ${account.siteTitle}: $e');
    }

    return _SyncDiff(
      newAssignments: newAssignments,
      newGrades: newGrades,
      newAnnouncements: newAnnouncements,
    );
  }

  // ──────────────────────────────────────────
  // Deadline Uyarıları (Faz 2)
  // ──────────────────────────────────────────

  /// Yaklaşan deadline'lar için kademeli uyarı kontrol et
  Future<void> _checkDeadlineAlerts() async {
    final prefs = await SharedPreferences.getInstance();
    final langCode = prefs.getString('language_code') ?? 'tr';
    final sentAlerts = _getStringSet(prefs, _prefKeyDeadlineAlerts);

    try {
      final accounts = await _accountRepo.getAll();

      for (final account in accounts) {
        // Cache'den ödevleri oku
        final cached = await _cacheRepo.read(
          accountId: account.id,
          dataType: 'assignments',
          ignoreExpiry: true,
        );
        if (cached == null) continue;

        final assignments = (cached as List).map((a) {
          return MoodleAssignment(
            id: a['id'] as int,
            accountId: a['accountId'] as String,
            courseId: a['courseId'] as int,
            courseName: a['courseName'] as String,
            name: a['name'] as String,
            description: a['description'] as String?,
            dueDate: DateTime.parse(a['dueDate'] as String),
            submitted: a['submitted'] as bool? ?? false,
          );
        }).toList();

        final now = DateTime.now();

        for (final assignment in assignments) {
          if (assignment.submitted) continue;
          if (assignment.dueDate.isBefore(now)) continue;

          final hoursLeft = assignment.dueDate.difference(now).inHours;

          // Kademeli uyarılar: 168h (7 gün), 24h, 3h
          for (final threshold in [168, 24, 3]) {
            if (hoursLeft <= threshold) {
              final alertKey =
                  '${account.id}_${assignment.id}_${threshold}h';
              if (!sentAlerts.contains(alertKey)) {
                await _notifier.notifyDeadlineApproaching(
                  assignmentId: assignment.id,
                  courseName: MoodleUtils.parseMultilang(assignment.courseName, langCode),
                  assignmentName: MoodleUtils.parseMultilang(assignment.name, langCode),
                  hoursRemaining: hoursLeft,
                );
                sentAlerts.add(alertKey);
              }
            }
          }
        }
      }

      await prefs.setStringList(_prefKeyDeadlineAlerts, sentAlerts.toList());
    } catch (e) {
      debugPrint('[MoodleBG] Deadline alert check error: $e');
    }
  }

  // ──────────────────────────────────────────
  // Yardımcı
  // ──────────────────────────────────────────

  Set<String> _getStringSet(SharedPreferences prefs, String key) {
    return (prefs.getStringList(key) ?? []).toSet();
  }
}

/// Internal sync karşılaştırma sonucu
class _SyncDiff {
  final int newAssignments;
  final int newGrades;
  final int newAnnouncements;

  const _SyncDiff({
    required this.newAssignments,
    required this.newGrades,
    required this.newAnnouncements,
  });

  static const empty = _SyncDiff(
    newAssignments: 0,
    newGrades: 0,
    newAnnouncements: 0,
  );
}
