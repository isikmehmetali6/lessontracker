import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lesson_tracker/l10n/app_localizations.dart';
import 'package:lesson_tracker/providers/auth_provider.dart';
import 'package:lesson_tracker/screens/auth/password_recovery_screen.dart';
import 'package:lesson_tracker/screens/auth/reset_password_screen.dart';
import 'package:mocktail/mocktail.dart';
import 'package:provider/provider.dart';

class MockAuthProvider extends Mock implements AuthProvider {}

void main() {
  late MockAuthProvider auth;

  setUp(() {
    auth = MockAuthProvider();
    when(() => auth.isLoading).thenReturn(false);
    when(() => auth.error).thenReturn(null);
  });

  Widget wrap(Widget child) => ChangeNotifierProvider<AuthProvider>.value(
        value: auth,
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: child,
        ),
      );

  group('PasswordRecoveryScreen', () {
    testWidgets('geçerli e-postada sıfırlama linki gönderir', (tester) async {
      when(() => auth.resetPassword(any())).thenAnswer((_) async => true);
      await tester.pumpWidget(wrap(const PasswordRecoveryScreen()));

      await tester.enterText(find.byType(TextFormField), 'ogrenci@example.com');
      await tester.tap(find.text('Send reset link'));
      await tester.pumpAndSettle();

      verify(() => auth.resetPassword('ogrenci@example.com')).called(1);
      expect(find.text('Check your email'), findsOneWidget);
      expect(find.textContaining('ogrenci@example.com'), findsOneWidget);
    });

    testWidgets('geçersiz e-postada istek gönderilmez', (tester) async {
      await tester.pumpWidget(wrap(const PasswordRecoveryScreen()));
      await tester.enterText(find.byType(TextFormField), 'gecersiz');
      await tester.tap(find.text('Send reset link'));
      await tester.pumpAndSettle();
      verifyNever(() => auth.resetPassword(any()));
    });
  });

  group('ResetPasswordScreen', () {
    testWidgets('şifreler eşleşmezse kaydetmez', (tester) async {
      await tester.pumpWidget(wrap(const ResetPasswordScreen()));
      final fields = find.byType(TextFormField);
      await tester.enterText(fields.at(0), 'yeniSifre1');
      await tester.enterText(fields.at(1), 'farkli');
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();

      expect(find.text('Passwords do not match'), findsOneWidget);
      verifyNever(() => auth.completePasswordRecovery(any()));
    });

    testWidgets('geçerli şifreyi kaydeder', (tester) async {
      when(() => auth.completePasswordRecovery(any())).thenAnswer(
        (_) async => (success: true, e2eKeyPreserved: true),
      );
      await tester.pumpWidget(wrap(const ResetPasswordScreen()));
      final fields = find.byType(TextFormField);
      await tester.enterText(fields.at(0), 'yeniSifre1');
      await tester.enterText(fields.at(1), 'yeniSifre1');
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();

      verify(() => auth.completePasswordRecovery('yeniSifre1')).called(1);
      expect(find.text('Password changed successfully'), findsOneWidget);
    });

    testWidgets('vazgeç kurtarma oturumunu kapatır', (tester) async {
      when(() => auth.cancelPasswordRecovery()).thenAnswer((_) async {});
      await tester.pumpWidget(wrap(const ResetPasswordScreen()));
      await tester.tap(find.text('Cancel'));
      await tester.pump();
      verify(() => auth.cancelPasswordRecovery()).called(1);
    });
  });
}
