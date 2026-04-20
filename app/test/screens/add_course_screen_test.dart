import "package:lesson_tracker/l10n/app_localizations.dart";
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lesson_tracker/models/course.dart';
import 'package:lesson_tracker/providers/course_provider.dart';
import 'package:lesson_tracker/providers/theme_provider.dart';
import 'package:lesson_tracker/providers/auth_provider.dart';
import 'package:lesson_tracker/screens/add_course/add_course_screen.dart';
import 'package:mocktail/mocktail.dart';
import 'package:provider/provider.dart';

// Mock Provider
class MockCourseProvider extends Mock implements CourseProvider {}
class MockAuthProvider extends Mock implements AuthProvider {}

void main() {
  late MockCourseProvider mockCourseProvider;

  setUpAll(() {
    // Register fallback value for TimeOfDay and Course if needed by mocktail
    registerFallbackValue(const TimeOfDay(hour: 0, minute: 0));
    registerFallbackValue(Colors.red);
    registerFallbackValue(
      Course(
        id: 'fallback_id',
        name: 'fallback',
        color: Colors.red,
        scheduleDays: [],
        startTime: const TimeOfDay(hour: 0, minute: 0),
        endTime: const TimeOfDay(hour: 0, minute: 0),
      )
    );
  });

  setUp(() {
    mockCourseProvider = MockCourseProvider();
  });

  Widget buildTestWidget(Widget child) {
    final authProvider = MockAuthProvider();
    when(() => authProvider.isGuest).thenReturn(true);
    when(() => authProvider.user).thenReturn(null);

    return MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: MultiProvider(
        providers: [
          ChangeNotifierProvider<CourseProvider>.value(value: mockCourseProvider),
          ChangeNotifierProvider<ThemeProvider>(create: (_) => ThemeProvider()),
          ChangeNotifierProvider<AuthProvider>.value(value: authProvider),
        ],
        child: child,
      ),
    );
  }

  group('AddCourseScreen Integration Tests', () {
    testWidgets('Validates empty form submission', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestWidget(const AddCourseScreen()));

      // Tap on save without entering name
      await tester.tap(find.text('Create Course'));
      await tester.pump();

      // Expect specific snackbar text that name is required
      // AppLocalizations is used, so we need to either wrap with localizations or test by finding snackbar
      expect(find.byType(SnackBar), findsOneWidget);
    });

    testWidgets('Submits form with valid data', (WidgetTester tester) async {
      when(() => mockCourseProvider.addCourse(
        name: any(named: 'name'),
        location: any(named: 'location'),
        professor: any(named: 'professor'),
        color: any(named: 'color'),
        scheduleDays: any(named: 'scheduleDays'),
        startTime: any(named: 'startTime'),
        endTime: any(named: 'endTime'),
        absenceLimit: any(named: 'absenceLimit'),
      )).thenAnswer((_) async => true);

      await tester.pumpWidget(buildTestWidget(const AddCourseScreen()));

      // Enter course name
      // Use the first text field for the course name
      await tester.enterText(find.byType(TextField).first, 'Biology 101');
      await tester.pumpAndSettle();

      // Tap the create button
      await tester.tap(find.text('Create Course'));
      await tester.pumpAndSettle();

      // Verify addCourse was called with 'Biology 101'
      verify(() => mockCourseProvider.addCourse(
        name: 'Biology 101',
        location: any(named: 'location'),
        professor: any(named: 'professor'),
        color: any(named: 'color'),
        scheduleDays: any(named: 'scheduleDays'),
        startTime: any(named: 'startTime'),
        endTime: any(named: 'endTime'),
        absenceLimit: any(named: 'absenceLimit'),
      )).called(1);
    });
  });
}
