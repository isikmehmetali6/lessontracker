import 'dart:io';
import 'dart:ui';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import '../../models/note.dart';
import '../../models/course.dart';
import 'file_service.dart';

/// PDF ve paylaşım servisi
class ExportService {
  /// iOS'ta sharePositionOrigin zorunlu — varsayılan orta nokta
  static const Rect _shareOrigin = Rect.fromLTWH(0, 0, 1, 1);
  /// Nota ait resim varsa pw.Image widget'ı oluştur
  static Future<pw.Widget?> _buildNoteImage(Note note) async {
    // Önce thumbnailPath, yoksa filePath'i dene (image/ocr notları için)
    final imagePath = note.thumbnailPath ?? 
        ((note.type == NoteType.image || note.type == NoteType.ocr) ? note.filePath : null);
    
    if (imagePath == null) return null;
    
    // Resolve path (handles relative paths)
    final resolvedPath = await FileService().resolveFilePath(imagePath);
    if (resolvedPath == null) return null;
    
    final file = File(resolvedPath);
    if (!await file.exists()) return null;
    
    try {
      final bytes = await file.readAsBytes();
      final image = pw.MemoryImage(bytes);
      
      return pw.Container(
        margin: const pw.EdgeInsets.only(bottom: 16),
        child: pw.ClipRRect(
          horizontalRadius: 8,
          verticalRadius: 8,
          child: pw.Image(
            image,
            width: double.infinity,
            fit: pw.BoxFit.fitWidth,
          ),
        ),
      );
    } catch (_) {
      return null;
    }
  }

  /// Tek bir notu PDF olarak dışa aktar
  static Future<void> exportNoteToPdf(Note note, {String? courseName}) async {
    final pdf = pw.Document();

    // Resmi önceden yükle (async)
    final imageWidget = await _buildNoteImage(note);

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (context) => [
          pw.Header(
            level: 0,
            child: pw.Text(
              note.title,
              style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold),
            ),
          ),
          if (courseName != null)
            pw.Padding(
              padding: const pw.EdgeInsets.only(bottom: 8),
              child: pw.Text(
                'Course: $courseName',
                style: pw.TextStyle(
                  fontSize: 12,
                  color: PdfColors.grey600,
                  fontStyle: pw.FontStyle.italic,
                ),
              ),
            ),
          pw.Padding(
            padding: const pw.EdgeInsets.only(bottom: 16),
            child: pw.Row(
              children: [
                pw.Text(
                  'Created: ${note.createdAt!.day}/${note.createdAt!.month}/${note.createdAt!.year}',
                  style: pw.TextStyle(fontSize: 10, color: PdfColors.grey500),
                ),
                pw.SizedBox(width: 16),
                pw.Container(
                  padding: const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: pw.BoxDecoration(
                    color: PdfColors.grey100,
                    borderRadius: pw.BorderRadius.circular(4),
                  ),
                  child: pw.Text(
                    note.type.name.toUpperCase(),
                    style: pw.TextStyle(fontSize: 8, color: PdfColors.grey600),
                  ),
                ),
              ],
            ),
          ),
          pw.Divider(),
          pw.SizedBox(height: 12),
          // 📸 Fotoğraf varsa göster
          if (imageWidget != null) imageWidget,
          // 📝 Metin içeriği
          if (note.content != null && note.content!.isNotEmpty)
            pw.Paragraph(
              text: note.content!,
              style: const pw.TextStyle(fontSize: 12, lineSpacing: 6),
            ),
          // 🏷 Etiketler
          if (note.tags.isNotEmpty)
            pw.Padding(
              padding: const pw.EdgeInsets.only(top: 16),
              child: pw.Wrap(
                spacing: 6,
                children: note.tags.map((tag) {
                  return pw.Container(
                    padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: pw.BoxDecoration(
                      color: PdfColors.blue50,
                      borderRadius: pw.BorderRadius.circular(8),
                    ),
                    child: pw.Text('#$tag', style: pw.TextStyle(fontSize: 10, color: PdfColors.blue800)),
                  );
                }).toList(),
              ),
            ),
        ],
      ),
    );

    await Printing.layoutPdf(onLayout: (format) => pdf.save());
  }

  /// Tüm notları ders bazlı PDF olarak dışa aktar
  static Future<void> exportAllNotesToPdf(
    Map<Course, List<Note>> courseNotes,
  ) async {
    final pdf = pw.Document();

    // Kapak sayfası
    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (context) => pw.Center(
          child: pw.Column(
            mainAxisAlignment: pw.MainAxisAlignment.center,
            children: [
              pw.Text(
                'Study Notes',
                style: pw.TextStyle(fontSize: 36, fontWeight: pw.FontWeight.bold),
              ),
              pw.SizedBox(height: 16),
              pw.Text(
                'Exported on ${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}',
                style: pw.TextStyle(fontSize: 14, color: PdfColors.grey600),
              ),
              pw.SizedBox(height: 8),
              pw.Text(
                '${courseNotes.length} courses • ${courseNotes.values.fold<int>(0, (sum, list) => sum + list.length)} notes',
                style: pw.TextStyle(fontSize: 12, color: PdfColors.grey500),
              ),
            ],
          ),
        ),
      ),
    );

    // Her ders için sayfalar
    for (final entry in courseNotes.entries) {
      final course = entry.key;
      final notes = entry.value;
      if (notes.isEmpty) continue;

      // Resimleri önceden yükle
      final noteImages = <String, pw.Widget>{};
      for (final note in notes) {
        final img = await _buildNoteImage(note);
        if (img != null) noteImages[note.id] = img;
      }

      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(32),
          header: (context) => pw.Container(
            padding: const pw.EdgeInsets.only(bottom: 12),
            decoration: const pw.BoxDecoration(
              border: pw.Border(bottom: pw.BorderSide(color: PdfColors.grey300)),
            ),
            child: pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text(
                  course.name,
                  style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold),
                ),
                pw.Text(
                  '${notes.length} notes',
                  style: pw.TextStyle(fontSize: 10, color: PdfColors.grey500),
                ),
              ],
            ),
          ),
          build: (context) => notes.map((note) {
            return pw.Container(
              margin: const pw.EdgeInsets.only(bottom: 20),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    note.title,
                    style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold),
                  ),
                  pw.SizedBox(height: 4),
                  pw.Text(
                    '${note.createdAt!.day}/${note.createdAt!.month}/${note.createdAt!.year} • ${note.type.name}',
                    style: pw.TextStyle(fontSize: 9, color: PdfColors.grey500),
                  ),
                  pw.SizedBox(height: 6),
                  // 📸 Resim
                  if (noteImages.containsKey(note.id)) noteImages[note.id]!,
                  // 📝 İçerik
                  if (note.content != null && note.content!.isNotEmpty)
                    pw.Text(
                      note.content!,
                      style: const pw.TextStyle(fontSize: 11, lineSpacing: 4),
                    ),
                  pw.Divider(color: PdfColors.grey200),
                ],
              ),
            );
          }).toList(),
        ),
      );
    }

    await Printing.layoutPdf(onLayout: (format) => pdf.save());
  }

  /// Notu metin olarak paylaş
  static Future<void> shareNoteAsText(Note note, {String? courseName}) async {
    final buffer = StringBuffer();
    buffer.writeln('📝 ${note.title}');
    if (courseName != null && courseName.isNotEmpty) {
      buffer.writeln('📚 $courseName');
    }
    buffer.writeln('📅 ${note.createdAt!.day}/${note.createdAt!.month}/${note.createdAt!.year}');
    buffer.writeln('---');
    if (note.content != null && note.content!.isNotEmpty) {
      buffer.writeln(note.content);
    }
    if (note.tags.isNotEmpty) {
      buffer.writeln();
      buffer.writeln(note.tags.map((t) => '#$t').join(' '));
    }

    // Resim varsa dosya olarak da ekle — hata olursa sadece text paylaş
    try {
      final imagePath = note.thumbnailPath ?? 
          ((note.type == NoteType.image || note.type == NoteType.ocr) ? note.filePath : null);
      if (imagePath != null) {
        final resolvedPath = await FileService().resolveFilePath(imagePath);
        if (resolvedPath != null && await File(resolvedPath).exists()) {
          await Share.shareXFiles(
            [XFile(resolvedPath)],
            text: buffer.toString(),
            sharePositionOrigin: _shareOrigin,
          );
          return;
        }
      }
    } catch (_) {
      // Image share failed, fall back to text
    }
    
    // Fallback: sadece text paylaş
    await Share.share(buffer.toString(), sharePositionOrigin: _shareOrigin);
  }

  /// Notu PDF dosyası olarak paylaş (fotoğraf dahil)
  static Future<void> shareNoteAsPdf(Note note, {String? courseName}) async {
    try {
      final pdf = pw.Document();
      final imageWidget = await _buildNoteImage(note);

      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(32),
          build: (context) => [
            pw.Text(note.title, style: pw.TextStyle(fontSize: 22, fontWeight: pw.FontWeight.bold)),
            if (courseName != null && courseName.isNotEmpty) pw.SizedBox(height: 4),
            if (courseName != null && courseName.isNotEmpty)
              pw.Text('Course: $courseName', style: pw.TextStyle(fontSize: 11, color: PdfColors.grey600)),
            pw.SizedBox(height: 16),
            pw.Divider(),
            pw.SizedBox(height: 12),
            if (imageWidget != null) imageWidget,
            if (note.content != null && note.content!.isNotEmpty)
              pw.Text(note.content!, style: const pw.TextStyle(fontSize: 12, lineSpacing: 5)),
          ],
        ),
      );

      final dir = await getTemporaryDirectory();
      final file = File('${dir.path}/note_${note.id.substring(0, 8)}.pdf');
      await file.writeAsBytes(await pdf.save());

      await Share.shareXFiles(
        [XFile(file.path)],
        text: note.title,
        sharePositionOrigin: _shareOrigin,
      );
    } catch (e) {
      rethrow;
    }
  }

  /// Notun orijinal dosyasını (resim/ses) paylaş
  static Future<void> shareNoteFile(Note note) async {
    final filePath = note.filePath;
    if (filePath == null) {
      throw Exception('No file attached to this note');
    }
    
    // Resolve path (handles relative paths)
    final resolvedPath = await FileService().resolveFilePath(filePath);
    if (resolvedPath == null || !await File(resolvedPath).exists()) {
      throw Exception('File no longer exists on device');
    }
    
    try {
      // iOS'ta mimeType sorun çıkarabiliyor, parametresiz dene
      await Share.shareXFiles(
        [XFile(resolvedPath)],
        text: note.title,
        sharePositionOrigin: _shareOrigin,
      );
    } catch (_) {
      // Fallback: text parametresi olmadan dene
      try {
        await Share.shareXFiles([XFile(resolvedPath)], sharePositionOrigin: _shareOrigin);
      } catch (e2) {
        throw Exception('Could not share file');
      }
    }
  }
}
