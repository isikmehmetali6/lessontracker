import 'dart:io';
import 'dart:ui';
import 'package:flutter/foundation.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

/// OCR Servisi - Google ML Kit ile metin tanıma
class OcrService {
  static final OcrService _instance = OcrService._internal();
  factory OcrService() => _instance;
  OcrService._internal();

  TextRecognizer? _textRecognizer;

  /// Text recognizer'ı başlat
  TextRecognizer get textRecognizer {
    _textRecognizer ??= TextRecognizer(script: TextRecognitionScript.latin);
    return _textRecognizer!;
  }

  /// Resimden metin çıkar
  Future<OcrResult> recognizeText(String imagePath) async {
    try {
      if (!await File(imagePath).exists()) {
        debugPrint('[OcrService] ⚠️ Image file not found at path: $imagePath');
        return OcrResult(
          fullText: '',
          blocks: [],
          success: false,
          error: 'Image file not found at path: $imagePath',
        );
      }

      final inputImage = InputImage.fromFilePath(imagePath);
      final recognizedText = await textRecognizer.processImage(inputImage);

      final blocks = <OcrBlock>[];
      for (final block in recognizedText.blocks) {
        final lines = <OcrLine>[];
        for (final line in block.lines) {
          lines.add(OcrLine(
            text: line.text,
            confidence: line.confidence ?? 0.0,
            boundingBox: line.boundingBox,
          ));
        }
        blocks.add(OcrBlock(
          text: block.text,
          lines: lines,
          boundingBox: block.boundingBox,
        ));
      }

      return OcrResult(
        fullText: recognizedText.text,
        blocks: blocks,
        success: true,
      );
    } catch (e) {
      return OcrResult(
        fullText: '',
        blocks: [],
        success: false,
        error: e.toString(),
      );
    }
  }

  /// Resim dosyasından metin çıkar
  Future<OcrResult> recognizeTextFromFile(File file) async {
    return recognizeText(file.path);
  }

  /// Servisi kapat
  Future<void> close() async {
    await _textRecognizer?.close();
    _textRecognizer = null;
  }
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
