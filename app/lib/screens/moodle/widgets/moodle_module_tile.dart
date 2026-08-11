import 'package:flutter/material.dart';
import 'package:lesson_tracker/l10n/app_localizations.dart';
import 'package:open_filex/open_filex.dart';
import 'package:provider/provider.dart';
import '../../../models/moodle/moodle_course_content.dart';
import '../../../providers/language_provider.dart';
import '../../../services/moodle_file_download_service.dart';
import 'add_moodle_file_as_note.dart';
import 'moodle_export_to_course.dart';
import 'moodle_module_options_sheet.dart';
import 'moodle_module_tile_view.dart';
import 'moodle_open_action_sheet.dart';
import 'moodle_course_selection_sheet.dart';
import 'open_external_url.dart';

/// A single Moodle course module row: download/open state, options sheet,
/// and export-to-course/add-as-note actions.
class MoodleModuleTile extends StatefulWidget {
  final MoodleCourseModule module;
  final String token;
  final String courseName; // İndirme klasörü için gerekli

  const MoodleModuleTile({
    super.key,
    required this.module,
    required this.token,
    required this.courseName,
  });

  @override
  State<MoodleModuleTile> createState() => _MoodleModuleTileState();
}

class _MoodleModuleTileState extends State<MoodleModuleTile> {
  final _downloadService = MoodleFileDownloadService();
  bool _isDownloaded = false;
  bool _isDownloading = false;
  double _progress = 0;
  String? _localPath;

  @override
  void initState() {
    super.initState();
    _checkStatus();
  }

  Future<void> _checkStatus() async {
    final file = widget.module.primaryFile;
    if (file == null) return;

    final path = await _downloadService.getLocalPath(
        fileName: file.fileName, courseName: widget.courseName);

    if (mounted) {
      setState(() {
        _localPath = path;
        _isDownloaded = path != null;
      });
    }
  }

  Future<void> _handleDownload() async {
    final file = widget.module.primaryFile;
    if (file == null) return;

    setState(() {
      _isDownloading = true;
      _progress = 0;
    });

    final path = await _downloadService.downloadFile(
      file: file,
      token: widget.token,
      courseName: widget.courseName,
      onProgress: (p) {
        if (mounted) {
          setState(() => _progress = p);
        }
      },
    );

    if (mounted) {
      setState(() {
        _isDownloading = false;
        if (path != null) {
          _localPath = path;
          _isDownloaded = true;
        }
      });

      if (path != null) {
        OpenFilex.open(path);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context)!.moodleDownloadFailed)),
        );
      }
    }
  }

  void _showOptionsBottomSheet(BuildContext context) {
    showMoodleModuleOptionsSheet(
      context: context,
      onTransferToCourse: () => _showCourseSelectionDialog(context),
    );
  }

  void _showCourseSelectionDialog(BuildContext parentContext) {
    showMoodleCourseSelectionSheet(
      parentContext,
      onCourseSelected: (courseId, courseName) {
        _handleExportToCourse(parentContext, courseId, courseName);
      },
    );
  }

  Future<void> _handleExportToCourse(BuildContext context, String courseId, String cName) async {
    if (_localPath == null || widget.module.primaryFile == null) return;
    await exportMoodleFileToCourse(
      context: context,
      downloadService: _downloadService,
      localPath: _localPath!,
      courseId: courseId,
      fileName: widget.module.primaryFile!.fileName,
      courseName: cName,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final langCode = context.watch<LanguageProvider>().locale.languageCode;
    final isDark = theme.brightness == Brightness.dark;
    final file = widget.module.primaryFile;

    return MoodleModuleTileView(
      module: widget.module,
      file: file,
      isDark: isDark,
      theme: theme,
      langCode: langCode,
      isDownloaded: _isDownloaded,
      isDownloading: _isDownloading,
      progress: _progress,
      onTileTap: () => _handleTap(context),
      onMoreActionsPressed: () => _showOptionsBottomSheet(context),
    );
  }

  Future<void> _handleTap(BuildContext context) async {
    if (_isDownloading) return;

    final file = widget.module.primaryFile;

    // İndirilebilir Dosya
    if (file != null) {
      if (_isDownloaded && _localPath != null) {
        // İndirilmişse: kullanıcıya dışarı aç veya nota ekle seçeneği sun
        if (!mounted) return;
        if (!context.mounted) return;
        final action = await _showOpenActionSheet(context);
        if (!mounted) return;
        if (!context.mounted) return;
        if (action == MoodleOpenAction.external) {
          await OpenFilex.open(_localPath!);
        } else if (action == MoodleOpenAction.addAsNote) {
          await _addDownloadedFileAsNote(context);
        }
      } else {
        // İndirilmemişse indir
        await _handleDownload();
      }
      return;
    }

    // URL Modülleri
    if (widget.module.isUrl && widget.module.contents.isNotEmpty) {
      final urlStr = widget.module.contents.first.fileUrl;
      if (urlStr != null) {
        await openExternalUrl(urlStr);
      }
    }
  }

  Future<MoodleOpenAction?> _showOpenActionSheet(BuildContext context) {
    return showMoodleOpenActionSheet(context);
  }

  Future<void> _addDownloadedFileAsNote(BuildContext context) async {
    if (_localPath == null) return;
    await addMoodleFileAsNoteAction(
      context: context,
      localPath: _localPath!,
      fileName: widget.module.name,
      isMounted: () => mounted,
      onNoteSaved: () async {},
    );
  }
}
