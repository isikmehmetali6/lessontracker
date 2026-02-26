import 'package:sqflite/sqflite.dart';
import '../core/database/database_helper.dart';
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

  /// Tüm notları getir
  Future<List<Note>> getAllNotes() async {
    if (_dbHelper.isWeb) {
      return List.from(_notesInMemory)..sort((a, b) => b.createdAt!.compareTo(a.createdAt!));
    }
    final db = await _dbHelper.database;
    final maps = await db.query('notes', orderBy: 'createdAt DESC');
    return maps.map((map) => Note.fromMap(map)).toList();
  }

  /// Derse göre notları getir
  Future<List<Note>> getNotesByCourse(String courseId) async {
    if (_dbHelper.isWeb) {
      return _notesInMemory
          .where((n) => n.courseId == courseId)
          .toList()
        ..sort((a, b) => b.createdAt!.compareTo(a.createdAt!));
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
        ..sort((a, b) => b.createdAt!.compareTo(a.createdAt!));
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
    await db.insert(
      'notes',
      {
        ...note.toMap(),
        'searchContent': _dbHelper.normalizeForSearch(note.title + ' ' + (note.content ?? '') + ' ' + note.tags.join(' ')),
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    await _dbHelper.recordChange('notes', note.id, 'insert');
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
        'searchContent': _dbHelper.normalizeForSearch(note.title + ' ' + (note.content ?? '') + ' ' + note.tags.join(' ')),
      },
      where: 'id = ?',
      whereArgs: [note.id],
    );
    await _dbHelper.recordChange('notes', note.id, 'update');
  }

  /// Not sil
  Future<void> deleteNote(String id) async {
    if (_dbHelper.isWeb) {
      _notesInMemory.removeWhere((n) => n.id == id);
      return;
    }
    final db = await _dbHelper.database;
    await db.delete(
      'notes',
      where: 'id = ?',
      whereArgs: [id],
    );
    await _dbHelper.recordChange('notes', id, 'delete');
  }

  /// Not getir
  Future<Note?> getNoteById(String id) async {
    if (_dbHelper.isWeb) {
      try {
        return _notesInMemory.firstWhere((n) => n.id == id);
      } catch (_) {
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

  /// Arama yap
  Future<List<Note>> searchNotes(String query) async {
    if (_dbHelper.isWeb) {
      final q = _dbHelper.normalizeForSearch(query);
      return _notesInMemory.where((n) {
        final searchContent = _dbHelper.normalizeForSearch(n.title + ' ' + (n.content ?? '') + ' ' + n.tags.join(' '));
        return searchContent.contains(q);
      }).toList();
    }
    final db = await _dbHelper.database;
    final normalizedQuery = _dbHelper.normalizeForSearch(query);
    final maps = await db.query(
      'notes',
      where: 'searchContent LIKE ?',
      whereArgs: ['%$normalizedQuery%'],
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
      final searchContent = _dbHelper.normalizeForSearch(note.title + ' ' + (note.content ?? '') + ' ' + note.tags.join(' '));
      
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

  Future<int> getCount() async {
    if (_dbHelper.isWeb) {
      return _notesInMemory.length;
    }
    final db = await _dbHelper.database;
    final result = await db.rawQuery('SELECT COUNT(*) FROM notes');
    return Sqflite.firstIntValue(result) ?? 0;
  }
}
