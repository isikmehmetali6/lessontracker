import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:uuid/uuid.dart';

/// Dosya yönetimi servisi
class FileService {
  static final FileService _instance = FileService._internal();
  factory FileService() => _instance;
  FileService._internal();

  final _uuid = const Uuid();

  /// Uygulama dokümanlar dizini
  Future<Directory> get _documentsDir async {
    return await getApplicationDocumentsDirectory();
  }

  /// iOS sandbox path değişikliğini düzelt — eski mutlak yolları yeni dizinle güncelle
  Future<String?> resolveFilePath(String? storedPath) async {
    if (storedPath == null || storedPath.isEmpty) return null;

    // Mutlak yol ise ve dosya mevcutsa, mutlak yolu döndür
    // Göreceli yol ise (images/xxx.jpg gibi) mutlak yola çevir
    if (storedPath.startsWith('/')) {
      if (await File(storedPath).exists()) return storedPath;
    } else {
      // Göreceli yol — mutlak yola çevir
      final docs = await _documentsDir;
      final absolutePath = path.join(docs.path, storedPath);
      if (await File(absolutePath).exists()) return absolutePath;
    }

    final knownDirs = [
      'images/',
      'audio/',
      'course_materials/',
      'restored_notes/',
    ];

    // Göreceli yol ise (images/xxx.jpg gibi) doğrudan documents dizinindeki tam yolu oluştur
    for (final dir in knownDirs) {
      if (storedPath.startsWith(dir)) {
        final docs = await _documentsDir;
        final resolvedPath = path.join(docs.path, storedPath);
        // Ensure parent directory exists when checking or creating
        final parentDir = Directory(path.dirname(resolvedPath));
        if (!await parentDir.exists()) {
          await parentDir.create(recursive: true);
        }
        if (await File(resolvedPath).exists()) {
          return resolvedPath;
        }
      }
    }

    // Mutlak yoldan relative path'i çıkar (images/xxx.jpg veya audio/xxx.m4a)
    for (final dir in knownDirs) {
      final idx = storedPath.indexOf(dir);
      if (idx != -1) {
        final relativePath = storedPath.substring(idx);
        final docs = await _documentsDir;
        final resolvedPath = path.join(docs.path, relativePath);

        final parentDir = Directory(path.dirname(resolvedPath));
        if (!await parentDir.exists()) {
          await parentDir.create(recursive: true);
        }

        if (await File(resolvedPath).exists()) {
          debugPrint(
            '[FileService] Resolved path: $storedPath -> $resolvedPath',
          );
          return resolvedPath;
        }
      }
    }

    // Son çare: Tüm knownDirs içinde recursive ara (course_materials öncelikli)
    final fileName = path.basename(storedPath);
    final docs = await _documentsDir;

    // Önce course_materials içinde ID/ dosya yapısında ara
    final courseMatDir = Directory(path.join(docs.path, 'course_materials'));
    if (await courseMatDir.exists()) {
      await for (final entity in courseMatDir.list(recursive: true)) {
        if (entity is File && path.basename(entity.path) == fileName) {
          debugPrint(
            '[FileService] Found in course_materials: $storedPath -> ${entity.path}',
          );
          return entity.path;
        }
      }
    }

    // Tüm knownDirs içinde basename ile ara (images/, audio/, restored_notes/)
    for (final dir in knownDirs) {
      final searchDir = Directory(path.join(docs.path, dir));
      if (!await searchDir.exists()) continue;

      await for (final entity in searchDir.list()) {
        if (entity is File && path.basename(entity.path) == fileName) {
          debugPrint(
            '[FileService] Found by basename in $dir: $storedPath -> ${entity.path}',
          );
          return entity.path;
        }
      }
    }

    debugPrint('[FileService] ⚠️ Could not resolve file: $storedPath');
    return null; // dosya bulunamazsa null döndür
  }

  /// Resimler klasörü
  Future<Directory> get _imagesDir async {
    final docs = await _documentsDir;
    final dir = Directory(path.join(docs.path, 'images'));
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    return dir;
  }

  /// Ses kayıtları klasörü
  Future<Directory> get _audioDir async {
    final docs = await _documentsDir;
    final dir = Directory(path.join(docs.path, 'audio'));
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    return dir;
  }

  /// Önbellek klasörü
  Future<Directory> get _cacheDir async {
    return await getTemporaryDirectory();
  }

  /// Benzersiz dosya adı oluştur
  String _generateFileName(String extension) {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final uniqueId = _uuid.v4().substring(0, 8);
    return '${timestamp}_$uniqueId.$extension';
  }

  /// Resim kaydet — göreceli yol döndürür (iOS sandbox-safe)
  Future<String> saveImage(File sourceFile) async {
    final imagesDir = await _imagesDir;
    final extension = path.extension(sourceFile.path).replaceFirst('.', '');
    final fileName = _generateFileName(extension.isEmpty ? 'jpg' : extension);
    final destPath = path.join(imagesDir.path, fileName);

    // Kaynak dosya var mı kontrol et
    if (!await sourceFile.exists()) {
      debugPrint(
        '[FileService] ⚠️ Source image file does not exist: ${sourceFile.path}',
      );
      throw Exception('Source image file does not exist');
    }

    await sourceFile.copy(destPath);

    // Doğrulama: kopyalanan dosya gerçekten var mı?
    final destFile = File(destPath);
    if (!await destFile.exists()) {
      debugPrint('[FileService] ⚠️ Image copy failed! Dest: $destPath');
      throw Exception('Image copy verification failed');
    }

    final size = await destFile.length();
    debugPrint('[FileService] ✅ Image saved: $destPath ($size bytes)');

    // Göreceli yol döndür (images/xxx.jpg) — iOS sandbox-safe
    return 'images/$fileName';
  }

  /// Ses kaydı kaydet — göreceli yol döndürür (iOS sandbox-safe)
  Future<String> saveAudio(File sourceFile) async {
    final audioDir = await _audioDir;
    final extension = path.extension(sourceFile.path).replaceFirst('.', '');
    final fileName = _generateFileName(extension.isEmpty ? 'm4a' : extension);
    final destPath = path.join(audioDir.path, fileName);

    if (!await sourceFile.exists()) {
      debugPrint(
        '[FileService] ⚠️ Source audio file does not exist: ${sourceFile.path}',
      );
      throw Exception('Source audio file does not exist');
    }

    await sourceFile.copy(destPath);

    // Doğrulama
    final destFile = File(destPath);
    if (!await destFile.exists()) {
      debugPrint('[FileService] ⚠️ Audio copy failed! Dest: $destPath');
      throw Exception('Audio copy verification failed');
    }

    final size = await destFile.length();
    debugPrint('[FileService] ✅ Audio saved: $destPath ($size bytes)');

    // Göreceli yol döndür (audio/xxx.m4a)
    return 'audio/$fileName';
  }

  /// Ses kaydı için geçici dosya yolu oluştur
  Future<String> getTempAudioPath() async {
    final cacheDir = await _cacheDir;
    final fileName = _generateFileName('m4a');
    return path.join(cacheDir.path, fileName);
  }

  /// Dosya sil (göreceli ve mutlak yolları destekler)
  Future<bool> deleteFile(String filePath) async {
    try {
      final resolvedPath = await resolveFilePath(filePath);
      if (resolvedPath == null) return false;
      final file = File(resolvedPath);
      if (await file.exists()) {
        await file.delete();
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  /// Dosya var mı?
  Future<bool> fileExists(String filePath) async {
    final resolved = await resolveFilePath(filePath);
    if (resolved == null) return false;
    return await File(resolved).exists();
  }

  /// Dosya boyutu
  Future<int> getFileSize(String filePath) async {
    final resolved = await resolveFilePath(filePath);
    if (resolved == null) return 0;
    final file = File(resolved);
    if (await file.exists()) {
      return await file.length();
    }
    return 0;
  }

  /// Dosya boyutunu formatla
  String formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  /// Tüm resimleri getir
  Future<List<File>> getAllImages() async {
    final imagesDir = await _imagesDir;
    if (!await imagesDir.exists()) return [];

    final files = <File>[];
    await for (final entity in imagesDir.list()) {
      if (entity is File && _isImageFile(entity.path)) {
        files.add(entity);
      }
    }
    return files;
  }

  /// Tüm ses kayıtlarını getir
  Future<List<File>> getAllAudio() async {
    final audioDir = await _audioDir;
    if (!await audioDir.exists()) return [];

    final files = <File>[];
    await for (final entity in audioDir.list()) {
      if (entity is File && _isAudioFile(entity.path)) {
        files.add(entity);
      }
    }
    return files;
  }

  /// Resim dosyası mı?
  bool _isImageFile(String filePath) {
    final ext = path.extension(filePath).toLowerCase();
    return ['.jpg', '.jpeg', '.png', '.gif', '.webp', '.heic'].contains(ext);
  }

  /// Ses dosyası mı?
  bool _isAudioFile(String filePath) {
    final ext = path.extension(filePath).toLowerCase();
    return ['.m4a', '.mp3', '.wav', '.aac', '.ogg'].contains(ext);
  }

  /// Kullanılmayan dosyaları temizle
  /// [usedPaths] can contain relative or absolute paths
  Future<int> cleanupUnusedFiles(List<String> usedPaths) async {
    int deletedCount = 0;
    final docs = await _documentsDir;

    // Resolve all used paths to absolute and also keep relative forms for comparison
    final resolvedUsedPaths = <String>{};
    for (final p in usedPaths) {
      resolvedUsedPaths.add(p);
      if (!p.startsWith('/')) {
        resolvedUsedPaths.add(path.join(docs.path, p));
      } else {
        final knownDirs = [
          'images/',
          'audio/',
          'course_materials/',
          'restored_notes/',
        ];
        for (final dir in knownDirs) {
          final idx = p.indexOf(dir);
          if (idx != -1) {
            resolvedUsedPaths.add(p.substring(idx));
            break;
          }
        }
      }
    }

    final allImages = await getAllImages();
    for (final file in allImages) {
      final relativePath = 'images/${path.basename(file.path)}';
      if (!resolvedUsedPaths.contains(file.path) &&
          !resolvedUsedPaths.contains(relativePath)) {
        await deleteFile(file.path);
        deletedCount++;
      }
    }

    final allAudio = await getAllAudio();
    for (final file in allAudio) {
      final relativePath = 'audio/${path.basename(file.path)}';
      if (!resolvedUsedPaths.contains(file.path) &&
          !resolvedUsedPaths.contains(relativePath)) {
        await deleteFile(file.path);
        deletedCount++;
      }
    }

    return deletedCount;
  }

  /// Toplam depolama kullanımı
  Future<int> getTotalStorageUsage() async {
    int total = 0;

    final allImages = await getAllImages();
    for (final file in allImages) {
      total += await file.length();
    }

    final allAudio = await getAllAudio();
    for (final file in allAudio) {
      total += await file.length();
    }

    return total;
  }
}
