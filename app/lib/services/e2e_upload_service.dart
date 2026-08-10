import 'dart:io';
import 'e2e_file_service.dart';
import 'e2e_key_service.dart';
import 'image_compressor_service.dart';

class E2EUploadService {
  static final E2EUploadService _instance = E2EUploadService._internal();
  factory E2EUploadService() => _instance;
  E2EUploadService._internal();

  final E2EFileService _e2eService = E2EFileService();

  bool _isImageFile(String path) {
    final lower = path.toLowerCase();
    return lower.contains('.jpg') ||
        lower.contains('.jpeg') ||
        lower.contains('.png') ||
        lower.contains('.heic');
  }

  Future<String?> uploadNoteFile(File file) async {
    if (!await E2EKeyService().isE2EEnabled()) return null;

    if (_isImageFile(file.path)) {
      return await _compressAndUpload(file, UploadType.photo);
    }
    return await _e2eService.uploadAudio(file);
  }

  Future<String?> uploadNoteThumbnail(File file) async {
    if (!await E2EKeyService().isE2EEnabled()) return null;
    return await _e2eService.uploadPhoto(file);
  }

  Future<String?> uploadCourseFile(File file) async {
    if (!await E2EKeyService().isE2EEnabled()) return null;

    if (_isImageFile(file.path)) {
      return await _compressAndUpload(file, UploadType.document);
    }
    return await _e2eService.uploadDocument(file);
  }

  Future<String?> _compressAndUpload(File file, UploadType type) async {
    final compressor = ImageCompressorService();
    final compressedBytes = await compressor.compressAndGetBytes(file.path);

    if (compressedBytes == null) {
      throw Exception('Image compression failed');
    }

    final tempPath = '${file.path}_compressed.jpg';
    final tempFile = File(tempPath);
    await tempFile.writeAsBytes(compressedBytes);

    try {
      final cloudPath = type == UploadType.photo
          ? await _e2eService.uploadPhoto(tempFile)
          : await _e2eService.uploadDocument(tempFile);
      return cloudPath;
    } finally {
      await tempFile.delete();
    }
  }
}

enum UploadType { photo, document }
