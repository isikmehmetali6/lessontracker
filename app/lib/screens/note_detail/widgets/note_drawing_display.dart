import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:lesson_tracker/core/theme/app_colors.dart';
import 'package:lesson_tracker/l10n/app_localizations.dart';
import 'package:lesson_tracker/widgets/course/drawing_canvas.dart';

class NoteDrawingDisplay extends StatefulWidget {
  final String drawingData;
  final bool isDark;

  const NoteDrawingDisplay({
    super.key,
    required this.drawingData,
    required this.isDark,
  });

  @override
  State<NoteDrawingDisplay> createState() => _NoteDrawingDisplayState();
}

class _NoteDrawingDisplayState extends State<NoteDrawingDisplay> {
  late final Map<int, List<DrawingStroke>> _strokesByPage =
      _parseStrokes(widget.drawingData);
  final PageController _pageController = PageController();
  int _currentPage = 1;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  static Map<int, List<DrawingStroke>> _parseStrokes(String drawingData) {
    try {
      final decoded = jsonDecode(drawingData);
      final Map<int, List<DrawingStroke>> result = {};

      if (decoded is Map<String, dynamic>) {
        final strokesByPage = decoded['strokesByPage'];
        if (strokesByPage is Map<String, dynamic>) {
          strokesByPage.forEach((key, value) {
            final pageNum = int.tryParse(key.toString());
            if (pageNum == null || value is! List) return;
            result[pageNum] = value
                .map((e) => DrawingStroke.fromMap(e as Map<String, dynamic>))
                .toList(growable: false);
          });
          if (result.isNotEmpty) return result;
        }
      }

      if (decoded is List) {
        result[1] = decoded
            .map((e) => DrawingStroke.fromMap(e as Map<String, dynamic>))
            .toList(growable: false);
        return result;
      }

      return result;
    } catch (e) {
      debugPrint('Error parsing drawing data: $e');
      return const {};
    }
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
            DrawingCanvas(
              strokes: strokes,
              currentColor: Colors.black,
              currentSize: 4.0,
              backgroundColor: AppColors.surfaceLight,
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
}