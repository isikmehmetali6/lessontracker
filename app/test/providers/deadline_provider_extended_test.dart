import 'package:flutter_test/flutter_test.dart';
import 'package:lesson_tracker/providers/deadline_provider.dart';
import 'package:lesson_tracker/models/deadline.dart';
import 'package:lesson_tracker/core/database/database_helper.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../test_helpers.dart';

void main() {
  setUpAll(() {
    setupTestInfrastructure();
    setupSecureStorageMock();
    setupSqlCipherMock();
    DatabaseHelper.dbName = 'test_deadlines_extended.db';
  });

  group('DeadlineProvider - Extended Business Logic Tests', () {
    late DeadlineProvider provider;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      provider = DeadlineProvider();
      await DatabaseHelper().clearAllData();

      final db = await DatabaseHelper().database;
      await db.insert('courses', {
        'id': 'c1',
        'name': 'Test',
        'color': 0xFF000000,
        'scheduleDays': '0',
        'startTimeHour': 9,
        'startTimeMinute': 0,
        'endTimeHour': 10,
        'endTimeMinute': 0,
        'createdAt': DateTime.now().toIso8601String(),
      });

      await provider.loadDeadlines();
    });

    test('deadlines are sorted by date ascending', () async {
      final now = DateTime.now();

      final d1 = Deadline(
        id: 'd1',
        courseId: 'c1',
        title: 'Third',
        date: DateTime(now.year, now.month, now.day + 10),
        type: DeadlineType.assignment,
      );
      final d2 = Deadline(
        id: 'd2',
        courseId: 'c1',
        title: 'First',
        date: DateTime(now.year, now.month, now.day + 2),
        type: DeadlineType.exam,
      );
      final d3 = Deadline(
        id: 'd3',
        courseId: 'c1',
        title: 'Second',
        date: DateTime(now.year, now.month, now.day + 5),
        type: DeadlineType.project,
      );

      await provider.addDeadline(d1);
      await provider.addDeadline(d2);
      await provider.addDeadline(d3);

      expect(provider.deadlines[0].title, 'First');
      expect(provider.deadlines[1].title, 'Second');
      expect(provider.deadlines[2].title, 'Third');
    });

    test('upcomingDeadlines filters past deadlines', () async {
      final now = DateTime.now();

      final pastDeadline = Deadline(
        id: 'past',
        courseId: 'c1',
        title: 'Past',
        date: DateTime(now.year, now.month, now.day - 1),
        type: DeadlineType.assignment,
      );
      final futureDeadline = Deadline(
        id: 'future',
        courseId: 'c1',
        title: 'Future',
        date: DateTime(now.year, now.month, now.day + 5),
        type: DeadlineType.exam,
      );

      await provider.addDeadline(pastDeadline);
      await provider.addDeadline(futureDeadline);

      final upcoming = provider.upcomingDeadlines;
      expect(upcoming.length, 1);
      expect(upcoming.first.title, 'Future');
    });

    test('updateDeadline modifies existing deadline', () async {
      final deadline = Deadline(
        id: 'update_test',
        courseId: 'c1',
        title: 'Original',
        date: DateTime.now().add(const Duration(days: 5)),
        type: DeadlineType.assignment,
      );

      await provider.addDeadline(deadline);

      final updated = deadline.copyWith(title: 'Modified');
      await provider.updateDeadline(updated);

      final found = provider.deadlines.firstWhere((d) => d.id == 'update_test');
      expect(found.title, 'Modified');
    });

    test('getDaysLeft returns correct values', () {
      final now = DateTime.now();

      expect(provider.getDaysLeft(DateTime(now.year, now.month, now.day)), 0);
      expect(
        provider.getDaysLeft(DateTime(now.year, now.month, now.day + 1)),
        1,
      );
      expect(
        provider.getDaysLeft(DateTime(now.year, now.month, now.day - 3)),
        -3,
      );
    });

    test('createDeadline with addToCalendar flag works', () async {
      final result = await provider.createDeadline(
        courseId: 'c1',
        title: 'Calendar Event',
        date: DateTime.now().add(const Duration(days: 3)),
        type: DeadlineType.exam,
        reminder: true,
        addToCalendar: true,
      );

      expect(result, true);
      expect(provider.deadlines.any((d) => d.title == 'Calendar Event'), true);
    });

    test('deleteDeadline returns true on success', () async {
      final deadline = Deadline(
        id: 'delete_success',
        courseId: 'c1',
        title: 'To Delete',
        date: DateTime.now().add(const Duration(days: 5)),
        type: DeadlineType.other,
      );

      await provider.addDeadline(deadline);
      expect(provider.deadlines.length, 1);

      final result = await provider.deleteDeadline('delete_success');
      expect(result, true);
      expect(provider.deadlines.length, 0);
    });

    test('deleteDeadline handles non-existent id gracefully', () async {
      final result = await provider.deleteDeadline('non_existent_id');
      expect(result, true);
    });

    test('clear empties all deadlines', () async {
      final deadline = Deadline(
        id: 'clear_test',
        courseId: 'c1',
        title: 'Clear Me',
        date: DateTime.now().add(const Duration(days: 5)),
        type: DeadlineType.assignment,
      );

      await provider.addDeadline(deadline);
      expect(provider.deadlines.length, 1);

      provider.clear();
      expect(provider.deadlines.length, 0);
    });
  });
}
