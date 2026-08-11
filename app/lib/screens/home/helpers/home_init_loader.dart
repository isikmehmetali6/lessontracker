import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
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
  final deadlineProvider = context.read<DeadlineProvider>();
  final authProvider = context.read<AuthProvider>();
  final syncProvider = context.read<SyncProvider>();

  // Yeni cihaz kontrolü — sadece giriş yapan (misafir olmayan) kullanıcılar için
  if (authProvider.user != null && !authProvider.isGuest) {
    final uid = authProvider.user!.uid;
    final knownKey = 'known_user_$uid';
    final isKnownDevice = await SecureStorageService.getBool(knownKey);

    if (!isKnownDevice) {
      try {
        final syncService = SyncService();
        final hasBackup = await syncService.hasCloudBackup();
        if (hasBackup && isMounted()) {
          final courseCount = await syncService.getCloudCourseCount();
          if (!isMounted()) return;

          final shouldRestore = await showRestoreCloudDialog(
            context: context,
            courseCount: courseCount,
            onStartFresh: () async {
              try {
                await SyncService().clearCloudData();
                if (!isMounted() || !context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      AppLocalizations.of(context)!.cloudDataCleared,
                    ),
                    backgroundColor: AppColors.green,
                    duration: const Duration(seconds: 3),
                  ),
                );
              } catch (e) {
                debugPrint('Bulut silme hatası: $e');
              }
            },
          );
          if (shouldRestore == true && isMounted()) {
            syncProvider.registerProviders(
              courseProvider,
              noteProvider,
              deadlineProvider,
            );
            await syncProvider.restore();
            if (!isMounted()) return;
          }
        }
      } catch (e) {
        debugPrint('Cloud backup check error: $e');
      }
      await SecureStorageService.setBool(knownKey, true);
    }
  }

  // Normal veri yükleme
  await courseProvider.loadCourses();
  if (!isMounted()) return;
  await noteProvider.loadNotes();
  if (!isMounted()) return;

  // Eğer yerel DB boşsa ve kullanıcı giriş yapmışsa, bulutta veri olabilir
  if (courseProvider.courses.isEmpty &&
      authProvider.user != null &&
      !authProvider.isGuest) {
    try {
      final syncService = SyncService();
      final hasBackup = await syncService.hasCloudBackup();
      if (hasBackup && isMounted()) {
        final courseCount = await syncService.getCloudCourseCount();
        if (!isMounted()) return;
        final shouldRestore = await showRestoreCloudDialog(
          context: context,
          courseCount: courseCount,
          onStartFresh: () async {
            try {
              await SyncService().clearCloudData();
              if (!isMounted() || !context.mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    AppLocalizations.of(context)!.cloudDataCleared,
                  ),
                  backgroundColor: AppColors.green,
                  duration: const Duration(seconds: 3),
                ),
              );
            } catch (e) {
              debugPrint('Bulut silme hatası: $e');
            }
          },
        );
        if (shouldRestore == true && isMounted()) {
          syncProvider.registerProviders(
            courseProvider,
            noteProvider,
            deadlineProvider,
          );
          await syncProvider.restore();
          if (!isMounted()) return;
          await courseProvider.loadCourses();
          if (!isMounted()) return;
          await noteProvider.loadNotes();
          if (!isMounted()) return;
        }
      }
    } catch (e) {
      debugPrint('Empty DB cloud check error: $e');
    }
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