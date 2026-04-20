import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';
import '../../models/course_file.dart';
import '../../repositories/file_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../models/moodle/moodle_course_content.dart';

/// Moodle dosyalarını (PDF, slayt, doküman) cihaza indirir.
/// Wi-Fi only modu ve indirme limiti destekler.
class MoodleFileDownloadService {
  static const String _prefWifiOnly = 'moodle_download_wifi_only';
  static const int _maxFileSizeMB = 100; // 100 MB limit

  /// İndirme klasörünü döner (uygulama documents dizini)
  static Future<Directory> get _downloadDir async {
    final appDir = await getApplicationDocumentsDirectory();
    final moodleDir = Directory('${appDir.path}/moodle_files');
    if (!await moodleDir.exists()) {
      await moodleDir.create(recursive: true);
    }
    return moodleDir;
  }

  /// Dosyayı indir ve yerel yolunu döner
  Future<String?> downloadFile({
    required MoodleModuleFile file,
    required String token,
    required String courseName,
    void Function(double progress)? onProgress,
  }) async {
    try {
      // Boyut kontrolü
      if (file.fileSize > _maxFileSizeMB * 1024 * 1024) {
        debugPrint('[MoodleDownload] File too large: ${file.readableSize}');
        return null;
      }

      final dir = await _downloadDir;
      // Ders adıyhla alt klasör oluştur
      final courseDir = Directory('${dir.path}/$courseName');
      if (!await courseDir.exists()) {
        await courseDir.create(recursive: true);
      }

      final localPath = '${courseDir.path}/${file.fileName}';
      final localFile = File(localPath);

      // Zaten indirilmişse doğrudan döner
      if (await localFile.exists()) {
        debugPrint('[MoodleDownload] Already exists: ${file.fileName}');
        return localPath;
      }

      // İndir
      final downloadUrl = file.downloadUrl(token);
      if (downloadUrl.isEmpty) return null;

      final request = http.Request('GET', Uri.parse(downloadUrl));
      final response = await http.Client().send(request);

      if (response.statusCode != 200) {
        debugPrint('[MoodleDownload] HTTP ${response.statusCode}');
        return null;
      }

      final totalBytes = response.contentLength ?? file.fileSize;
      int receivedBytes = 0;
      final sink = localFile.openWrite();

      await for (final chunk in response.stream) {
        sink.add(chunk);
        receivedBytes += chunk.length;
        if (onProgress != null && totalBytes > 0) {
          onProgress(receivedBytes / totalBytes);
        }
      }
      await sink.close();

      debugPrint('[MoodleDownload] Downloaded: ${file.fileName} (${file.readableSize})');
      return localPath;
    } catch (e) {
      debugPrint('[MoodleDownload] Error: $e');
      return null;
    }
  }

  /// İnen dosyayı uygulamanın kendi dersleri (Course) içine aktarır
  Future<bool> exportToAppCourse({
    required String moodleFilePath,
    required String courseId, // Hedef Course ID
    required String fileName,
  }) async {
    try {
      final sourceFile = File(moodleFilePath);
      if (!await sourceFile.exists()) return false;

      // Uygulamanın course_files dizini
      final docsDir = await getApplicationDocumentsDirectory();
      final targetDir = Directory('${docsDir.path}/course_files');
      if (!await targetDir.exists()) {
        await targetDir.create(recursive: true);
      }

      // Dosyayı oraya kopyala (benzersiz isimle)
      final uuid = const Uuid().v4();
      final ext = fileName.contains('.') ? fileName.split('.').last : '';
      final newFileName = '${uuid}_${DateTime.now().millisecondsSinceEpoch}.$ext';
      final targetPath = '${targetDir.path}/$newFileName';

      await sourceFile.copy(targetPath);

      // Veritabanına kaydet
      final type = ext.toLowerCase() == 'pdf'
          ? 'pdf'
          : (['png', 'jpg', 'jpeg'].contains(ext.toLowerCase())
              ? 'image'
              : 'other');
              
      final courseFile = CourseFile(
        id: uuid,
        courseId: courseId,
        path: targetPath,
        name: fileName,
        type: type,
        createdAt: DateTime.now(),
      );

      await FileRepository().insertFile(courseFile);
      return true;
    } catch (e) {
      if (kDebugMode) print('Moodle dosyasını derse aktarırken hata: $e');
      return false;
    }
  }

  /// İndirilen dosyanın yerel yolunu döner (yoksa null)
  Future<String?> getLocalPath({
    required String fileName,
    required String courseName,
  }) async {
    final dir = await _downloadDir;
    final path = '${dir.path}/$courseName/$fileName';
    if (await File(path).exists()) return path;
    return null;
  }

  /// Tüm indirilen dosyaların toplam boyutunu döner
  Future<int> getTotalDownloadSize() async {
    final dir = await _downloadDir;
    if (!await dir.exists()) return 0;

    int total = 0;
    await for (final entity in dir.list(recursive: true)) {
      if (entity is File) {
        total += await entity.length();
      }
    }
    return total;
  }

  /// Tüm indirmeleri sil
  Future<void> clearAllDownloads() async {
    final dir = await _downloadDir;
    if (await dir.exists()) {
      await dir.delete(recursive: true);
    }
  }

  /// Wi-Fi only mod getir/ayarla
  static Future<bool> isWifiOnly() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_prefWifiOnly) ?? false;
  }

  static Future<void> setWifiOnly(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_prefWifiOnly, value);
  }
}
