import 'package:flutter_test/flutter_test.dart';
import 'package:lesson_tracker/providers/note_provider.dart';
import 'package:flutter/services.dart';
import 'package:lesson_tracker/core/database/database_helper.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../test_helpers.dart';

void main() {
  setUpAll(() {
    setupTestInfrastructure();
    setupSecureStorageMock();
    setupSqlCipherMock();
    DatabaseHelper.dbName = 'test_notes.db';

    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(
      const MethodChannel('com.llfbandit.record/messages'),
      (message) async => null,
    );
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(
      const MethodChannel('xyz.luan/audioplayers.global'),
      (message) async => 1,
    );
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(
      const MethodChannel('xyz.luan/audioplayers'),
      (message) async => 1,
    );
  });

  group('NoteProvider - Business Logic Tests', () {
    late NoteProvider provider;

    setUp(() async {
      provider = NoteProvider();
      await DatabaseHelper().clearAllData();
      
      // Ensure the course exists to satisfy the FOREIGN KEY constraint
      final db = await DatabaseHelper().database;
      await db.insert(
        'courses',
        {
          'id': 'test-course',
          'name': 'Test',
          'color': 0xFF000000,
          'scheduleDays': '[0]',
          'startTimeHour': 9,
          'startTimeMinute': 0,
          'endTimeHour': 10,
          'endTimeMinute': 0,
          'createdAt': DateTime.now().toIso8601String(),
        },
      );
      
      await provider.loadNotes();
    });

    test('addTextNote creates a note and reloads', () async {
      expect(provider.notes.length, 0);

      final note = await provider.addTextNote(
        courseId: 'test-course',
        title: 'My First Note',
        content: 'This is a test note.',
        tags: ['test', 'flutter'],
      );

      expect(note, isNotNull);
      expect(note!.title, 'My First Note');
      expect(note.tags.length, 2);

      // Provider should have loaded the new note
      expect(provider.notes.length, 1);
      expect(provider.notes.first.id, note.id);
    });

    test('toggleBookmark changes bookmark status', () async {
      final note = await provider.addTextNote(
        courseId: 'test-course',
        title: 'Bookmark test',
        content: 'content',
      );

      expect(note!.isBookmarked, false);

      await provider.toggleBookmark(note);

      // Verify the list has updated note
      final updatedNote = provider.notes.firstWhere((n) => n.id == note.id);
      expect(updatedNote.isBookmarked, true);

      // Toggle back
      await provider.toggleBookmark(updatedNote);
      final revertedNote = provider.notes.firstWhere((n) => n.id == note.id);
      expect(revertedNote.isBookmarked, false);
    });

    test('deleteNote removes note', () async {
      final note = await provider.addTextNote(
        courseId: 'test-course',
        title: 'To delete',
        content: 'content',
      );

      expect(provider.notes.length, 1);

      final success = await provider.deleteNote(note!);
      
      expect(success, true);
      expect(provider.notes.length, 0);
    });
  });
}
