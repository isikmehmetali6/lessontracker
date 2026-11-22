import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lesson_tracker/core/database/database_helper.dart';
import 'package:lesson_tracker/models/course.dart';
import 'package:lesson_tracker/repositories/absence_repository.dart';
import 'package:lesson_tracker/repositories/course_repository.dart';
import 'package:lesson_tracker/services/attendance_automation_service.dart';
import 'package:lesson_tracker/services/location_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../test_helpers.dart';

class _FakeLocation extends Fake implements LocationService {
  _FakeLocation(this.atUni);
  bool? atUni;

  @override
  Future<List<double>?> getUniversityLocation() async => [41.0, 29.0, 500.0];

  @override
  Future<bool?> isAtUniversity() async => atUni;
}

void main() {
  final courseRepo = CourseRepository();
  final absenceRepo = AbsenceRepository();
  late List<String> notifications;

  // Ders her gün 09:00–11:00; "şimdi" 10:00 → ders saatinde.
  final now = DateTime(2026, 3, 2, 10, 0);

  AttendanceAutomationService service(bool? atUni, {DateTime? at}) =>
      AttendanceAutomationService.forTesting(
        location: _FakeLocation(atUni),
        courseRepo: courseRepo,
        absenceRepo: absenceRepo,
        now: () => at ?? now,
        notify: (course, suffix, title, body) async =>
            notifications.add(suffix),
      );

  setUpAll(() {
    setupTestInfrastructure();
    setupSecureStorageMock();
    setupSqlCipherMock();
    DatabaseHelper.dbName = 'test_attendance_automation.db';
  });

  setUp(() async {
    SharedPreferences.setMockInitialValues({'smart_attendance_enabled': true});
    await DatabaseHelper().clearAllData();
    notifications = [];
    await courseRepo.insertCourse(
      Course(
        id: 'c1',
        name: 'Fizik',
        color: Colors.blue,
        scheduleDays: const [0, 1, 2, 3, 4, 5, 6],
        startTime: const TimeOfDay(hour: 9, minute: 0),
        endTime: const TimeOfDay(hour: 11, minute: 0),
        absenceLimit: 5,
      ),
    );
  });

  test('konum alınamazsa devamsızlık eklenmez (B9)', () async {
    await service(null).executeBackgroundCheck();
    expect(await absenceRepo.getAbsencesByCourse('c1'), isEmpty);

    // İşaretlenmediği için konum gelince tekrar denenir
    await service(false).executeBackgroundCheck();
    expect(await absenceRepo.getAbsencesByCourse('c1'), hasLength(1));
  });

  test('konum bilinmiyor ve ders bitmek üzere → tek seferlik bildirim', () async {
    final nearEnd = DateTime(2026, 3, 2, 10, 50);
    await service(null, at: nearEnd).executeBackgroundCheck();
    await service(null, at: nearEnd).executeBackgroundCheck();
    expect(notifications, ['location']);
    expect(await absenceRepo.getAbsencesByCourse('c1'), isEmpty);
  });

  test('kampüs dışında devamsızlık eklenir', () async {
    await service(false).executeBackgroundCheck();
    expect(await absenceRepo.getAbsencesByCourse('c1'), hasLength(1));
    expect(notifications, ['absence']);
  });

  test('kampüste devamsızlık eklenmez', () async {
    await service(true).executeBackgroundCheck();
    expect(await absenceRepo.getAbsencesByCourse('c1'), isEmpty);
    expect(notifications, ['']);
  });
}
