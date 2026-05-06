import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdfx/pdfx.dart';
import 'package:file_picker/file_picker.dart';
import 'package:uuid/uuid.dart';

import 'package:lesson_tracker/l10n/app_localizations.dart';
import '../../core/theme/app_colors.dart';
import '../../models/course.dart';
import '../../models/note.dart';
import '../../providers/note_provider.dart';
import '../../widgets/course/drawing_canvas.dart';

enum CanvasMode { blank, photo, pdf }

class HandwritingCanvasScreen extends StatefulWidget {
  final Course course;
  final Note? existingNote;

  const HandwritingCanvasScreen({
    super.key,
    required this.course,
    this.existingNote,
  });

  @override
  State<HandwritingCanvasScreen> createState() =>
      _HandwritingCanvasScreenState();
}

class _HandwritingCanvasScreenState extends State<HandwritingCanvasScreen> {
  CanvasMode _mode = CanvasMode.blank;
  final Map<int, List<DrawingStroke>> _strokesByPage = {};
  List<DrawingStroke> _currentPageStrokes = [];
  Color _currentColor = Colors.black;
  double _currentSize = 4.0;

  // Photo mode
  Uint8List? _photoBytes;
  String? _photoPath;

  // PDF mode
  PdfControllerPinch? _pdfController;
  int _currentPdfPage = 1;
  int _totalPdfPages = 0;
  String? _pdfPath;

  bool _isLoading = false;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _loadExistingNote();
  }

  void _loadExistingNote() {
    if (widget.existingNote != null &&
        widget.existingNote!.drawingData != null) {
      try {
        final drawingDataStr = widget.existingNote!.drawingData!;
        final decoded = jsonDecode(drawingDataStr);

        if (decoded is List) {
          final List<dynamic> jsonList = decoded;
          final strokes = jsonList
              .map((e) => DrawingStroke.fromMap(e as Map<String, dynamic>))
              .toList();
          if (strokes.isNotEmpty) {
            _strokesByPage[1] = strokes;
            _currentPageStrokes = strokes;
          }
        } else if (decoded is Map && decoded.containsKey('strokesByPage')) {
          final strokesByPage = decoded['strokesByPage'] as Map<String, dynamic>;
          strokesByPage.forEach((pageStr, strokesList) {
            final page = int.parse(pageStr);
            final strokes = (strokesList as List)
                .map((e) => DrawingStroke.fromMap(e as Map<String, dynamic>))
                .toList();
            _strokesByPage[page] = strokes;
          });
          _totalPdfPages = decoded['totalPages'] ?? _strokesByPage.keys.length;
          _currentPageStrokes = _strokesByPage[1] ?? [];
        }
      } catch (e, stackTrace) {
        debugPrint(
          'Error loading existing note drawing data: $e\nStack: $stackTrace',
        );
      }
    }
  }

  Future<void> _pickPhoto() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        allowMultiple: false,
      );

      if (result != null && result.files.isNotEmpty) {
        final file = File(result.files.first.path!);
        final bytes = await file.readAsBytes();

        setState(() {
          _photoBytes = bytes;
          _photoPath = file.path;
          _mode = CanvasMode.photo;
          _currentPageStrokes = [];
          _strokesByPage.clear();
        });
      }
    } catch (e) {
      _showError('Failed to pick photo: $e');
    }
  }

  Future<void> _pickPdf() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
        allowMultiple: false,
      );

      if (result != null && result.files.isNotEmpty) {
        setState(() => _isLoading = true);

        _pdfPath = result.files.first.path!;
        _pdfController = PdfControllerPinch(
          document: PdfDocument.openFile(_pdfPath!),
        );

        setState(() {
          _mode = CanvasMode.pdf;
          _strokesByPage.clear();
          _currentPageStrokes = [];
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() => _isLoading = false);
      _showError('Failed to pick PDF: $e');
    }
  }

  void _undo() {
    if (_currentPageStrokes.isNotEmpty) {
      setState(() {
        _currentPageStrokes = List.from(_currentPageStrokes)..removeLast();
        _strokesByPage[_currentPdfPage] = _currentPageStrokes;
      });
    }
  }

  void _clear() {
    if (_currentPageStrokes.isEmpty) return;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.clearCanvas),
        content: Text(AppLocalizations.of(context)!.clearCanvasConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(AppLocalizations.of(context)!.cancel),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              setState(() {
                _currentPageStrokes = [];
                _strokesByPage[_currentPdfPage] = [];
              });
            },
            child: Text(AppLocalizations.of(context)!.clearAction, style: const TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Future<void> _saveDrawing() async {
    if (_currentPageStrokes.isEmpty && _photoBytes == null && _pdfPath == null) {
      _showError(AppLocalizations.of(context)!.nothingToSave);
      return;
    }

    setState(() => _isSaving = true);

    try {
      final noteProvider = context.read<NoteProvider>();
      final uuid = const Uuid();
      final noteId = widget.existingNote?.id ?? uuid.v4();

      String? filePath;
      String? thumbnailPath;

      // Save photo if exists
      if (_photoBytes != null && _photoPath != null) {
        final dir = await getApplicationDocumentsDirectory();
        final savedPath = '${dir.path}/notes/$noteId.jpg';

        // Ensure directory exists
        await Directory('${dir.path}/notes').create(recursive: true);

        // Save the original photo
        await File(_photoPath!).copy(savedPath);
        filePath = savedPath;

        // Generate thumbnail
        final thumbPath = '${dir.path}/notes/$noteId.thumb.jpg';
        thumbnailPath = thumbPath;
      }

      // Save PDF path reference
      if (_pdfPath != null) {
        final dir = await getApplicationDocumentsDirectory();
        final pdfDir = Directory('${dir.path}/pdfs');
        if (!await pdfDir.exists()) {
          await pdfDir.create(recursive: true);
        }
        final pdfFileName = '${noteId}_${DateTime.now().millisecondsSinceEpoch}.pdf';
        final savedPdfPath = '${pdfDir.path}/$pdfFileName';
        await File(_pdfPath!).copy(savedPdfPath);
        filePath = savedPdfPath;
      }

      // Convert strokes per-page to JSON for storage
      final Map<String, dynamic> drawingData = {
        'strokesByPage': _strokesByPage.map(
          (page, strokes) => MapEntry(page.toString(), strokes.map((s) => s.toMap()).toList()),
        ),
        'totalPages': _totalPdfPages,
      };
      final drawingJson = jsonEncode(drawingData);

      final note = Note(
        id: noteId,
        courseId: widget.course.id,
        type: _getNoteType(),
        title: _generateTitle(),
        content: _generateContent(),
        filePath: filePath,
        thumbnailPath: thumbnailPath,
        tags: _getTags(),
        createdAt: widget.existingNote?.createdAt ?? DateTime.now(),
        updatedAt: DateTime.now(),
        drawingData: drawingJson,
      );

      await noteProvider.saveNoteWithDrawing(note);

      if (mounted) {
        HapticFeedback.mediumImpact();
        Navigator.pop(context, note);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(AppLocalizations.of(context)!.drawingSaved)));
      }
    } catch (e) {
      _showError('Failed to save: $e');
    } finally {
      setState(() => _isSaving = false);
    }
  }

  NoteType _getNoteType() {
    switch (_mode) {
      case CanvasMode.blank:
        return NoteType.drawing;
      case CanvasMode.photo:
        return NoteType.image;
      case CanvasMode.pdf:
        return NoteType.drawing;
    }
  }

  String _generateTitle() {
    switch (_mode) {
      case CanvasMode.blank:
        return 'Handwriting ${DateTime.now().toString().substring(0, 16)}';
      case CanvasMode.photo:
        return 'Photo Note ${DateTime.now().toString().substring(0, 16)}';
      case CanvasMode.pdf:
        return 'PDF Annotation - Page $_currentPdfPage';
    }
  }

  String? _generateContent() {
    if (_strokesByPage.isEmpty) return null;
    final totalStrokes = _strokesByPage.values.fold<int>(0, (sum, strokes) => sum + strokes.length);
    if (totalStrokes == 0) return null;
    return 'Handwritten notes with $totalStrokes strokes across ${_strokesByPage.length} page(s)';
  }

  List<String> _getTags() {
    final tags = <String>['handwriting', 'drawing'];
    switch (_mode) {
      case CanvasMode.blank:
        tags.add('blank_paper');
        break;
      case CanvasMode.photo:
        tags.add('photo_annotation');
        break;
      case CanvasMode.pdf:
        tags.add('pdf_annotation');
        break;
    }
    return tags;
  }

  void _showError(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), backgroundColor: Colors.red),
      );
    }
  }

  @override
  void dispose() {
    _pdfController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF1C1C1E) : Colors.grey[100],
      appBar: AppBar(
        backgroundColor: isDark ? const Color(0xFF1C1C1E) : Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          _getTitle(),
          style: TextStyle(
            color: isDark ? Colors.white : Colors.black87,
            fontSize: 16,
          ),
        ),
        actions: [
          if (_isSaving)
            const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            )
          else
            TextButton.icon(
              onPressed: _saveDrawing,
              icon: const Icon(Icons.check, size: 20),
              label: Text(l10n.save),
            ),
        ],
      ),
      body: Column(
        children: [
          // Mode selector
          _buildModeSelector(isDark, l10n),
          // Canvas area
          Expanded(child: _buildCanvasArea(isDark, l10n)),
          // Drawing toolbar
          DrawingToolbar(
            selectedColor: _currentColor,
            selectedSize: _currentSize,
            onColorChanged: (color) => setState(() => _currentColor = color),
            onSizeChanged: (size) => setState(() => _currentSize = size),
            onUndo: _undo,
            onClear: _clear,
            isDark: isDark,
          ),
        ],
      ),
    );
  }

  String _getTitle() {
    final l10n = AppLocalizations.of(context)!;
    switch (_mode) {
      case CanvasMode.blank:
        return l10n.blankPaper;
      case CanvasMode.photo:
        return l10n.photoAnnotation;
      case CanvasMode.pdf:
        return l10n.pdfAnnotation;
    }
  }

  Widget _buildModeSelector(bool isDark, AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _ModeChip(
            icon: Icons.article_outlined,
            label: l10n.blankLabel,
            isSelected: _mode == CanvasMode.blank,
            onTap: () => setState(() {
              _mode = CanvasMode.blank;
              _currentPageStrokes = [];
            }),
            isDark: isDark,
          ),
          const SizedBox(width: 12),
          _ModeChip(
            icon: Icons.image_outlined,
            label: l10n.photoLabel,
            isSelected: _mode == CanvasMode.photo,
            onTap: _pickPhoto,
            isDark: isDark,
          ),
          const SizedBox(width: 12),
          _ModeChip(
            icon: Icons.picture_as_pdf_outlined,
            label: l10n.pdfLabel,
            isSelected: _mode == CanvasMode.pdf,
            onTap: _pickPdf,
            isDark: isDark,
          ),
        ],
      ),
    );
  }

  Widget _buildCanvasArea(bool isDark, AppLocalizations l10n) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    switch (_mode) {
      case CanvasMode.blank:
        return _buildBlankCanvas(isDark);
      case CanvasMode.photo:
        return _buildPhotoCanvas(isDark, l10n);
      case CanvasMode.pdf:
        return _buildPdfCanvas(isDark, l10n);
    }
  }

  Widget _buildBlankCanvas(bool isDark) {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
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
          strokes: _currentPageStrokes,
          currentColor: _currentColor,
          currentSize: _currentSize,
          backgroundColor: Colors.white,
          onStrokesChanged: (newStrokes) =>
              setState(() => _currentPageStrokes = newStrokes),
        ),
      ),
    );
  }

  Widget _buildPhotoCanvas(bool isDark, AppLocalizations l10n) {
    if (_photoBytes == null) {
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
              l10n.tapPhotoHint,
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
            Image.memory(_photoBytes!, fit: BoxFit.contain),
            // Drawing overlay
            DrawingCanvas(
              strokes: _currentPageStrokes,
              currentColor: _currentColor,
              currentSize: _currentSize,
              backgroundColor: Colors.transparent,
              onStrokesChanged: (newStrokes) =>
                  setState(() => _currentPageStrokes = newStrokes),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPdfCanvas(bool isDark, AppLocalizations l10n) {
    if (_pdfController == null) {
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
              l10n.tapPdfHint,
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
          controller: _pdfController!,
          onDocumentLoaded: (document) {
            setState(() {
              _totalPdfPages = document.pagesCount;
            });
          },
          onPageChanged: (page) {
            setState(() {
              _currentPdfPage = page;
              _currentPageStrokes = _strokesByPage[page] ?? [];
            });
          },
        ),
        // Drawing overlay (transparency adjusted for annotation)
        DrawingCanvas(
          strokes: _currentPageStrokes,
          currentColor: _currentColor.withValues(alpha: 0.7),
          currentSize: _currentSize,
          backgroundColor: Colors.transparent,
          onStrokesChanged: (newStrokes) {
            setState(() {
              _currentPageStrokes = newStrokes;
              _strokesByPage[_currentPdfPage] = newStrokes;
            });
          },
        ),
      ],
    );
  }
}

class _ModeChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final bool isDark;

  const _ModeChip({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary
              : (isDark ? const Color(0xFF2C2C2E) : Colors.grey[200]),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 18,
              color: isSelected
                  ? Colors.white
                  : (isDark ? Colors.white70 : Colors.black54),
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                color: isSelected
                    ? Colors.white
                    : (isDark ? Colors.white70 : Colors.black54),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
