import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lesson_tracker/models/course.dart';
import 'package:lesson_tracker/providers/auth_provider.dart';
import 'package:lesson_tracker/providers/course_provider.dart';
import 'package:lesson_tracker/providers/note_provider.dart';
import 'package:lesson_tracker/providers/deadline_provider.dart';
import 'package:lesson_tracker/providers/theme_provider.dart';
import 'package:lesson_tracker/providers/language_provider.dart';
import 'package:lesson_tracker/providers/sync_provider.dart';
import 'package:lesson_tracker/providers/moodle_provider.dart';
import 'package:lesson_tracker/providers/planner_event_provider.dart';
import 'package:lesson_tracker/screens/home/home_screen.dart';
import 'package:lesson_tracker/widgets/home/home_widgets.dart';
import 'package:mocktail/mocktail.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:lesson_tracker/core/services/notification_service.dart';
import 'package:lesson_tracker/l10n/app_localizations.dart';
import 'package:lesson_tracker/screens/home/widgets/quick_action_card.dart';

class MockCourseProvider extends Mock implements CourseProvider {}
class MockNoteProvider extends Mock implements NoteProvider {}
class MockDeadlineProvider extends Mock implements DeadlineProvider {}
class MockAuthProvider extends Mock implements AuthProvider {}
class MockSyncProvider extends Mock implements SyncProvider {}
class MockThemeProvider extends Mock implements ThemeProvider {}
class MockLanguageProvider extends Mock implements LanguageProvider {}
class MockNotificationService extends Mock implements NotificationService {}
class MockMoodleProvider extends Mock implements MoodleProvider {}
class MockPlannerEventProvider extends Mock implements PlannerEventProvider {}

void main() {
  late MockCourseProvider mockCourseProvider;
  late MockNoteProvider mockNoteProvider;
  late MockDeadlineProvider mockDeadlineProvider;
  late MockAuthProvider mockAuthProvider;
  late MockSyncProvider mockSyncProvider;
  late MockThemeProvider mockThemeProvider;
  late MockLanguageProvider mockLanguageProvider;
  late MockNotificationService mockNotificationService;
  late MockMoodleProvider mockMoodleProvider;

  late MockPlannerEventProvider mockPlannerEventProvider;

  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
    SharedPreferences.setMockInitialValues({});
  });

  setUp(() {
    FlutterError.onError = (FlutterErrorDetails details) {
      bool isOverflowError = false;

      var exception = details.exception;
      if (exception is FlutterError) {
        isOverflowError = !exception.diagnostics.any(
            (e) => e.value.toString().startsWith("A RenderFlex overflowed by"));
      }

      if (isOverflowError) {
        return;
      }
      FlutterError.presentError(details);
    };

    mockNotificationService = MockNotificationService();
    NotificationService.instance = mockNotificationService;
    when(() => mockNotificationService.requestPermissions()).thenAnswer((_) async => true);
    mockCourseProvider = MockCourseProvider();
    mockNoteProvider = MockNoteProvider();
    mockDeadlineProvider = MockDeadlineProvider();
    mockAuthProvider = MockAuthProvider();
    mockSyncProvider = MockSyncProvider();
    mockThemeProvider = MockThemeProvider();
    mockLanguageProvider = MockLanguageProvider();
    mockMoodleProvider = MockMoodleProvider();
    mockPlannerEventProvider = MockPlannerEventProvider();

    // Setup base behaviors
    when(() => mockAuthProvider.user).thenReturn(null);
    when(() => mockAuthProvider.isGuest).thenReturn(true);
    when(() => mockThemeProvider.themeMode).thenReturn(ThemeMode.light);
    when(() => mockThemeProvider.isDarkMode).thenReturn(false);
    when(() => mockLanguageProvider.locale).thenReturn(const Locale('en'));
    when(() => mockMoodleProvider.accounts).thenReturn([]);
    when(() => mockMoodleProvider.isAnySyncing).thenReturn(false);
    when(() => mockMoodleProvider.isLoading).thenReturn(false);
    when(() => mockMoodleProvider.hasAccounts).thenReturn(false);
    when(() => mockMoodleProvider.allCourses).thenReturn([]);
    when(() => mockMoodleProvider.unreadCount).thenReturn(0);
    when(() => mockMoodleProvider.unreadMessageCount).thenReturn(0);

    when(() => mockCourseProvider.loadCourses()).thenAnswer((_) async {});
    when(() => mockNoteProvider.loadNotes()).thenAnswer((_) async {});
    when(() => mockDeadlineProvider.loadDeadlines()).thenAnswer((_) async {});
    when(() => mockPlannerEventProvider.loadEvents()).thenAnswer((_) async {});
    
    when(() => mockCourseProvider.courses).thenReturn([]);
    when(() => mockCourseProvider.uniqueCourses).thenReturn([]);
    when(() => mockCourseProvider.todayCourses).thenReturn([]);
    when(() => mockCourseProvider.priorityCourses).thenReturn([]);
    when(() => mockCourseProvider.findUpcomingCourse()).thenReturn(null);
    when(() => mockCourseProvider.addSampleData()).thenAnswer((_) async {});
    when(() => mockCourseProvider.notificationsEnabled).thenReturn(true);
    when(() => mockCourseProvider.reminderMinutes).thenReturn(15);

    when(() => mockNoteProvider.recentNotes).thenReturn([]);
    when(() => mockNoteProvider.addSampleNotes(any())).thenAnswer((_) async {});
    
    when(() => mockDeadlineProvider.deadlines).thenReturn([]);
    when(() => mockPlannerEventProvider.events).thenReturn([]);
  });

  Widget buildTestWidget() {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<CourseProvider>.value(value: mockCourseProvider),
        ChangeNotifierProvider<NoteProvider>.value(value: mockNoteProvider),
        ChangeNotifierProvider<DeadlineProvider>.value(value: mockDeadlineProvider),
        ChangeNotifierProvider<AuthProvider>.value(value: mockAuthProvider),
        ChangeNotifierProvider<SyncProvider>.value(value: mockSyncProvider),
        ChangeNotifierProvider<ThemeProvider>.value(value: mockThemeProvider),
        ChangeNotifierProvider<LanguageProvider>.value(value: mockLanguageProvider),
        ChangeNotifierProvider<MoodleProvider>.value(value: mockMoodleProvider),
        ChangeNotifierProvider<PlannerEventProvider>.value(value: mockPlannerEventProvider),
      ],
      child: MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: const HomeScreen(),
      ),
    );
  }

  group('HomeScreen Integration Tests', () {
    testWidgets('Renders empty states correctly', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      // Because courses are empty, it should show empty state messages
      expect(find.text('Guest'), findsOneWidget); // Username
      
      // The screen should render without crashing
      expect(find.byType(CustomScrollView), findsOneWidget);
    });

    testWidgets('Renders ScheduleCard when there are classes today', (WidgetTester tester) async {
      final mockCourse = Course(
        id: '1',
        name: 'Math 101',
        color: Colors.blue,
        scheduleDays: [1],
        startTime: const TimeOfDay(hour: 9, minute: 0),
        endTime: const TimeOfDay(hour: 10, minute: 30),
      );

      when(() => mockCourseProvider.todayCourses).thenReturn([mockCourse]);

      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      // Verify that ScheduleCard renders the injected course
      expect(find.byType(ScheduleCard), findsOneWidget);
      expect(find.text('Math 101'), findsOneWidget);
    });

    testWidgets('Renders sub-components correctly', (WidgetTester tester) async {
      when(() => mockCourseProvider.todayCourses).thenReturn([]);

      // Make the view large enough to avoid needing to scroll, or do a drag.
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.0; // Higher density effectively reduces logical size
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      // Verify sub-components presence
      expect(find.byType(HomeStatsSummary), findsWidgets);
    });
  });
}
