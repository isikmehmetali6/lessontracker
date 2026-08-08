import 'dart:io';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../../core/theme/app_colors.dart';
import '../../models/course.dart';
import '../../providers/course_provider.dart';
import '../../providers/note_provider.dart';
import '../course_detail/course_detail_screen.dart';
import 'tabs/weekly_plan_screen.dart';
import 'tabs/weekly_timetable_screen.dart';
import '../settings/settings_screen.dart';
import 'package:lesson_tracker/l10n/app_localizations.dart';
import '../../core/services/notification_service.dart';
import '../../providers/auth_provider.dart';
import '../../providers/deadline_provider.dart';
import '../../providers/sync_provider.dart';
import '../../core/services/sync_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/services/secure_storage_service.dart';
import 'widgets/home_content.dart';
import 'widgets/home_bottom_nav.dart';
import 'widgets/restore_cloud_dialog.dart';
import 'helpers/quick_capture_ocr.dart';
import '../../widgets/course/course_selection_sheet.dart';
import '../moodle/moodle_hub_screen.dart';

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
      final isKnownDevice = await SecureStorageService.getBool(knownKey);

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
    return showRestoreCloudDialog(
      context: context,
      courseCount: courseCount,
      onStartFresh: () async {
        try {
          await SyncService().clearCloudData();
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(AppLocalizations.of(context)!.cloudDataCleared),
                backgroundColor: AppColors.green,
                duration: const Duration(seconds: 3),
              ),
            );
          }
        } catch (e) {
          debugPrint('Bulut silme hatası: $e');
        }
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
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.wifi_off, color: Colors.white, size: 16),
                    const SizedBox(width: 8),
                    Text(
                      AppLocalizations.of(context)!.youAreOffline,
                      style: const TextStyle(
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
                  HomeContent(
                    onScanTap: () => _quickCaptureOcr(context),
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

  /// OCR Quick Capture: Camera → OCR → Course Selection → Save
  Future<void> _quickCaptureOcr(BuildContext context) async {
    await runQuickCaptureOcr(
      context: context,
      pickCourse: (ctx) => _showCourseSelectionDialog(ctx),
    );
  }

  /// Course selection dialog — returns courseId or null if cancelled
  Future<String?> _showCourseSelectionDialog(BuildContext context) async {
    return showCourseSelectionSheet(context);
  }
}

/// Ana sayfa içeriği
