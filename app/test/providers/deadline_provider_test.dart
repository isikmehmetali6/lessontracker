import 'package:flutter_test/flutter_test.dart';
import 'package:lesson_tracker/providers/deadline_provider.dart';
import 'package:lesson_tracker/models/deadline.dart';
import 'package:lesson_tracker/core/database/database_helper.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
    DatabaseHelper.dbName = 'test_deadlines.db';
  });

  group('DeadlineProvider - Business Logic Tests', () {
    late DeadlineProvider provider;

    setUp(() async {
      provider = DeadlineProvider();
      await DatabaseHelper().clearAllData();

      // Ensure the course exists to satisfy the FOREIGN KEY constraint for 'c1'
      final db = await DatabaseHelper().database;
      await db.insert('courses', {
        'id': 'c1',
        'name': 'Test',
        'color': 0xFF000000,
        'scheduleDays': '[0]',
        'startTimeHour': 9,
        'startTimeMinute': 0,
        'endTimeHour': 10,
        'endTimeMinute': 0,
        'createdAt': DateTime.now().toIso8601String(),
      });

      await provider.loadDeadlines();
    });

    test('addDeadline creates a deadline and sorts them', () async {
      expect(provider.deadlines.length, 0);

      final d1 = Deadline(
        id: '1',
        courseId: 'c1',
        title: 'Later Deadline',
        date: DateTime.now().add(const Duration(days: 5)),
        type: DeadlineType.assignment,
        reminder: true,
      );

      final d2 = Deadline(
        id: '2',
        courseId: 'c1',
        title: 'Earlier Deadline',
        date: DateTime.now().add(const Duration(days: 2)),
        type: DeadlineType.exam,
        reminder: true,
      );

      await provider.addDeadline(d1);
      await provider.addDeadline(d2);

      expect(provider.deadlines.length, 2);
      expect(
        provider.deadlines.first.id,
        '2',
      ); // Earlier deadline should be first
    });

    test('getDaysLeft correctly calculates difference in days', () {
      final now = DateTime.now();
      final targetDate = DateTime(now.year, now.month, now.day + 4);
      final daysLeft = provider.getDaysLeft(targetDate);
      expect(daysLeft, 4);
    });

    test('deleteDeadline removes deadline', () async {
      final deadline = Deadline(
        id: '123',
        courseId: 'c1',
        title: 'To Be Deleted',
        date: DateTime.now().add(const Duration(days: 2)),
        type: DeadlineType.other,
        reminder: false,
      );

      await provider.addDeadline(deadline);
      expect(provider.deadlines.length, 1);

      final success = await provider.deleteDeadline('123');
      expect(success, true);
      expect(provider.deadlines.length, 0);
    });
  });
}
