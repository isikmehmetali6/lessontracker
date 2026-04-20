import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lesson_tracker/models/course.dart';
import 'package:lesson_tracker/widgets/home/home_widgets.dart';

void main() {
  group('PriorityCourseCard Widget Tests', () {
    testWidgets('renders priority course info correctly', (WidgetTester tester) async {
      final mockCourse = Course(
        id: '1',
        name: 'Database Systems',
        location: 'Lab 4',
        professor: 'Dr. Database',
        color: Colors.purple,
        absenceLimit: 4,
        currentAbsences: 3, // Danger condition (3/4 absences means 1 left)
        scheduleDays: [3],
        startTime: const TimeOfDay(hour: 10, minute: 0),
        endTime: const TimeOfDay(hour: 12, minute: 0),
      );

      bool tapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PriorityCourseCard(
              course: mockCourse,
              onTap: () {
                tapped = true;
              },
            ),
          ),
        ),
      );

      // Verify text elements
      expect(find.text('Database Systems'), findsOneWidget);
      expect(find.text('BEHIND'), findsOneWidget); 
      expect(find.text('0% Complete'), findsOneWidget); 

      // Tap card
      await tester.tap(find.byType(PriorityCourseCard));
      await tester.pumpAndSettle();
      expect(tapped, isTrue);
    });
  });
}
