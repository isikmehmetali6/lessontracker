import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lesson_tracker/providers/course_provider.dart';
import 'package:lesson_tracker/models/grade.dart';
import 'package:lesson_tracker/core/database/database_helper.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../test_helpers.dart';

void main() {
  setUpAll(() {
    setupTestInfrastructure();
    setupSecureStorageMock();
    setupSqlCipherMock();
    DatabaseHelper.dbName = 'test_grades.db';
  });

  group('GradeProvider - Business Logic Tests', () {
    late CourseProvider provider;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      provider = CourseProvider();
      await DatabaseHelper().clearAllData();
      await provider.loadCourses();
    });

    test('addGrade creates a grade successfully', () async {
      await provider.addCourse(
        name: 'Math',
        color: Colors.blue,
        scheduleDays: [0, 2],
        startTime: const TimeOfDay(hour: 10, minute: 0),
        endTime: const TimeOfDay(hour: 12, minute: 0),
      );

      final course = provider.courses.first;

      final grade = await provider.addGrade(
        courseId: course.id,
        name: 'Midterm',
        score: 85.0,
        maxScore: 100.0,
        weight: 30.0,
      );

      expect(grade, isNotNull);
      expect(grade!.name, 'Midterm');
      expect(grade.score, 85.0);
      expect(grade.weight, 30.0);
    });

    test('addGrade triggers warning when total weight exceeds 100%', () async {
      await provider.addCourse(
        name: 'Math',
        color: Colors.blue,
        scheduleDays: [0, 2],
        startTime: const TimeOfDay(hour: 10, minute: 0),
        endTime: const TimeOfDay(hour: 12, minute: 0),
      );

      final course = provider.courses.first;

      await provider.addGrade(
        courseId: course.id,
        name: 'Midterm',
        score: 80.0,
        weight: 60.0,
      );

      expect(provider.warning, isNull);

      await provider.addGrade(
        courseId: course.id,
        name: 'Final',
        score: 90.0,
        weight: 50.0,
      );

      expect(provider.warning, isNotNull);
      expect(provider.warning!.contains('100%'), true);
    });

    test('calculateWeightedAverage handles empty list', () {
      expect(provider.calculateWeightedAverage([]), 0.0);
    });

    test('calculateWeightedAverage calculates correctly', () {
      final grades = [
        Grade(
          id: '1',
          courseId: 'c1',
          name: 'Midterm',
          score: 80.0,
          maxScore: 100.0,
          weight: 30.0,
          createdAt: DateTime.now(),
        ),
        Grade(
          id: '2',
          courseId: 'c1',
          name: 'Final',
          score: 90.0,
          maxScore: 100.0,
          weight: 50.0,
          createdAt: DateTime.now(),
        ),
        Grade(
          id: '3',
          courseId: 'c1',
          name: 'Project',
          score: 100.0,
          maxScore: 100.0,
          weight: 20.0,
          createdAt: DateTime.now(),
        ),
      ];

      final average = provider.calculateWeightedAverage(grades);
      expect(average, 89.0);
    });

    test('calculateWeightedAverage handles different max scores', () {
      final grades = [
        Grade(
          id: '1',
          courseId: 'c1',
          name: 'Quiz',
          score: 45.0,
          maxScore: 50.0,
          weight: 20.0,
          createdAt: DateTime.now(),
        ),
        Grade(
          id: '2',
          courseId: 'c1',
          name: 'Exam',
          score: 80.0,
          maxScore: 100.0,
          weight: 80.0,
          createdAt: DateTime.now(),
        ),
      ];

      // Quiz: 45/50 * 100 = 90%, weighted = 90 * 20 / 100 = 18
      // Exam: 80/100 * 100 = 80%, weighted = 80 * 80 / 100 = 64
      // Total: (18 + 64) / 100 * 100 = 82.0
      final average = provider.calculateWeightedAverage(grades);
      expect(average, 82.0);
    });

    test('calculateWeightedAverage handles zero weight', () {
      final grades = [
        Grade(
          id: '1',
          courseId: 'c1',
          name: 'Zero Weight',
          score: 100.0,
          maxScore: 100.0,
          weight: 0.0,
          createdAt: DateTime.now(),
        ),
      ];

      expect(provider.calculateWeightedAverage(grades), 0.0);
    });

    test('updateGrade modifies existing grade', () async {
      await provider.addCourse(
        name: 'Math',
        color: Colors.blue,
        scheduleDays: [0, 2],
        startTime: const TimeOfDay(hour: 10, minute: 0),
        endTime: const TimeOfDay(hour: 12, minute: 0),
      );

      final course = provider.courses.first;
      final grade = await provider.addGrade(
        courseId: course.id,
        name: 'Midterm',
        score: 80.0,
        weight: 30.0,
      );

      final updated = grade!.copyWith(score: 95.0);
      final result = await provider.updateGrade(updated);

      expect(result, true);
    });

    test('deleteGrade removes grade', () async {
      await provider.addCourse(
        name: 'Math',
        color: Colors.blue,
        scheduleDays: [0, 2],
        startTime: const TimeOfDay(hour: 10, minute: 0),
        endTime: const TimeOfDay(hour: 12, minute: 0),
      );

      final course = provider.courses.first;
      final grade = await provider.addGrade(
        courseId: course.id,
        name: 'To Delete',
        score: 80.0,
        weight: 30.0,
      );

      final result = await provider.deleteGrade(grade!.id);
      expect(result, true);
    });

    test('loadCourseGrades returns grades for specific course', () async {
      await provider.addCourse(
        name: 'Math',
        color: Colors.blue,
        scheduleDays: [0, 2],
        startTime: const TimeOfDay(hour: 10, minute: 0),
        endTime: const TimeOfDay(hour: 12, minute: 0),
      );

      final course = provider.courses.first;
      await provider.addGrade(
        courseId: course.id,
        name: 'Midterm',
        score: 85.0,
        weight: 30.0,
      );

      final grades = await provider.loadCourseGrades(course.id);
      expect(grades.length, 1);
      expect(grades.first.name, 'Midterm');
    });

    test('getTotalWeight calculates correctly', () async {
      await provider.addCourse(
        name: 'Math',
        color: Colors.blue,
        scheduleDays: [0, 2],
        startTime: const TimeOfDay(hour: 10, minute: 0),
        endTime: const TimeOfDay(hour: 12, minute: 0),
      );

      final course = provider.courses.first;
      await provider.addGrade(
        courseId: course.id,
        name: 'Midterm',
        score: 80.0,
        weight: 30.0,
      );
      await provider.addGrade(
        courseId: course.id,
        name: 'Final',
        score: 90.0,
        weight: 40.0,
      );

      final total = await provider.getTotalWeight(course.id);
      expect(total, 70.0);
    });
  });
}
