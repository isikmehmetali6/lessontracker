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
    DatabaseHelper.dbName = 'test_courses.db';
  });

  group('CourseProvider - Business Logic Tests', () {
    late CourseProvider provider;

    setUp(() async {
      provider = CourseProvider();
      await DatabaseHelper().clearAllData();
      await provider.loadCourses(); // ensure it's empty
    });

    test('calculateWeightedAverage calculates correctly with varying weights', () {
      final grades = [
        Grade(
          id: '1', courseId: 'c1', name: 'Midterm',
          score: 80, maxScore: 100, weight: 30, createdAt: DateTime.now()
        ),
        Grade(
          id: '2', courseId: 'c1', name: 'Final',
          score: 90, maxScore: 100, weight: 50, createdAt: DateTime.now()
        ),
        Grade(
          id: '3', courseId: 'c1', name: 'Project',
          score: 100, maxScore: 100, weight: 20, createdAt: DateTime.now()
        ),
      ];

      final average = provider.calculateWeightedAverage(grades);
      // (80*30 + 90*50 + 100*20) / 100 
      // 2400 + 4500 + 2000 = 8900 / 100 = 89.0
      expect(average, 89.0);
    });

    test('calculateWeightedAverage handles empty list', () {
      expect(provider.calculateWeightedAverage([]), 0.0);
    });

    test('calculateWeightedAverage handles zero and missing weights gracefully', () {
      final grades = [
        Grade(id: '1', courseId: 'c1', name: 'Zero Weight', score: 100, maxScore: 100, weight: 0, createdAt: DateTime.now()),
      ];
      expect(provider.calculateWeightedAverage(grades), 0.0);
    });

    test('hasScheduleConflict correctly identifies conflicts', () async {
      // 1. Add a course via the provider directly
      await provider.addCourse(
        name: 'Math',
        color: Colors.blue,
        scheduleDays: [0, 2], // Mon, Wed
        startTime: const TimeOfDay(hour: 10, minute: 0),
        endTime: const TimeOfDay(hour: 12, minute: 0),
      );
      
      expect(provider.courses, isNotEmpty, reason: 'Course should be loaded');
      final course1 = provider.courses.firstWhere((c) => c.name == 'Math', orElse: () => provider.courses.first);
      
      // 2. Check conflict with overlapping time on the same day
      final conflict1 = provider.hasScheduleConflict(
        days: [0], // Mon
        startTime: const TimeOfDay(hour: 11, minute: 0),
        endTime: const TimeOfDay(hour: 13, minute: 0),
      );
      expect(conflict1, isNotNull);
      expect(conflict1!.name, 'Math');

      // 3. Check conflict with exact same time on same day
      final conflict2 = provider.hasScheduleConflict(
        days: [2], // Wed
        startTime: const TimeOfDay(hour: 10, minute: 0),
        endTime: const TimeOfDay(hour: 12, minute: 0),
      );
      expect(conflict2, isNotNull);

      // 4. Check NO conflict on different day
      final noConflict1 = provider.hasScheduleConflict(
        days: [1], // Tue
        startTime: const TimeOfDay(hour: 10, minute: 0),
        endTime: const TimeOfDay(hour: 12, minute: 0),
      );
      expect(noConflict1, isNull);

      // 5. Check NO conflict on same day but different time
      final noConflict2 = provider.hasScheduleConflict(
        days: [0], // Mon
        startTime: const TimeOfDay(hour: 13, minute: 0),
        endTime: const TimeOfDay(hour: 15, minute: 0),
      );
      expect(noConflict2, isNull);

      // 6. Check excludeId works
      final conflictButExcluded = provider.hasScheduleConflict(
        days: [0], // Mon
        startTime: const TimeOfDay(hour: 11, minute: 0),
        endTime: const TimeOfDay(hour: 13, minute: 0),
        excludeId: course1.id, // Exclude the existing course
      );
      expect(conflictButExcluded, isNull);
    });
  });
}
