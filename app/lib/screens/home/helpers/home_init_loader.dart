import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:lesson_tracker/services/e2e_key_service.dart';
import 'package:lesson_tracker/services/notification_service.dart';
import 'package:lesson_tracker/services/secure_storage_service.dart';
import 'package:lesson_tracker/services/sync_service.dart';
import 'package:lesson_tracker/core/theme/app_colors.dart';
import 'package:lesson_tracker/l10n/app_localizations.dart';
import 'package:lesson_tracker/providers/auth_provider.dart';
import 'package:lesson_tracker/providers/course_provider.dart';
import 'package:lesson_tracker/providers/deadline_provider.dart';
import 'package:lesson_tracker/providers/note_provider.dart';
import 'package:lesson_tracker/providers/sync_provider.dart';
import 'package:lesson_tracker/screens/home/widgets/restore_cloud_dialog.dart';
import 'package:lesson_tracker/screens/home/widgets/restore_password_dialog.dart';

/// Runs the home screen's initial data pipeline. Extracted from
/// `_HomeScreenState._loadData` per plan 3.1.4 (home shell).
///
/// Steps:
/// 1. If the signed-in user is on a new device, ask whether to restore
///    their cloud backup (and register providers + restore if yes).
/// 2. Always load courses and notes from the local DB.
/// 3. If the local DB is empty AND the signed-in (non-guest) user has
///    cloud data, offer the restore flow again.
/// 4. If still empty, seed with sample data the first time.
/// 5. Fire the notifications permission request.
///
/// The [isMounted] callback gates every step on the host's
/// `State.mounted` flag.
Future<void> runHomeInit({
  required BuildContext context,
  required bool Function() isMounted,
}) async {
  if (!isMounted()) return;
  final courseProvider = context.read<CourseProvider>();
  final noteProvider = context.read<NoteProvider>();
  final authProvider = context.read<AuthProvider>();
  final isSignedInUser = authProvider.user != null && !authProvider.isGuest;

  // Yeni cihaz kontrolü — sadece giriş yapan (misafir olmayan) kullanıcılar için
  if (isSignedInUser) {
    final uid = authProvider.user!.uid;
    final knownKey = 'known_user_$uid';
    final isKnownDevice = await SecureStorageService.getBool(knownKey);

    if (!isKnownDevice) {
      if (!context.mounted || !isMounted()) return;
      await offerCloudRestore(context: context, isMounted: isMounted);
      await SecureStorageService.setBool(knownKey, true);
    }
  }

  // Normal veri yükleme
  await courseProvider.loadCourses();
  if (!isMounted()) return;
  await noteProvider.loadNotes();
  if (!isMounted()) return;

  // Eğer yerel DB boşsa ve kullanıcı giriş yapmışsa, bulutta veri olabilir
  if (courseProvider.courses.isEmpty && isSignedInUser) {
    if (!context.mounted) return;
    await offerCloudRestore(context: context, isMounted: isMounted);
    if (!isMounted()) return;
  }

  // Sadece ilk kurulumda örnek veri ekle
  if (courseProvider.courses.isEmpty) {
    final prefs = await SharedPreferences.getInstance();
    final hasSeenSampleData =
        prefs.getBool('has_seen_sample_data') ?? false;
    if (!hasSeenSampleData) {
      await courseProvider.addSampleData();
      if (!isMounted()) return;
      await noteProvider.addSampleNotes(
        courseProvider.courses.map((c) => c.id).toList(),
      );
      await prefs.setBool('has_seen_sample_data', true);
    }
  }

  if (isMounted()) {
    await NotificationService().requestPermissions();
  }
}

/// Bulutta yedek varsa kullanıcıya "yükle / sıfırdan başla" sorar; gerekirse
/// E2E anahtarını açmak için hesap parolasını ister ve restore eder.
/// Restore yapıldıysa `true` döner.
Future<bool> offerCloudRestore({
  required BuildContext context,
  required bool Function() isMounted,
}) async {
  final syncProvider = context.read<SyncProvider>();
  syncProvider.registerProviders(
    context.read<CourseProvider>(),
    context.read<NoteProvider>(),
    context.read<DeadlineProvider>(),
  );

  try {
    final syncService = SyncService();
    if (!await syncService.hasCloudBackup()) return false;
    final courseCount = await syncService.getCloudCourseCount();
    if (!isMounted() || !context.mounted) return false;

    final shouldRestore = await showRestoreCloudDialog(
      context: context,
      courseCount: courseCount,
      onStartFresh: () async {
        try {
          await SyncService().clearCloudData();
          if (!isMounted() || !context.mounted) return;
          _showSnack(
            context,
            AppLocalizations.of(context)!.cloudDataCleared,
            AppColors.green,
          );
        } catch (e) {
          debugPrint('Bulut silme hatası: $e');
        }
      },
    );
    if (shouldRestore != true || !isMounted()) return false;

    var outcome = await syncProvider.restore();
    var wrongPassword = false;
    while (outcome == RestoreOutcome.needsPassword) {
      if (!isMounted() || !context.mounted) return false;
      final password = await showRestorePasswordDialog(
        context: context,
        showWrongPassword: wrongPassword,
      );
      if (password == null) return false;
      final unlocked = await E2EKeyService().loadKeyFromCloud(password);
      if (!unlocked) {
        wrongPassword = true;
        continue;
      }
      outcome = await syncProvider.restore();
    }

    if (!isMounted() || !context.mounted) return false;
    final l10n = AppLocalizations.of(context)!;
    if (outcome == RestoreOutcome.failed) {
      _showSnack(context, l10n.restoreFailed, AppColors.red);
      return false;
    }
    if (syncProvider.skippedRecords > 0) {
      _showSnack(
        context,
        l10n.restoreSkippedRecords(syncProvider.skippedRecords),
        AppColors.orange,
      );
    }
    return true;
  } catch (e) {
    debugPrint('Cloud restore offer error: $e');
    return false;
  }
}

void _showSnack(BuildContext context, String message, Color color) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(message),
      backgroundColor: color,
      duration: const Duration(seconds: 4),
    ),
  );
}
