import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

import '../../models/note.dart'; // Needed for Migration

/// SQLite veritabanı yönetimi (Web için in-memory fallback)
class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  static Database? _database;
  
  bool get isWeb => kIsWeb;

  final List<VoidCallback> _webClearCaches = [];

  void registerWebCacheClear(VoidCallback callback) {
    _webClearCaches.add(callback);
  }

  Future<Database> get database async {
    if (isWeb) {
      throw UnsupportedError('SQLite is not supported on web');
    }
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'lesson_tracker.db');

    return await openDatabase(
      path,
      version: 11, // Version 11: relative file paths migration
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    // Dersler tablosu
    await db.execute('''
      CREATE TABLE courses (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        subtitle TEXT,
        professor TEXT,
        location TEXT,
        color INTEGER NOT NULL,
        scheduleDays TEXT NOT NULL,
        startTimeHour INTEGER NOT NULL,
        startTimeMinute INTEGER NOT NULL,
        endTimeHour INTEGER NOT NULL,
        endTimeMinute INTEGER NOT NULL,
        absenceLimit INTEGER DEFAULT 3,
        currentAbsences INTEGER DEFAULT 0,
        progress REAL DEFAULT 0.0,
        iconName TEXT,
        createdAt TEXT NOT NULL,
        nextExamDate TEXT,
        credits INTEGER DEFAULT 3,
        status TEXT DEFAULT 'active',
        latitude REAL,
        longitude REAL,
        updatedAt TEXT
      )
    ''');

    // Notlar tablosu
    await db.execute('''
      CREATE TABLE notes (
        id TEXT PRIMARY KEY,
        courseId TEXT NOT NULL,
        type TEXT NOT NULL,
        title TEXT NOT NULL,
        content TEXT,
        filePath TEXT,
        thumbnailPath TEXT,
        audioDuration INTEGER,
        tags TEXT,
        bookmarks TEXT,
        isBookmarked INTEGER DEFAULT 0,
        createdAt TEXT NOT NULL,
        updatedAt TEXT NOT NULL,
        searchContent TEXT,
        FOREIGN KEY (courseId) REFERENCES courses (id) ON DELETE CASCADE
      )
    ''');

    // Notlar (Grades) tablosu
    await db.execute('''
      CREATE TABLE grades (
        id TEXT PRIMARY KEY,
        courseId TEXT NOT NULL,
        name TEXT NOT NULL,
        score REAL NOT NULL,
        maxScore REAL NOT NULL DEFAULT 100.0,
        weight REAL NOT NULL,
        createdAt TEXT NOT NULL,
        FOREIGN KEY (courseId) REFERENCES courses (id) ON DELETE CASCADE
      )
    ''');

    // Devamsızlıklar tablosu
    await db.execute('''
      CREATE TABLE absences (
        id TEXT PRIMARY KEY,
        courseId TEXT NOT NULL,
        date TEXT NOT NULL,
        FOREIGN KEY (courseId) REFERENCES courses (id) ON DELETE CASCADE
      )
    ''');

    // Dosyalar tablosu
    await db.execute('''
      CREATE TABLE course_files (
        id TEXT PRIMARY KEY,
        courseId TEXT NOT NULL,
        path TEXT NOT NULL,
        name TEXT NOT NULL,
        type TEXT NOT NULL,
        createdAt TEXT NOT NULL,
        FOREIGN KEY (courseId) REFERENCES courses (id) ON DELETE CASCADE
      )
    ''');
    
    // Deadline tablosu
    await db.execute('''
      CREATE TABLE deadlines (
        id TEXT PRIMARY KEY,
        courseId TEXT NOT NULL,
        title TEXT NOT NULL,
        date TEXT NOT NULL,
        type INTEGER NOT NULL,
        reminder INTEGER DEFAULT 1,
        FOREIGN KEY (courseId) REFERENCES courses (id) ON DELETE CASCADE
      )
    ''');

    // İndeksler
    await db.execute('CREATE INDEX idx_notes_courseId ON notes (courseId)');
    await db.execute('CREATE INDEX idx_notes_type ON notes (type)');
    await db.execute('CREATE INDEX idx_grades_courseId ON grades (courseId)');
    await db.execute('CREATE INDEX idx_absences_courseId ON absences (courseId)');
    await db.execute('CREATE INDEX idx_courses_status ON courses (status)');
    await db.execute('CREATE INDEX idx_files_courseId ON course_files (courseId)');
    await db.execute('CREATE INDEX idx_deadlines_courseId ON deadlines (courseId)');

    // Pending Changes tablosu — offline-first sync için
    await db.execute('''
      CREATE TABLE pending_changes (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        tableName TEXT NOT NULL,
        recordId TEXT NOT NULL,
        operation TEXT NOT NULL,
        timestamp TEXT NOT NULL,
        synced INTEGER DEFAULT 0
      )
    ''');
    await db.execute('CREATE INDEX idx_pending_synced ON pending_changes (synced)');

    // Study Sessions tablosu
    await db.execute('''
      CREATE TABLE study_sessions (
        id TEXT PRIMARY KEY,
        courseId TEXT,
        durationMinutes INTEGER NOT NULL,
        startedAt TEXT NOT NULL,
        endedAt TEXT NOT NULL,
        sessionType TEXT DEFAULT 'work',
        FOREIGN KEY (courseId) REFERENCES courses (id) ON DELETE SET NULL
      )
    ''');
    await db.execute('CREATE INDEX idx_study_sessions_courseId ON study_sessions (courseId)');
    await db.execute('CREATE INDEX idx_study_sessions_startedAt ON study_sessions (startedAt)');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('''
        CREATE TABLE grades (
          id TEXT PRIMARY KEY,
          courseId TEXT NOT NULL,
          name TEXT NOT NULL,
          score REAL NOT NULL,
          maxScore REAL NOT NULL DEFAULT 100.0,
          weight REAL NOT NULL,
          createdAt TEXT NOT NULL,
          FOREIGN KEY (courseId) REFERENCES courses (id) ON DELETE CASCADE
        )
      ''');
      await db.execute('CREATE INDEX idx_grades_courseId ON grades (courseId)');
    }
    if (oldVersion < 3) {
      await db.execute('''
        CREATE TABLE absences (
          id TEXT PRIMARY KEY,
          courseId TEXT NOT NULL,
          date TEXT NOT NULL,
          FOREIGN KEY (courseId) REFERENCES courses (id) ON DELETE CASCADE
        )
      ''');
      await db.execute('CREATE INDEX idx_absences_courseId ON absences (courseId)');
    }
    if (oldVersion < 4) {
      await db.execute('''
        CREATE TABLE course_files (
          id TEXT PRIMARY KEY,
          courseId TEXT NOT NULL,
          path TEXT NOT NULL,
          name TEXT NOT NULL,
          type TEXT NOT NULL,
          createdAt TEXT NOT NULL,
          FOREIGN KEY (courseId) REFERENCES courses (id) ON DELETE CASCADE
        )
      ''');
      await db.execute('CREATE INDEX idx_files_courseId ON course_files (courseId)');
    }
    if (oldVersion < 5) {
      await db.execute('''
        CREATE TABLE deadlines (
          id TEXT PRIMARY KEY,
          courseId TEXT NOT NULL,
          title TEXT NOT NULL,
          date TEXT NOT NULL,
          type INTEGER NOT NULL,
          reminder INTEGER DEFAULT 1,
          FOREIGN KEY (courseId) REFERENCES courses (id) ON DELETE CASCADE
        )
      ''');
      await db.execute('CREATE INDEX idx_deadlines_courseId ON deadlines (courseId)');
    }
    if (oldVersion < 6) {
      await db.execute('ALTER TABLE notes ADD COLUMN bookmarks TEXT');
    }
    if (oldVersion < 7) {
      await db.execute('ALTER TABLE courses ADD COLUMN latitude REAL');
      await db.execute('ALTER TABLE courses ADD COLUMN longitude REAL');
    }
    if (oldVersion < 8) {
      await db.execute('ALTER TABLE notes ADD COLUMN searchContent TEXT');
      final notes = await db.query('notes');
      for (final noteMap in notes) {
        final note = Note.fromMap(noteMap);
        final searchContent = _generateSearchContent(note);
        await db.update(
          'notes',
          {'searchContent': searchContent},
          where: 'id = ?',
          whereArgs: [note.id],
        );
      }
    }
    if (oldVersion < 9) {
      await db.execute('ALTER TABLE courses ADD COLUMN updatedAt TEXT');
      await db.execute('''
        CREATE TABLE IF NOT EXISTS pending_changes (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          tableName TEXT NOT NULL,
          recordId TEXT NOT NULL,
          operation TEXT NOT NULL,
          timestamp TEXT NOT NULL,
          synced INTEGER DEFAULT 0
        )
      ''');
      await db.execute('CREATE INDEX IF NOT EXISTS idx_pending_synced ON pending_changes (synced)');
      final now = DateTime.now().toIso8601String();
      await db.update('courses', {'updatedAt': now});
    }
    if (oldVersion < 10) {
      await db.execute('''
        CREATE TABLE IF NOT EXISTS study_sessions (
          id TEXT PRIMARY KEY,
          courseId TEXT,
          durationMinutes INTEGER NOT NULL,
          startedAt TEXT NOT NULL,
          endedAt TEXT NOT NULL,
          sessionType TEXT DEFAULT 'work',
          FOREIGN KEY (courseId) REFERENCES courses (id) ON DELETE SET NULL
        )
      ''');
      await db.execute('CREATE INDEX IF NOT EXISTS idx_study_sessions_courseId ON study_sessions (courseId)');
      await db.execute('CREATE INDEX IF NOT EXISTS idx_study_sessions_startedAt ON study_sessions (startedAt)');
    }
    if (oldVersion < 11) {
      debugPrint('[DB Migration v11] Converting absolute paths to relative paths...');
      final knownDirs = ['images/', 'audio/', 'course_materials/', 'restored_notes/'];
      
      final notes = await db.query('notes', columns: ['id', 'filePath', 'thumbnailPath']);
      for (final noteRow in notes) {
        final id = noteRow['id'] as String;
        final filePath = noteRow['filePath'] as String?;
        final thumbnailPath = noteRow['thumbnailPath'] as String?;
        
        String? newFilePath = filePath;
        String? newThumbPath = thumbnailPath;
        bool needsUpdate = false;
        
        if (filePath != null && filePath.startsWith('/')) {
          for (final dir in knownDirs) {
            final idx = filePath.indexOf(dir);
            if (idx != -1) {
              newFilePath = filePath.substring(idx);
              needsUpdate = true;
              break;
            }
          }
        }
        
        if (thumbnailPath != null && thumbnailPath.startsWith('/')) {
          for (final dir in knownDirs) {
            final idx = thumbnailPath.indexOf(dir);
            if (idx != -1) {
              newThumbPath = thumbnailPath.substring(idx);
              needsUpdate = true;
              break;
            }
          }
        }
        
        if (needsUpdate) {
          await db.update(
            'notes',
            {'filePath': newFilePath, 'thumbnailPath': newThumbPath},
            where: 'id = ?',
            whereArgs: [id],
          );
        }
      }
      
      final files = await db.query('course_files', columns: ['id', 'path']);
      for (final fileRow in files) {
        final id = fileRow['id'] as String;
        final filePath = fileRow['path'] as String?;
        
        if (filePath != null && filePath.startsWith('/')) {
          for (final dir in knownDirs) {
            final idx = filePath.indexOf(dir);
            if (idx != -1) {
              final newPath = filePath.substring(idx);
              await db.update(
                'course_files',
                {'path': newPath},
                where: 'id = ?',
                whereArgs: [id],
              );
              break;
            }
          }
        }
      }
      debugPrint('[DB Migration v11] Migration completed.');
    }
  }

  String _generateSearchContent(Note note) {
    final buffer = StringBuffer();
    buffer.write(note.title);
    buffer.write(' ');
    if (note.content != null) {
      buffer.write(note.content);
      buffer.write(' ');
    }
    if (note.tags.isNotEmpty) {
      buffer.write(note.tags.join(' '));
    }
    return normalizeForSearch(buffer.toString());
  }

  String normalizeForSearch(String text) {
    if (text.isEmpty) return '';
    return text
        .replaceAll('İ', 'i')
        .replaceAll('I', 'i')
        .replaceAll('ı', 'i')
        .replaceAll('Ş', 's')
        .replaceAll('ş', 's')
        .replaceAll('Ğ', 'g')
        .replaceAll('ğ', 'g')
        .replaceAll('Ü', 'u')
        .replaceAll('ü', 'u')
        .replaceAll('Ö', 'o')
        .replaceAll('ö', 'o')
        .replaceAll('Ç', 'c')
        .replaceAll('ç', 'c')
        .toLowerCase();
  }

  // ==================== DEPOLAMA İSTATİSTİKLERİ ====================

  Future<int> getDatabaseSize() async {
    if (isWeb) return 0;
    try {
      final dbPath = await getDatabasesPath();
      final path = join(dbPath, 'lesson_tracker.db');
      final file = File(path);
      if (await file.exists()) {
        return await file.length();
      }
    } catch (e) {
      debugPrint('Error getting database size: $e');
    }
    return 0;
  }



  /// Tüm kullanıcı verilerini temizle — hesap çıkışında çağrılır
  Future<void> clearAllData() async {
    if (isWeb) {
      for (final callback in _webClearCaches) {
        callback();
      }
      return;
    }
    final db = await database;
    await db.delete('courses');
    await db.delete('notes');
    await db.delete('grades');
    await db.delete('absences');
    await db.delete('course_files');
    await db.delete('deadlines');
    await db.delete('pending_changes');
    await db.delete('study_sessions');
    debugPrint('DatabaseHelper: All user data cleared.');
  }

  // ==================== PENDING CHANGES (Offline-First Sync) ====================

  Future<void> recordChange(String tableName, String recordId, String operation) async {
    if (isWeb) return;
    try {
      final db = await database;
      await db.insert('pending_changes', {
        'tableName': tableName,
        'recordId': recordId,
        'operation': operation,
        'timestamp': DateTime.now().toIso8601String(),
        'synced': 0,
      });
    } catch (e) {
      debugPrint('Error recording change: $e');
    }
  }

  Future<List<Map<String, dynamic>>> getPendingChanges() async {
    if (isWeb) return [];
    final db = await database;
    return await db.query(
      'pending_changes',
      where: 'synced = ?',
      whereArgs: [0],
      orderBy: 'timestamp ASC',
    );
  }

  Future<void> markChangesSynced(List<int> ids) async {
    if (isWeb || ids.isEmpty) return;
    final db = await database;
    final batch = db.batch();
    for (final id in ids) {
      batch.update(
        'pending_changes',
        {'synced': 1},
        where: 'id = ?',
        whereArgs: [id],
      );
    }
    await batch.commit(noResult: true);
  }

  Future<void> clearSyncedChanges() async {
    if (isWeb) return;
    final db = await database;
    await db.delete(
      'pending_changes',
      where: 'synced = ?',
      whereArgs: [1],
    );
  }

  Future<void> close() async {
    if (isWeb) return;
    final db = await database;
    await db.close();
    _database = null;
  }
}
