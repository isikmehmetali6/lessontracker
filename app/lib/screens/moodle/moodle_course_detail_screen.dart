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
import 'widgets/open_external_url.dart';
import '../../providers/note_provider.dart';
import '../../services/moodle/moodle_api_service.dart';
import '../../services/moodle/moodle_token_storage.dart';
import '../../core/theme/app_colors.dart';
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
    final courses = parentContext.read<CourseProvider>().uniqueCourses;

    showModalBottomSheet(
      context: parentContext,
      isScrollControlled: true,
      backgroundColor: Theme.of(parentContext).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.6,
          maxChildSize: 0.9,
          minChildSize: 0.4,
          expand: false,
          builder: (context, scrollController) {
            return Column(
              children: [
                const SizedBox(height: 8),
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    children: [
                      const Icon(Icons.menu_book_rounded, color: AppColors.primary),
                      const SizedBox(width: 8),
                      Text(
                        AppLocalizations.of(context)!.moodleSelectCourse,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: courses.isEmpty
                      ? Center(
                          child:                           Text(
                            AppLocalizations.of(context)!.moodleNoLocalCourses,
                            style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
                          ),
                        )
                      : ListView.builder(
                          controller: scrollController,
                          itemCount: courses.length,
                          itemBuilder: (context, index) {
                            final course = courses[index];
                            return ListTile(
                              leading: CircleAvatar(
                                backgroundColor: course.color.withValues(alpha: 0.2),
                                child: Text(
                                  course.name.substring(0, 1).toUpperCase(),
                                  style: TextStyle(color: course.color, fontWeight: FontWeight.bold),
                                ),
                              ),
                              title: Text(course.name, style: const TextStyle(fontWeight: FontWeight.w500)),
                              subtitle: course.subtitle != null ? Text(course.subtitle!) : null,
                              onTap: () {
                                Navigator.pop(context);
                                _handleExportToCourse(parentContext, course.id, course.name);
                              },
                            );
                          },
                        ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _handleExportToCourse(BuildContext context, String courseId, String cName) async {
    if (_localPath == null || widget.module.primaryFile == null) return;

    final success = await _downloadService.exportToAppCourse(
      moodleFilePath: _localPath!,
      courseId: courseId,
      fileName: widget.module.primaryFile!.fileName,
    );

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(success ? AppLocalizations.of(context)!.moodleSavedToCourse(cName) : AppLocalizations.of(context)!.moodleSaveError),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          backgroundColor: success ? AppColors.green : AppColors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final langCode = context.watch<LanguageProvider>().locale.languageCode;
    final isDark = theme.brightness == Brightness.dark;
    final file = widget.module.primaryFile;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: () => _handleTap(context),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: isDark ? AppColors.surfaceDark : Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.1)
                    : Colors.grey.shade200,
              ),
              boxShadow: [
                if (!isDark)
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.03),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
              ],
            ),
            child: Row(
              children: [
                // Dosya tipi ikonu
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: _iconColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(_icon, color: _iconColor, size: 20),
                ),
                const SizedBox(width: 12),
                // İsim + boyut
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        MoodleUtils.parseMultilang(
                          widget.module.name,
                          langCode,
                        ),
                        style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: isDark
                                ? AppColors.textPrimaryDark
                                : AppColors.textPrimaryLight),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (file != null) ...[
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            Text(
                              '${file.extension.toUpperCase()} · ${file.readableSize}',
                              style: theme.textTheme.bodySmall?.copyWith(
                                  color: isDark
                                      ? AppColors.textSecondaryDark
                                      : AppColors.textSecondaryLight),
                            ),
                            if (_isDownloaded) ...[
                              const SizedBox(width: 6),
                              Icon(Icons.check_circle_rounded,
                                  size: 14, color: AppColors.green),
                            ],
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
                // İndirme / Açma İkonları
                if (_isDownloading)
                  SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      value: _progress,
                      strokeWidth: 2,
                      color: AppColors.primary,
                    ),
                  )
                else if (file != null)
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(
                          _isDownloaded
                              ? Icons.folder_open_rounded
                              : Icons.download_rounded,
                          size: 20,
                          color: _isDownloaded
                              ? AppColors.primary
                              : (isDark
                                  ? AppColors.textSecondaryDark
                                  : AppColors.textSecondaryLight),
                        ),
                        onPressed: () => _handleTap(context),
                      ),
                      if (_isDownloaded)
                        IconButton(
                          icon: Icon(
                            Icons.more_vert_rounded,
                            size: 20,
                            color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                          ),
                          onPressed: () => _showOptionsBottomSheet(context),
                        ),
                    ],
                  )
                else
                  Icon(Icons.open_in_new_rounded,
                      size: 16,
                      color: isDark
                          ? AppColors.textSecondaryDark
                          : AppColors.textSecondaryLight),
              ],
            ),
          ),
        ),
      ),
    );
  }

  IconData get _icon {
    final file = widget.module.primaryFile;
    if (file != null) {
      if (file.isPdf) return Icons.picture_as_pdf_rounded;
      if (file.isSlide) return Icons.slideshow_rounded;
      if (file.isDocument) return Icons.description_rounded;
      if (file.isSpreadsheet) return Icons.table_chart_rounded;
      if (file.isImage) return Icons.image_rounded;
      if (file.isVideo) return Icons.videocam_rounded;
      if (file.isAudio) return Icons.audiotrack_rounded;
    }
    if (widget.module.isUrl) return Icons.link_rounded;
    if (widget.module.isQuiz) return Icons.quiz_rounded;
    if (widget.module.isAssignment) return Icons.assignment_rounded;
    if (widget.module.isForum) return Icons.forum_rounded;
    if (widget.module.isPage) return Icons.article_rounded;
    return Icons.insert_drive_file_rounded;
  }

  Color get _iconColor {
    final file = widget.module.primaryFile;
    if (file != null) {
      if (file.isPdf) return AppColors.red;
      if (file.isSlide) return AppColors.orange;
      if (file.isDocument) return AppColors.blue;
      if (file.isSpreadsheet) return AppColors.green;
      if (file.isImage) return AppColors.purple;
      if (file.isVideo) return AppColors.emerald;
      if (file.isAudio) return AppColors.pink;
    }
    if (widget.module.isUrl) return AppColors.sky;
    if (widget.module.isQuiz) return AppColors.purple;
    return Colors.blueGrey;
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
