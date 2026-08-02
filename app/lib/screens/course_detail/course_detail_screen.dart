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
import '../../widgets/common/sliver_app_bar_delegate.dart';
import '../note_detail/note_detail_screen.dart';
import '../../models/grade.dart';
import '../../widgets/course/add_grade_dialog.dart';
import '../../widgets/course/add_media_note_dialog.dart';
import '../../providers/deadline_provider.dart';
import '../../widgets/deadlines/add_deadline_dialog.dart';
import '../add_course/add_course_screen.dart';
import 'package:lesson_tracker/l10n/app_localizations.dart';
import 'tabs/course_notes_tab.dart';
import 'tabs/course_grades_tab.dart';
import 'tabs/course_files_tab.dart';
import 'widgets/course_detail_app_bar.dart';
import 'widgets/course_detail_header_info.dart';
import 'widgets/course_bottom_toolbar.dart';
import 'widgets/add_text_note_sheet.dart';
import 'widgets/add_link_sheet.dart';
import 'widgets/course_options_sheet.dart';
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
    // Listen to course updates using O(1) lookup
    final coursesById = context.select<CourseProvider, Map<String, Course>>(
      (p) => p.coursesById,
    );
    final course = coursesById[widget.course.id] ?? widget.course;

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
                      ? AppColors.surfaceDarkElevated
                      : AppColors.surfaceLight, // Premium background style
                  borderRadius: BorderRadius.circular(25),
                ),
                child: TabBar(
                  controller: _tabController,
                  indicator: BoxDecoration(
                    borderRadius: BorderRadius.circular(25),
                    color: isDark ? AppColors.primary : AppColors.surfaceLight,
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
    final courseProvider = context.read<CourseProvider>();
    showCourseOptionsSheet(
      context: context,
      course: course,
      notificationsEnabled: () => courseProvider.notificationsEnabled,
      onEdit: (c) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => AddCourseScreen(courseToEdit: c),
          ),
        ).then((_) {
          _loadData();
        });
      },
      onArchive: (updated) async {
        await courseProvider.updateCourse(updated);
        if (mounted) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(AppLocalizations.of(context)!.courseArchived)),
          );
        }
      },
      onAddDeadline: () => _showAddDeadlineDialog(course),
      onToggleNotifications: (newState) {
        courseProvider.toggleNotifications(newState);
      },
      showSnack: (previousState) {
        _showSnackBar(
          previousState
              ? AppLocalizations.of(context)!.notificationsDisabled
              : AppLocalizations.of(context)!.notificationsEnabled,
        );
      },
      onDelete: () => _deleteCourse(course),
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
              SnackBar(content: Text(AppLocalizations.of(context)!.deadlineAdded)),
            );
          }
        },
      ),
    );
  }

  Future<void> _addFile(Course course) async {
    final success = await context.read<CourseProvider>().addFile(course.id);
    if (!mounted) return;
    if (success) {
      _loadFiles();
      _showSnackBar(AppLocalizations.of(context)!.fileAdded);
    }
  }

  void _showAddLinkDialog(Course course) {
    showAddLinkSheet(
      context: context,
      course: course,
      onSaved: () {
        if (mounted) {
          _loadFiles();
          _showSnackBar(AppLocalizations.of(context)!.linkAdded);
        }
      },
    );
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
            _showSnackBar(AppLocalizations.of(context)!.photoSaved(saved));
          }
        }
      } else {
        final consent = await ConsentUtils.showContentCaptureConsentDialog(
          context,
        );
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

      _showSnackBar(AppLocalizations.of(context)!.processingOcr);

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
        _showSnackBar(AppLocalizations.of(context)!.ocrNoteSaved);
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

          if (!context.mounted) return;
          if (note != null) {
            HapticFeedback.mediumImpact();
            if (!mounted) return;
            if (!context.mounted) return;
            _showSnackBar(AppLocalizations.of(context)!.noteSaved);
          }
        },
      ),
    );
  }

  void _showTextNoteDialog(Course course) {
    showAddTextNoteSheet(
      context: context,
      course: course,
      onSaved: () {
        if (mounted) {
          _showSnackBar(AppLocalizations.of(context)!.noteSaved);
        }
      },
    );
  }

  void _showNoteDetail(Note note) {
    if (note.type == NoteType.drawing || note.drawingData != null) {
      final course = context.read<CourseProvider>().coursesById[note.courseId] ??
          widget.course;
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => HandwritingCanvasScreen(
            course: course,
            existingNote: note,
          ),
        ),
      ).then((_) => _loadNotes());
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => NoteDetailScreen(note: note)),
      ).then((_) => _loadNotes());
    }
  }

  void _openDrawingCanvas(Course course) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => HandwritingCanvasScreen(course: course),
      ),
    ).then((savedNote) {
      if (!context.mounted) return;
      if (savedNote != null) {
        _loadNotes();
        if (!mounted) return;
        if (!context.mounted) return;
        _showSnackBar(AppLocalizations.of(context)!.drawingSaved);
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
          content: Text(AppLocalizations.of(context)!.gradeDeleted),
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
