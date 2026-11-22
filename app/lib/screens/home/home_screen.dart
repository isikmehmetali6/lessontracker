import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../../models/course.dart';
import '../course_detail/course_detail_screen.dart';
import 'tabs/weekly_plan_screen.dart';
import 'tabs/weekly_timetable_screen.dart';
import '../settings/settings_screen.dart';
import 'widgets/home_content.dart';
import 'widgets/home_bottom_nav.dart';
import 'widgets/offline_banner.dart';
import 'helpers/home_init_loader.dart';
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
    await runHomeInit(context: context, isMounted: () => mounted);
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
              const OfflineBanner(),
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
      pickCourse: showCourseSelectionSheet,
    );
  }

}
