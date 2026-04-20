import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lesson_tracker/models/course.dart';
import 'package:lesson_tracker/widgets/home/home_widgets.dart';
import 'package:provider/provider.dart';
import 'package:lesson_tracker/providers/theme_provider.dart';

void main() {
  group('ScheduleCard Widget Tests', () {
    testWidgets('renders course info correctly', (WidgetTester tester) async {
      final mockCourse = Course(
        id: '1',
        name: 'Mathematics',
        location: 'Room 101',
        professor: 'Dr. Smith',
        color: Colors.blue,
        scheduleDays: [1],
        startTime: const TimeOfDay(hour: 9, minute: 0),
        endTime: const TimeOfDay(hour: 10, minute: 30),
      );

      bool tapped = false;

      await tester.pumpWidget(
        ChangeNotifierProvider<ThemeProvider>(
          create: (_) {
            final provider = ThemeProvider();
            return provider;
          },
          child: MaterialApp(
            home: Scaffold(
              body: ScheduleCard(
                course: mockCourse,
                onTap: () {
                  tapped = true;
                },
              ),
            ),
          ),
        ),
      );

      // Verify texts
      expect(find.text('Mathematics'), findsOneWidget);
      expect(find.text('Room 101'), findsOneWidget);
      expect(find.text('09:00 - 10:30'), findsOneWidget);

      // Tap card
      await tester.tap(find.byType(ScheduleCard));
      await tester.pumpAndSettle();
      expect(tapped, isTrue);
    });

    testWidgets('handles course without location properly', (WidgetTester tester) async {
       final mockCourse = Course(
        id: '2',
        name: 'Physics',
        color: Colors.red,
        scheduleDays: [2],
        startTime: const TimeOfDay(hour: 14, minute: 0),
        endTime: const TimeOfDay(hour: 16, minute: 0),
      );

      await tester.pumpWidget(
        ChangeNotifierProvider<ThemeProvider>(
          create: (_) {
            final provider = ThemeProvider();
            return provider;
          },
          child: MaterialApp(
            home: Scaffold(
              body: ScheduleCard(
                course: mockCourse,
              ),
            ),
          ),
        ),
      );

      expect(find.text('Physics'), findsOneWidget);
      expect(find.text('14:00 - 16:00'), findsOneWidget);
      // Ensure no location container throws error
      expect(find.byType(Container), findsWidgets);
    });
  });
}
