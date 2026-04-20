import 'dart:async';
import 'package:flutter/foundation.dart';
import '../../models/moodle/moodle_account.dart';
import '../../models/moodle/moodle_announcement.dart';
import '../../models/moodle/moodle_assignment.dart';
import '../../models/moodle/moodle_calendar_event.dart';
import '../../models/moodle/moodle_course.dart';
import '../../models/moodle/moodle_grade.dart';
import '../../repositories/moodle_account_repository.dart';
import '../../repositories/moodle_cache_repository.dart';
import 'moodle_api_service.dart';
import 'moodle_token_storage.dart';

/// Bir sync sonucunu taşır
class MoodleSyncResult {
  final MoodleAccount account;
  final List<MoodleCourse> courses;
  final List<MoodleAssignment> assignments;
  final List<MoodleGrade> grades;
  final List<MoodleAnnouncement> announcements;
  final List<MoodleCalendarEvent> events;
  final String? error;

  const MoodleSyncResult({
    required this.account,
    this.courses = const [],
    this.assignments = const [],
    this.grades = const [],
    this.announcements = const [],
    this.events = const [],
    this.error,
  });

  bool get isSuccess => error == null;
}

/// Bir hesabın tüm Moodle verilerini paralel olarak çeker ve cache'e yazar.
class MoodleSyncService {
  final MoodleApiService _api = MoodleApiService();
  final MoodleTokenStorage _tokenStorage = MoodleTokenStorage();
  final MoodleAccountRepository _accountRepo = MoodleAccountRepository();
  final MoodleCacheRepository _cacheRepo = MoodleCacheRepository();

  /// Tek hesabın tüm verilerini senkronize et.
  /// Courses önce alınır çünkü diğer tüm çağrılar course listesine ihtiyaç duyar.
  /// Sonrasında assignments, grades, announcements, events paralel çekilir.
  Future<MoodleSyncResult> syncAccount(MoodleAccount account) async {
    try {
      final token = await _tokenStorage.getToken(account.id);
      if (token == null) {
        return MoodleSyncResult(
          account: account,
          error: 'Token bulunamadı — lütfen tekrar giriş yapın',
        );
      }

      // 1. Kullanıcı ID'si için site bilgisi
      final siteInfo = await _api.getSiteInfo(
        baseUrl: account.baseUrl,
        token: token,
      );
      final userId = siteInfo['userid'] as int;

      // 2. Dersler (diğerleri buna bağımlı)
      final courses = await _api.getEnrolledCourses(
        account: account,
        token: token,
        userId: userId,
      );
      await _cacheRepo.write(
        accountId: account.id,
        dataType: 'courses',
        payload: courses
            .map((c) => {
                  'id': c.id,
                  'accountId': c.accountId,
                  'shortName': c.shortName,
                  'fullName': c.fullName,
                  'summary': c.summary,
                  'categoryName': c.categoryName,
                  'courseImageUrl': c.courseImageUrl,
                  'startDate': c.startDate?.toIso8601String(),
                  'endDate': c.endDate?.toIso8601String(),
                  'progress': c.progress,
                  'isFavorite': c.isFavorite,
                })
            .toList(),
      );

      // 3. Paralel çekim
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
        _api.getCalendarEvents(
          account: account,
          token: token,
          courses: courses,
        ),
      ]);

      final assignments = results[0] as List<MoodleAssignment>;
      final grades = results[1] as List<MoodleGrade>;
      final announcements = results[2] as List<MoodleAnnouncement>;
      final events = results[3] as List<MoodleCalendarEvent>;

      // 4. Cache'e yaz
      await Future.wait([
        _cacheRepo.write(
          accountId: account.id,
          dataType: 'assignments',
          payload: assignments
              .map((a) => {
                    'id': a.id,
                    'accountId': a.accountId,
                    'courseId': a.courseId,
                    'courseName': a.courseName,
                    'name': a.name,
                    'description': a.description,
                    'dueDate': a.dueDate.toIso8601String(),
                    'submitted': a.submitted,
                    'grade': a.grade,
                    'maxGrade': a.maxGrade,
                  })
              .toList(),
        ),
        _cacheRepo.write(
          accountId: account.id,
          dataType: 'grades',
          payload: grades
              .map((g) => {
                    'accountId': g.accountId,
                    'courseId': g.courseId,
                    'courseName': g.courseName,
                    'itemName': g.itemName,
                    'gradeValue': g.gradeValue,
                    'gradeMax': g.gradeMax,
                    'percentage': g.percentage,
                    'letterGrade': g.letterGrade,
                  })
              .toList(),
        ),
        _cacheRepo.write(
          accountId: account.id,
          dataType: 'announcements',
          payload: announcements
              .map((a) => {
                    'id': a.id,
                    'accountId': a.accountId,
                    'courseId': a.courseId,
                    'courseName': a.courseName,
                    'subject': a.subject,
                    'message': a.message,
                    'authorName': a.authorName,
                    'created': a.created.toIso8601String(),
                    'isRead': a.isRead,
                  })
              .toList(),
        ),
        _cacheRepo.write(
          accountId: account.id,
          dataType: 'events',
          payload: events
              .map((e) => {
                    'id': e.id,
                    'accountId': e.accountId,
                    'name': e.name,
                    'description': e.description,
                    'timeStart': e.timeStart.toIso8601String(),
                    'durationSeconds': e.durationSeconds,
                    'eventType': e.eventType,
                    'courseId': e.courseId,
                    'courseName': e.courseName,
                    'eventUrl': e.eventUrl,
                  })
              .toList(),
        ),
      ]);

      // 5. lastSynced güncelle
      final updated = account.copyWith(lastSynced: DateTime.now());
      await _accountRepo.update(updated);

      return MoodleSyncResult(
        account: updated,
        courses: courses,
        assignments: assignments,
        grades: grades,
        announcements: announcements,
        events: events,
      );
    } catch (e) {
      debugPrint('[MoodleSyncService] Sync failed for ${account.siteTitle}: $e');
      
      // Hata durumunda cache'den yükle (offline-first)
      return _loadFromCache(account, e.toString());
    }
  }

  /// Cache'den yükle — sync başarısız olduğunda fallback
  Future<MoodleSyncResult> _loadFromCache(
    MoodleAccount account,
    String error,
  ) async {
    try {
      final cachedCourses = await _cacheRepo.read(
        accountId: account.id,
        dataType: 'courses',
        ignoreExpiry: true,
      );

      if (cachedCourses == null) {
        return MoodleSyncResult(account: account, error: error);
      }

      final courses = (cachedCourses as List)
          .map((c) => MoodleCourse(
                id: c['id'] as int,
                accountId: c['accountId'] as String,
                shortName: c['shortName'] as String,
                fullName: c['fullName'] as String,
                summary: c['summary'] as String?,
                categoryName: c['categoryName'] as String?,
                courseImageUrl: c['courseImageUrl'] as String?,
                startDate: c['startDate'] != null
                    ? DateTime.parse(c['startDate'] as String)
                    : null,
                endDate: c['endDate'] != null
                    ? DateTime.parse(c['endDate'] as String)
                    : null,
                progress: c['progress'] as int? ?? 0,
              ))
          .toList();

      return MoodleSyncResult(
        account: account,
        courses: courses,
        error: error, // Hata mesajını taşı ama cache verisi göster
      );
    } catch (cacheError) {
      debugPrint('[MoodleSyncService] Cache load failed: $cacheError');
      return MoodleSyncResult(account: account, error: error);
    }
  }
}
