import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lesson_tracker/providers/course_provider.dart';
import 'package:lesson_tracker/models/course.dart';
import 'package:lesson_tracker/core/database/database_helper.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
    DatabaseHelper.dbName = 'test_absences.db';
    SharedPreferences.setMockInitialValues({});
  });

  group('Absence Management - Business Logic Tests', () {
    late CourseProvider provider;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      provider = CourseProvider();
      await DatabaseHelper().clearAllData();
      await provider.loadCourses();
    });

    test('addAbsence increments absence count', () async {
      await provider.addCourse(
        name: 'Math',
        color: Colors.blue,
        scheduleDays: [0, 2],
        startTime: const TimeOfDay(hour: 10, minute: 0),
        endTime: const TimeOfDay(hour: 12, minute: 0),
        absenceLimit: 3,
      );

      final course = provider.courses.first;
      final initialAbsences = course.currentAbsences;

      await provider.addAbsence(course.id);

      final updatedCourse = provider.courses.first;
      expect(updatedCourse.currentAbsences, initialAbsences + 1);
    });

    test('removeLastAbsence decrements absence count', () async {
      await provider.addCourse(
        name: 'Math',
        color: Colors.blue,
        scheduleDays: [0, 2],
        startTime: const TimeOfDay(hour: 10, minute: 0),
        endTime: const TimeOfDay(hour: 12, minute: 0),
        absenceLimit: 3,
      );

      final course = provider.courses.first;
      await provider.addAbsence(course.id);
      await provider.addAbsence(course.id);

      expect(provider.courses.first.currentAbsences, 2);

      await provider.removeLastAbsence(course.id);

      expect(provider.courses.first.currentAbsences, 1);
    });

    test('removeLastAbsence does nothing when no absences', () async {
      await provider.addCourse(
        name: 'Math',
        color: Colors.blue,
        scheduleDays: [0, 2],
        startTime: const TimeOfDay(hour: 10, minute: 0),
        endTime: const TimeOfDay(hour: 12, minute: 0),
        absenceLimit: 3,
      );

      final course = provider.courses.first;
      expect(provider.courses.first.currentAbsences, 0);

      await provider.removeLastAbsence(course.id);

      expect(provider.courses.first.currentAbsences, 0);
    });

    test('absence limit warning triggers at limit', () async {
      await provider.addCourse(
        name: 'Math',
        color: Colors.blue,
        scheduleDays: [0, 2],
        startTime: const TimeOfDay(hour: 10, minute: 0),
        endTime: const TimeOfDay(hour: 12, minute: 0),
        absenceLimit: 2,
      );

      final course = provider.courses.first;
      await provider.addAbsence(course.id);
      await provider.addAbsence(course.id);

      final updatedCourse = provider.courses.first;
      expect(updatedCourse.isAbsenceLimitExceeded, true);
    });

    test('absence dates are tracked correctly', () async {
      await provider.addCourse(
        name: 'Math',
        color: Colors.blue,
        scheduleDays: [0, 2],
        startTime: const TimeOfDay(hour: 10, minute: 0),
        endTime: const TimeOfDay(hour: 12, minute: 0),
      );

      final course = provider.courses.first;
      final beforeAdd = DateTime.now();
      await provider.addAbsence(course.id);

      final updatedCourse = provider.courses.first;
      expect(updatedCourse.absenceDates.length, 1);
      expect(updatedCourse.absenceDates.first.year, beforeAdd.year);
    });
  });
}
