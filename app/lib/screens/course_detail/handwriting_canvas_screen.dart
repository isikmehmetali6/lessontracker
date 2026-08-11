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
import '../../core/utils/drawing_data_codec.dart';
import '../../models/course.dart';
import '../../models/note.dart';
import '../../providers/note_provider.dart';
import '../../widgets/course/drawing_canvas.dart';
import 'widgets/canvas_mode_selector.dart';
import 'widgets/canvas_mode_views.dart';

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
        final decoded = DrawingDataCodec.decode(
          widget.existingNote!.drawingData!,
        );
        if (decoded.isNotEmpty) {
          _strokesByPage
            ..clear()
            ..addAll(decoded);
          _totalPdfPages = _strokesByPage.keys.length;
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
      final drawingJson = DrawingDataCodec.encode(_strokesByPage);

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
      backgroundColor: isDark ? AppColors.canvasDark : Colors.grey[100],
      appBar: AppBar(
        backgroundColor: isDark ? AppColors.canvasDark : AppColors.surfaceLight,
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
    return CanvasModeSelector(
      mode: _mode,
      isDark: isDark,
      blankLabel: l10n.blankLabel,
      photoLabel: l10n.photoLabel,
      pdfLabel: l10n.pdfLabel,
      onBlankTap: () => setState(() {
        _mode = CanvasMode.blank;
        _currentPageStrokes = [];
      }),
      onPhotoTap: _pickPhoto,
      onPdfTap: _pickPdf,
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
    return BlankCanvasView(
      strokes: _currentPageStrokes,
      currentColor: _currentColor,
      currentSize: _currentSize,
      onStrokesChanged: (newStrokes) => setState(() {
        _currentPageStrokes = newStrokes;
        _strokesByPage[1] = newStrokes;
      }),
    );
  }

  Widget _buildPhotoCanvas(bool isDark, AppLocalizations l10n) {
    return PhotoCanvasView(
      photoBytes: _photoBytes,
      isDark: isDark,
      tapPhotoHint: l10n.tapPhotoHint,
      strokes: _currentPageStrokes,
      currentColor: _currentColor,
      currentSize: _currentSize,
      onStrokesChanged: (newStrokes) => setState(() {
        _currentPageStrokes = newStrokes;
        _strokesByPage[1] = newStrokes;
      }),
    );
  }

  Widget _buildPdfCanvas(bool isDark, AppLocalizations l10n) {
    return PdfCanvasView(
      pdfController: _pdfController,
      isDark: isDark,
      tapPdfHint: l10n.tapPdfHint,
      strokes: _currentPageStrokes,
      currentColor: _currentColor,
      currentSize: _currentSize,
      onStrokesChanged: (newStrokes) => setState(() {
        _currentPageStrokes = newStrokes;
        _strokesByPage[_currentPdfPage] = newStrokes;
      }),
      onDocumentLoaded: (document) {
        setState(() {
          _totalPdfPages = document.pagesCount;
          _currentPdfPage = 1;
          _currentPageStrokes = _strokesByPage[1] ?? [];
        });
      },
      onPageChanged: (page) {
        setState(() {
          _currentPdfPage = page;
          _currentPageStrokes = _strokesByPage[page] ?? [];
        });
      },
    );
  }
}
