import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/directory_size_utils.dart';
import '../../core/database/database_helper.dart';
import '../../repositories/course_repository.dart';
import '../../repositories/note_repository.dart';
import '../../repositories/grade_repository.dart';
import '../../repositories/deadline_repository.dart';
import '../../repositories/absence_repository.dart';
import '../../repositories/file_repository.dart';
import 'widgets/storage_breakdown_widgets.dart';
import 'package:lesson_tracker/l10n/app_localizations.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import '../../core/utils/error_handler.dart';

class StorageScreen extends StatefulWidget {
  const StorageScreen({super.key});

  @override
  State<StorageScreen> createState() => _StorageScreenState();
}

class _StorageScreenState extends State<StorageScreen> {
  final DatabaseHelper _dbHelper = DatabaseHelper();

  bool _isLoading = true;
  int _dbSize = 0;
  int _mediaSize = 0;
  int _cacheSize = 0;
  Map<String, int> _stats = {};

  @override
  void initState() {
    super.initState();
    _loadStorageInfo();
  }

  Future<void> _loadStorageInfo() async {
    setState(() => _isLoading = true);

    try {
      final dbSize = await _dbHelper.getDatabaseSize();
      final stats = <String, int>{
        'courses': await CourseRepository().getCourseCount(),
        'notes': await NoteRepository().getNoteCount(),
        'grades': await GradeRepository().getCount(),
        'course_files': await FileRepository().getCount(),
        'deadlines': await DeadlineRepository().getCount(),
        'absences': await AbsenceRepository().getCount(),
      };

      // Calculate media files size
      int mediaSize = 0;
      try {
        final appDir = await getApplicationDocumentsDirectory();
        mediaSize = await DirectorySizeUtils.directorySize(appDir);
      } catch (e, stackTrace) {
        debugPrint('Error calculating media size: $e\nStack: $stackTrace');
      }

      // Calculate cache size
      int cacheSize = 0;
      try {
        final tempDir = await getTemporaryDirectory();
        cacheSize = await DirectorySizeUtils.directorySize(tempDir);
      } catch (e, stackTrace) {
        debugPrint('Error calculating cache size: $e\nStack: $stackTrace');
      }

      if (mounted) {
        setState(() {
          _dbSize = dbSize;
          _mediaSize = mediaSize;
          _cacheSize = cacheSize;
          _stats = stats;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _clearCache() async {
    setState(() => _isLoading = true);
    try {
      final tempDir = await getTemporaryDirectory();
      if (await tempDir.exists()) {
        await for (var entity in tempDir.list()) {
          try {
            if (entity is File) {
              await entity.delete();
            } else if (entity is Directory) {
              await entity.delete(recursive: true);
            }
          } catch (e, stackTrace) {
            debugPrint('Error deleting temp entity: $e\nStack: $stackTrace');
          }
        }
      }

      // Resim cache temizliği
      PaintingBinding.instance.imageCache.clear();
      PaintingBinding.instance.imageCache.clearLiveImages();

      await Future.delayed(
        const Duration(milliseconds: 800),
      ); // Animasyon için süre

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white),
                const SizedBox(width: 12),
                Text(AppLocalizations.of(context)!.cacheCleared),
              ],
            ),
            backgroundColor: AppColors.green,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
        _loadStorageInfo();
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ErrorHandler.handleError(context, e);
      }
    }
  }

  Future<void> _deepClean() async {
    final loc = AppLocalizations.of(context)!;
    setState(() => _isLoading = true);
    try {
      // Inline cache clearing without showing its own snackbar
      final tempDir = await getTemporaryDirectory();
      if (await tempDir.exists()) {
        await for (var entity in tempDir.list()) {
          try {
            if (entity is File) {
              await entity.delete();
            } else if (entity is Directory) {
              await entity.delete(recursive: true);
            }
          } catch (e, stackTrace) {
            debugPrint(
              'Error deleting temp entity in deep clean: $e\nStack: $stackTrace',
            );
          }
        }
      }
      PaintingBinding.instance.imageCache.clear();
      PaintingBinding.instance.imageCache.clearLiveImages();

      // Cached network image disk cache temizliği
      try {
        await DefaultCacheManager().emptyCache();
      } catch (e, stackTrace) {
        debugPrint('Error clearing image cache: $e\nStack: $stackTrace');
      }

      await Future.delayed(const Duration(milliseconds: 1500));

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.rocket_launch_rounded, color: Colors.white),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(loc.storageOptimized,
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
            backgroundColor: AppColors.purple,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
        _loadStorageInfo();
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showOptimizationMenu() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final loc = AppLocalizations.of(context)!;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => Container(
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
                    color: isDark ? Colors.grey.shade600 : Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.cleaning_services_rounded,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        loc.smartStorageManagement,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: isDark
                              ? AppColors.textPrimaryDark
                              : AppColors.textPrimaryLight,
                        ),
                      ),
                      Text(
                        loc.storageOptions,
                        style: TextStyle(
                          fontSize: 14,
                          color: isDark
                              ? AppColors.textSecondaryDark
                              : AppColors.textSecondaryLight,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),

            // Seçenek 1
            GestureDetector(
              onTap: () {
                Navigator.pop(ctx);
                _clearCache();
              },
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.orange.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: AppColors.orange.withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.auto_delete_outlined,
                      color: AppColors.orange,
                      size: 28,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            loc.standardCleanup,
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              color: isDark ? Colors.white : Colors.black87,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            loc.standardCleanupDesc(DirectorySizeUtils.formatBytes(_cacheSize)),
                            style: TextStyle(
                              color: isDark
                                  ? Colors.grey.shade400
                                  : Colors.grey.shade600,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Seçenek 2
            GestureDetector(
              onTap: () {
                Navigator.pop(ctx);
                _deepClean();
              },
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.purple.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: AppColors.purple.withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.memory_rounded,
                      color: AppColors.purple,
                      size: 28,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            loc.deepOptimization,
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              color: isDark ? Colors.white : Colors.black87,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            loc.deepOptimizationDesc,
                            style: TextStyle(
                              color: isDark
                                  ? Colors.grey.shade400
                                  : Colors.grey.shade600,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final loc = AppLocalizations.of(context)!;
    final totalSize = _dbSize + _mediaSize + _cacheSize;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          loc.storage,
          style: TextStyle(
            color: isDark
                ? AppColors.textPrimaryDark
                : AppColors.textPrimaryLight,
            fontWeight: FontWeight.w700,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new,
            color: isDark
                ? AppColors.textSecondaryDark
                : AppColors.textSecondaryLight,
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            )
          : ListView(
              padding: const EdgeInsets.all(24),
              children: [
                // Total Storage Card
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [AppColors.primary, AppColors.primaryDark],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    children: [
                      const Icon(Icons.storage, color: Colors.white, size: 40),
                      const SizedBox(height: 12),
                      Text(
                        DirectorySizeUtils.formatBytes(totalSize),
                        style: const TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        loc.totalStorageUsed,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.white.withValues(alpha: 0.8),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Breakdown
                StorageSectionTitle(title: loc.storageBreakdown, isDark: isDark),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.surfaceDark : Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    children: [
                      StorageRow(
                        isDark: isDark,
                        icon: Icons.data_usage,
                        color: AppColors.primary,
                        label: loc.database,
                        bytes: _dbSize,
                        total: totalSize,
                      ),
                      const SizedBox(height: 16),
                      StorageRow(
                        isDark: isDark,
                        icon: Icons.perm_media,
                        color: AppColors.purple,
                        label: loc.mediaFiles,
                        bytes: _mediaSize,
                        total: totalSize,
                      ),
                      const SizedBox(height: 16),
                      StorageRow(
                        isDark: isDark,
                        icon: Icons.cached,
                        color: AppColors.orange,
                        label: loc.cache,
                        bytes: _cacheSize,
                        total: totalSize,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Data Stats
                StorageSectionTitle(title: loc.dataStats, isDark: isDark),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.surfaceDark : Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    children: [
                      StatRow(
                        isDark: isDark,
                        icon: Icons.school,
                        color: AppColors.primary,
                        label: loc.totalCourses,
                        count: _stats['courses'] ?? 0,
                      ),
                      Divider(
                        height: 20,
                        color: isDark
                            ? Colors.grey.shade800
                            : Colors.grey.shade200,
                      ),
                      StatRow(
                        isDark: isDark,
                        icon: Icons.note,
                        color: AppColors.blue,
                        label: loc.totalNotes,
                        count: _stats['notes'] ?? 0,
                      ),
                      Divider(
                        height: 20,
                        color: isDark
                            ? Colors.grey.shade800
                            : Colors.grey.shade200,
                      ),
                      StatRow(
                        isDark: isDark,
                        icon: Icons.grade,
                        color: AppColors.orange,
                        label: loc.gradesTab,
                        count: _stats['grades'] ?? 0,
                      ),
                      Divider(
                        height: 20,
                        color: isDark
                            ? Colors.grey.shade800
                            : Colors.grey.shade200,
                      ),
                      StatRow(
                        isDark: isDark,
                        icon: Icons.insert_drive_file,
                        color: AppColors.purple,
                        label: loc.filesTab,
                        count: _stats['course_files'] ?? 0,
                      ),
                      Divider(
                        height: 20,
                        color: isDark
                            ? Colors.grey.shade800
                            : Colors.grey.shade200,
                      ),
                      StatRow(
                        isDark: isDark,
                        icon: Icons.event,
                        color: AppColors.pink,
                        label: loc.deadlinesHeader,
                        count: _stats['deadlines'] ?? 0,
                      ),
                      Divider(
                        height: 20,
                        color: isDark
                            ? Colors.grey.shade800
                            : Colors.grey.shade200,
                      ),
                      StatRow(
                        isDark: isDark,
                        icon: Icons.event_busy,
                        color: AppColors.red,
                        label: loc.absenceLabel,
                        count: _stats['absences'] ?? 0,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Enhanced Optimization Button
                GestureDetector(
                  onTap: _showOptimizationMenu,
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppColors.primary.withValues(alpha: 0.8),
                          AppColors.primaryDark,
                        ],
                      ),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.3),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.rocket_launch_rounded,
                          color: Colors.white,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          loc.optimizeStorage,
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 16,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 60),
              ],
            ),
    );
  }
}
