import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:lesson_tracker/main.dart' as app;
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:lesson_tracker/core/database/database_helper.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    SharedPreferences.setMockInitialValues({});
  });

  group('Lesson Tracker E2E Flow', () {
    testWidgets('App starts, skips onboarding, adds basic course', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Because it's a cold boot, Onboarding or Login may be presented
      // In tests it's better to verify basic widgets first
      expect(find.byType(MaterialApp), findsOneWidget);

      // Check if we are at onboarding and skip
      if (find.text('Skip').evaluate().isNotEmpty) {
        await tester.tap(find.text('Skip'));
        await tester.pumpAndSettle();
      }

      // Check if Guest option is available on Login
      if (find.text('Continue as Guest').evaluate().isNotEmpty) {
        await tester.tap(find.text('Continue as Guest'));
        await tester.pumpAndSettle();
      }

      // Should be on Home Screen at this point with a bottom nav bar
      expect(find.byType(BottomNavigationBar), findsWidgets);
      
      // Tap FAB to add course
      final fab = find.byType(FloatingActionButton);
      if (fab.evaluate().isNotEmpty) {
        await tester.tap(fab);
        await tester.pumpAndSettle();
        
        // Wait for bottom sheet options
        await tester.tap(find.text('Add New Course'));
        await tester.pumpAndSettle();
      }
    });
  });
}
