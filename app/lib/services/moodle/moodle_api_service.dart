import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../../models/moodle/moodle_account.dart';
import '../../models/moodle/moodle_announcement.dart';
import '../../models/moodle/moodle_assignment.dart';
import '../../models/moodle/moodle_calendar_event.dart';
import '../../models/moodle/moodle_course.dart';
import '../../models/moodle/moodle_course_content.dart';
import '../../models/moodle/moodle_grade.dart';
import '../../models/moodle/moodle_message.dart';

// ==================== İSTİSNALAR ====================

class MoodleAuthException implements Exception {
  final String message;
  const MoodleAuthException(this.message);
  @override
  String toString() => 'MoodleAuthException: $message';
}

class MoodleNetworkException implements Exception {
  final String message;
  const MoodleNetworkException(this.message);
  @override
  String toString() => 'MoodleNetworkException: $message';
}

class MoodleServiceException implements Exception {
  final String message;
  const MoodleServiceException(this.message);
  @override
  String toString() => 'MoodleServiceException: $message';
}

// ==================== API SERVİSİ ====================

/// Moodle REST API ile tüm iletişimi yöneten servis.
/// Tüm üniversiteler aynı endpoint yapısını kullanır; yalnızca baseUrl değişir.
class MoodleApiService {
  static const _timeout = Duration(seconds: 30);
  static const _tokenService = 'moodle_mobile_app';

  // ===== TOKEN ALMA =====

  /// Kullanıcı adı + şifre ile Moodle token'ı al.
  /// Başarılıysa token string döner.
  /// Şifre bu sınıfın dışına çıkmaz — yalnızca bu tek çağrıda kullanılır.
  Future<String> login({
    required String baseUrl,
    required String username,
    required String password,
  }) async {
    final uri = _buildLoginUri(baseUrl);

    try {
      final response = await http
          .post(
            uri,
            headers: {'Content-Type': 'application/x-www-form-urlencoded'},
            body: 'username=${Uri.encodeComponent(username)}&password=${Uri.encodeComponent(password)}&service=$_tokenService',
          )
          .timeout(_timeout);
      final body = _parseResponse(response);

      if (body.containsKey('error')) {
        throw MoodleAuthException(
          body['error'] as String? ?? 'Geçersiz kullanıcı adı veya şifre',
        );
      }

      final token = body['token'] as String?;
      if (token == null || token.isEmpty) {
        throw MoodleAuthException(
          'Token alınamadı — lütfen bilgilerinizi kontrol edin',
        );
      }

      return token;
    } on MoodleAuthException {
      rethrow;
    } on MoodleNetworkException {
      rethrow;
    } catch (e) {
      debugPrint('[MoodleApiService.login] Error: $e');
      throw MoodleNetworkException(
        'Moodle sunucusuna bağlanılamadı. İnternet bağlantınızı kontrol edin.',
      );
    }
  }

  // ===== SITE BİLGİSİ =====

  /// Giriş yapılan kullanıcının profil bilgilerini ve site adını döner.
  Future<Map<String, dynamic>> getSiteInfo({
    required String baseUrl,
    required String token,
  }) async {
    final data = await _call(
      baseUrl: baseUrl,
      token: token,
      function: 'core_webservice_get_site_info',
    );
    return data as Map<String, dynamic>;
  }

  // ===== DERSLER =====

  /// Kullanıcının kayıtlı olduğu dersleri döner.
  Future<List<MoodleCourse>> getEnrolledCourses({
    required MoodleAccount account,
    required String token,
    required int userId,
  }) async {
    final data = await _call(
      baseUrl: account.baseUrl,
      token: token,
      function: 'core_enrol_get_users_courses',
      params: {'userid': userId.toString()},
    );

    final list = data as List<dynamic>? ?? [];
    return list
        .map(
          (e) =>
              MoodleCourse.fromApiJson(e as Map<String, dynamic>, account.id),
        )
        .toList();
  }

  // ===== DERS İÇERİĞİ (PDF, SLAYT, DOSYALAR) =====

  /// Bir dersin tüm bölümlerini ve içindeki modülleri (dosyalar, URL'ler, quizler) döner.
  Future<List<MoodleCourseSection>> getCourseContents({
    required String baseUrl,
    required String token,
    required int courseId,
  }) async {
    final data = await _call(
      baseUrl: baseUrl,
      token: token,
      function: 'core_course_get_contents',
      params: {'courseid': courseId.toString()},
    );

    final list = data as List<dynamic>? ?? [];
    return list
        .map((s) => MoodleCourseSection.fromApiJson(s as Map<String, dynamic>))
        .toList();
  }

  // ===== ÖDEVLER =====

  /// Verilen ders listesi için tüm ödevleri döner.
  Future<List<MoodleAssignment>> getAssignments({
    required MoodleAccount account,
    required String token,
    required List<MoodleCourse> courses,
  }) async {
    if (courses.isEmpty) return [];

    final courseIds = courses.map((c) => c.id.toString()).join(',');

    try {
      final data = await _call(
        baseUrl: account.baseUrl,
        token: token,
        function: 'mod_assign_get_assignments',
        params: {'courseids[0]': courseIds},
      );

      final assignments = <MoodleAssignment>[];
      final courseMap = {for (final c in courses) c.id: c};

      final coursesJson =
          (data as Map<String, dynamic>)['courses'] as List<dynamic>? ?? [];

      for (final courseJson in coursesJson) {
        final courseData = courseJson as Map<String, dynamic>;
        final courseId = courseData['id'] as int;
        final course = courseMap[courseId];
        if (course == null) continue;

        final assignList = courseData['assignments'] as List<dynamic>? ?? [];
        for (final a in assignList) {
          assignments.add(
            MoodleAssignment.fromApiJson(
              a as Map<String, dynamic>,
              account.id,
              courseId,
              course.fullName,
            ),
          );
        }
      }

      return assignments;
    } catch (e) {
      debugPrint('[MoodleApiService.getAssignments] Error: $e');
      return []; // Ödevler isteğe bağlı — hata olsa da devam et
    }
  }

  // ===== NOTLAR =====

  /// Tüm dersler için ağırlıklı not özetini döner.
  Future<List<MoodleGrade>> getGrades({
    required MoodleAccount account,
    required String token,
    required int userId,
    required List<MoodleCourse> courses,
  }) async {
    if (courses.isEmpty) return [];

    try {
      final data = await _call(
        baseUrl: account.baseUrl,
        token: token,
        function: 'gradereport_overview_get_course_grades',
        params: {'userid': userId.toString()},
      );

      final gradesRaw =
          (data as Map<String, dynamic>)['grades'] as List<dynamic>? ?? [];

      final courseMap = {for (final c in courses) c.id: c};
      final grades = <MoodleGrade>[];

      for (final g in gradesRaw) {
        final gradeMap = g as Map<String, dynamic>;
        final courseId = gradeMap['courseid'] as int;
        final course = courseMap[courseId];
        if (course == null) continue;

        grades.add(
          MoodleGrade.fromApiJson(
            gradeMap,
            account.id,
            courseId,
            course.fullName,
          ),
        );
      }

      return grades;
    } catch (e) {
      debugPrint('[MoodleApiService.getGrades] Error: $e');
      return [];
    }
  }

  // ===== DUYURULAR =====

  /// Her ders için forum duyurularını toplu getirir.
  Future<List<MoodleAnnouncement>> getAnnouncements({
    required MoodleAccount account,
    required String token,
    required List<MoodleCourse> courses,
  }) async {
    if (courses.isEmpty) return [];

    final announcements = <MoodleAnnouncement>[];

    // Her ders için ayrı çağrı — Moodle API bunu toplu desteklemez
    for (final course in courses) {
      try {
        final data = await _call(
          baseUrl: account.baseUrl,
          token: token,
          function: 'mod_forum_get_forum_discussions_paginated',
          params: {
            'forumid': '0', // 0 = news/announcements forum
            'courseid': course.id.toString(),
            'page': '0',
            'perpage': '10',
          },
        );

        final discussions =
            (data as Map<String, dynamic>)['discussions'] as List<dynamic>? ??
            [];

        for (final d in discussions) {
          announcements.add(
            MoodleAnnouncement.fromApiJson(
              d as Map<String, dynamic>,
              account.id,
              course.id,
              course.fullName,
            ),
          );
        }
      } catch (e, stackTrace) {
        debugPrint(
          'Error fetching announcement for course ${course.id}: $e\nStack: $stackTrace',
        );
        continue;
      }
    }

    // En yeni duyuru en üste
    announcements.sort((a, b) => b.created.compareTo(a.created));
    return announcements;
  }

  // ===== TAKVİM =====

  /// Önümüzdeki 30 günün takvim etkinliklerini döner.
  Future<List<MoodleCalendarEvent>> getCalendarEvents({
    required MoodleAccount account,
    required String token,
    required List<MoodleCourse> courses,
  }) async {
    try {
      final now = DateTime.now();
      final future = now.add(const Duration(days: 90));

      final data = await _call(
        baseUrl: account.baseUrl,
        token: token,
        function: 'core_calendar_get_calendar_events',
        params: {
          'events[timestart]': (now.millisecondsSinceEpoch ~/ 1000).toString(),
          'events[timeend]': (future.millisecondsSinceEpoch ~/ 1000).toString(),
        },
      );

      final events =
          (data as Map<String, dynamic>)['events'] as List<dynamic>? ?? [];

      final courseNameMap = {for (final c in courses) c.id: c.fullName};

      return events
          .map(
            (e) => MoodleCalendarEvent.fromApiJson(
              e as Map<String, dynamic>,
              account.id,
              courseNameMap: courseNameMap,
            ),
          )
          .toList();
    } catch (e) {
      debugPrint('[MoodleApiService.getCalendarEvents] Error: $e');
      return [];
    }
  }

  // ===== MESAJLAR =====

  /// Kullanıcının son mesajlarını döner.
  Future<List<MoodleMessage>> getMessages({
    required MoodleAccount account,
    required String token,
    required int userId,
  }) async {
    try {
      final data = await _call(
        baseUrl: account.baseUrl,
        token: token,
        function: 'core_message_get_messages',
        params: {
          'useridto': userId.toString(),
          'type': 'both',
          'limitnum': '50',
        },
      );

      final messages =
          (data as Map<String, dynamic>)['messages'] as List<dynamic>? ?? [];

      return messages
          .map(
            (m) => MoodleMessage.fromApiJson(
              m as Map<String, dynamic>,
              account.id,
            ),
          )
          .toList()
        ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
    } catch (e) {
      debugPrint('[MoodleApiService.getMessages] Error: $e');
      return [];
    }
  }

  // ==================== YARDIMCI METODLAR ====================

  /// Genel Moodle REST API çağrısı
  Future<dynamic> _call({
    required String baseUrl,
    required String token,
    required String function,
    Map<String, String> params = const {},
  }) async {
    final queryParams = {
      'wstoken': token,
      'wsfunction': function,
      'moodlewsrestformat': 'json',
      ...params,
    };

    final uri = Uri.parse(
      '${_normalizeUrl(baseUrl)}/webservice/rest/server.php',
    ).replace(queryParameters: queryParams);

    try {
      final response = await http.get(uri).timeout(_timeout);
      final body = _parseResponse(response);

      // Moodle hata nesne kontrolü
      if (body is Map<String, dynamic>) {
        if (body.containsKey('exception')) {
          final errorCode = body['errorcode'] as String? ?? '';
          if (errorCode == 'invalidtoken' || errorCode == 'accessexception') {
            throw MoodleAuthException(
              body['message'] as String? ?? 'Token geçersiz',
            );
          }
          throw MoodleServiceException(
            body['message'] as String? ??
                body['exception'] as String? ??
                'Moodle API hatası',
          );
        }
      }

      return body;
    } on MoodleAuthException {
      rethrow;
    } on MoodleServiceException {
      rethrow;
    } on MoodleNetworkException {
      rethrow;
    } catch (e) {
      debugPrint('[MoodleApiService._call] $function error: $e');
      throw MoodleNetworkException('API isteği başarısız: $function');
    }
  }

  /// HTTP yanıtını JSON'a parse eder
  dynamic _parseResponse(http.Response response) {
    if (response.statusCode != 200) {
      throw MoodleNetworkException(
        'HTTP ${response.statusCode}: Sunucu yanıt vermedi',
      );
    }
    try {
      return jsonDecode(utf8.decode(response.bodyBytes));
    } catch (e, stackTrace) {
      debugPrint('Error decoding JSON response: $e\nStack: $stackTrace');
      throw MoodleNetworkException('Sunucu geçersiz yanıt döndürdü');
    }
  }

  /// Login URL oluşturucu (şifre URL'de değil, body'de gönderilir)
  Uri _buildLoginUri(String baseUrl) {
    return Uri.parse('${_normalizeUrl(baseUrl)}/login/token.php');
  }

  /// Trailing slash ve http/https normalisation
  String _normalizeUrl(String url) {
    var normalized = url.trim();
    if (!normalized.startsWith('http')) {
      normalized = 'https://$normalized';
    }
    while (normalized.endsWith('/')) {
      normalized = normalized.substring(0, normalized.length - 1);
    }
    return normalized;
  }
}
