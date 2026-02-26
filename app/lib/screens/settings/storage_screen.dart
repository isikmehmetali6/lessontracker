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
        'courses': await CourseRepository().getCount(),
        'notes': await NoteRepository().getCount(),
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
      } catch (_) {}
      
      // Calculate cache size
      int cacheSize = 0;
      try {
        final tempDir = await getTemporaryDirectory();
        cacheSize = await _getDirectorySize(tempDir);
      } catch (_) {}
      
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
        await for (var entity in dir.list(recursive: true, followLinks: false)) {
          if (entity is File) {
            size += await entity.length();
          }
        }
      }
    } catch (_) {}
    return size;
  }

  String _formatBytes(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }

  Future<void> _clearCache() async {
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
          } catch (_) {}
        }
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.cacheCleared),
            backgroundColor: AppColors.primary,
          ),
        );
        _loadStorageInfo();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: AppColors.red,
          ),
        );
      }
    }
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
            color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
            fontWeight: FontWeight.w700,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
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
                      _buildStorageRow(isDark, Icons.data_usage, AppColors.primary, loc.database, _dbSize, totalSize),
                      const SizedBox(height: 16),
                      _buildStorageRow(isDark, Icons.perm_media, AppColors.purple, loc.mediaFiles, _mediaSize, totalSize),
                      const SizedBox(height: 16),
                      _buildStorageRow(isDark, Icons.cached, AppColors.orange, loc.cache, _cacheSize, totalSize),
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
                      _buildStatRow(isDark, Icons.school, AppColors.primary, loc.totalCourses, _stats['courses'] ?? 0),
                      Divider(height: 20, color: isDark ? Colors.grey.shade800 : Colors.grey.shade200),
                      _buildStatRow(isDark, Icons.note, AppColors.blue, loc.totalNotes, _stats['notes'] ?? 0),
                      Divider(height: 20, color: isDark ? Colors.grey.shade800 : Colors.grey.shade200),
                      _buildStatRow(isDark, Icons.grade, AppColors.orange, loc.gradesTab, _stats['grades'] ?? 0),
                      Divider(height: 20, color: isDark ? Colors.grey.shade800 : Colors.grey.shade200),
                      _buildStatRow(isDark, Icons.insert_drive_file, AppColors.purple, loc.filesTab, _stats['course_files'] ?? 0),
                      Divider(height: 20, color: isDark ? Colors.grey.shade800 : Colors.grey.shade200),
                      _buildStatRow(isDark, Icons.event, AppColors.pink, loc.deadlinesHeader, _stats['deadlines'] ?? 0),
                      Divider(height: 20, color: isDark ? Colors.grey.shade800 : Colors.grey.shade200),
                      _buildStatRow(isDark, Icons.event_busy, AppColors.red, loc.absenceLabel, _stats['absences'] ?? 0),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Clear Cache Button
                GestureDetector(
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        backgroundColor: isDark ? AppColors.surfaceDark : Colors.white,
                        title: Text(
                          loc.clearCache,
                          style: TextStyle(color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight),
                        ),
                        content: Text(
                          loc.clearCacheConfirmation,
                          style: TextStyle(color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(ctx),
                            child: Text(loc.cancel),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.pop(ctx);
                              _clearCache();
                            },
                            child: Text(loc.clearCache, style: const TextStyle(color: AppColors.red)),
                          ),
                        ],
                      ),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.red.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.red.withValues(alpha: 0.3)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.delete_sweep, color: AppColors.red),
                        const SizedBox(width: 12),
                        Text(
                          loc.clearCache,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                            color: AppColors.red,
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
        color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
      ),
    );
  }

  Widget _buildStorageRow(bool isDark, IconData icon, Color color, String label, int bytes, int total) {
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
                      color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                    ),
                  ),
                  Text(
                    _formatBytes(bytes),
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: fraction,
                  backgroundColor: isDark ? Colors.grey.shade800 : Colors.grey.shade200,
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

  Widget _buildStatRow(bool isDark, IconData icon, Color color, String label, int count) {
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
              color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
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
