import 'dart:io';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import '../../core/theme/app_colors.dart';
import '../../models/course.dart';
import '../../models/note.dart';
import '../../providers/course_provider.dart';
import '../../providers/note_provider.dart';
import '../../models/course_file.dart';
import '../../widgets/common/common_widgets.dart';
import '../../widgets/common/sliver_app_bar_delegate.dart';
import '../note_detail/note_detail_screen.dart';
import '../../models/grade.dart';
import '../../widgets/course/add_grade_dialog.dart';
import '../../widgets/course/add_media_note_dialog.dart';
import '../../providers/deadline_provider.dart';
import '../../widgets/deadlines/add_deadline_dialog.dart';
import '../add_course/add_course_screen.dart';
import 'package:lesson_tracker/l10n/app_localizations.dart';
import '../../core/utils/note_templates.dart';
import 'tabs/course_notes_tab.dart';
import 'tabs/course_grades_tab.dart';
import 'tabs/course_files_tab.dart';
import 'widgets/course_detail_app_bar.dart';
import 'widgets/course_detail_header_info.dart';
import 'widgets/course_bottom_toolbar.dart';
import '../../core/utils/error_handler.dart';
import '../../core/utils/consent_utils.dart';
import 'handwriting_canvas_screen.dart';

/// Ders detay sayfası
class CourseDetailScreen extends StatefulWidget {
  final Course course;

  const CourseDetailScreen({super.key, required this.course});

  @override
  State<CourseDetailScreen> createState() => _CourseDetailScreenState();
}

class _CourseDetailScreenState extends State<CourseDetailScreen>
    with SingleTickerProviderStateMixin {
  final ImagePicker _imagePicker = ImagePicker();
  late TabController _tabController;

  List<Grade> _grades = [];
  bool _isLoadingGrades = false;

  List<CourseFile> _files = [];
  bool _isLoadingFiles = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    Future.microtask(() => _loadData());
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    await Future.wait([
      context.read<NoteProvider>().loadCourseNotes(widget.course.id),
      _loadGrades(),
      _loadFiles(),
    ]);
  }

  Future<void> _loadNotes() async {
    await context.read<NoteProvider>().loadCourseNotes(widget.course.id);
  }

  Future<void> _loadGrades() async {
    if (!mounted) return;
    setState(() => _isLoadingGrades = true);
    final grades = await context.read<CourseProvider>().loadCourseGrades(
      widget.course.id,
    );
    if (mounted) {
      setState(() {
        _grades = grades;
        _isLoadingGrades = false;
      });
    }
  }

  Future<void> _loadFiles() async {
    if (!mounted) return;
    setState(() => _isLoadingFiles = true);
    final files = await context.read<CourseProvider>().loadCourseFiles(
      widget.course.id,
    );
    if (mounted) {
      setState(() {
        _files = files;
        _isLoadingFiles = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Listen to course updates
    final course =
        context.select<CourseProvider, Course?>(
          (p) => p.courses.cast<Course?>().firstWhere(
            (c) => c?.id == widget.course.id,
            orElse: () => null,
          ),
        ) ??
        widget
            .course; // Fallback to widget.course if not found (e.g. before load)

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // AppBar
            CourseDetailAppBar(
              course: course,
              onOptionsTap: () => _showCourseOptions(course),
              onAddDeadlineTap: () => _showAddDeadlineDialog(course),
            ),
            // İçerik
            Expanded(child: _buildContent(isDark, course)),
          ],
        ),
      ),
      // Alt araç çubuğu
      bottomNavigationBar: CourseBottomToolbar(
        onAddBookmark: () {
          context.read<NoteProvider>().addBookmark();
          HapticFeedback.mediumImpact();
          _showSnackBar('Marked important moment! 🚩');
        },
        onCaptureImageCamera: () => _captureImage(ImageSource.camera, course),
        onCaptureImageGallery: () => _captureImage(ImageSource.gallery, course),
        onToggleRecording: () => _toggleRecording(course),
        onShowTextNoteDialog: () => _showTextNoteDialog(course),
        onCaptureOcr: () => _captureOcr(course),
        onOpenDrawingCanvas: () => _openDrawingCanvas(course),
      ),
    );
  }

  Widget _buildNotesTab(bool isDark, Course course) {
    return CourseNotesTab(
      course: course,
      onShowNoteDetail: _showNoteDetail,
      onPlayAudio: _playAudio,
      onToggleBookmark: _toggleBookmark,
    );
  }

  Widget _buildGradesTab(bool isDark, Course course) {
    return CourseGradesTab(
      course: course,
      grades: _grades,
      isLoading: _isLoadingGrades,
      onAddGrade: () => _showAddGradeDialog(course),
      onDeleteGrade: _deleteGrade,
      onEditGrade: (grade) {
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (_) => AddGradeDialog(
            gradeToEdit: grade,
            onSave: (name, score, maxScore, weight) async {
              final updatedGrade = grade.copyWith(
                name: name,
                score: score,
                maxScore: maxScore,
                weight: weight,
              );
              await context.read<CourseProvider>().updateGrade(updatedGrade);
              _loadGrades();
            },
          ),
        );
      },
    );
  }

  Widget _buildFilesTab(bool isDark, Course course) {
    return CourseFilesTab(
      course: course,
      files: _files,
      isLoading: _isLoadingFiles,
      onAddFile: () => _addFile(course),
      onDeleteFile: _deleteFile,
      onOpenFile: _openFile,
      onAddLink: () => _showAddLinkDialog(course),
    );
  }

  Widget _buildContent(bool isDark, Course course) {
    return NestedScrollView(
      headerSliverBuilder: (context, innerBoxIsScrolled) {
        return [
          SliverToBoxAdapter(child: CourseDetailHeaderInfo(course: course)),
          SliverPersistentHeader(
            delegate: CourseSliverAppBarDelegate(
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                height: 50,
                decoration: BoxDecoration(
                  color: isDark
                      ? const Color(0xFF2C2C2E)
                      : const Color(0xFFE5E5EA), // Premium background style
                  borderRadius: BorderRadius.circular(25),
                ),
                child: TabBar(
                  controller: _tabController,
                  indicator: BoxDecoration(
                    borderRadius: BorderRadius.circular(25),
                    color: isDark ? AppColors.primary : Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  indicatorSize: TabBarIndicatorSize.tab,
                  dividerColor: Colors.transparent,
                  labelColor: isDark ? Colors.black : AppColors.primary,
                  unselectedLabelColor: isDark
                      ? Colors.grey
                      : Colors.grey.shade600,
                  labelStyle: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                  overlayColor: WidgetStateProperty.all(
                    Colors.transparent,
                  ), // No splash
                  padding: const EdgeInsets.all(
                    4,
                  ), // Gap between indicator and container
                  tabs: [
                    Tab(text: AppLocalizations.of(context)!.notesTab),
                    Tab(text: AppLocalizations.of(context)!.gradesTab),
                    Tab(text: AppLocalizations.of(context)!.filesTab),
                  ],
                ),
              ),
            ),
            pinned: true,
          ),
        ];
      },
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildNotesTab(isDark, course),
          _buildGradesTab(isDark, course),
          _buildFilesTab(isDark, course),
        ],
      ),
    );
  }

  void _showCourseOptions(Course course) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return DraggableScrollableSheet(
          initialChildSize: 0.6,
          minChildSize: 0.4,
          maxChildSize: 0.9,
          builder: (_, scrollController) => Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: isDark ? AppColors.surfaceDark : Colors.white,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(28),
              ),
            ),
            child: Column(
              children: [
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 24),
                Expanded(
                  child: ListView(
                    controller: scrollController,
                    children: [
                      _OptionTile(
                        icon: Icons.edit,
                        title:
                            AppLocalizations.of(context)?.editCourse ??
                            'Edit Course',
                        onTap: () async {
                          Navigator.pop(context);
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  AddCourseScreen(courseToEdit: course),
                            ),
                          ).then((_) {
                            _loadData();
                          });
                        },
                      ),

                      _OptionTile(
                        icon: Icons.archive,
                        title:
                            AppLocalizations.of(context)?.archiveCourse ??
                            'Archive Course',
                        onTap: () async {
                          Navigator.pop(context);
                          final updated = course.copyWith(status: 'archived');
                          await this.context
                              .read<CourseProvider>()
                              .updateCourse(updated);
                          if (mounted) {
                            Navigator.pop(this.context);
                            ScaffoldMessenger.of(this.context).showSnackBar(
                              const SnackBar(content: Text('Course archived')),
                            );
                          }
                        },
                      ),
                      _OptionTile(
                        icon: Icons.event_available,
                        title:
                            AppLocalizations.of(context)?.addDeadlineTitle ??
                            'Add Deadline',
                        color: AppColors.primary,
                        onTap: () {
                          Navigator.pop(context);
                          _showAddDeadlineDialog(course);
                        },
                      ),

                      _OptionTile(
                        icon: Icons.notifications,
                        title: AppLocalizations.of(context)!.notifications,
                        onTap: () {
                          Navigator.pop(context);
                          final provider = this.context.read<CourseProvider>();
                          final enabled = provider.notificationsEnabled;
                          provider.toggleNotifications(!enabled);
                          _showSnackBar(
                            enabled
                                ? 'Notifications disabled'
                                : 'Notifications enabled',
                          );
                        },
                      ),
                      _OptionTile(
                        icon: Icons.delete_outline,
                        title: AppLocalizations.of(context)!.deleteCourse,
                        color: AppColors.red,
                        onTap: () {
                          Navigator.pop(context);
                          _deleteCourse(course);
                        },
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showAddDeadlineDialog(Course course) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AddDeadlineDialog(
        onSave: (title, selectedCourseId, date, type, addToCalendar) {
          // AddDeadlineDialog actually asks for a course inside, but we can set its default if we want, or just let users use the dialog as normal.
          // For now, it will default to the top course or you can modify AddDeadlineDialog to accept an initialCourseId.
          context.read<DeadlineProvider>().createDeadline(
            courseId: selectedCourseId,
            title: title,
            date: date,
            type: type,
            addToCalendar: addToCalendar,
          );
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Deadline added successfully!')),
            );
          }
        },
      ),
    );
  }


  Future<void> _addFile(Course course) async {
    final success = await context.read<CourseProvider>().addFile(course.id);
    if (success) {
      _loadFiles();
      _showSnackBar('File added successfully');
    }
  }

  void _showAddLinkDialog(Course course) {
    final urlController = TextEditingController();
    final nameController = TextEditingController();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: isDark ? AppColors.surfaceDark : Colors.white,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(28),
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'Add Link',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: isDark
                        ? AppColors.textPrimaryDark
                        : AppColors.textPrimaryLight,
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: nameController,
                  decoration: InputDecoration(
                    hintText: 'Link Name',
                    prefixIcon: const Icon(Icons.label_outline),
                    filled: true,
                    fillColor: isDark
                        ? Colors.grey.shade800
                        : Colors.grey.shade100,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: urlController,
                  decoration: InputDecoration(
                    hintText: 'https://...',
                    prefixIcon: const Icon(Icons.link),
                    filled: true,
                    fillColor: isDark
                        ? Colors.grey.shade800
                        : Colors.grey.shade100,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  keyboardType: TextInputType.url,
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () async {
                      final url = urlController.text.trim();
                      if (url.isEmpty) return;
                      final name = nameController.text.trim().isNotEmpty
                          ? nameController.text.trim()
                          : url;

                      final provider = this.context.read<CourseProvider>();
                      await provider.addLink(course.id, name, url);
                      if (mounted) {
                        Navigator.pop(context);
                        _loadFiles();
                        _showSnackBar('Link added');
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('Add Link'),
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        );
      },
    ).then((_) {
      urlController.dispose();
      nameController.dispose();
    });
  }

  Future<void> _deleteFile(CourseFile file) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.delete),
        content: Text(AppLocalizations.of(context)!.thisActionCannotBeUndone),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(AppLocalizations.of(context)!.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              AppLocalizations.of(context)!.delete,
              style: const TextStyle(color: AppColors.red),
            ),
          ),
        ],
      ),
    );

    if (confirm == true) {
      if (!mounted) return;
      await context.read<CourseProvider>().deleteFile(file);
      _loadFiles();
    }
  }

  Future<void> _openFile(CourseFile file) async {
    await context.read<CourseProvider>().openFile(file);
  }

  Future<void> _captureImage(ImageSource source, Course course) async {
    try {
      if (source == ImageSource.gallery) {
        final List<XFile> images = await _imagePicker.pickMultiImage(
          maxWidth: 1920,
          maxHeight: 1920,
          imageQuality: 85,
        );

        if (images.isEmpty || !mounted) return;

        if (images.length == 1) {
          _showImageNoteDialog(File(images.first.path), course);
        } else {
          int saved = 0;
          for (final image in images) {
            if (!mounted) break;
            final note = await context.read<NoteProvider>().addImageNote(
              courseId: course.id,
              imageFile: File(image.path),
              customTitle: 'Photo ${saved + 1}',
              courseName: course.name,
              userName: 'User',
            );
            if (note != null) saved++;
          }
          if (mounted) {
            HapticFeedback.mediumImpact();
            _showSnackBar('$saved photos saved!');
          }
        }
      } else {
        final consent = await ConsentUtils.showContentCaptureConsentDialog(context);
        if (consent != true || !mounted) return;

        final XFile? image = await _imagePicker.pickImage(
          source: source,
          maxWidth: 1920,
          maxHeight: 1920,
          imageQuality: 85,
        );

        if (image != null && mounted) {
          _showImageNoteDialog(File(image.path), course);
        }
      }
    } catch (e) {
      if (mounted) {
        ErrorHandler.handleError(
          context,
          e,
          customMessage: 'Failed to capture image',
        );
      }
    }
  }

  /// OCR: Kameradan fotoğraf çek → OCR ile metin tanı → otomatik kaydet
  Future<void> _captureOcr(Course course) async {
    debugPrint('🔍 DEBUG: _captureOcr called');
    final consent = await ConsentUtils.showContentCaptureConsentDialog(context);
    debugPrint('🔍 DEBUG: consent = $consent');
    if (consent != true || !mounted) return;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(
      'ocr_consent_timestamp',
      DateTime.now().millisecondsSinceEpoch,
    );

    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1920,
        maxHeight: 1920,
        imageQuality: 85,
      );

      if (image == null || !mounted) return;

      _showSnackBar('Processing OCR...');

      final note = await context.read<NoteProvider>().addOcrNote(
        courseId: course.id,
        imageFile: File(image.path),
        courseName: course.name,
        userName: 'User',
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).hideCurrentSnackBar();

      if (note != null) {
        HapticFeedback.mediumImpact();
        _showSnackBar('📝 OCR note saved!');
      } else {
        ErrorHandler.handleError(
          context,
          context.read<NoteProvider>().error ?? 'OCR failed',
        );
      }
    } catch (e) {
      if (mounted) {
        ErrorHandler.handleError(context, e, customMessage: 'OCR failed: $e');
      }
    }
  }



  void _showImageNoteDialog(File imageFile, Course course) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => AddMediaNoteDialog(
        imageFile: imageFile,
        onSave: (title, content, tags) async {
          final noteProvider = context.read<NoteProvider>();
          Navigator.pop(sheetContext);

          final note = await noteProvider.addImageNote(
            courseId: course.id,
            imageFile: imageFile,
            customTitle: title.isNotEmpty ? title : null,
            content: content?.isNotEmpty == true ? content : null,
            tags: tags,
            courseName: course.name,
            userName: 'User',
          );

          if (note != null) {
            HapticFeedback.mediumImpact();
            _showSnackBar('Note saved!');
          }
        },
      ),
    );
  }

  Future<void> _toggleRecording(Course course) async {
    final provider = context.read<NoteProvider>();

    if (provider.isRecording) {
      // Kaydı durdur
      final note = await provider.stopRecordingAndSave(courseId: course.id);

      if (note != null) {
        HapticFeedback.mediumImpact();
        _showSnackBar('Voice memo saved!');
      }
    } else {
      final consent = await ConsentUtils.showContentCaptureConsentDialog(context, isAudio: true);
      if (consent != true || !mounted) return;

      // Kaydı başlat
      final success = await provider.startRecording();
      if (success) {
        HapticFeedback.mediumImpact();
        _showSnackBar('Recording started...');
      } else {
        ErrorHandler.handleError(context, 'Microphone permission required');
      }
    }
  }

  void _showTextNoteDialog(Course course) {
    final titleController = TextEditingController();
    final contentController = TextEditingController();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: isDark ? AppColors.surfaceDark : Colors.white,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(28),
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  AppLocalizations.of(context)!.newNote,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: isDark
                        ? AppColors.textPrimaryDark
                        : AppColors.textPrimaryLight,
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: titleController,
                  decoration: InputDecoration(
                    hintText: AppLocalizations.of(context)!.title,
                    filled: true,
                    fillColor: isDark
                        ? Colors.grey.shade800
                        : Colors.grey.shade100,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: contentController,
                  maxLines: 4,
                  decoration: InputDecoration(
                    hintText: AppLocalizations.of(context)!.writeYourNote,
                    filled: true,
                    fillColor: isDark
                        ? Colors.grey.shade800
                        : Colors.grey.shade100,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                // Template selector
                SizedBox(
                  height: 40,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: NoteTemplates.templates.length,
                    itemBuilder: (context, index) {
                      final template = NoteTemplates.templates[index];
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: ActionChip(
                          avatar: Text(template.icon),
                          label: Text(
                            template.name,
                            style: const TextStyle(fontSize: 12),
                          ),
                          onPressed: () {
                            contentController.text = template.content;
                            if (titleController.text.isEmpty) {
                              titleController.text = template.name;
                            }
                          },
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 12),
                PrimaryButton(
                  text: AppLocalizations.of(context)!.saveNote,
                  icon: Icons.check,
                  onPressed: () async {
                    if (titleController.text.isNotEmpty) {
                      await context.read<NoteProvider>().addTextNote(
                        courseId: course.id,
                        title: titleController.text,
                        content: contentController.text,
                      );
                      if (!context.mounted) return;
                      Navigator.pop(context);
                      HapticFeedback.mediumImpact();
                      _showSnackBar('Note saved!');
                    }
                  },
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        );
      },
    ).then((_) {
      titleController.dispose();
      contentController.dispose();
    });
  }

  void _showNoteDetail(Note note) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => NoteDetailScreen(note: note)),
    ).then((_) => _loadNotes()); // Dönüşte notları yenile
  }

  void _openDrawingCanvas(Course course) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => HandwritingCanvasScreen(course: course),
      ),
    ).then((savedNote) {
      if (savedNote != null) {
        _loadNotes();
        _showSnackBar('Drawing saved!');
      }
    });
  }

  void _playAudio(Note note) {
    if (note.filePath != null) {
      context.read<NoteProvider>().playAudio(note.filePath!);
      HapticFeedback.selectionClick();
      _showSnackBar('Playing audio...');
    }
  }

  void _toggleBookmark(Note note) {
    context.read<NoteProvider>().toggleBookmark(note);
    HapticFeedback.lightImpact();
  }

  void _deleteCourse(Course course) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.deleteCourse),
        content: Text(AppLocalizations.of(context)!.deleteCourseConfirmation),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(AppLocalizations.of(context)!.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              AppLocalizations.of(context)!.delete,
              style: const TextStyle(color: AppColors.red),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      if (!context.mounted) return;
      // ignore: use_build_context_synchronously
      await context.read<CourseProvider>().deleteCourse(course.id);
      if (!context.mounted) return;
      // ignore: use_build_context_synchronously
      Navigator.pop(context);
    }
  }

  void _showAddGradeDialog(Course course) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AddGradeDialog(
        onSave: (name, score, maxScore, weight) async {
          final provider = context.read<CourseProvider>();
          await provider.addGrade(
            courseId: course.id,
            name: name,
            score: score,
            maxScore: maxScore,
            weight: weight,
          );
          _loadGrades(); // Refresh list

          // Ağırlık uyarısı kontrolü
          if (provider.warning != null && mounted) {
            ScaffoldMessenger.of(this.context).showSnackBar(
              SnackBar(
                content: Text(provider.warning!),
                backgroundColor: Colors.amber.shade700,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                duration: const Duration(seconds: 4),
              ),
            );
            provider.clearWarning();
          }
        },
      ),
    );
  }

  Future<void> _deleteGrade(String gradeId) async {
    final success = await context.read<CourseProvider>().deleteGrade(gradeId);
    if (!mounted) return;

    if (success) {
      _loadGrades();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Grade deleted'),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}

class _OptionTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;
  final Color? color;

  const _OptionTile({
    required this.icon,
    required this.title,
    required this.onTap,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final baseColor = color ?? (isDark ? Colors.white : AppColors.primary);
    final textColor =
        color ?? (isDark ? Colors.white : AppColors.textPrimaryLight);

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF2C2C2E) : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isDark ? Colors.white10 : Colors.grey.shade200,
              width: 1,
            ),
            boxShadow: isDark
                ? []
                : [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.02),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: baseColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: baseColor, size: 22),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: textColor,
                  ),
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: isDark ? Colors.grey.shade600 : Colors.grey.shade400,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
