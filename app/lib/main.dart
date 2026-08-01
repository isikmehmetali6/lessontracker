import 'dart:ui' show PlatformDispatcher;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:lesson_tracker/l10n/app_localizations.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter/foundation.dart' show kIsWeb, kDebugMode;

import 'core/theme/app_theme.dart';
import 'providers/theme_provider.dart';
import 'providers/course_provider.dart';
import 'providers/note_provider.dart';
import 'providers/deadline_provider.dart';
import 'providers/language_provider.dart';
import 'providers/auth_provider.dart';
import 'providers/sync_provider.dart';
import 'core/services/notification_service.dart';
import 'core/services/auto_sync_service.dart';
import 'core/services/app_lock_service.dart';
import 'core/services/weekly_report_service.dart';
import 'providers/planner_event_provider.dart';
import 'providers/moodle_provider.dart';
import 'core/services/attendance_automation_service.dart';
import 'core/services/moodle_background_service.dart';
import 'package:workmanager/workmanager.dart';

import 'screens/home/home_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/onboarding/onboarding_screen.dart';
import 'screens/onboarding/kvkk_flow.dart';
import 'firebase_options.dart';

@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    if (task == 'attendance_check_task') {
      try {
        final service = AttendanceAutomationService();
        await service.executeBackgroundCheck();
      } catch (e) {
        debugPrint('Workmanager error: $e');
      }
    } else if (task == 'moodle_sync_task') {
      try {
        final service = MoodleBackgroundService();
        await service.executeBackgroundSync();
      } catch (e) {
        debugPrint('Moodle Workmanager error: $e');
      }
    }
    return Future.value(true);
  });
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load Env (optional: app boots even without .env present)
  await dotenv.load(fileName: ".env", isOptional: true);

  // Status bar
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Init Services (only on mobile)
  if (!kIsWeb) {
    NotificationService().init();

    // Init Workmanager for Background Tasks (only on mobile)
    Workmanager().initialize(callbackDispatcher);
  }

  // Initialize Firebase — must succeed before sync/auth services
  bool firebaseReady = false;
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    firebaseReady = true;
  } catch (e) {
    debugPrint('Firebase Init Warning: $e');
  }

  // Firebase initialized — start connectivity listener for auto-sync retry
  if (firebaseReady) {
    AutoSyncService().init();

    // Crashlytics: Flutter framework hatalarını ve async error'ları yakala.
    // Sadece release modda aktif (debug'da noisy olur).
    if (!kDebugMode) {
      FlutterError.onError =
          FirebaseCrashlytics.instance.recordFlutterFatalError;
      PlatformDispatcher.instance.onError = (error, stack) {
        FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
        return true;
      };
    }
  }

  if (!kIsWeb) {
    try {
      NotificationService().scheduleWeeklyReport();
    } catch (e) {
      debugPrint('NotificationService: scheduleWeeklyReport failed: $e');
    }
  }

  if (!kIsWeb && DateTime.now().weekday == DateTime.sunday) {
    WeeklyReportService().checkAndSendReport();
  }

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => CourseProvider()),
        ChangeNotifierProvider(create: (_) => NoteProvider()),
        ChangeNotifierProvider(create: (_) => DeadlineProvider()),
        ChangeNotifierProvider(create: (_) => LanguageProvider()),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => SyncProvider()),
        ChangeNotifierProvider(
          create: (_) => PlannerEventProvider()..loadEvents(),
        ),
        ChangeNotifierProvider(create: (_) => MoodleProvider()..initialize()),
      ],
      child: const LessonTrackerApp(),
    ),
  );
}

class LessonTrackerApp extends StatelessWidget {
  const LessonTrackerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer2<ThemeProvider, LanguageProvider>(
      builder: (context, themeProvider, languageProvider, _) {
        return MaterialApp(
          title: 'Lesson Tracker',
          debugShowCheckedModeBanner: false,

          // Theme
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: themeProvider.themeMode,

          // Localization
          locale: languageProvider.locale, // Using provider's locale
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,

          // Home Wrapper
          home: const AuthWrapper(),
        );
      },
    );
  }
}

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  bool _callbacksRegistered = false;
  bool _showOnboarding = false;
  bool _showKvkk = false;
  bool _isLocked = false;
  bool _initChecked = false;

  @override
  void initState() {
    super.initState();
    _initChecks();
  }

  Future<void> _initChecks() async {
    final prefs = await SharedPreferences.getInstance();
    final onboardingComplete = prefs.getBool('onboarding_complete') ?? false;
    final isLocked = await AppLockService.isLockEnabled();
    if (mounted) {
      await context.read<AuthProvider>().ensureGuestRestored();
    }
    if (mounted) {
      setState(() {
        _showOnboarding = !onboardingComplete;
        _isLocked = isLocked;
        _initChecked = true;
      });
    }
  }

  Future<void> _checkKvkkConsent() async {
    if (_showOnboarding || _isLocked) return;

    final user = context.read<AuthProvider>().user;
    if (user == null) return;

    final prefs = await SharedPreferences.getInstance();
    final kvkkConsent = prefs.getInt('kvkk_consent_timestamp');

    if (kvkkConsent == null && mounted) {
      setState(() => _showKvkk = true);
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_callbacksRegistered) {
      _callbacksRegistered = true;
      final authProvider = context.read<AuthProvider>();
      final courseProvider = context.read<CourseProvider>();
      final noteProvider = context.read<NoteProvider>();
      final deadlineProvider = context.read<DeadlineProvider>();

      authProvider.addSignOutCallback(() async => courseProvider.clear());
      authProvider.addSignOutCallback(() async => noteProvider.clear());
      authProvider.addSignOutCallback(() async => deadlineProvider.clear());
      authProvider.addSignOutCallback(
        () async => context.read<MoodleProvider>().clearAll(),
      );

      if (authProvider.isAuthenticated) {
        _checkKvkkConsent();
      }
    } else if (_initChecked && !_showOnboarding && !_isLocked) {
      final auth = context.watch<AuthProvider>();
      if (auth.isAuthenticated && !_showKvkk) {
        _checkKvkkConsent();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // App Lock
    if (_isLocked) {
      return AppLockScreen(onUnlocked: () => setState(() => _isLocked = false));
    }

    // Onboarding
    if (!_initChecked) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (_showOnboarding) {
      return OnboardingScreen(
        onComplete: () {
          setState(() => _showOnboarding = false);
          _checkKvkkConsent();
        },
      );
    }

    // Auth check
    return Consumer<AuthProvider>(
      builder: (context, auth, _) {
        if (auth.isAuthenticated) {
          // TODO: Enable email verification check after SMTP settings are configured
          // if (!auth.isEmailVerified) {
          //   return EmailVerificationScreen();
          // }
          if (_showKvkk) {
            return KvkkOnboardingFlow(
              onComplete: () => setState(() => _showKvkk = false),
            );
          }
          return const HomeScreen();
        } else {
          return const LoginScreen();
        }
      },
    );
  }
}
