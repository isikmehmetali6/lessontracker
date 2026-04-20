/// Bir dersin içindeki bölüm (hafta/konu)
class MoodleCourseSection {
  final int id;
  final String name;
  final String? summary;
  final int sectionNumber;
  final List<MoodleCourseModule> modules;

  const MoodleCourseSection({
    required this.id,
    required this.name,
    this.summary,
    required this.sectionNumber,
    required this.modules,
  });

  factory MoodleCourseSection.fromApiJson(Map<String, dynamic> json) {
    final modulesJson = json['modules'] as List<dynamic>? ?? [];
    return MoodleCourseSection(
      id: json['id'] as int,
      name: json['name'] as String? ?? 'Bölüm ${json['section']}',
      summary: json['summary'] as String?,
      sectionNumber: json['section'] as int? ?? 0,
      modules: modulesJson
          .map((m) => MoodleCourseModule.fromApiJson(m as Map<String, dynamic>))
          .toList(),
    );
  }

  /// Dosya içeren modülleri filtrele
  List<MoodleCourseModule> get fileModules =>
      modules.where((m) => m.contents.isNotEmpty).toList();
}

/// Bir modül (aktivite/kaynak): PDF, slayt, quiz, URL vb.
class MoodleCourseModule {
  final int id;
  final String name;
  final String? description;
  final String modName; // 'resource', 'url', 'assign', 'quiz', 'forum', 'folder', 'page' vb.
  final String? modIcon;
  final List<MoodleModuleFile> contents;

  const MoodleCourseModule({
    required this.id,
    required this.name,
    this.description,
    required this.modName,
    this.modIcon,
    required this.contents,
  });

  factory MoodleCourseModule.fromApiJson(Map<String, dynamic> json) {
    final contentsJson = json['contents'] as List<dynamic>? ?? [];
    return MoodleCourseModule(
      id: json['id'] as int,
      name: json['name'] as String? ?? '',
      description: json['description'] as String?,
      modName: json['modname'] as String? ?? 'unknown',
      modIcon: json['modicon'] as String?,
      contents: contentsJson
          .map((c) => MoodleModuleFile.fromApiJson(c as Map<String, dynamic>))
          .toList(),
    );
  }

  /// Bu modül bir dosya mı (PDF, slayt vb.)
  bool get isFile => modName == 'resource' || modName == 'folder';
  bool get isUrl => modName == 'url';
  bool get isQuiz => modName == 'quiz';
  bool get isAssignment => modName == 'assign';
  bool get isForum => modName == 'forum';
  bool get isPage => modName == 'page';

  /// Ana dosya (resource modüllerinde genelde tek dosya olur)
  MoodleModuleFile? get primaryFile => contents.isNotEmpty ? contents.first : null;
}

/// Bir modülün içindeki dosya
class MoodleModuleFile {
  final String fileName;
  final String? fileUrl;
  final int fileSize; // bytes
  final String? mimeType;
  final int? timeModified;

  const MoodleModuleFile({
    required this.fileName,
    this.fileUrl,
    required this.fileSize,
    this.mimeType,
    this.timeModified,
  });

  factory MoodleModuleFile.fromApiJson(Map<String, dynamic> json) {
    return MoodleModuleFile(
      fileName: json['filename'] as String? ?? 'Bilinmeyen dosya',
      fileUrl: json['fileurl'] as String?,
      fileSize: json['filesize'] as int? ?? 0,
      mimeType: json['mimetype'] as String?,
      timeModified: json['timemodified'] as int?,
    );
  }

  /// Dosya boyutunu okunabilir formata çevir
  String get readableSize {
    if (fileSize < 1024) return '$fileSize B';
    if (fileSize < 1024 * 1024) return '${(fileSize / 1024).toStringAsFixed(1)} KB';
    return '${(fileSize / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  /// Dosya uzantısı
  String get extension {
    final parts = fileName.split('.');
    return parts.length > 1 ? parts.last.toLowerCase() : '';
  }

  bool get isPdf => extension == 'pdf';
  bool get isImage => ['jpg', 'jpeg', 'png', 'gif', 'webp'].contains(extension);
  bool get isSlide => ['pptx', 'ppt', 'odp'].contains(extension);
  bool get isDocument => ['docx', 'doc', 'odt', 'txt', 'rtf'].contains(extension);
  bool get isSpreadsheet => ['xlsx', 'xls', 'csv', 'ods'].contains(extension);
  bool get isVideo => ['mp4', 'avi', 'mkv', 'mov'].contains(extension);
  bool get isAudio => ['mp3', 'wav', 'ogg', 'm4a'].contains(extension);

  /// Token'lı indirme URL'i oluştur
  String downloadUrl(String token) {
    if (fileUrl == null) return '';
    final separator = fileUrl!.contains('?') ? '&' : '?';
    return '$fileUrl${separator}token=$token';
  }
}
