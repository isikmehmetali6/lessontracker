import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart' show getDatabasesPath, Database;
import 'package:sqflite_sqlcipher/sqflite.dart' as sqlcipher;
import 'package:path/path.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:encrypt/encrypt.dart' as encrypt;

import '../../models/note.dart';

/// Test ortamı için override hook'u.
/// Testlerde bu fonksiyon set edilerek SqlCipher atlanıp FFI kullanılır.
/// Prod'da null kalır.
Future<Database> Function(
  String path,
  int version, {
  required Future<void> Function(Database) onConfigure,
  required Future<void> Function(Database, int) onCreate,
  required Future<void> Function(Database, int, int) onUpgrade,
})?
    testOpenDatabaseOverride;

const String _keyDbEncryptionKey = 'db_encryption_key';
const FlutterSecureStorage _secureStorage = FlutterSecureStorage();

/// SQLite veritabanı yönetimi (Web için in-memory fallback)
class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  static String dbName = 'lesson_tracker.db';

  static Database? _database;
  static Completer<Database>? _initCompleter;

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
    if (_initCompleter != null) return _initCompleter!.future;
    _initCompleter = Completer<Database>();
    try {
      final db = await _initDatabase();
      _database = db;
      _initCompleter!.complete(db);
      return db;
    } catch (e) {
      _initCompleter!.completeError(e);
      _initCompleter = null;
      rethrow;
    }
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, dbName);

    // Test ortamı: FFI factory atanmışsa (test_helpers.dart → databaseFactoryFfi),
    // SqlCipher'ı bypass et ve platform-conditional FFI helper'ı kullan.
    final override = testOpenDatabaseOverride;
    if (override != null) {
      return await override(
        path,
        17,
        onConfigure: (db) async {
          await db.execute('PRAGMA foreign_keys = ON');
        },
        onCreate: _onCreate,
        onUpgrade: _onUpgrade,
      );
    }

    String? encryptionKey = await _secureStorage.read(key: _keyDbEncryptionKey);
    if (encryptionKey == null) {
      final key = encrypt.Key.fromSecureRandom(32);
      await _secureStorage.write(key: _keyDbEncryptionKey, value: key.base64);
      encryptionKey = key.base64;
    }

    return await sqlcipher.openDatabase(
      path,
      version: 17,
      password: encryptionKey,
      onConfigure: (db) async {
        await db.execute('PRAGMA foreign_keys = ON');
      },
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
        updatedAt TEXT,
        professorEmail TEXT,
        professorPhone TEXT,
        professorOffice TEXT,
        officeHours TEXT,
        assistantName TEXT
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
        drawingData TEXT,
        cloudPath TEXT,
        thumbnailCloudPath TEXT,
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
        reason TEXT DEFAULT 'unexcused',
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
        url TEXT,
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
    await db.execute('CREATE INDEX idx_notes_createdAt ON notes (createdAt)');
    await db.execute(
      'CREATE INDEX idx_notes_isBookmarked ON notes (isBookmarked)',
    );
    await db.execute('CREATE INDEX idx_grades_courseId ON grades (courseId)');
    await db.execute(
      'CREATE INDEX idx_absences_courseId ON absences (courseId)',
    );
    await db.execute('CREATE INDEX idx_courses_status ON courses (status)');
    await db.execute(
      'CREATE INDEX idx_files_courseId ON course_files (courseId)',
    );
    await db.execute(
      'CREATE INDEX idx_deadlines_courseId ON deadlines (courseId)',
    );
    await db.execute('CREATE INDEX idx_deadlines_date ON deadlines (date)');

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
    await db.execute(
      'CREATE INDEX idx_pending_synced ON pending_changes (synced)',
    );

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
    await db.execute(
      'CREATE INDEX idx_study_sessions_courseId ON study_sessions (courseId)',
    );
    await db.execute(
      'CREATE INDEX idx_study_sessions_startedAt ON study_sessions (startedAt)',
    );

    // Planner Events tablosu (v13)
    await db.execute('''
      CREATE TABLE planner_events (
        id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        type INTEGER NOT NULL,
        startTime TEXT NOT NULL,
        endTime TEXT NOT NULL,
        color INTEGER NOT NULL,
        notes TEXT
      )
    ''');
    await db.execute(
      'CREATE INDEX idx_planner_events_startTime ON planner_events (startTime)',
    );

    // Moodle hesapları (v14)
    await db.execute('''
      CREATE TABLE moodle_accounts (
        id TEXT PRIMARY KEY,
        baseUrl TEXT NOT NULL,
        siteTitle TEXT NOT NULL,
        username TEXT NOT NULL,
        fullName TEXT NOT NULL,
        avatarUrl TEXT,
        lastSynced TEXT NOT NULL,
        isActive INTEGER DEFAULT 1
      )
    ''');

    // Moodle önbelleği (v14) — JSON payload olarak API yanıtları
    await db.execute('''
      CREATE TABLE moodle_cache (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        accountId TEXT NOT NULL,
        dataType TEXT NOT NULL,
        payload TEXT NOT NULL,
        cachedAt TEXT NOT NULL,
        accessedAt TEXT NOT NULL,
        FOREIGN KEY (accountId) REFERENCES moodle_accounts (id) ON DELETE CASCADE
      )
    ''');
    await db.execute(
      'CREATE INDEX idx_moodle_cache_account ON moodle_cache (accountId, dataType)',
    );
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
      await db.execute(
        'CREATE INDEX idx_absences_courseId ON absences (courseId)',
      );
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
      await db.execute(
        'CREATE INDEX idx_files_courseId ON course_files (courseId)',
      );
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
      await db.execute(
        'CREATE INDEX idx_deadlines_courseId ON deadlines (courseId)',
      );
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
      final batch = db.batch();
      for (final noteMap in notes) {
        final note = Note.fromMap(noteMap);
        final searchContent = _generateSearchContent(note);
        batch.update(
          'notes',
          {'searchContent': searchContent},
          where: 'id = ?',
          whereArgs: [note.id],
        );
      }
      await batch.commit(noResult: true);
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
      await db.execute(
        'CREATE INDEX IF NOT EXISTS idx_pending_synced ON pending_changes (synced)',
      );
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
      await db.execute(
        'CREATE INDEX IF NOT EXISTS idx_study_sessions_courseId ON study_sessions (courseId)',
      );
      await db.execute(
        'CREATE INDEX IF NOT EXISTS idx_study_sessions_startedAt ON study_sessions (startedAt)',
      );
    }
    if (oldVersion < 11) {
      debugPrint(
        '[DB Migration v11] Converting absolute paths to relative paths...',
      );
      final knownDirs = [
        'images/',
        'audio/',
        'course_materials/',
        'restored_notes/',
      ];

      final notes = await db.query(
        'notes',
        columns: ['id', 'filePath', 'thumbnailPath'],
      );
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
    if (oldVersion < 12) {
      await db.execute(
        "ALTER TABLE absences ADD COLUMN reason TEXT DEFAULT 'unexcused'",
      );
      await db.execute('ALTER TABLE courses ADD COLUMN professorEmail TEXT');
      await db.execute('ALTER TABLE courses ADD COLUMN professorPhone TEXT');
      await db.execute('ALTER TABLE courses ADD COLUMN professorOffice TEXT');
      await db.execute('ALTER TABLE courses ADD COLUMN officeHours TEXT');
      await db.execute('ALTER TABLE courses ADD COLUMN assistantName TEXT');
      await db.execute('ALTER TABLE course_files ADD COLUMN url TEXT');
    }
    if (oldVersion < 13) {
      await db.execute('''
        CREATE TABLE planner_events (
          id TEXT PRIMARY KEY,
          title TEXT NOT NULL,
          type INTEGER NOT NULL,
          startTime TEXT NOT NULL,
          endTime TEXT NOT NULL,
          color INTEGER NOT NULL,
          notes TEXT
        )
      ''');
      await db.execute(
        'CREATE INDEX idx_planner_events_startTime ON planner_events (startTime)',
      );
    }
    if (oldVersion < 14) {
      await db.execute('''
        CREATE TABLE IF NOT EXISTS moodle_accounts (
          id TEXT PRIMARY KEY,
          baseUrl TEXT NOT NULL,
          siteTitle TEXT NOT NULL,
          username TEXT NOT NULL,
          fullName TEXT NOT NULL,
          avatarUrl TEXT,
          lastSynced TEXT NOT NULL,
          isActive INTEGER DEFAULT 1
        )
      ''');
      await db.execute('''
        CREATE TABLE IF NOT EXISTS moodle_cache (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          accountId TEXT NOT NULL,
          dataType TEXT NOT NULL,
          payload TEXT NOT NULL,
          cachedAt TEXT NOT NULL,
          accessedAt TEXT NOT NULL,
          FOREIGN KEY (accountId) REFERENCES moodle_accounts (id) ON DELETE CASCADE
        )
      ''');
      await db.execute(
        'CREATE INDEX IF NOT EXISTS idx_moodle_cache_account ON moodle_cache (accountId, dataType)',
      );
      debugPrint('[DB Migration v14] Moodle tables created.');
    }
    if (oldVersion < 15) {
      // drawingData için migration - mevcut kolon kontrolü
      try {
        await db.execute("ALTER TABLE notes ADD COLUMN drawingData TEXT");
        debugPrint('[DB Migration v15] Drawing data column added.');
      } catch (e) {
        debugPrint('[DB Migration v15] Column may already exist: $e');
      }
    }
    if (oldVersion < 16) {
      debugPrint('[DB Migration v16] Database encryption enabled.');
    }
    if (oldVersion < 17) {
      // cloudPath için migration - mevcut kolon kontrolü
      try {
        await db.execute('ALTER TABLE notes ADD COLUMN cloudPath TEXT');
      } catch (e) {
        debugPrint('[DB Migration v17] cloudPath may already exist: $e');
      }
      try {
        await db.execute(
          'ALTER TABLE notes ADD COLUMN thumbnailCloudPath TEXT',
        );
      } catch (e) {
        debugPrint(
          '[DB Migration v17] thumbnailCloudPath may already exist: $e',
        );
      }
      try {
        await db.execute('ALTER TABLE course_files ADD COLUMN cloudPath TEXT');
      } catch (e) {
        debugPrint(
          '[DB Migration v17] course_files.cloudPath may already exist: $e',
        );
      }
      debugPrint('[DB Migration v17] Cloud path columns processed.');
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
    await db.transaction((txn) async {
      await txn.delete('study_sessions');
      await txn.delete('pending_changes');
      await txn.delete('deadlines');
      await txn.delete('course_files');
      await txn.delete('absences');
      await txn.delete('grades');
      await txn.delete('notes');
      await txn.delete('courses');
      await txn.delete('planner_events');
      await txn.delete('moodle_cache');
      await txn.delete('moodle_accounts');
    });
    debugPrint('DatabaseHelper: All user data cleared.');
  }

  Future<void> close() async {
    if (isWeb) return;
    if (_database == null) return;
    await _database!.close();
    _database = null;
    _initCompleter = null;
  }
}
