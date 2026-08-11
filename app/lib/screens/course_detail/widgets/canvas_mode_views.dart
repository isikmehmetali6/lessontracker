import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:pdfx/pdfx.dart';
import '../../../core/theme/app_colors.dart';
import '../../../widgets/course/drawing_canvas.dart';

/// Blank-paper drawing layer: a plain surface with a [DrawingCanvas] on top.
class BlankCanvasView extends StatelessWidget {
  final List<DrawingStroke> strokes;
  final Color currentColor;
  final double currentSize;
  final ValueChanged<List<DrawingStroke>> onStrokesChanged;

  const BlankCanvasView({
    super.key,
    required this.strokes,
    required this.currentColor,
    required this.currentSize,
    required this.onStrokesChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: DrawingCanvas(
          strokes: strokes,
          currentColor: currentColor,
          currentSize: currentSize,
          backgroundColor: AppColors.surfaceLight,
          onStrokesChanged: onStrokesChanged,
        ),
      ),
    );
  }
}

/// Photo-annotation layer: picked photo with a transparent [DrawingCanvas]
/// overlay, or an empty-state hint before a photo is picked.
class PhotoCanvasView extends StatelessWidget {
  final Uint8List? photoBytes;
  final bool isDark;
  final String tapPhotoHint;
  final List<DrawingStroke> strokes;
  final Color currentColor;
  final double currentSize;
  final ValueChanged<List<DrawingStroke>> onStrokesChanged;

  const PhotoCanvasView({
    super.key,
    required this.photoBytes,
    required this.isDark,
    required this.tapPhotoHint,
    required this.strokes,
    required this.currentColor,
    required this.currentSize,
    required this.onStrokesChanged,
  });

  @override
  Widget build(BuildContext context) {
    if (photoBytes == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.add_photo_alternate_outlined,
              size: 64,
              color: isDark ? Colors.grey[600] : Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              tapPhotoHint,
              style: TextStyle(
                color: isDark ? Colors.grey[400] : Colors.grey[600],
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Photo
            Image.memory(photoBytes!, fit: BoxFit.contain),
            // Drawing overlay
            DrawingCanvas(
              strokes: strokes,
              currentColor: currentColor,
              currentSize: currentSize,
              backgroundColor: Colors.transparent,
              onStrokesChanged: onStrokesChanged,
            ),
          ],
        ),
      ),
    );
  }
}

/// PDF-annotation layer: [PdfViewPinch] with a transparent [DrawingCanvas]
/// overlay tracking the current page, or an empty-state hint before a PDF
/// is picked.
class PdfCanvasView extends StatelessWidget {
  final PdfControllerPinch? pdfController;
  final bool isDark;
  final String tapPdfHint;
  final List<DrawingStroke> strokes;
  final Color currentColor;
  final double currentSize;
  final ValueChanged<List<DrawingStroke>> onStrokesChanged;
  final void Function(PdfDocument document) onDocumentLoaded;
  final ValueChanged<int> onPageChanged;

  const PdfCanvasView({
    super.key,
    required this.pdfController,
    required this.isDark,
    required this.tapPdfHint,
    required this.strokes,
    required this.currentColor,
    required this.currentSize,
    required this.onStrokesChanged,
    required this.onDocumentLoaded,
    required this.onPageChanged,
  });

  @override
  Widget build(BuildContext context) {
    if (pdfController == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.picture_as_pdf_outlined,
              size: 64,
              color: isDark ? Colors.grey[600] : Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              tapPdfHint,
              style: TextStyle(
                color: isDark ? Colors.grey[400] : Colors.grey[600],
              ),
            ),
          ],
        ),
      );
    }

    return Stack(
      fit: StackFit.expand,
      children: [
        // PDF Viewer
        PdfViewPinch(
          controller: pdfController!,
          onDocumentLoaded: onDocumentLoaded,
          onPageChanged: onPageChanged,
        ),
        // Drawing overlay (transparency adjusted for annotation)
        DrawingCanvas(
          strokes: strokes,
          currentColor: currentColor.withValues(alpha: 0.7),
          currentSize: currentSize,
          backgroundColor: Colors.transparent,
          onStrokesChanged: onStrokesChanged,
        ),
      ],
    );
  }
}
