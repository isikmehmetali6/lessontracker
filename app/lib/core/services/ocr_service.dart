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
    if (kIsWeb) {
      return OcrResult(
        fullText: '',
        blocks: [],
        success: false,
        error: 'OCR is not supported on web',
      );
    }
    try {
      if (!await File(imagePath).exists()) {
        debugPrint('[OcrService] ⚠️ Image file not found at path: $imagePath');
        return OcrResult(
          fullText: '',
          blocks: [],
          success: false,
          error: 'Image file not found',
        );
      }

      // Validate image format
      final ext = imagePath.split('.').last.toLowerCase();
      final supportedFormats = ['jpg', 'jpeg', 'png', 'bmp', 'gif'];
      if (!supportedFormats.contains(ext)) {
        debugPrint('[OcrService] ⚠️ Unsupported format: $ext');
        return OcrResult(
          fullText: '',
          blocks: [],
          success: false,
          error: 'Unsupported image format (.$ext). Please use JPG, PNG, or BMP.',
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

      if (recognizedText.text.trim().isEmpty) {
        return OcrResult(
          fullText: '',
          blocks: [],
          success: false,
          error: 'No text found in image. Make sure the text is clear and well-lit.',
        );
      }

      return OcrResult(
        fullText: recognizedText.text,
        blocks: blocks,
        success: true,
      );
    } catch (e) {
      final errorMsg = e.toString().toLowerCase();
      String userMessage;
      if (errorMsg.contains('format') || errorMsg.contains('decode')) {
        userMessage = 'Image format not supported. Please use JPG or PNG.';
      } else if (errorMsg.contains('memory') || errorMsg.contains('size')) {
        userMessage = 'Image is too large. Try with a smaller resolution.';
      } else {
        userMessage = 'OCR processing failed. Please try again.';
      }
      return OcrResult(
        fullText: '',
        blocks: [],
        success: false,
        error: userMessage,
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

  /// Metin boş mu?
  bool get isEmpty => fullText.trim().isEmpty;

  /// Metin var mı?
  bool get hasText => fullText.trim().isNotEmpty;

  /// Kelime sayısı
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
