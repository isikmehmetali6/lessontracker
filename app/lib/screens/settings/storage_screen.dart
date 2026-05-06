import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/database/database_helper.dart';
import '../../repositories/course_repository.dart';
import '../../repositories/note_repository.dart';
import '../../repositories/grade_repository.dart';
import '../../repositories/deadline_repository.dart';
import '../../repositories/absence_repository.dart';
import '../../repositories/file_repository.dart';
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
        mediaSize = await _getDirectorySize(appDir);
      } catch (e, stackTrace) {
        debugPrint('Error calculating media size: $e\nStack: $stackTrace');
      }

      // Calculate cache size
      int cacheSize = 0;
      try {
        final tempDir = await getTemporaryDirectory();
        cacheSize = await _getDirectorySize(tempDir);
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

  Future<int> _getDirectorySize(Directory dir) async {
    int size = 0;
    try {
      if (await dir.exists()) {
        await for (var entity in dir.list(
          recursive: true,
          followLinks: false,
        )) {
          if (entity is File) {
            size += await entity.length();
          }
        }
      }
    } catch (e, stackTrace) {
      debugPrint(
        'Error getting directory size for ${dir.path}: $e\nStack: $stackTrace',
      );
    }
    return size;
  }

  String _formatBytes(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
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
            } else if (entity is Directory)
              await entity.delete(recursive: true);
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
            } else if (entity is Directory)
              await entity.delete(recursive: true);
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
                  color: Colors.grey.shade300,
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
                            loc.standardCleanupDesc(_formatBytes(_cacheSize)),
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
                        _formatBytes(totalSize),
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
                _buildSectionTitle(isDark, loc.storageBreakdown),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.surfaceDark : Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    children: [
                      _buildStorageRow(
                        isDark,
                        Icons.data_usage,
                        AppColors.primary,
                        loc.database,
                        _dbSize,
                        totalSize,
                      ),
                      const SizedBox(height: 16),
                      _buildStorageRow(
                        isDark,
                        Icons.perm_media,
                        AppColors.purple,
                        loc.mediaFiles,
                        _mediaSize,
                        totalSize,
                      ),
                      const SizedBox(height: 16),
                      _buildStorageRow(
                        isDark,
                        Icons.cached,
                        AppColors.orange,
                        loc.cache,
                        _cacheSize,
                        totalSize,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Data Stats
                _buildSectionTitle(isDark, loc.dataStats),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.surfaceDark : Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    children: [
                      _buildStatRow(
                        isDark,
                        Icons.school,
                        AppColors.primary,
                        loc.totalCourses,
                        _stats['courses'] ?? 0,
                      ),
                      Divider(
                        height: 20,
                        color: isDark
                            ? Colors.grey.shade800
                            : Colors.grey.shade200,
                      ),
                      _buildStatRow(
                        isDark,
                        Icons.note,
                        AppColors.blue,
                        loc.totalNotes,
                        _stats['notes'] ?? 0,
                      ),
                      Divider(
                        height: 20,
                        color: isDark
                            ? Colors.grey.shade800
                            : Colors.grey.shade200,
                      ),
                      _buildStatRow(
                        isDark,
                        Icons.grade,
                        AppColors.orange,
                        loc.gradesTab,
                        _stats['grades'] ?? 0,
                      ),
                      Divider(
                        height: 20,
                        color: isDark
                            ? Colors.grey.shade800
                            : Colors.grey.shade200,
                      ),
                      _buildStatRow(
                        isDark,
                        Icons.insert_drive_file,
                        AppColors.purple,
                        loc.filesTab,
                        _stats['course_files'] ?? 0,
                      ),
                      Divider(
                        height: 20,
                        color: isDark
                            ? Colors.grey.shade800
                            : Colors.grey.shade200,
                      ),
                      _buildStatRow(
                        isDark,
                        Icons.event,
                        AppColors.pink,
                        loc.deadlinesHeader,
                        _stats['deadlines'] ?? 0,
                      ),
                      Divider(
                        height: 20,
                        color: isDark
                            ? Colors.grey.shade800
                            : Colors.grey.shade200,
                      ),
                      _buildStatRow(
                        isDark,
                        Icons.event_busy,
                        AppColors.red,
                        loc.absenceLabel,
                        _stats['absences'] ?? 0,
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

  Widget _buildSectionTitle(bool isDark, String title) {
    return Text(
      title.toUpperCase(),
      style: TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w700,
        letterSpacing: 1.2,
        color: isDark
            ? AppColors.textSecondaryDark
            : AppColors.textSecondaryLight,
      ),
    );
  }

  Widget _buildStorageRow(
    bool isDark,
    IconData icon,
    Color color,
    String label,
    int bytes,
    int total,
  ) {
    final fraction = total > 0 ? bytes / total : 0.0;
    return Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: isDark
                          ? AppColors.textPrimaryDark
                          : AppColors.textPrimaryLight,
                    ),
                  ),
                  Text(
                    _formatBytes(bytes),
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: isDark
                          ? AppColors.textSecondaryDark
                          : AppColors.textSecondaryLight,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: fraction,
                  backgroundColor: isDark
                      ? Colors.grey.shade800
                      : Colors.grey.shade200,
                  color: color,
                  minHeight: 6,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatRow(
    bool isDark,
    IconData icon,
    Color color,
    String label,
    int count,
  ) {
    return Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: isDark
                  ? AppColors.textPrimaryDark
                  : AppColors.textPrimaryLight,
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            '$count',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ),
      ],
    );
  }
}
