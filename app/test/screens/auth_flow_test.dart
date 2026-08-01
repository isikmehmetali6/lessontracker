import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:provider/provider.dart';
import 'package:lesson_tracker/screens/auth/login_screen.dart';
import 'package:lesson_tracker/screens/auth/signup_screen.dart';
import 'package:lesson_tracker/providers/auth_provider.dart';
import 'package:lesson_tracker/l10n/app_localizations.dart';

class MockAuthProvider extends Mock implements AuthProvider {}

Widget _wrap(Widget child, AuthProvider provider) {
  return ChangeNotifierProvider<AuthProvider>.value(
    value: provider,
    child: MaterialApp(
      locale: const Locale('en'),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: child,
    ),
  );
}

void main() {
  late MockAuthProvider mockAuthProvider;

  setUpAll(() {
    registerFallbackValue('');
  });

  setUp(() {
    mockAuthProvider = MockAuthProvider();
    when(() => mockAuthProvider.isLoading).thenReturn(false);
    when(() => mockAuthProvider.error).thenReturn(null);
    when(
      () => mockAuthProvider.signIn(any(), any()),
    ).thenAnswer((_) async => true);
    when(
      () => mockAuthProvider.signUp(any(), any(), any()),
    ).thenAnswer((_) async => true);
    when(() => mockAuthProvider.loginAsGuest()).thenAnswer((_) async {});
  });

  Future<void> pumpScreen(WidgetTester tester, Widget screen) async {
    tester.view.physicalSize = const Size(1080, 1920);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    await tester.pumpWidget(_wrap(screen, mockAuthProvider));
    await tester.pumpAndSettle();
  }

  group('Authentication Flow Widget Tests', () {
    testWidgets('Login Screen UI elements are present', (
      WidgetTester tester,
    ) async {
      await pumpScreen(tester, const LoginScreen());

      expect(find.text('Email Address'), findsOneWidget);
      expect(find.text('Log In'), findsOneWidget);
      expect(find.text('Continue as Guest'), findsOneWidget);
      expect(find.text('Forgot Password?'), findsOneWidget);
    });

    testWidgets('Guest Mode shows local data warning', (
      WidgetTester tester,
    ) async {
      await pumpScreen(tester, const LoginScreen());

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
      await pumpScreen(tester, const LoginScreen());

      await tester.tap(find.text('Log In'));
      await tester.pumpAndSettle();

      expect(find.text('Please enter your email address'), findsOneWidget);
      expect(find.text('Please enter your password'), findsOneWidget);
    });

    testWidgets('Sign Up Error validations', (WidgetTester tester) async {
      await pumpScreen(tester, const SignUpScreen());

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