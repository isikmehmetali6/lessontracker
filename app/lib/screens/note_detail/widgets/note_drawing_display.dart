import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:pdfx/pdfx.dart';
import 'package:lesson_tracker/core/theme/app_colors.dart';
import 'package:lesson_tracker/core/utils/drawing_data_codec.dart';
import 'package:lesson_tracker/l10n/app_localizations.dart';
import 'package:lesson_tracker/services/file_service.dart';
import 'package:lesson_tracker/widgets/course/drawing_canvas.dart';

class NoteDrawingDisplay extends StatefulWidget {
  final String drawingData;
  final bool isDark;

  /// Path to the PDF this drawing was annotated on top of, if any (PDF
  /// canvas mode). When set, each page is rendered as a background layer
  /// behind its strokes instead of a plain surface.
  final String? pdfPath;

  const NoteDrawingDisplay({
    super.key,
    required this.drawingData,
    required this.isDark,
    this.pdfPath,
  });

  @override
  State<NoteDrawingDisplay> createState() => _NoteDrawingDisplayState();
}

class _NoteDrawingDisplayState extends State<NoteDrawingDisplay> {
  late final Map<int, List<DrawingStroke>> _strokesByPage =
      DrawingDataCodec.decode(widget.drawingData);
  final PageController _pageController = PageController();
  int _currentPage = 1;

  PdfDocument? _pdfDocument;
  final Map<int, Future<Uint8List?>> _pdfPageImages = {};

  @override
  void initState() {
    super.initState();
    _openPdfIfNeeded();
  }

  Future<void> _openPdfIfNeeded() async {
    final pdfPath = widget.pdfPath;
    if (pdfPath == null) return;
    final resolved = await FileService().resolveFilePath(pdfPath);
    if (resolved == null || !await File(resolved).exists()) return;
    try {
      final document = await PdfDocument.openFile(resolved);
      if (!mounted) {
        await document.close();
        return;
      }
      setState(() => _pdfDocument = document);
    } catch (_) {
      // PDF açılamadıysa sessizce boş arka planla devam et.
    }
  }

  Future<Uint8List?> _pdfPageImage(int pageNumber) {
    final document = _pdfDocument;
    if (document == null) return Future.value(null);
    if (pageNumber < 1 || pageNumber > document.pagesCount) {
      return Future.value(null);
    }
    return _pdfPageImages.putIfAbsent(pageNumber, () async {
      final page = await document.getPage(pageNumber);
      try {
        final image = await page.render(
          width: page.width * 2,
          height: page.height * 2,
          format: PdfPageImageFormat.jpeg,
        );
        return image?.bytes;
      } finally {
        await page.close();
      }
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    _pdfDocument?.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = widget.isDark;
    final pageNumbers = _strokesByPage.keys.toList()..sort();

    if (pageNumbers.isEmpty) {
      return Container(
        height: 200,
        decoration: BoxDecoration(
          color: isDark ? Colors.grey.shade800 : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Center(
          child: Text(AppLocalizations.of(context)!.noDrawingData),
        ),
      );
    }

    if (pageNumbers.length == 1) {
      return _buildPageCanvas(
        pageNumber: pageNumbers.first,
        strokes: _strokesByPage[pageNumbers.first]!,
        isDark: isDark,
        showIndicator: false,
      );
    }

    return Column(
      children: [
        SizedBox(
          height: 320,
          child: PageView.builder(
            controller: _pageController,
            itemCount: pageNumbers.length,
            onPageChanged: (index) {
              setState(() => _currentPage = pageNumbers[index]);
            },
            itemBuilder: (context, index) {
              final pageNum = pageNumbers[index];
              return _buildPageCanvas(
                pageNumber: pageNum,
                strokes: _strokesByPage[pageNum]!,
                isDark: isDark,
                showIndicator: false,
              );
            },
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              icon: const Icon(Icons.chevron_left),
              onPressed: _currentPage > pageNumbers.first
                  ? () => _pageController.previousPage(
                        duration: const Duration(milliseconds: 250),
                        curve: Curves.easeInOut,
                      )
                  : null,
            ),
            Text(
              '${pageNumbers.indexOf(_currentPage) + 1} / ${pageNumbers.length}',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            IconButton(
              icon: const Icon(Icons.chevron_right),
              onPressed: _currentPage < pageNumbers.last
                  ? () => _pageController.nextPage(
                        duration: const Duration(milliseconds: 250),
                        curve: Curves.easeInOut,
                      )
                  : null,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPageCanvas({
    required int pageNumber,
    required List<DrawingStroke> strokes,
    required bool isDark,
    required bool showIndicator,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          children: [
            if (widget.pdfPath != null) _buildPdfBackground(pageNumber),
            DrawingCanvas(
              strokes: strokes,
              currentColor: Colors.black,
              currentSize: 4.0,
              backgroundColor: widget.pdfPath != null
                  ? Colors.transparent
                  : AppColors.surfaceLight,
            ),
            if (showIndicator)
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'Sayfa $pageNumber',
                    style: const TextStyle(color: Colors.white, fontSize: 12),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildPdfBackground(int pageNumber) {
    if (_pdfDocument == null) {
      return Positioned.fill(
        child: Container(color: AppColors.surfaceLight),
      );
    }
    return Positioned.fill(
      child: FutureBuilder<Uint8List?>(
        future: _pdfPageImage(pageNumber),
        builder: (context, snapshot) {
          final bytes = snapshot.data;
          if (bytes == null) {
            return Container(
              color: AppColors.surfaceLight,
              child: snapshot.connectionState == ConnectionState.waiting
                  ? const Center(
                      child: SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    )
                  : null,
            );
          }
          return Image.memory(
            bytes,
            fit: BoxFit.contain,
            gaplessPlayback: true,
          );
        },
      ),
    );
  }
}
