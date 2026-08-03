import 'dart:io';
import 'package:flutter/foundation.dart';

/// Helpers for computing the on-disk size of arbitrary directories.
///
/// Extracted from StorageScreen per plan 3.1.5.
class DirectorySizeUtils {
  DirectorySizeUtils._();

  /// Sum of all file sizes under [dir] (recursive). Returns 0 on error.
  static Future<int> directorySize(Directory dir) async {
    int size = 0;
    try {
      if (await dir.exists()) {
        await for (var entity in dir.list(
          recursive: true,
          followLinks: false,
        )) {
          if (entity is File) {
            size += await entity.length();
          }
        }
      }
    } catch (e, stackTrace) {
      debugPrint(
        'Error getting directory size for ${dir.path}: $e\nStack: $stackTrace',
      );
    }
    return size;
  }

  /// Human-readable byte count (B / KB / MB / GB).
  static String formatBytes(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }
}