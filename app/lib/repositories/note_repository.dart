import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';
import '../core/database/database_helper.dart';
import '../core/services/auto_sync_service.dart';
import '../core/services/e2e_file_service.dart';
import '../core/services/e2e_key_service.dart';
import '../core/services/e2e_upload_service.dart';
import '../models/note.dart';

class NoteRepository {
  static final NoteRepository _instance = NoteRepository._internal();
  factory NoteRepository() => _instance;
  NoteRepository._internal() {
    DatabaseHelper().registerWebCacheClear(() {
      _notesInMemory.clear();
    });
  }

  final DatabaseHelper _dbHelper = DatabaseHelper();
  final List<Note> _notesInMemory = [];

  // ==================== NOT İŞLEMLERİ ====================

  /// Tüm notları getir (paginated)
  Future<List<Note>> getAllNotes({int limit = 50, int offset = 0}) async {
    if (_dbHelper.isWeb) {
      final sorted = List.from(_notesInMemory)
        ..sort(
          (a, b) => (b.createdAt ?? DateTime(2000)).compareTo(
            a.createdAt ?? DateTime(2000),
          ),
        );
      final start = offset.clamp(0, sorted.length);
      final end = (offset + limit).clamp(0, sorted.length);
      return sorted.sublist(start, end).cast<Note>();
    }
    final db = await _dbHelper.database;
    final maps = await db.query(
      'notes',
      orderBy: 'createdAt DESC',
      limit: limit,
      offset: offset,
    );
    return maps.map((map) => Note.fromMap(map)).toList();
  }

  /// Derse göre notları getir
  Future<List<Note>> getNotesByCourse(String courseId) async {
    if (_dbHelper.isWeb) {
      return _notesInMemory.where((n) => n.courseId == courseId).toList()..sort(
        (a, b) => (b.createdAt ?? DateTime(2000)).compareTo(
          a.createdAt ?? DateTime(2000),
        ),
      );
    }
    final db = await _dbHelper.database;
    final maps = await db.query(
      'notes',
      where: 'courseId = ?',
      whereArgs: [courseId],
      orderBy: 'createdAt DESC',
    );
    return maps.map((map) => Note.fromMap(map)).toList();
  }

  /// Son notları getir
  Future<List<Note>> getRecentNotes({int limit = 10}) async {
    if (_dbHelper.isWeb) {
      final sorted = List<Note>.from(_notesInMemory)
        ..sort(
          (a, b) => (b.createdAt ?? DateTime(2000)).compareTo(
            a.createdAt ?? DateTime(2000),
          ),
        );
      return sorted.take(limit).toList();
    }
    final db = await _dbHelper.database;
    final maps = await db.query(
      'notes',
      orderBy: 'createdAt DESC',
      limit: limit,
    );
    return maps.map((map) => Note.fromMap(map)).toList();
  }

  /// Not ekle
  Future<void> insertNote(Note note) async {
    if (_dbHelper.isWeb) {
      _notesInMemory.removeWhere((n) => n.id == note.id);
      _notesInMemory.add(note);
      return;
    }
    final db = await _dbHelper.database;

    // Sadece mevcut kolonları kullan (migration'dan bağımsız)
    final map = note.toMap();
    final columns = [
      'id',
      'courseId',
      'type',
      'title',
      'content',
      'filePath',
      'thumbnailPath',
      'audioDuration',
      'tags',
      'bookmarks',
      'isBookmarked',
      'createdAt',
      'updatedAt',
    ];
    final values = <dynamic>[];
    final placeholders = <String>[];

    for (final col in columns) {
      if (map.containsKey(col)) {
        placeholders.add('?');
        values.add(map[col]);
      }
    }
    placeholders.add('?');
    values.add(
      _dbHelper.normalizeForSearch(
        '${note.title} ${note.content ?? ''} ${note.tags.join(' ')} ${note.filePath ?? ''} ${note.type.name}',
      ),
    );

    await db.execute(
      'INSERT OR REPLACE INTO notes (${columns.join(',')}, searchContent) VALUES (${placeholders.join(',')})',
      values,
    );
    AutoSyncService().triggerBackup();
  }

  /// Not ekle (E2E dosya yüklemesi ile)
  Future<void> insertNoteWithFile(
    Note note, {
    File? attachedFile,
    File? thumbnail,
  }) async {
    String? cloudPath;
    String? thumbnailCloudPath;

    if (attachedFile != null && await E2EKeyService().isE2EEnabled()) {
      try {
        final uploadService = E2EUploadService();
        cloudPath = await uploadService.uploadNoteFile(attachedFile);
        debugPrint('Note file uploaded to cloud: $cloudPath');

        if (thumbnail != null) {
          thumbnailCloudPath = await uploadService.uploadNoteThumbnail(
            thumbnail,
          );
          debugPrint('Thumbnail uploaded to cloud: $thumbnailCloudPath');
        }
      } catch (e) {
        debugPrint('E2E upload error: $e');
      }
    }

    await insertNote(note);

    if (cloudPath != null) {
      await _updateNoteCloudPath(note.id, cloudPath, thumbnailCloudPath);
    }
  }

  Future<void> _updateNoteCloudPath(
    String noteId,
    String cloudPath,
    String? thumbnailCloudPath,
  ) async {
    if (_dbHelper.isWeb) return;
    final db = await _dbHelper.database;
    final updates = <String, dynamic>{'cloudPath': cloudPath};
    if (thumbnailCloudPath != null) {
      updates['thumbnailCloudPath'] = thumbnailCloudPath;
    }
    await db.update('notes', updates, where: 'id = ?', whereArgs: [noteId]);
  }

  /// Not dosyasını cloud'dan indir
  Future<Uint8List?> downloadNoteFile(String cloudPath) async {
    try {
      final e2eService = E2EFileService();
      return await e2eService.downloadPhoto(cloudPath);
    } catch (e) {
      debugPrint('Error downloading note file: $e');
      return null;
    }
  }

  /// Not sil (cloud dosyasını da siler)
  Future<void> deleteNoteWithFiles(String id) async {
    final cloudPath = await _getNoteCloudPath(id);
    if (cloudPath != null) {
      try {
        final e2eService = E2EFileService();
        await e2eService.deleteFile(cloudPath);
        final thumbnailCloudPath = await _getNoteThumbnailCloudPath(id);
        if (thumbnailCloudPath != null) {
          await e2eService.deleteFile(thumbnailCloudPath);
        }
      } catch (e) {
        debugPrint('Error deleting cloud files: $e');
      }
    }
    await deleteNote(id);
  }

  Future<String?> _getNoteCloudPath(String noteId) async {
    if (_dbHelper.isWeb) return null;
    final db = await _dbHelper.database;
    final result = await db.query(
      'notes',
      columns: ['cloudPath'],
      where: 'id = ?',
      whereArgs: [noteId],
      limit: 1,
    );
    if (result.isNotEmpty && result.first['cloudPath'] != null) {
      return result.first['cloudPath'] as String;
    }
    return null;
  }

  Future<String?> _getNoteThumbnailCloudPath(String noteId) async {
    if (_dbHelper.isWeb) return null;
    final db = await _dbHelper.database;
    final result = await db.query(
      'notes',
      columns: ['thumbnailCloudPath'],
      where: 'id = ?',
      whereArgs: [noteId],
      limit: 1,
    );
    if (result.isNotEmpty && result.first['thumbnailCloudPath'] != null) {
      return result.first['thumbnailCloudPath'] as String;
    }
    return null;
  }

  /// Not güncelle
  Future<void> updateNote(Note note) async {
    if (_dbHelper.isWeb) {
      final index = _notesInMemory.indexWhere((n) => n.id == note.id);
      if (index != -1) {
        _notesInMemory[index] = note;
      }
      return;
    }
    final db = await _dbHelper.database;
    await db.update(
      'notes',
      {
        ...note.toMap(),
        'searchContent': _dbHelper.normalizeForSearch(
          '${note.title} ${note.content ?? ''} ${note.tags.join(' ')}',
        ),
      },
      where: 'id = ?',
      whereArgs: [note.id],
    );
    AutoSyncService().triggerBackup();
  }

  /// Not sil
  Future<void> deleteNote(String id) async {
    if (_dbHelper.isWeb) {
      _notesInMemory.removeWhere((n) => n.id == id);
      return;
    }
    final db = await _dbHelper.database;
    await db.delete('notes', where: 'id = ?', whereArgs: [id]);
    AutoSyncService().triggerBackup();
  }

  /// Not getir
  Future<Note?> getNoteById(String id) async {
    if (_dbHelper.isWeb) {
      try {
        return _notesInMemory.firstWhere((n) => n.id == id);
      } catch (e, stackTrace) {
        debugPrint('Error finding note $id in memory: $e\nStack: $stackTrace');
        return null;
      }
    }
    final db = await _dbHelper.database;
    final maps = await db.query(
      'notes',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (maps.isEmpty) return null;
    return Note.fromMap(maps.first);
  }

  /// Arama yap - title, content, tags, filePath, type, courseId hepsine bakar
  Future<List<Note>> searchNotes(String query) async {
    if (_dbHelper.isWeb) {
      final q = _dbHelper.normalizeForSearch(query);
      return _notesInMemory.where((n) {
        final searchContent = _dbHelper.normalizeForSearch(
          '${n.title} ${n.content ?? ''} ${n.tags.join(' ')} ${n.filePath ?? ''} ${n.type.name}',
        );
        return searchContent.contains(q);
      }).toList();
    }
    final db = await _dbHelper.database;
    final normalizedQuery = _dbHelper.normalizeForSearch(query);
    final maps = await db.query(
      'notes',
      where: 'searchContent LIKE ? OR filePath LIKE ? OR title LIKE ?',
      whereArgs: [
        '%$normalizedQuery%',
        '%$normalizedQuery%',
        '%$normalizedQuery%',
      ],
      orderBy: 'createdAt DESC',
    );
    return maps.map((map) => Note.fromMap(map)).toList();
  }

  /// Arama indeksini onar (Migration hatası durumunda)
  Future<void> repairSearchIndex() async {
    if (_dbHelper.isWeb) return;
    final db = await _dbHelper.database;

    final notes = await db.query('notes');
    final batch = db.batch();

    for (final noteMap in notes) {
      final note = Note.fromMap(noteMap);
      final searchContent = _dbHelper.normalizeForSearch(
        '${note.title} ${note.content ?? ''} ${note.tags.join(' ')} ${note.filePath ?? ''} ${note.type.name}',
      );

      if (noteMap['searchContent'] == searchContent) continue;

      batch.update(
        'notes',
        {'searchContent': searchContent},
        where: 'id = ?',
        whereArgs: [note.id],
      );
    }

    await batch.commit(noResult: true);
  }

  /// Tür'e göre notları getir
  Future<List<Note>> getNotesByType(NoteType type) async {
    if (_dbHelper.isWeb) {
      return _notesInMemory.where((n) => n.type == type).toList();
    }
    final db = await _dbHelper.database;
    final maps = await db.query(
      'notes',
      where: 'type = ?',
      whereArgs: [type.name],
      orderBy: 'createdAt DESC',
    );
    return maps.map((map) => Note.fromMap(map)).toList();
  }

  /// Yer imli notları getir
  Future<List<Note>> getBookmarkedNotes() async {
    if (_dbHelper.isWeb) {
      return _notesInMemory.where((n) => n.isBookmarked).toList();
    }
    final db = await _dbHelper.database;
    final maps = await db.query(
      'notes',
      where: 'isBookmarked = ?',
      whereArgs: [1],
      orderBy: 'createdAt DESC',
    );
    return maps.map((map) => Note.fromMap(map)).toList();
  }

  Future<int> getNoteCount() async {
    if (_dbHelper.isWeb) {
      return _notesInMemory.length;
    }
    final db = await _dbHelper.database;
    final result = await db.rawQuery('SELECT COUNT(*) as count FROM notes');
    return Sqflite.firstIntValue(result) ?? 0;
  }

  Future<int> getNoteCountByCourse(String courseId) async {
    if (_dbHelper.isWeb) {
      return _notesInMemory.where((n) => n.courseId == courseId).length;
    }
    final db = await _dbHelper.database;
    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM notes WHERE courseId = ?',
      [courseId],
    );
    return Sqflite.firstIntValue(result) ?? 0;
  }
}
