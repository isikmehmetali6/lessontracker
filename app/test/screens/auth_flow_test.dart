import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:lesson_tracker/screens/auth/login_screen.dart';
import 'package:lesson_tracker/screens/auth/signup_screen.dart';
import 'package:lesson_tracker/providers/auth_provider.dart';
import 'package:lesson_tracker/l10n/app_localizations.dart';

import 'package:mockito/mockito.dart';

// Mock AuthProvider
class MockAuthProvider extends Mock implements AuthProvider {
  @override
  bool get isLoading => false;
  @override
  String? get error => null;
  @override
  Future<bool> signIn(String email, String password) async => true;
  @override
  Future<bool> signUp(String email, String password, String name) async => true;
  @override
  Future<void> loginAsGuest() async {}
}

void main() {
  Widget createTestWidget(Widget child, AuthProvider provider) {
    return ChangeNotifierProvider<AuthProvider>.value(
      value: provider,
      child: MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: child,
      ),
    );
  }

  group('Authentication Flow Widget Tests', () {
    late MockAuthProvider mockAuthProvider;

    setUp(() {
      mockAuthProvider = MockAuthProvider();
    });

    testWidgets('Login Screen UI elements are present', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        createTestWidget(const LoginScreen(), mockAuthProvider),
      );
      await tester.pumpAndSettle();

      expect(find.text('Email Address'), findsOneWidget);
      expect(find.text('Password'), findsOneWidget);
      expect(find.text('Log In'), findsOneWidget);
      expect(find.text('Continue as Guest'), findsOneWidget);
      expect(find.text('Forgot Password?'), findsOneWidget);
    });

    testWidgets('Guest Mode shows local data warning', (
      WidgetTester tester,
    ) async {
      tester.view.physicalSize = const Size(1080, 1920);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        createTestWidget(const LoginScreen(), mockAuthProvider),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Continue as Guest'));
      await tester.pumpAndSettle();

      expect(
        find.textContaining('Your data will be stored locally'),
        findsOneWidget,
      );
    });

    testWidgets('Invalid Login triggers validation errors', (
      WidgetTester tester,
    ) async {
      tester.view.physicalSize = const Size(1080, 1920);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        createTestWidget(const LoginScreen(), mockAuthProvider),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Log In'));
      await tester.pumpAndSettle();

      expect(find.text('Please enter your email address'), findsOneWidget);
      expect(find.text('Please enter your password'), findsOneWidget);
    });

    testWidgets('Sign Up Error validations', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 1920);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        createTestWidget(const SignUpScreen(), mockAuthProvider),
      );
      await tester.pumpAndSettle();

      final emailField = find.widgetWithText(
        TextFormField,
        'Enter your Email Address',
      );
      expect(emailField, findsOneWidget);

      await tester.enterText(emailField, 'invalidemail');
      await tester.tap(find.text('Sign Up'));
      await tester.pumpAndSettle();

      expect(find.text('Please enter a valid email address'), findsOneWidget);
    });
  });
}
