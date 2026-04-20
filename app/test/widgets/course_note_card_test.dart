import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lesson_tracker/models/note.dart';
import 'package:lesson_tracker/widgets/course/note_cards.dart';
import 'package:provider/provider.dart';
import 'package:lesson_tracker/providers/theme_provider.dart';

void main() {
  group('CourseNoteCard Widget Tests', () {
    testWidgets('renders Text Note correctly', (WidgetTester tester) async {
       final mockNote = Note(
        id: '1',
        courseId: 'c1',
        type: NoteType.text,
        title: 'Chapter 1 Summary',
        content: 'This is the body of the note',
        createdAt: DateTime(2023, 1, 1),
      );

      bool tapped = false;

      await tester.pumpWidget(
        ChangeNotifierProvider<ThemeProvider>(
          create: (_) => ThemeProvider(),
          child: MaterialApp(
            home: Scaffold(
              body: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: CourseNoteCard(
                    note: mockNote,
                    onTap: () {
                      tapped = true;
                    },
                  ),
                ),
              ),
            ),
          ),
        ),
      );

      expect(find.text('Chapter 1 Summary'), findsOneWidget);
      expect(find.text('This is the body of the note'), findsOneWidget);
      expect(find.byIcon(Icons.edit_note_rounded), findsOneWidget);

      await tester.tap(find.byType(CourseNoteCard));
      await tester.pumpAndSettle();
      expect(tapped, isTrue);
    });

    testWidgets('renders Audio Note correctly', (WidgetTester tester) async {
       final mockNote = Note(
        id: '2',
        courseId: 'c1',
        type: NoteType.audio,
        title: 'Lecture Recording',
        content: '',
        filePath: '/path/to/audio.m4a',
        createdAt: DateTime(2023, 1, 1),
      );

      bool playTapped = false;

      await tester.pumpWidget(
        ChangeNotifierProvider<ThemeProvider>(
          create: (_) => ThemeProvider(),
          child: MaterialApp(
            home: Scaffold(
              body: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: CourseNoteCard(
                    note: mockNote,
                    onPlayTap: () {
                      playTapped = true;
                    },
                  ),
                ),
              ),
            ),
          ),
        ),
      );

      expect(find.text('Lecture Recording'), findsOneWidget);
      expect(find.byIcon(Icons.mic_rounded), findsOneWidget);
      expect(find.byIcon(Icons.play_arrow_rounded), findsOneWidget);

      await tester.tap(find.byIcon(Icons.play_arrow_rounded));
      await tester.pumpAndSettle();
      expect(playTapped, isTrue);
    });

    testWidgets('bookmark icon is visible on text note card', (WidgetTester tester) async {
      final mockNote = Note(
        id: '3',
        courseId: 'c1',
        type: NoteType.text,
        title: 'Bookmarkable Note',
        content: 'Test content',
        isBookmarked: false,
        createdAt: DateTime(2023, 1, 1),
      );

      bool bookmarkTapped = false;

      await tester.pumpWidget(
        ChangeNotifierProvider<ThemeProvider>(
          create: (_) => ThemeProvider(),
          child: MaterialApp(
            home: Scaffold(
              body: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: CourseNoteCard(
                    note: mockNote,
                    onBookmarkTap: () {
                      bookmarkTapped = true;
                    },
                  ),
                ),
              ),
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.bookmark_border_rounded), findsOneWidget);
      await tester.tap(find.byIcon(Icons.bookmark_border_rounded));
      await tester.pumpAndSettle();
      expect(bookmarkTapped, isTrue);
    });

    testWidgets('bookmark icon is visible on audio note card', (WidgetTester tester) async {
      final mockNote = Note(
        id: '4',
        courseId: 'c1',
        type: NoteType.audio,
        title: 'Audio with bookmark',
        content: '',
        isBookmarked: true,
        createdAt: DateTime(2023, 1, 1),
      );

      await tester.pumpWidget(
        ChangeNotifierProvider<ThemeProvider>(
          create: (_) => ThemeProvider(),
          child: MaterialApp(
            home: Scaffold(
              body: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: CourseNoteCard(
                    note: mockNote,
                  ),
                ),
              ),
            ),
          ),
        ),
      );

      // Bookmarked audio note should show filled bookmark icon
      expect(find.byIcon(Icons.bookmark_rounded), findsOneWidget);
    });
  });
}
