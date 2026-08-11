import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'helpers/course_actions.dart';
import 'helpers/grade_actions.dart';
import 'helpers/course_delete_actions.dart';
import '../../core/theme/app_colors.dart';
import '../../models/course.dart';
import '../../models/grade.dart';
import '../../models/course_file.dart';
import '../../providers/course_provider.dart';
import '../../providers/note_provider.dart';
import '../../widgets/common/sliver_app_bar_delegate.dart';
import '../../widgets/course/add_grade_dialog.dart';
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
import 'widgets/course_add_deadline_sheet.dart';
import 'widgets/course_image_note_sheet.dart';
import 'widgets/confirm_action_dialog.dart';
import 'widgets/course_add_grade_sheet.dart';
import '../../core/utils/error_handler.dart';

/// Ders detay sayfası
class CourseDetailScreen extends StatefulWidget {
  final Course course;

  const CourseDetailScreen({super.key, required this.course});

  @override
  State<CourseDetailScreen> createState() => _CourseDetailScreenState();
}

class _CourseDetailScreenState extends State<CourseDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late final CourseActions _actions;

  List<Grade> _grades = [];
  bool _isLoadingGrades = false;

  List<CourseFile> _files = [];
  bool _isLoadingFiles = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _actions = CourseActions(
      context: context,
      isMounted: () => mounted,
      showSnack: _showSnackBar,
      onSingleImagePicked: (file, course) =>
          _showImageNoteDialog(file, course),
      onMultipleImagesPicked: (files, course) async {
        int saved = 0;
        for (final file in files) {
          if (!mounted) break;
          final note = await context.read<NoteProvider>().addImageNote(
                courseId: course.id,
                imageFile: file,
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
      },
      handleError: (e, {customMessage}) {
        ErrorHandler.handleError(context, e, customMessage: customMessage);
      },
      onNotesChanged: _loadNotes,
      fallbackCourse: widget.course,
    );
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
        onShowTextNoteDialog: () {
          showAddTextNoteSheet(
            context: context,
            course: course,
            onSaved: () {
              if (mounted) {
                _showSnackBar(AppLocalizations.of(context)!.noteSaved);
              }
            },
          );
        },
        onCaptureImageCamera: () =>
            _actions.captureImage(ImageSource.camera, course),
        onCaptureImageGallery: () =>
            _actions.captureImage(ImageSource.gallery, course),
        onCaptureOcr: () => _actions.captureOcr(course),
        onOpenDrawingCanvas: () => _actions.openDrawingCanvas(course),
      ),
    );
  }

  Widget _buildNotesTab(bool isDark, Course course) {
    return CourseNotesTab(
      course: course,
      onShowNoteDetail: _actions.showNoteDetail,
      onPlayAudio: _actions.playAudio,
      onToggleBookmark: _actions.toggleBookmark,
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
    showCourseAddDeadlineDialog(context, courseId: course.id);
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
    final confirm = await showConfirmActionDialog(context);
    if (confirm) {
      if (!mounted) return;
      await context.read<CourseProvider>().deleteFile(file);
      _loadFiles();
    }
  }

  Future<void> _openFile(CourseFile file) async {
    await context.read<CourseProvider>().openFile(file);
  }


  void _showImageNoteDialog(File imageFile, Course course) {
    showCourseImageNoteSheet(
      context: context,
      imageFile: imageFile,
      course: course,
      onSaved: () {
        if (mounted) {
          _showSnackBar(AppLocalizations.of(context)!.noteSaved);
        }
      },
    );
    HapticFeedback.lightImpact();
  }

  void _deleteCourse(Course course) async {
    await deleteCourseAction(
      context: context,
      course: course,
      isMounted: () => mounted,
    );
  }

void _showAddGradeDialog(Course course) {
    showCourseAddGradeSheet(
      context: context,
      course: course,
      onGradesChanged: _loadGrades,
    );
  }

  Future<void> _deleteGrade(String gradeId) async {
    await deleteGradeAction(
      context: context,
      gradeId: gradeId,
      isMounted: () => mounted,
      onSuccess: _loadGrades,
    );
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
