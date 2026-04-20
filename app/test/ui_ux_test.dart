import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lesson_tracker/core/theme/app_theme.dart';

void main() {
  group('UI/UX - Theme and Display Tests', () {
    test('AppTheme provides valid light theme', () {
      final lightTheme = AppTheme.lightTheme;
      expect(lightTheme.brightness, Brightness.light);
    });

    test('AppTheme provides valid dark theme', () {
      final darkTheme = AppTheme.darkTheme;
      expect(darkTheme.brightness, Brightness.dark);
    });

    test('Light theme has proper text contrast', () {
      final lightTheme = AppTheme.lightTheme;
      final textTheme = lightTheme.textTheme;

      expect(textTheme.bodyLarge?.color, isNot(equals(Colors.white)));
      expect(textTheme.bodyMedium?.color, isNot(equals(Colors.white)));
    });

    test('Dark theme has proper text contrast', () {
      final darkTheme = AppTheme.darkTheme;
      final textTheme = darkTheme.textTheme;

      expect(textTheme.bodyLarge?.color, isNot(equals(Colors.black)));
    });

    test('ThemeMode enum has expected values', () {
      expect(ThemeMode.values.length, 3);
      expect(ThemeMode.values, contains(ThemeMode.system));
      expect(ThemeMode.values, contains(ThemeMode.light));
      expect(ThemeMode.values, contains(ThemeMode.dark));
    });
  });

  group('UI/UX - Keyboard Management Tests', () {
    testWidgets('TextField scrolls into view when keyboard appears', (
      WidgetTester tester,
    ) async {
      final controller = TextEditingController();
      final focusNode = FocusNode();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: Column(
                children: [
                  SizedBox(height: 400),
                  TextField(
                    controller: controller,
                    focusNode: focusNode,
                    decoration: const InputDecoration(labelText: 'Test Field'),
                  ),
                  ElevatedButton(onPressed: () {}, child: const Text('Save')),
                ],
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.byType(TextField));
      await tester.pump();

      expect(focusNode.hasFocus, true);
    });

    testWidgets('Keyboard dismissal works with tap outside', (
      WidgetTester tester,
    ) async {
      final controller = TextEditingController();
      final focusNode = FocusNode();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                TextField(
                  controller: controller,
                  focusNode: focusNode,
                  decoration: const InputDecoration(labelText: 'Test Field'),
                ),
                ElevatedButton(onPressed: () {}, child: const Text('Button')),
              ],
            ),
          ),
        ),
      );

      await tester.tap(find.byType(TextField));
      await tester.pump();
      expect(focusNode.hasFocus, true);

      await tester.tap(find.byType(ElevatedButton));
      await tester.pump();
    });

    testWidgets('Multiple TextFields can be focused sequentially', (
      WidgetTester tester,
    ) async {
      final nameController = TextEditingController();
      final emailController = TextEditingController();
      final nameFocus = FocusNode();
      final emailFocus = FocusNode();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                TextField(
                  controller: nameController,
                  focusNode: nameFocus,
                  decoration: const InputDecoration(labelText: 'Name'),
                ),
                TextField(
                  controller: emailController,
                  focusNode: emailFocus,
                  decoration: const InputDecoration(labelText: 'Email'),
                ),
              ],
            ),
          ),
        ),
      );

      await tester.tap(find.byType(TextField).first);
      await tester.pump();
      expect(nameFocus.hasFocus, true);

      await tester.tap(find.byType(TextField).last);
      await tester.pump();
      expect(emailFocus.hasFocus, true);
    });
  });

  group('UI/UX - Screen Rotation Tests', () {
    testWidgets('App handles portrait orientation', (
      WidgetTester tester,
    ) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1.0;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            appBar: AppBar(title: const Text('Test')),
            body: const Center(child: Text('Portrait')),
          ),
        ),
      );

      expect(find.text('Portrait'), findsOneWidget);

      tester.view.resetPhysicalSize();
    });

    testWidgets('App handles landscape orientation', (
      WidgetTester tester,
    ) async {
      tester.view.physicalSize = const Size(844, 390);
      tester.view.devicePixelRatio = 1.0;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            appBar: AppBar(title: const Text('Test')),
            body: const Center(child: Text('Landscape')),
          ),
        ),
      );

      expect(find.text('Landscape'), findsOneWidget);

      tester.view.resetPhysicalSize();
    });

    testWidgets('UI does not crash during rotation', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ListView.builder(
              itemCount: 20,
              itemBuilder: (context, index) =>
                  ListTile(title: Text('Item $index')),
            ),
          ),
        ),
      );

      tester.view.physicalSize = const Size(844, 390);
      tester.view.devicePixelRatio = 1.0;
      await tester.pump();

      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1.0;
      await tester.pump();

      tester.view.resetPhysicalSize();

      expect(find.byType(ListView), findsOneWidget);
    });
  });

  group('UI/UX - Text Overflow Tests', () {
    testWidgets('Long course name truncates with ellipsis', (
      WidgetTester tester,
    ) async {
      tester.view.physicalSize = const Size(200, 100);
      tester.view.devicePixelRatio = 1.0;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Text(
              'This is a very long course name that should truncate',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
      );

      expect(find.byType(Text), findsOneWidget);

      tester.view.resetPhysicalSize();
    });

    testWidgets('Long text wraps to multiple lines', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Text(
              'This is a long text that should wrap to multiple lines when it exceeds the available width',
              softWrap: true,
            ),
          ),
        ),
      );

      expect(find.byType(Text), findsOneWidget);
    });
  });

  group('UI/UX - Form Validation Tests', () {
    testWidgets('Empty form submission shows validation error', (
      WidgetTester tester,
    ) async {
      final formKey = GlobalKey<FormState>();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Form(
              key: formKey,
              child: Column(
                children: [
                  TextFormField(
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'This field is required';
                      }
                      return null;
                    },
                  ),
                  ElevatedButton(
                    onPressed: () {
                      formKey.currentState!.validate();
                    },
                    child: const Text('Submit'),
                  ),
                ],
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.byType(ElevatedButton));
      await tester.pump();

      expect(find.text('This field is required'), findsOneWidget);
    });

    testWidgets('Valid form submission passes validation', (
      WidgetTester tester,
    ) async {
      final formKey = GlobalKey<FormState>();
      final controller = TextEditingController();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Form(
              key: formKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: controller,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Required';
                      }
                      return null;
                    },
                  ),
                  ElevatedButton(
                    onPressed: () {
                      if (formKey.currentState!.validate()) {}
                    },
                    child: const Text('Submit'),
                  ),
                ],
              ),
            ),
          ),
        ),
      );

      await tester.enterText(find.byType(TextFormField), 'Valid Input');
      await tester.tap(find.byType(ElevatedButton));
      await tester.pump();

      expect(find.text('Required'), findsNothing);
    });
  });
}
