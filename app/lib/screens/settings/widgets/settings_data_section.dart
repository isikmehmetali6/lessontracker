import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:lesson_tracker/l10n/app_localizations.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/database/database_helper.dart';
import '../../../providers/sync_provider.dart';
import '../storage_screen.dart';
import '../help_support_screen.dart';
import 'settings_shared.dart';

class SettingsDataSection extends StatefulWidget {
  const SettingsDataSection({super.key});

  @override
  State<SettingsDataSection> createState() => _SettingsDataSectionState();
}

class _SettingsDataSectionState extends State<SettingsDataSection> {
  String _storageSize = '';
  String _lastBackup = '';

  @override
  void initState() {
    super.initState();
    _loadDynamicInfo();
  }

  Future<void> _loadDynamicInfo() async {
    // Storage size
    final dbSize = await DatabaseHelper().getDatabaseSize();
    String formatted;
    if (dbSize < 1024) {
      formatted = '$dbSize B';
    } else if (dbSize < 1024 * 1024) {
      formatted = '${(dbSize / 1024).toStringAsFixed(1)} KB';
    } else {
      formatted = '${(dbSize / (1024 * 1024)).toStringAsFixed(1)} MB';
    }

    // Last backup
    final prefs = await SharedPreferences.getInstance();
    final lastBackupMs = prefs.getInt('last_backup_timestamp');
    String backupText = '';
    if (lastBackupMs != null) {
      final dt = DateTime.fromMillisecondsSinceEpoch(lastBackupMs);
      final diff = DateTime.now().difference(dt);
      if (diff.inMinutes < 60) {
        backupText = '${diff.inMinutes}m ago';
      } else if (diff.inHours < 24) {
        backupText = '${diff.inHours}h ago';
      } else {
        backupText = '${diff.inDays}d ago';
      }
    }

    if (mounted) {
      setState(() {
        _storageSize = formatted;
        _lastBackup = backupText;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: [
          SettingsTile(
            icon: Icons.cloud_sync,
            iconColor: AppColors.primary,
            title: AppLocalizations.of(context)!.syncBackup,
            subtitle: _lastBackup.isNotEmpty ? '${AppLocalizations.of(context)!.lastBackup}: $_lastBackup' : null,
            isDark: isDark,
            onTap: () async {
               await _showSyncOptions(context);
               _loadDynamicInfo(); // Reload after syncing
            },
          ),
          SettingsDivider(isDark: isDark),
          SettingsTile(
            icon: Icons.storage,
            iconColor: AppColors.orange,
            title: AppLocalizations.of(context)!.storage,
            subtitle: _storageSize.isNotEmpty ? _storageSize : null,
            isDark: isDark,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const StorageScreen()),
              ).then((_) => _loadDynamicInfo());
            },
          ),
          SettingsDivider(isDark: isDark),
          SettingsTile(
            icon: Icons.help_outline,
            iconColor: AppColors.purple,
            title: AppLocalizations.of(context)!.helpSupport,
            isDark: isDark,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const HelpSupportScreen()),
              );
            },
          ),
        ],
      ),
    );
  }

  Future<void> _showSyncOptions(BuildContext context) async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const SyncOptionsSheet(),
    );
  }
}

class SyncOptionsSheet extends StatelessWidget {
  const SyncOptionsSheet({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Consumer<SyncProvider>(
        builder: (context, sync, _) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                AppLocalizations.of(context)!.syncBackup,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                AppLocalizations.of(context)!.syncDescription,
                style: TextStyle(
                  fontSize: 14,
                  color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                ),
              ),
              const SizedBox(height: 24),
              
              if (sync.isSyncing) ...[
                LinearProgressIndicator(value: sync.progress, color: AppColors.primary),
                const SizedBox(height: 16),
                Text(
                   sync.statusMessage ?? AppLocalizations.of(context)!.processing,
                   style: TextStyle(color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight),
                ),
                const SizedBox(height: 24),
              ],

              if (sync.error != null) ...[
                 Container(
                   padding: const EdgeInsets.all(12),
                   decoration: BoxDecoration(
                     color: AppColors.red.withValues(alpha: 0.1),
                     borderRadius: BorderRadius.circular(12),
                   ),
                   child: Text(
                     sync.error!,
                     style: TextStyle(color: AppColors.red, fontSize: 13),
                   ),
                 ),
                 const SizedBox(height: 16),
              ],
              
              if (!sync.isSyncing) ...[
                _SyncButton(
                  icon: Icons.cloud_upload,
                  title: AppLocalizations.of(context)!.backupData,
                  subtitle: AppLocalizations.of(context)!.backupDescription,
                  color: AppColors.primary,
                  isDark: isDark,
                  onTap: () => sync.backup(),
                ),
                const SizedBox(height: 12),
                 _SyncButton(
                  icon: Icons.cloud_download,
                  title: AppLocalizations.of(context)!.restoreData,
                  subtitle: AppLocalizations.of(context)!.restoreDescription,
                  color: AppColors.orange,
                  isDark: isDark,
                  onTap: () {
                    // Show confirmation
                    showDialog(
                      context: context, 
                      builder: (ctx) => AlertDialog(
                        title: Text(AppLocalizations.of(context)!.confirmRestore),
                        content: Text(AppLocalizations.of(context)!.restoreWarning),
                        actions: [
                          TextButton(onPressed: () => Navigator.pop(ctx), child: Text(AppLocalizations.of(context)!.cancel)),
                          TextButton(
                            onPressed: () {
                              Navigator.pop(ctx);
                              sync.restore();
                            }, 
                            child: Text(AppLocalizations.of(context)!.restoreAction, style: const TextStyle(color: Colors.red)),
                          ),
                        ],
                      )
                    );
                  },
                ),
              ],
              
               const SizedBox(height: 16),
            ],
          );
        },
      ),
    );
  }
}

class _SyncButton extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final bool isDark;
  final VoidCallback onTap;

  const _SyncButton({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios, size: 16, color: color),
          ],
        ),
      ),
    );
  }
}
