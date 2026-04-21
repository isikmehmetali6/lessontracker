import 'dart:io';
import 'package:flutter/material.dart';
import '../repositories/note_repository.dart';
import '../core/services/ocr_service.dart';
import '../core/services/file_service.dart';
import '../core/services/audio_service.dart';
import '../core/services/watermark_service.dart';
import '../models/note.dart';
import 'package:uuid/uuid.dart';

/// Not yönetimi provider
class NoteProvider extends ChangeNotifier {
  final NoteRepository _noteRepo = NoteRepository();
  final OcrService _ocr = OcrService();
  final FileService _fileService = FileService();
  final AudioService _audioService = AudioService();
  final _uuid = const Uuid();

  // Audio Streams
  Stream<dynamic> get onPlayerStateChanged =>
      _audioService.onPlayerStateChanged;
  Stream<Duration> get onPositionChanged => _audioService.onPositionChanged;
  Stream<void> get onPlayerComplete => _audioService.onPlayerComplete;

  List<Note> _notes = [];
  List<Note> _recentNotes = [];
  List<Note> _courseNotes = [];
  bool _isLoading = false;
  bool _isRecording = false;
  bool _isProcessingOcr = false;
  String? _error;

  // Getters
  List<Note> get notes => List.unmodifiable(_notes);
  List<Note> get recentNotes => List.unmodifiable(_recentNotes);
  List<Note> get courseNotes => _courseNotes;
  bool get isLoading => _isLoading;
  bool get isRecording => _isRecording;
  bool get isProcessingOcr => _isProcessingOcr;
  String? get error => _error;

  /// Hata mesajını temizle
  void clearError() {
    _error = null;
    notifyListeners();
  }

  /// Tüm notları yükle
  Future<void> loadNotes() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _notes = await _noteRepo.getAllNotes();
      _recentNotes = await _noteRepo.getRecentNotes(limit: 10);

      await _noteRepo.repairSearchIndex();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Ders notlarını yükle
  Future<void> loadCourseNotes(String courseId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _courseNotes = await _noteRepo.getNotesByCourse(courseId);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Metin notu ekle
  Future<Note?> addTextNote({
    required String courseId,
    required String title,
    required String content,
    List<String>? tags,
  }) async {
    _error = null;
    try {
      final note = Note(
        id: _uuid.v4(),
        courseId: courseId,
        type: NoteType.text,
        title: title,
        content: content,
        tags: tags ?? [],
      );

      await _noteRepo.insertNote(note);
      await loadNotes();
      await loadCourseNotes(courseId);
      return note;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return null;
    }
  }

  /// OCR notu ekle (resimden metin çıkar)
  Future<Note?> addOcrNote({
    required String courseId,
    required File imageFile,
    String? customTitle,
    List<String>? tags,
    String? courseName,
    String userName = 'User',
  }) async {
    _error = null;
    _isProcessingOcr = true;
    notifyListeners();

    try {
      File imageToSave = imageFile;

      if (courseName != null) {
        final watermarkedFile = await WatermarkService.addWatermarkToImage(
          imageFile: imageFile,
          courseName: courseName,
          userName: userName,
        );
        if (watermarkedFile != null) {
          imageToSave = watermarkedFile;
        }
      }

      final imagePath = await _fileService.saveImage(imageToSave);

      final resolvedPath = await _fileService.resolveFilePath(imagePath);
      if (resolvedPath == null) {
        _error = 'Saved image file could not be found';
        return null;
      }

      final ocrResult = await _ocr.recognizeText(resolvedPath);

      if (!ocrResult.success) {
        _error = ocrResult.error ?? 'OCR işlemi başarısız';
        return null;
      }

      final title =
          customTitle ?? 'Scan ${DateTime.now().day}/${DateTime.now().month}';

      final note = Note(
        id: _uuid.v4(),
        courseId: courseId,
        type: NoteType.ocr,
        title: title,
        content: ocrResult.fullText,
        filePath: imagePath,
        thumbnailPath: imagePath,
        tags: tags ?? [],
      );

      await _noteRepo.insertNoteWithFile(
        note,
        attachedFile: File(resolvedPath),
        thumbnail: File(resolvedPath),
      );
      await loadNotes();
      await loadCourseNotes(courseId);
      return note;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return null;
    } finally {
      _isProcessingOcr = false;
      notifyListeners();
    }
  }

  List<Duration> _currentBookmarks = [];
  List<Duration> get currentBookmarks => _currentBookmarks;

  /// Ses kaydı başlat
  Future<bool> startRecording() async {
    try {
      _error = null;
      _currentBookmarks = [];
      final success = await _audioService.startRecording();
      _isRecording = success;
      notifyListeners();
      return success;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  /// Kayıt sırasında yer imi ekle
  void addBookmark() {
    if (!_isRecording) return;

    final currentMs = _audioService.recordingDurationMs;
    _currentBookmarks.add(Duration(milliseconds: currentMs));
    notifyListeners();
  }

  /// Ses kaydını durdur ve kaydet

  /// Ses kaydını durdur ve kaydet
  Future<Note?> stopRecordingAndSave({
    required String courseId,
    String? customTitle,
    List<String>? tags,
  }) async {
    _error = null;
    try {
      final result = await _audioService.stopRecording();
      _isRecording = false;
      notifyListeners();

      if (result == null) {
        _error = 'Ses kaydı oluşturulamadı';
        return null;
      }

      final title =
          customTitle ??
          'Voice Memo ${DateTime.now().day}/${DateTime.now().month}';

      final note = Note(
        id: _uuid.v4(),
        courseId: courseId,
        type: NoteType.audio,
        title: title,
        filePath: result.filePath,
        audioDuration: result.duration,
        tags: tags ?? [],
        bookmarks: _currentBookmarks,
      );

      await _noteRepo.insertNoteWithFile(
        note,
        attachedFile: File(result.filePath),
      );
      await loadNotes();
      await loadCourseNotes(courseId);
      return note;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return null;
    }
  }

  /// Ses kaydını iptal et
  Future<void> cancelRecording() async {
    await _audioService.cancelRecording();
    _isRecording = false;
    _currentBookmarks = [];
    notifyListeners();
  }

  // --- Ses Oynatma ---

  Future<void> playAudio(String path) async {
    final resolvedPath = await _fileService.resolveFilePath(path);
    if (resolvedPath != null) {
      await _audioService.play(resolvedPath);
    }
  }

  Future<void> stopAudio() async {
    await _audioService.stopPlayback();
  }

  Future<void> pauseAudio() async {
    await _audioService.pausePlayback();
  }

  Future<void> seekAudio(Duration position) async {
    await _audioService.seek(position);
  }

  /// Resim notu ekle (sadece resim, OCR yok)
  Future<Note?> addImageNote({
    required String courseId,
    required File imageFile,
    String? customTitle,
    String? content,
    List<String>? tags,
    String? courseName,
    String userName = 'User',
  }) async {
    _error = null;
    try {
      File imageToSave = imageFile;

      if (courseName != null) {
        final watermarkedFile = await WatermarkService.addWatermarkToImage(
          imageFile: imageFile,
          courseName: courseName,
          userName: userName,
        );
        if (watermarkedFile != null) {
          imageToSave = watermarkedFile;
        }
      }

      final imagePath = await _fileService.saveImage(imageToSave);

      final title =
          customTitle ?? 'Image ${DateTime.now().day}/${DateTime.now().month}';

      final note = Note(
        id: _uuid.v4(),
        courseId: courseId,
        type: NoteType.image,
        title: title,
        content: content,
        filePath: imagePath,
        thumbnailPath: imagePath,
        tags: tags ?? [],
      );

      await _noteRepo.insertNoteWithFile(
        note,
        attachedFile: imageToSave,
        thumbnail: imageToSave,
      );
      await loadNotes();
      await loadCourseNotes(courseId);
      return note;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return null;
    }
  }

  /// Notu güncelle
  Future<bool> updateNote(Note note) async {
    _error = null;
    try {
      await _noteRepo.updateNote(note.copyWith(updatedAt: DateTime.now()));
      await loadNotes();
      await loadCourseNotes(note.courseId);
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  /// Notu sil
  Future<bool> deleteNote(Note note) async {
    _error = null;
    try {
      // Dosyaları sil
      if (note.filePath != null) {
        await _fileService.deleteFile(note.filePath!);
      }
      if (note.thumbnailPath != null && note.thumbnailPath != note.filePath) {
        await _fileService.deleteFile(note.thumbnailPath!);
      }

      await _noteRepo.deleteNote(note.id);
      await loadNotes();
      await loadCourseNotes(note.courseId);
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  /// Çizim ile notu kaydet (el yazısı, PDF açıklama, fotoğraf üzerine çizim)
  Future<bool> saveNoteWithDrawing(Note note) async {
    _error = null;
    try {
      // Check if note exists - update or insert
      final existing = await _noteRepo.getNoteById(note.id);
      if (existing != null) {
        await _noteRepo.updateNote(note.copyWith(updatedAt: DateTime.now()));
      } else {
        await _noteRepo.insertNote(note);
      }
      await loadNotes();
      await loadCourseNotes(note.courseId);
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  /// Note by ID
  Future<Note?> getNoteById(String id) async {
    return await _noteRepo.getNoteById(id);
  }

  /// Notu başka bir derse taşı
  Future<bool> moveNoteToCourse(Note note, String newCourseId) async {
    _error = null;
    try {
      final oldCourseId = note.courseId;
      final updated = note.copyWith(
        courseId: newCourseId,
        updatedAt: DateTime.now(),
      );
      await _noteRepo.updateNote(updated);
      await loadNotes();
      await loadCourseNotes(oldCourseId);
      await loadCourseNotes(newCourseId);
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  /// Yer imi ekle/kaldır
  Future<void> toggleBookmark(Note note) async {
    await updateNote(note.copyWith(isBookmarked: !note.isBookmarked));
  }

  /// Not ara
  Future<List<Note>> searchNotes(String query) async {
    if (query.isEmpty) return [];
    return await _noteRepo.searchNotes(query);
  }

  /// Yer imli notları getir
  Future<List<Note>> getBookmarkedNotes() async {
    return await _noteRepo.getBookmarkedNotes();
  }

  /// Örnek notlar ekle
  Future<void> addSampleNotes(List<String> courseIds) async {
    if (courseIds.isEmpty) return;

    final sampleNotes = [
      Note(
        id: _uuid.v4(),
        courseId: courseIds[0],
        type: NoteType.ocr,
        title: 'Chapter 4 Summary',
        content:
            'Key concepts on cellular respiration and mitochondrial functions...',
        tags: ['biology', 'exam-prep'],
      ),
      Note(
        id: _uuid.v4(),
        courseId: courseIds.length > 1 ? courseIds[1] : courseIds[0],
        type: NoteType.audio,
        title: 'Lecture Audio',
        audioDuration: 765, // 12:45
        tags: ['history', 'lecture'],
      ),
      Note(
        id: _uuid.v4(),
        courseId: courseIds[0],
        type: NoteType.text,
        title: 'Study Group Notes',
        content:
            'Discussed integration by parts and how to choose \'u\' and \'dv\'. Key takeaway: use LIATE rule (Logarithmic, Inverse trig, Algebraic, Trig, Exponential) to prioritize selection.',
        tags: ['exam-prep', 'group'],
      ),
      Note(
        id: _uuid.v4(),
        courseId: courseIds[0],
        type: NoteType.ocr,
        title: 'Whiteboard Scan',
        content: '∫ x² dx = x³/3 + C. Remember to apply the power rule...',
        tags: ['calculus', 'formulas'],
      ),
    ];

    for (final note in sampleNotes) {
      await _noteRepo.insertNote(note);
    }

    await loadNotes();
  }

  /// Tüm in-memory verileri sıfırla — kullanıcı çıkışında çağrılır
  void clear() {
    _notes = [];
    _recentNotes = [];
    _courseNotes = [];
    _error = null;
    _isLoading = false;
    notifyListeners();
  }

  @override
  void dispose() {
    _ocr.close();
    _audioService.dispose();
    super.dispose();
  }
}
