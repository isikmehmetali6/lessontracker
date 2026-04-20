import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

class WatermarkService {
  static Future<File?> addWatermarkToImage({
    required File imageFile,
    required String courseName,
    required String userName,
    String? additionalText,
  }) async {
    try {
      final bytes = await imageFile.readAsBytes();
      final codec = await ui.instantiateImageCodec(bytes);
      final frame = await codec.getNextFrame();
      final image = frame.image;

      final recorder = ui.PictureRecorder();
      final canvas = Canvas(recorder);
      final size = Size(image.width.toDouble(), image.height.toDouble());

      canvas.drawImage(image, Offset.zero, Paint());

      final watermarkText = _buildWatermarkText(
        courseName: courseName,
        userName: userName,
        additionalText: additionalText,
      );

      _drawWatermark(canvas, size, watermarkText);

      final picture = recorder.endRecording();
      final watermarkedImage = await picture.toImage(image.width, image.height);

      final pngBytes = await watermarkedImage.toByteData(
        format: ui.ImageByteFormat.png,
      );

      if (pngBytes == null) return null;

      final dir = await getTemporaryDirectory();
      final fileName =
          'watermarked_${DateTime.now().millisecondsSinceEpoch}.png';
      final outputFile = File('${dir.path}/$fileName');
      await outputFile.writeAsBytes(pngBytes.buffer.asUint8List());

      return outputFile;
    } catch (e) {
      debugPrint('Watermark error: $e');
      return null;
    }
  }

  static String _buildWatermarkText({
    required String courseName,
    required String userName,
    String? additionalText,
  }) {
    final buffer = StringBuffer();
    buffer.writeln('Kişisel Kullanım');
    buffer.writeln('Ders: $courseName');
    buffer.writeln('Kullanıcı: $userName');
    buffer.writeln('Tarih: ${_formatDate(DateTime.now())}');
    if (additionalText != null && additionalText.isNotEmpty) {
      buffer.writeln(additionalText);
    }
    return buffer.toString();
  }

  static void _drawWatermark(Canvas canvas, Size size, String text) {
    final textStyle = ui.TextStyle(
      color: Colors.white.withAlpha((0.6 * 255).round()),
      fontSize: size.width * 0.03,
      fontWeight: FontWeight.w600,
    );

    final paragraphStyle = ui.ParagraphStyle(
      textAlign: TextAlign.left,
      maxLines: 5,
    );

    final builder = ui.ParagraphBuilder(paragraphStyle)
      ..pushStyle(textStyle)
      ..addText(text);

    final paragraph = builder.build();
    paragraph.layout(ui.ParagraphConstraints(width: size.width * 0.4));

    final textRect = Rect.fromLTWH(
      size.width * 0.02,
      size.height * 0.02,
      paragraph.width + 20,
      paragraph.height + 20,
    );

    final bgPaint = Paint()
      ..color = Colors.black.withAlpha((0.4 * 255).round())
      ..style = PaintingStyle.fill;

    canvas.drawRRect(
      RRect.fromRectAndRadius(textRect, const Radius.circular(8)),
      bgPaint,
    );

    canvas.drawParagraph(
      paragraph,
      Offset(textRect.left + 10, textRect.top + 10),
    );
  }

  static String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  static String generateExportWatermark({
    required String userName,
    required String courseName,
    String fskText =
        'Bu içerik 5846 Sayılı FSK kapsamında şahsi kullanım amacıyla kaydedilmiştir.',
  }) {
    final now = DateTime.now();
    return 'Kişisel Kullanım - $userName - ${_formatDate(now)}\n$fskText\nDers: $courseName';
  }
}
