import 'dart:io';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../../core/theme/app_colors.dart';
import '../../models/course.dart';
import '../../providers/course_provider.dart';
import '../../providers/note_provider.dart';
import '../../widgets/home/home_widgets.dart';
import '../course_detail/course_detail_screen.dart';
import 'tabs/weekly_plan_screen.dart';
import 'tabs/weekly_timetable_screen.dart';
import '../settings/settings_screen.dart';
import '../study_timer/study_timer_screen.dart';
import '../gpa/gpa_calculator_screen.dart';
import 'package:lesson_tracker/l10n/app_localizations.dart';
import '../../core/services/notification_service.dart';
import '../../providers/auth_provider.dart';
import '../../providers/deadline_provider.dart';
import '../../providers/sync_provider.dart';
import '../../core/services/sync_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/services/secure_storage_service.dart';
import 'widgets/quick_action_card.dart';
import 'widgets/voice_recording_sheet.dart';
import 'widgets/today_schedule_list.dart';
import 'widgets/priority_courses_list.dart';
import 'widgets/attendance_overview_list.dart';
import 'widgets/recent_notes_list.dart';
import 'widgets/home_bottom_nav.dart';
import 'widgets/home_header.dart';
import 'widgets/home_search_bar.dart';
import '../../core/utils/error_handler.dart';
import '../moodle/moodle_hub_screen.dart';
import '../../core/utils/consent_utils.dart';

/// Ana ekran
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  late StreamSubscription<List<ConnectivityResult>> _connectivitySubscription;
  bool _isOffline = false;

  @override
  void initState() {
    super.initState();
    _connectivitySubscription = Connectivity().onConnectivityChanged.listen((
      results,
    ) {
      final offline = results.every((r) => r == ConnectivityResult.none);
      if (_isOffline != offline) {
        setState(() => _isOffline = offline);
      }
    });
    // Call load data asynchronously
    Future.microtask(() => _loadData());
  }

  @override
  void dispose() {
    _connectivitySubscription.cancel();
    super.dispose();
  }

  Future<void> _loadData() async {
    if (!mounted) return;

    final courseProvider = context.read<CourseProvider>();
    final noteProvider = context.read<NoteProvider>();
    final deadlineProvider = context.read<DeadlineProvider>();
    final authProvider = context.read<AuthProvider>();
    final syncProvider = context.read<SyncProvider>();

    // Yeni cihaz kontrolü — sadece giriş yapan (misafir olmayan) kullanıcılar için
    if (authProvider.user != null && !authProvider.isGuest) {
      final uid = authProvider.user!.uid;
      final knownKey = 'known_user_$uid';
      final isKnownDevice =
          await SecureStorageService.getBool(knownKey);

      if (!isKnownDevice) {
        // Bu kullanıcı bu cihazda ilk kez — bulutta veri var mı kontrol et
        try {
          final syncService = SyncService();
          final hasBackup = await syncService.hasCloudBackup();

          if (hasBackup && mounted) {
            final courseCount = await syncService.getCloudCourseCount();
            if (!mounted) return;

            // Kullanıcıya sor: verileri yükle mi, sıfırdan mı başla?
            final shouldRestore = await _showRestoreDialog(courseCount);

            if (shouldRestore == true && mounted) {
              syncProvider.registerProviders(
                courseProvider,
                noteProvider,
                deadlineProvider,
              );
              await syncProvider.restore();
              if (!mounted) return;
            }
          }
        } catch (e) {
          debugPrint('Cloud backup check error: $e');
        }

        // Bu cihazı artık bilinen olarak işaretle
        await SecureStorageService.setBool(knownKey, true);
      }
    }

    // Normal veri yükleme
    await courseProvider.loadCourses();
    if (!mounted) return;

    await noteProvider.loadNotes();
    if (!mounted) return;

    // Eğer yerel DB boşsa ve kullanıcı giriş yapmışsa, bulutta veri olabilir
    if (courseProvider.courses.isEmpty &&
        authProvider.user != null &&
        !authProvider.isGuest) {
      try {
        final syncService = SyncService();
        final hasBackup = await syncService.hasCloudBackup();
        if (hasBackup && mounted) {
          final courseCount = await syncService.getCloudCourseCount();
          if (!mounted) return;

          final shouldRestore = await _showRestoreDialog(courseCount);
          if (shouldRestore == true && mounted) {
            syncProvider.registerProviders(
              courseProvider,
              noteProvider,
              deadlineProvider,
            );
            await syncProvider.restore();
            if (!mounted) return;
            // Verileri tekrar yükle
            await courseProvider.loadCourses();
            if (!mounted) return;
            await noteProvider.loadNotes();
            if (!mounted) return;
          }
        }
      } catch (e) {
        debugPrint('Empty DB cloud check error: $e');
      }
    }

    // Sadece ilk kurulumda örnek veri ekle (giriş yapmamış veya hala boşsa)
    if (courseProvider.courses.isEmpty) {
      final prefs = await SharedPreferences.getInstance();
      final hasSeenSampleData = prefs.getBool('has_seen_sample_data') ?? false;

      if (!hasSeenSampleData) {
        await courseProvider.addSampleData();
        if (!mounted) return;

        await noteProvider.addSampleNotes(
          courseProvider.courses.map((c) => c.id).toList(),
        );
        await prefs.setBool('has_seen_sample_data', true);
      }
    }

    // Call permissions check
    if (mounted) {
      await NotificationService().requestPermissions();
    }
  }

  /// Yeni cihazda bulut verisi bulunduğunda gösterilen dialog
  Future<bool?> _showRestoreDialog(int courseCount) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        final isDark = Theme.of(ctx).brightness == Brightness.dark;
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          backgroundColor: isDark ? const Color(0xFF1E1E2E) : Colors.white,
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.cloud_download_rounded,
                  color: AppColors.primary,
                  size: 28,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Kayıtlı Veriler Bulundu',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Bu hesapta daha önce kaydedilmiş $courseCount ders bulunuyor.',
                style: TextStyle(
                  fontSize: 15,
                  color: isDark ? Colors.grey[300] : Colors.grey[700],
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.05)
                      : Colors.grey[50],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.1)
                        : Colors.grey[200]!,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      size: 18,
                      color: AppColors.primary,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Verilerinizi yüklemek ders, not ve deadline bilgilerinizi bu cihaza aktarır.',
                        style: TextStyle(
                          fontSize: 13,
                          color: isDark ? Colors.grey[400] : Colors.grey[600],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () async {
                // Return 'false' to dismiss dialog
                Navigator.of(ctx).pop(false);

                // Arka planda buluttaki eski verileri siliyoruz
                try {
                  await SyncService().clearCloudData();
                  if (ctx.mounted) {
                    ScaffoldMessenger.of(ctx).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Eski bulut kayıtları temizlendi. Yeni sayfa açık.',
                        ),
                        backgroundColor: AppColors.green,
                        duration: Duration(seconds: 3),
                      ),
                    );
                  }
                } catch (e) {
                  debugPrint('Bulut silme hatası: $e');
                }
              },
              child: Text(
                'Sıfırdan Başla',
                style: TextStyle(
                  color: isDark ? Colors.grey[400] : Colors.grey[600],
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            ElevatedButton.icon(
              onPressed: () => Navigator.of(ctx).pop(true),
              icon: const Icon(Icons.cloud_download_rounded, size: 18),
              label: const Text('Verileri Yükle'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset:
          false, // Prevents keyboard from squishing the UI and throwing pixel errors
      body: SafeArea(
        child: Column(
          children: [
            if (_isOffline)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  vertical: 8,
                  horizontal: 16,
                ),
                color: Colors.orange.shade800,
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.wifi_off, color: Colors.white, size: 16),
                    SizedBox(width: 8),
                    Text(
                      'You are offline',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            Expanded(
              child: IndexedStack(
                index: _currentIndex,
                children: [
                  _HomeContent(
                    onScanTap: () => _showQuickCapture(context, isOcr: true),
                    onVoiceTap: () => _showQuickCapture(context, isOcr: false),
                    onCourseTap: (course) => _navigateToCourse(course),
                  ),
                  const WeeklyPlanScreen(),
                  const WeeklyTimetableScreen(),
                  const SettingsScreen(),
                  const MoodleHubScreen(),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: HomeBottomNav(
        currentIndex: _currentIndex,
        onTabSelected: (index) => setState(() => _currentIndex = index),
      ),
    );
  }

  void _navigateToCourse(Course course) {
    Navigator.push(
      context,
      CupertinoPageRoute(builder: (_) => CourseDetailScreen(course: course)),
    );
  }

  final ImagePicker _imagePicker = ImagePicker();

  void _showQuickCapture(BuildContext context, {required bool isOcr}) {
    if (isOcr) {
      _quickCaptureOcr(context);
    } else {
      _quickCaptureVoice(context);
    }
  }

  /// OCR Quick Capture: Camera → OCR → Course Selection → Save
  Future<void> _quickCaptureOcr(BuildContext context) async {
    try {
      final consent = await ConsentUtils.showContentCaptureConsentDialog(context);
      if (consent != true || !mounted) return;

      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1920,
        maxHeight: 1920,
        imageQuality: 85,
      );

      if (image == null || !mounted) return;

      final courseId = await _showCourseSelectionDialog(context);
      if (courseId == null || !mounted) return;

      // Show processing indicator
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              ),
              SizedBox(width: 12),
              Text('Processing OCR...'),
            ],
          ),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          duration: const Duration(seconds: 10),
        ),
      );

      final courseProvider = context.read<CourseProvider>();
      final course = await courseProvider.getCourseById(courseId);
      final userName = 'User';

      final note = await context.read<NoteProvider>().addOcrNote(
        courseId: courseId,
        imageFile: File(image.path),
        courseName: course?.name,
        userName: userName,
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).hideCurrentSnackBar();

      if (note != null) {
        HapticFeedback.mediumImpact();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('📝 OCR note saved!'),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      } else {
        ErrorHandler.handleError(
          context,
          context.read<NoteProvider>().error ?? 'OCR failed',
        );
      }
    } catch (e) {
      if (mounted) {
        ErrorHandler.handleError(context, e, customMessage: 'Error: $e');
      }
    }
  }

  /// Voice Quick Capture: Record → Stop → Course Selection → Save
  Future<void> _quickCaptureVoice(BuildContext context) async {
    final consent = await ConsentUtils.showContentCaptureConsentDialog(context, isAudio: true);
    if (consent != true || !mounted) return;

    final noteProvider = context.read<NoteProvider>();

    // Start recording
    final success = await noteProvider.startRecording();
    if (!success) {
      if (mounted) {
        ErrorHandler.handleError(context, 'Microphone permission required');
      }
      return;
    }

    if (!mounted) return;
    HapticFeedback.mediumImpact();

    // Show recording bottom sheet
    final shouldSave = await showModalBottomSheet<bool>(
      context: context,
      isDismissible: false,
      enableDrag: false,
      backgroundColor: Colors.transparent,
      builder: (ctx) => VoiceRecordingSheet(noteProvider: noteProvider),
    );

    if (!mounted) return;

    if (shouldSave == true) {
      // Ask which course to save to
      final courseId = await _showCourseSelectionDialog(context);
      if (courseId == null || !mounted) {
        // User cancelled — discard recording
        await noteProvider.cancelRecording();
        return;
      }

      final note = await noteProvider.stopRecordingAndSave(courseId: courseId);

      if (!mounted) return;
      if (note != null) {
        HapticFeedback.mediumImpact();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('🎙️ Voice memo saved!'),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }
    } else {
      // User cancelled recording
      await noteProvider.cancelRecording();
    }
  }

  /// Course selection dialog — returns courseId or null if cancelled
  Future<String?> _showCourseSelectionDialog(BuildContext context) async {
    final courses = context.read<CourseProvider>().uniqueCourses;
    if (courses.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('No courses available. Add a course first!'),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
      return null;
    }

    return showModalBottomSheet<String>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        final isDark = Theme.of(ctx).brightness == Brightness.dark;
        return Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: isDark ? AppColors.surfaceDark : Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
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
              const SizedBox(height: 20),
              Text(
                'Select Course',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: isDark
                      ? AppColors.textPrimaryDark
                      : AppColors.textPrimaryLight,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Choose where to save this note',
                style: TextStyle(
                  fontSize: 14,
                  color: isDark
                      ? AppColors.textSecondaryDark
                      : AppColors.textSecondaryLight,
                ),
              ),
              const SizedBox(height: 16),
              ConstrainedBox(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(ctx).size.height * 0.4,
                ),
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: courses.length,
                  itemBuilder: (_, i) {
                    final course = courses[i];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      decoration: BoxDecoration(
                        color: isDark
                            ? Colors.white.withValues(alpha: 0.05)
                            : Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isDark
                              ? Colors.white.withValues(alpha: 0.1)
                              : Colors.grey.shade200,
                        ),
                      ),
                      child: ListTile(
                        leading: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: course.color.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(
                            Icons.school,
                            color: course.color,
                            size: 20,
                          ),
                        ),
                        title: Text(
                          course.name,
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: isDark
                                ? AppColors.textPrimaryDark
                                : AppColors.textPrimaryLight,
                          ),
                        ),
                        subtitle: course.professor != null
                            ? Text(
                                course.professor!,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: isDark
                                      ? AppColors.textSecondaryDark
                                      : AppColors.textSecondaryLight,
                                ),
                              )
                            : null,
                        trailing: Icon(
                          Icons.chevron_right,
                          color: isDark
                              ? AppColors.textSecondaryDark
                              : AppColors.textSecondaryLight,
                        ),
                        onTap: () => Navigator.pop(ctx, course.id),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }
}

/// Ana sayfa içeriği
class _HomeContent extends StatelessWidget {
  final VoidCallback onScanTap;
  final VoidCallback onVoiceTap;
  final Function(Course) onCourseTap;

  const _HomeContent({
    required this.onScanTap,
    required this.onVoiceTap,
    required this.onCourseTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Trigger widget update efficiently (e.g. at provider level when courses change)
    // Removed adPostFrameCallback here to prevent excessive calls during every rebuild.

    return RefreshIndicator(
      onRefresh: () async {
        await context.read<CourseProvider>().loadCourses();
        if (!context.mounted) return;
        await context.read<NoteProvider>().loadNotes();
      },
      child: CustomScrollView(
        slivers: [
          // Header
          const SliverToBoxAdapter(child: HomeHeader()),

          // Arama çubuğu
          const SliverToBoxAdapter(child: HomeSearchBar()),

          // Stats Summary (New)
          const SliverPadding(
            padding: EdgeInsets.symmetric(horizontal: 24),
            sliver: SliverToBoxAdapter(child: HomeStatsSummary()),
          ),

          // Today's Schedule
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 12),
              child: Text(
                AppLocalizations.of(context)!.todaySchedule,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: isDark
                      ? AppColors.textPrimaryDark
                      : AppColors.textPrimaryLight,
                ),
              ),
            ),
          ),

          TodayScheduleList(onCourseTap: onCourseTap),

          // Priority Focus Başlık
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 12),
              child: Text(
                AppLocalizations.of(context)!.priorityFocus,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: isDark
                      ? AppColors.textPrimaryDark
                      : AppColors.textPrimaryLight,
                ),
              ),
            ),
          ),

          // Priority Courses
          PriorityCoursesList(onCourseTap: onCourseTap),

          // Quick Capture
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 12),
              child: Text(
                AppLocalizations.of(context)!.quickCapture,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: isDark
                      ? AppColors.textPrimaryDark
                      : AppColors.textPrimaryLight,
                ),
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: QuickCaptureButtons(
                onScanTap: onScanTap,
                onVoiceTap: onVoiceTap,
              ),
            ),
          ),

          // Quick Actions (Timer & GPA)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 12),
              child: Text(
                AppLocalizations.of(context)!.quickActions,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: isDark
                      ? AppColors.textPrimaryDark
                      : AppColors.textPrimaryLight,
                ),
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                children: [
                  Expanded(
                    child: QuickActionCard(
                      icon: Icons.timer,
                      title: AppLocalizations.of(context)!.studyTimer,
                      subtitle: AppLocalizations.of(context)!.studyTimerDesc,
                      color: AppColors.orange,
                      isDark: isDark,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const StudyTimerScreen(),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: QuickActionCard(
                      icon: Icons.analytics,
                      title: AppLocalizations.of(context)!.gpaCalculator,
                      subtitle: AppLocalizations.of(context)!.gpaCalcDesc,
                      color: AppColors.purple,
                      isDark: isDark,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const GPACalculatorScreen(),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Attendance Overview
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 32, 24, 12),
              child: Text(
                AppLocalizations.of(context)!.attendanceStatus,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: isDark
                      ? AppColors.textPrimaryDark
                      : AppColors.textPrimaryLight,
                ),
              ),
            ),
          ),

          const AttendanceOverviewList(),

          // Recent Notes
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 32, 24, 12),
              child: Text(
                AppLocalizations.of(context)!.recentNotes,
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
              ),
            ),
          ),

          RecentNotesList(onCourseTap: onCourseTap),
        ],
      ),
    );
  }
}
