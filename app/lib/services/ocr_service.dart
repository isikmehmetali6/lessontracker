import 'dart:io';
import 'dart:ui';
import 'package:flutter/foundation.dart';

/// OCR Servisi - Apple Silicon simulator build'leri için stub.
/// Fiziksel cihazda veya Intel Mac'te google_mlkit_text_recognition kullanılır.
class OcrService {
  static final OcrService _instance = OcrService._internal();
  factory OcrService() => _instance;
  OcrService._internal();

  /// Resimden metin çıkar (stub)
  Future<OcrResult> recognizeText(String imagePath) async {
    debugPrint('[OcrService] ⚠️ OCR devre dışı (simulator build)');
    return OcrResult(
      fullText: '',
      blocks: [],
      success: false,
      error: 'OCR özelliği Apple Silicon simulator buildinde devre dışıdır. Fiziksel cihazda deneyin.',
    );
  }

  /// Resim dosyasından metin çıkar
  Future<OcrResult> recognizeTextFromFile(File file) async {
    return recognizeText(file.path);
  }

  /// Servisi kapat
  Future<void> close() async {}
}

/// OCR sonucu
class OcrResult {
  final String fullText;
  final List<OcrBlock> blocks;
  final bool success;
  final String? error;

  OcrResult({
    required this.fullText,
    required this.blocks,
    required this.success,
    this.error,
  });

  bool get isEmpty => fullText.trim().isEmpty;
  bool get hasText => fullText.trim().isNotEmpty;

  int get wordCount {
    final trimmed = fullText.trim();
    if (trimmed.isEmpty) return 0;
    return trimmed.split(RegExp(r'\s+')).length;
  }
}

/// OCR blok
class OcrBlock {
  final String text;
  final List<OcrLine> lines;
  final Rect boundingBox;

  OcrBlock({
    required this.text,
    required this.lines,
    required this.boundingBox,
  });
}

/// OCR satır
class OcrLine {
  final String text;
  final double confidence;
  final Rect boundingBox;

  OcrLine({
    required this.text,
    required this.confidence,
    required this.boundingBox,
  });
}