import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lesson_tracker/core/database/database_helper.dart';
import 'package:lesson_tracker/l10n/app_localizations.dart';
import 'package:lesson_tracker/models/course.dart';
import 'package:lesson_tracker/providers/auth_provider.dart';
import 'package:lesson_tracker/repositories/course_repository.dart';
import 'package:lesson_tracker/screens/auth/email_verification_screen.dart';
import 'package:lesson_tracker/screens/auth/login_screen.dart';
import 'package:mocktail/mocktail.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../test_helpers.dart';

class MockAuthProvider extends Mock implements AuthProvider {}

void main() {
  setUpAll(() {
    setupTestInfrastructure();
    setupSecureStorageMock();
    setupSqlCipherMock();
    DatabaseHelper.dbName = 'test_guest_upgrade.db';
  });

  test('misafir modundan çıkış yerel veriyi silmez (U1)', () async {
    SharedPreferences.setMockInitialValues({});
    await DatabaseHelper().clearAllData();
    await CourseRepository().insertCourse(
      Course(
        id: 'g1',
        name: 'Guest Course',
        color: Colors.blue,
        scheduleDays: const [0],
        startTime: const TimeOfDay(hour: 9, minute: 0),
        endTime: const TimeOfDay(hour: 10, minute: 0),
      ),
    );

    final auth = AuthProvider();
    await auth.loginAsGuest();
    expect(auth.isAuthenticated, isTrue);

    await auth.leaveGuestMode();
    expect(auth.isGuest, isFalse);
    expect(auth.isAuthenticated, isFalse);
    expect((await SharedPreferences.getInstance()).getBool('auth_is_guest'),
        isNull);
    expect(await CourseRepository().getCourseById('g1'), isNotNull);
  });

  group('e-posta onayı (U19)', () {
    late MockAuthProvider auth;

    Widget wrap(Widget child) => ChangeNotifierProvider<AuthProvider>.value(
          value: auth,
          child: MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: child,
          ),
        );

    setUp(() {
      auth = MockAuthProvider();
      when(() => auth.isLoading).thenReturn(false);
      when(() => auth.error).thenReturn(null);
      when(() => auth.needsEmailConfirmation).thenReturn(false);
      when(() => auth.clearError()).thenReturn(null);
    });

    testWidgets('onay ekranı oturum olmadan verilen adrese tekrar gönderir',
        (tester) async {
      when(() => auth.resendConfirmation(any())).thenAnswer((_) async => true);
      await tester.pumpWidget(
        wrap(const EmailVerificationScreen(email: 'yeni@example.com')),
      );
      expect(find.text('yeni@example.com'), findsOneWidget);

      final l10n = AppLocalizations.of(
        tester.element(find.byType(EmailVerificationScreen)),
      )!;
      await tester.tap(find.text(l10n.resendVerification));
      await tester.pumpAndSettle();
      verify(() => auth.resendConfirmation('yeni@example.com')).called(1);
    });

    testWidgets('onaysız girişte "tekrar gönder" seçeneği görünür',
        (tester) async {
      when(() => auth.error).thenReturn('Please verify your email');
      when(() => auth.needsEmailConfirmation).thenReturn(true);
      await tester.pumpWidget(wrap(const LoginScreen()));
      final l10n = AppLocalizations.of(
        tester.element(find.byType(LoginScreen)),
      )!;
      expect(find.text(l10n.resendVerification), findsOneWidget);
    });
  });
}
