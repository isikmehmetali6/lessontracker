import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lesson_tracker/core/utils/consent_utils.dart';
import 'package:lesson_tracker/l10n/app_localizations.dart';
import 'package:lesson_tracker/providers/note_provider.dart';
import 'package:lesson_tracker/screens/shared/ocr_capture_flow.dart';
import 'package:lesson_tracker/services/ocr_service.dart';
import 'package:mocktail/mocktail.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _MockNotes extends Mock implements NoteProvider {}

class _MockPicker extends Mock implements ImagePicker {}

/// Bir düğmeye basınca [action]'ı çalıştıran test iskeleti.
Widget _host(
  Future<void> Function(BuildContext) action, {
  NoteProvider? notes,
}) {
  final app = MaterialApp(
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: Scaffold(
      body: Builder(
        builder: (context) => ElevatedButton(
          onPressed: () => action(context),
          child: const Text('go'),
        ),
      ),
    ),
  );
  return notes == null
      ? app
      : ChangeNotifierProvider<NoteProvider>.value(value: notes, child: app);
}

AppLocalizations _l10n(WidgetTester tester) =>
    AppLocalizations.of(tester.element(find.text('go')))!;

void main() {
  setUpAll(() {
    registerFallbackValue(ImageSource.camera);
    registerFallbackValue(File(''));
  });

  group('rıza kapısı (O3)', () {
    testWidgets('OCR için kamera + OCR rızası ister ve kaydeder', (tester) async {
      SharedPreferences.setMockInitialValues({'consent_camera': true});
      bool? result;
      await tester.pumpWidget(_host((ctx) async {
        result = await ConsentUtils.ensureCaptureConsent(
          ctx,
          kind: CaptureKind.ocr,
        );
      }));
      await tester.tap(find.text('go'));
      await tester.pumpAndSettle();

      final l10n = _l10n(tester);
      expect(find.text(l10n.captureConsentKvkkOcr), findsOneWidget);
      await tester.tap(find.text(l10n.captureConsentAccept));
      await tester.pumpAndSettle();

      expect(result, isTrue);
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getBool('consent_camera'), isTrue);
      expect(prefs.getBool('consent_ocr'), isTrue);
    });

    testWidgets('vazgeçilirse reddedilmiş rıza değişmez', (tester) async {
      SharedPreferences.setMockInitialValues({
        'consent_camera': false,
        'consent_ocr': false,
      });
      bool? result;
      await tester.pumpWidget(_host((ctx) async {
        result = await ConsentUtils.ensureCaptureConsent(
          ctx,
          kind: CaptureKind.ocr,
        );
      }));
      await tester.tap(find.text('go'));
      await tester.pumpAndSettle();
      await tester.tap(find.text(_l10n(tester).cancel));
      await tester.pumpAndSettle();

      expect(result, isFalse);
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getBool('consent_camera'), isFalse);
      expect(prefs.getBool('consent_ocr'), isFalse);
    });

    testWidgets('rızalar varsa diyalog gösterilmez', (tester) async {
      SharedPreferences.setMockInitialValues({
        'consent_camera': true,
        'consent_ocr': true,
      });
      bool? result;
      await tester.pumpWidget(_host((ctx) async {
        result = await ConsentUtils.ensureCaptureConsent(
          ctx,
          kind: CaptureKind.ocr,
        );
      }));
      await tester.tap(find.text('go'));
      await tester.pumpAndSettle();
      expect(find.byType(AlertDialog), findsNothing);
      expect(result, isTrue);
    });
  });

  group('runOcrCapture', () {
    late _MockNotes notes;
    late _MockPicker picker;
    late File photo;

    setUp(() {
      SharedPreferences.setMockInitialValues({
        'consent_camera': true,
        'consent_ocr': true,
      });
      notes = _MockNotes();
      picker = _MockPicker();
      photo = File('${Directory.systemTemp.path}/ocr_flow.jpg')
        ..writeAsBytesSync([1, 2, 3]);
    });

    testWidgets('desteklenmeyen platformda kamera açılmadan uyarır (O8)',
        (tester) async {
      await tester.pumpWidget(_host(
        (ctx) => runOcrCapture(
          context: ctx,
          courseId: 'c1',
          imagePicker: picker,
          isSupportedPlatform: false,
        ),
        notes: notes,
      ));
      await tester.tap(find.text('go'));
      await tester.pumpAndSettle();

      expect(find.text(_l10n(tester).ocrUnavailable), findsOneWidget);
      verifyNever(() => picker.pickImage(source: any(named: 'source')));
    });

    testWidgets('galeriden seçilen fotoğrafta metin yoksa uyarır (O1, O2)',
        (tester) async {
      when(
        () => picker.pickImage(
          source: any(named: 'source'),
          maxWidth: any(named: 'maxWidth'),
          maxHeight: any(named: 'maxHeight'),
          imageQuality: any(named: 'imageQuality'),
        ),
      ).thenAnswer((_) async => XFile(photo.path));
      when(
        () => notes.addOcrNote(
          courseId: any(named: 'courseId'),
          imageFile: any(named: 'imageFile'),
          customTitle: any(named: 'customTitle'),
        ),
      ).thenAnswer((_) async => null);
      when(() => notes.ocrErrorCode).thenReturn(OcrErrorCode.noText);

      await tester.pumpWidget(_host(
        (ctx) => runOcrCapture(
          context: ctx,
          courseId: 'c1',
          imagePicker: picker,
          isSupportedPlatform: true,
        ),
        notes: notes,
      ));
      await tester.tap(find.text('go'));
      await tester.pumpAndSettle();

      final l10n = _l10n(tester);
      await tester.tap(find.text(l10n.ocrSourceGallery));
      await tester.pumpAndSettle();

      verify(
        () => picker.pickImage(
          source: ImageSource.gallery,
          maxWidth: any(named: 'maxWidth'),
          maxHeight: any(named: 'maxHeight'),
          imageQuality: any(named: 'imageQuality'),
        ),
      ).called(1);
      expect(find.text(l10n.ocrNoText), findsOneWidget);
      expect(find.text(l10n.ocrNoteSaved), findsNothing);
    });
  });
}
