import 'package:freezed_annotation/freezed_annotation.dart';

part 'note.freezed.dart';

/// Not türleri
enum NoteType {
  text, // Manuel metin notu
  ocr, // OCR ile taranan not
  audio, // Ses kaydı
  image, // Sadece resim
  drawing, // El yazısı/çizim notu
}

/// Not modeli
@freezed
abstract class Note with _$Note {
  const Note._();

  const factory Note({
    required String id,
    required String courseId,
    required NoteType type,
    required String title,
    String? content, // Metin içeriği (OCR sonucu dahil)
    String? filePath, // Ses/resim dosya yolu
    String? thumbnailPath, // Önizleme resmi
    int? audioDuration, // Ses süresi (saniye)
    @Default([]) List<String> tags,
    @Default([]) List<Duration> bookmarks,
    @Default(false) bool isBookmarked,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? drawingData, // JSON serialized drawing strokes
  }) = _Note;

  /// Ses notu mu?
  bool get isAudio => type == NoteType.audio;

  /// OCR notu mu?
  bool get isOcr => type == NoteType.ocr;

  /// Metin notu mu?
  bool get isText => type == NoteType.text;

  /// Resim notu mu?
  bool get isImage => type == NoteType.image;

  /// Ses formatını döndür
  String get formattedDuration {
    if (audioDuration == null) return '';
    final minutes = audioDuration! ~/ 60;
    final seconds = audioDuration! % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  /// Map'e dönüştür
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'courseId': courseId,
      'type': type.name,
      'title': title,
      'content': content,
      'filePath': filePath,
      'thumbnailPath': thumbnailPath,
      'audioDuration': audioDuration,
      'tags': tags.join(','),
      'bookmarks': bookmarks.map((d) => d.inMilliseconds).join(','),
      'isBookmarked': isBookmarked ? 1 : 0,
      'createdAt': (createdAt ?? DateTime.now()).toIso8601String(),
      'updatedAt': (updatedAt ?? DateTime.now()).toIso8601String(),
      'drawingData': drawingData,
    };
  }

  /// Map'ten oluştur
  factory Note.fromMap(Map<String, dynamic> map) {
    return Note(
      id: map['id'] as String,
      courseId: map['courseId'] as String,
      type: NoteType.values.firstWhere(
        (e) => e.name == map['type'],
        orElse: () => NoteType.text,
      ),
      title: map['title'] as String,
      content: map['content'] as String?,
      filePath: map['filePath'] as String?,
      thumbnailPath: map['thumbnailPath'] as String?,
      audioDuration: map['audioDuration'] as int?,
      tags:
          (map['tags'] as String?)
              ?.split(',')
              .where((s) => s.isNotEmpty)
              .toList() ??
          [],
      bookmarks:
          (map['bookmarks'] as String?)
              ?.split(',')
              .where((s) => s.isNotEmpty)
              .map((s) => Duration(milliseconds: int.parse(s)))
              .toList() ??
          [],
      isBookmarked: (map['isBookmarked'] as int) == 1,
      createdAt: DateTime.parse(map['createdAt'] as String),
      updatedAt: DateTime.parse(map['updatedAt'] as String),
      drawingData: map['drawingData'] as String?,
    );
  }
}
