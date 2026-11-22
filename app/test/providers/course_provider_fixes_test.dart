import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lesson_tracker/core/database/database_helper.dart';
import 'package:lesson_tracker/core/utils/absence_change_bus.dart';
import 'package:lesson_tracker/providers/course_provider.dart';
import 'package:lesson_tracker/repositories/absence_repository.dart';
import 'package:lesson_tracker/repositories/grade_repository.dart';
import 'package:lesson_tracker/services/notification_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../test_helpers.dart';

class _FakeNotifications extends Fake implements NotificationService {
  final List<int> scheduledDays = [];
  final List<int> cancelledDays = [];

  @override
  Future<void> scheduleClassNotification({
    required String courseId,
    required String courseName,
    required String? location,
    required int dayOfWeek,
    required int hour,
    required int minute,
    int reminderMinutes = 60,
  }) async =>
      scheduledDays.add(dayOfWeek);

  @override
  Future<void> cancelClassNotification(String courseId, int dayOfWeek) async =>
      cancelledDays.add(dayOfWeek);

  @override
  Future<void> cancelAllNotifications() async {}
}

void main() {
  late CourseProvider provider;
  late _FakeNotifications notifications;

  setUpAll(() {
    setupTestInfrastructure();
    setupSecureStorageMock();
    setupSqlCipherMock();
    DatabaseHelper.dbName = 'test_course_provider_fixes.db';
  });

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    notifications = _FakeNotifications();
    provider = CourseProvider(notificationService: notifications);
    await DatabaseHelper().clearAllData();
    await provider.loadCourses();
    await provider.addCourse(
      name: 'Math',
      color: Colors.blue,
      scheduleDays: const [0],
      startTime: const TimeOfDay(hour: 0, minute: 5),
      endTime: const TimeOfDay(hour: 1, minute: 0),
    );
  });

  test('addGrade DB\'ye yazılan puanı döndürür (B13)', () async {
    final course = provider.courses.first;
    final grade = await provider.addGrade(
      courseId: course.id,
      name: 'Vize',
      score: 70,
      weight: 40,
    );
    final stored = await GradeRepository().getGradesByCourse(course.id);
    expect(stored.single.id, grade!.id);
  });

  test('updateAbsenceReasonById doğru dersi bildirir (B14)', () async {
    final course = provider.courses.first;
    await provider.addAbsenceAt(course.id, DateTime(2026, 3, 2));
    final absence =
        (await AbsenceRepository().getAbsencesWithReasonByCourse(course.id))
            .single;

    final fired = <String>[];
    final sub = AbsenceChangeBus.instance.stream.listen(fired.add);
    await provider.updateAbsenceReasonById(
      course.id,
      absence['id'] as String,
      'medical',
    );
    await pumpEventQueue();
    await sub.cancel();

    expect(fired, contains(course.id));
    expect(fired, isNot(contains('')));
  });

  test('gece yarısını geçen hatırlatma iptal edilebilir (B18)', () async {
    // 00:05 dersi, 15 dk hatırlatma → bildirim bir önceki gün (Pazar=6)
    expect(notifications.scheduledDays, [6]);

    await provider.deleteCourse(provider.courses.first.id);
    expect(notifications.cancelledDays, containsAll([0, 6]));
  });
}
