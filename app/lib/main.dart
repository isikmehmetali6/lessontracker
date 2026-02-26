import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:lesson_tracker/l10n/app_localizations.dart';

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

import 'screens/home/home_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/onboarding/onboarding_screen.dart';

import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
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

  // Init Services
  await NotificationService().init();
  
  // Initialize Firebase
  try {
     await Firebase.initializeApp(
       options: DefaultFirebaseOptions.currentPlatform,
     );
     
     
  } catch (e) {
    debugPrint('Firebase Init Warning: $e');
  }

  // Start AutoSync
  AutoSyncService().startAutoSync();

  // Schedule weekly study report (every Sunday 20:00)
  NotificationService().scheduleWeeklyReport();

  // Pazar günü ise detaylı rapor gönder (devamsızlık + çalışma süresi)
  if (DateTime.now().weekday == DateTime.sunday) {
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
          
          // Builder for global accessibilities etc
          builder: (context, child) {
            return MediaQuery(
              data: MediaQuery.of(context).copyWith(
                textScaler: TextScaler.linear(
                  MediaQuery.of(context).textScaler.scale(1.0).clamp(0.8, 1.2),
                ),
              ),
              child: child!,
            );
          },
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
  bool _isLocked = false;
  bool _onboardingChecked = false;

  @override
  void initState() {
    super.initState();
    _checkOnboarding();
    _checkAppLock();
  }

  Future<void> _checkOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    final done = prefs.getBool('onboarding_complete') ?? false;
    if (mounted) {
      setState(() {
        _showOnboarding = !done;
        _onboardingChecked = true;
      });
    }
  }

  Future<void> _checkAppLock() async {
    final enabled = await AppLockService.isLockEnabled();
    if (enabled && mounted) {
      setState(() => _isLocked = true);
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

      authProvider.onSignOutCallbacks = [
        () async => courseProvider.clear(),
        () async => noteProvider.clear(),
        () async => deadlineProvider.clear(),
      ];
    }
  }

  @override
  Widget build(BuildContext context) {
    // App Lock
    if (_isLocked) {
      return AppLockScreen(
        onUnlocked: () => setState(() => _isLocked = false),
      );
    }

    // Onboarding
    if (!_onboardingChecked) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (_showOnboarding) {
      return OnboardingScreen(
        onComplete: () => setState(() => _showOnboarding = false),
      );
    }

    // Auth check
    return Consumer<AuthProvider>(
      builder: (context, auth, _) {
        if (auth.isAuthenticated) {
          return const HomeScreen();
        } else {
          return const LoginScreen();
        }
      },
    );
  }
}
