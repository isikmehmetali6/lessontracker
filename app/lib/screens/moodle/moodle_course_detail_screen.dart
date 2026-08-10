import 'package:flutter/material.dart';
import 'package:lesson_tracker/l10n/app_localizations.dart';
import 'package:open_filex/open_filex.dart';
import 'package:provider/provider.dart';
import '../../services/moodle_file_download_service.dart';
import '../../models/moodle/moodle_course.dart';
import '../../models/moodle/moodle_course_content.dart';
import '../../providers/course_provider.dart';
import '../../providers/moodle_provider.dart';
import 'widgets/moodle_module_options_sheet.dart';
import 'widgets/moodle_open_action_sheet.dart';
import 'widgets/moodle_course_picker.dart';
import 'widgets/moodle_module_tile_view.dart';
import 'widgets/moodle_export_to_course.dart';
import 'widgets/moodle_course_selection_sheet.dart';
import 'widgets/open_external_url.dart';
import '../../providers/note_provider.dart';
import '../../services/moodle/moodle_api_service.dart';
import '../../services/moodle/moodle_token_storage.dart';
import '../../core/utils/moodle_utils.dart';
import '../../providers/language_provider.dart';

/// Bir Moodle dersinin içeriğini gösteren detay ekranı.
/// PDF'ler, slaytlar, dosyalar, URL'ler — hepsi burada.
class MoodleCourseDetailScreen extends StatefulWidget {
  final MoodleCourse course;

  const MoodleCourseDetailScreen({super.key, required this.course});

  @override
  State<MoodleCourseDetailScreen> createState() =>
      _MoodleCourseDetailScreenState();
}

class _MoodleCourseDetailScreenState extends State<MoodleCourseDetailScreen> {
  final MoodleApiService _api = MoodleApiService();
  final MoodleTokenStorage _tokenStorage = MoodleTokenStorage();

  List<MoodleCourseSection> _sections = [];
  bool _isLoading = true;
  String? _error;
  String? _token;

  @override
  void initState() {
    super.initState();
    _loadContents();
  }

  Future<void> _loadContents() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final token = await _tokenStorage.getToken(widget.course.accountId);
      if (token == null) {
        setState(() {
          _error = AppLocalizations.of(context)!.moodleTokenNotFound;
          _isLoading = false;
        });
        return;
      }

      _token = token;

      if (!mounted) return;
      if (!context.mounted) return;
      final account = context
          .read<MoodleProvider>()
          .accounts
          .where((a) => a.id == widget.course.accountId)
          .firstOrNull;

      if (account == null) {
        setState(() {
          _error = AppLocalizations.of(context)!.moodleAccountNotFound;
          _isLoading = false;
        });
        return;
      }

      final sections = await _api.getCourseContents(
        baseUrl: account.baseUrl,
        token: token,
        courseId: widget.course.id,
      );

      setState(() {
        _sections = sections;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = AppLocalizations.of(context)!.moodleContentError(e.toString());
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final langCode = context.watch<LanguageProvider>().locale.languageCode;

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        title: Text(
          MoodleUtils.parseMultilang(
            widget.course.shortName,
            langCode,
          ),
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
      ),
      body: _buildBody(theme),
    );
  }

  Widget _buildBody(ThemeData theme) {
    if (_isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 16),
            Text(AppLocalizations.of(context)!.moodleContentLoading),
          ],
        ),
      );
    }

    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline_rounded,
                  size: 48, color: theme.colorScheme.error),
              const SizedBox(height: 12),
              Text(_error!,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyMedium
                      ?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
              const SizedBox(height: 20),
              OutlinedButton.icon(
                icon: const Icon(Icons.refresh_rounded),
                label: Text(AppLocalizations.of(context)!.moodleTryAgain),
                onPressed: _loadContents,
              ),
            ],
          ),
        ),
      );
    }

    if (_sections.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.folder_open_rounded,
                size: 56, color: theme.colorScheme.outlineVariant),
            const SizedBox(height: 12),
            Text(AppLocalizations.of(context)!.moodleContentNotFound,
                style: theme.textTheme.titleMedium
                    ?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
          ],
        ),
      );
    }

    // Boş bölümleri filtrele
    final nonEmptySections =
        _sections.where((s) => s.modules.isNotEmpty).toList();

    return RefreshIndicator(
      onRefresh: _loadContents,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: nonEmptySections.length,
        itemBuilder: (context, index) {
          final section = nonEmptySections[index];
          return _SectionCard(
            section: section,
            token: _token!,
            courseName: widget.course.shortName,
            theme: theme,
          );
        },
      ),
    );
  }
}

// ===== Bölüm Kartı =====
class _SectionCard extends StatelessWidget {
  final MoodleCourseSection section;
  final String token;
  final String courseName;
  final ThemeData theme;

  const _SectionCard({
    required this.section,
    required this.token,
    required this.courseName,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    final langCode = context.watch<LanguageProvider>().locale.languageCode;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Bölüm başlığı
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Text(
            MoodleUtils.parseMultilang(
              section.name,
              langCode,
            ),
            style: theme.textTheme.titleSmall
                ?.copyWith(fontWeight: FontWeight.w700),
          ),
        ),
        // Modüller
        ...section.modules.map((module) => _ModuleTile(
              module: module,
              token: token,
              courseName: courseName,
            )),
        const SizedBox(height: 12),
      ],
    );
  }
}

// ===== Modül Satırı =====
class _ModuleTile extends StatefulWidget {
  final MoodleCourseModule module;
  final String token;
  final String courseName; // İndirme klasörü için gerekli

  const _ModuleTile({
    required this.module,
    required this.token,
    required this.courseName,
  });

  @override
  State<_ModuleTile> createState() => _ModuleTileState();
}

class _ModuleTileState extends State<_ModuleTile> {
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

    if (!context.mounted) return;

    final selected = await showMoodleCoursePicker(
      context,
      context.read<CourseProvider>().courses,
    );
    if (selected == null || !context.mounted) return;

    final noteProvider = context.read<NoteProvider>();
    final fileName = widget.module.name;
    final result = await noteProvider.addPdfNote(
      courseId: selected,
      title: fileName,
      localPath: _localPath!,
    );

    if (!context.mounted) return;
    final locale = Localizations.localeOf(context).languageCode;
    final successMsg =
        locale == 'tr' ? 'Nota eklendi' : 'Added as note';
    final errorFallback =
        locale == 'tr' ? 'Bir hata oluştu' : 'An error occurred';

    if (result != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(successMsg)),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(noteProvider.error ?? errorFallback)),
      );
    }
  }
}
