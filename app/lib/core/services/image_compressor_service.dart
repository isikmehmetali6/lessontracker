import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path/path.dart' as path;

class ImageCompressorService {
  static const int quality = 80;
  static const int maxWidth = 1920;
  static const int maxHeight = 1080;
  static const int compressionThresholdBytes = 5 * 1024 * 1024;

  static final ImageCompressorService _instance =
      ImageCompressorService._internal();
  factory ImageCompressorService() => _instance;
  ImageCompressorService._internal();

  Future<Uint8List?> compressAndGetBytes(String imagePath) async {
    try {
      final file = File(imagePath);
      if (!await file.exists()) {
        debugPrint('ImageCompressorService: File not found at $imagePath');
        return null;
      }

      final fileSize = await file.length();
      debugPrint('ImageCompressorService: Original file size: $fileSize bytes');

      Uint8List result;
      if (fileSize > compressionThresholdBytes) {
        result = await _compressWithPlugin(imagePath);
      } else {
        result = await file.readAsBytes();
      }

      debugPrint(
        'ImageCompressorService: Compressed size: ${result.length} bytes',
      );
      return result;
    } catch (e) {
      debugPrint('ImageCompressorService: Error compressing image - $e');
      final file = File(imagePath);
      if (await file.exists()) {
        return await file.readAsBytes();
      }
      return null;
    }
  }

  Future<Uint8List> _compressWithPlugin(String imagePath) async {
    try {
      final result = await FlutterImageCompress.compressWithFile(
        imagePath,
        quality: quality,
        minWidth: maxWidth,
        minHeight: maxHeight,
      );
      if (result != null) return result;
    } catch (e) {
      debugPrint('ImageCompressorService: Plugin compression failed - $e');
    }

    final file = File(imagePath);
    return await file.readAsBytes();
  }

  Future<File?> compressAndSave(String imagePath) async {
    final bytes = await compressAndGetBytes(imagePath);
    if (bytes == null) return null;

    final extension = path.extension(imagePath);
    final newExtension = extension.isNotEmpty ? extension : '.jpg';
    final basename = path.basenameWithoutExtension(imagePath);
    final directory = path.dirname(imagePath);
    final outputPath = path.join(
      directory,
      '${basename}_compressed$newExtension',
    );

    final outputFile = File(outputPath);
    await outputFile.writeAsBytes(bytes);
    return outputFile;
  }

  Future<Uint8List?> compressFromBytes(Uint8List bytes) async {
    try {
      final dynamic result = await FlutterImageCompress.compressWithList(
        bytes,
        quality: quality,
        minWidth: maxWidth,
        minHeight: maxHeight,
      );
      if (result != null) {
        return result as Uint8List;
      }
      return bytes;
    } catch (e) {
      debugPrint('ImageCompressorService: Error compressing bytes - $e');
      return bytes;
    }
  }

  bool shouldCompress(int fileSizeBytes) {
    return fileSizeBytes > compressionThresholdBytes;
  }

  Future<Uint8List?> compressIfNeeded(String imagePath) async {
    final file = File(imagePath);
    if (!await file.exists()) return null;

    final fileSize = await file.length();
    if (!shouldCompress(fileSize)) {
      return await file.readAsBytes();
    }

    return await compressAndGetBytes(imagePath);
  }
}
