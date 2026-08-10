import 'dart:io';
import 'package:flutter/material.dart';
import 'package:pdfx/pdfx.dart';
import 'package:lesson_tracker/services/file_service.dart';
import 'package:lesson_tracker/l10n/app_localizations.dart';

class NotePdfDisplay extends StatefulWidget {
  final String pdfPath;
  final bool isDark;

  const NotePdfDisplay({
    super.key,
    required this.pdfPath,
    required this.isDark,
  });

  @override
  State<NotePdfDisplay> createState() => _NotePdfDisplayState();
}

class _NotePdfDisplayState extends State<NotePdfDisplay> {
  String? _resolvedPath;
  bool _fileExists = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _resolvePath();
  }

  Future<void> _resolvePath() async {
    final resolved = await FileService().resolveFilePath(widget.pdfPath);
    final exists = resolved != null && await File(resolved).exists();
    if (mounted) {
      setState(() {
        _resolvedPath = resolved;
        _fileExists = exists;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Container(
        height: 200,
        decoration: BoxDecoration(
          color: widget.isDark ? Colors.grey.shade800 : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Center(child: CircularProgressIndicator()),
      );
    }

    if (!_fileExists) {
      return Container(
        height: 200,
        decoration: BoxDecoration(
          color: widget.isDark ? Colors.grey.shade800 : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.picture_as_pdf,
                size: 48,
                color: widget.isDark ? Colors.grey : Colors.grey.shade600,
              ),
              const SizedBox(height: 8),
              Text(
                AppLocalizations.of(context)!.pdfFileNotFound,
                style: TextStyle(
                  color: widget.isDark ? Colors.grey : Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Container(
      height: 400,
      decoration: BoxDecoration(
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
        child: _PdfViewer(filePath: _resolvedPath!),
      ),
    );
  }
}

class _PdfViewer extends StatefulWidget {
  final String filePath;

  const _PdfViewer({required this.filePath});

  @override
  State<_PdfViewer> createState() => _PdfViewerState();
}

class _PdfViewerState extends State<_PdfViewer> {
  PdfControllerPinch? _controller;

  @override
  void initState() {
    super.initState();
    _controller = PdfControllerPinch(
      document: PdfDocument.openFile(widget.filePath),
    );
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_controller == null) {
      return const Center(child: CircularProgressIndicator());
    }
    return PdfViewPinch(controller: _controller!);
  }
}