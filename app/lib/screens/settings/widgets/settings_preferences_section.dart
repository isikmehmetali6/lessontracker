import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:lesson_tracker/l10n/app_localizations.dart';
import '../../../core/theme/app_colors.dart';
import '../../../providers/theme_provider.dart';
import '../../../providers/course_provider.dart';
import '../../../providers/language_provider.dart';
import '../../../services/app_lock_service.dart';
import '../../../services/sync_service.dart';
import '../notification_settings_screen.dart';
import 'settings_shared.dart';
import 'smart_attendance_settings.dart';
import 'moodle_sync_settings.dart';

class SettingsPreferencesSection extends StatefulWidget {
  const SettingsPreferencesSection({super.key});

  @override
  State<SettingsPreferencesSection> createState() =>
      _SettingsPreferencesSectionState();
}

class _SettingsPreferencesSectionState
    extends State<SettingsPreferencesSection> {
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final themeProvider = context.watch<ThemeProvider>();
    final l10n = AppLocalizations.of(context)!;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: [
          SettingsTile(
            icon: Icons.dark_mode,
            iconColor: AppColors.purple,
            title: l10n.darkMode,
            isDark: isDark,
            trailing: Switch(
              value: isDark,
              onChanged: (value) {
                themeProvider.toggleTheme();
              },
              activeThumbColor: AppColors.primary,
            ),
          ),
          SettingsDivider(isDark: isDark),
          Consumer<CourseProvider>(
            builder: (context, courseProvider, _) {
              return SettingsTile(
                icon: Icons.notifications,
                iconColor: AppColors.orange,
                title: l10n.notifications,
                isDark: isDark,
                subtitle: courseProvider.notificationsEnabled
                    ? '${l10n.notifications} • ${courseProvider.reminderMinutes}'
                    : l10n.notifications,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const NotificationSettingsScreen(),
                    ),
                  );
                },
              );
            },
          ),
          SettingsDivider(isDark: isDark),
          Consumer<LanguageProvider>(
            builder: (context, languageProvider, _) {
              return SettingsTile(
                icon: Icons.language,
                iconColor: AppColors.primary,
                title: l10n.language,
                subtitle: _getLanguageDisplayName(
                  languageProvider.locale.languageCode, l10n,
                ),
                isDark: isDark,
                onTap: () => _showLanguagePicker(context),
              );
            },
          ),
          SettingsDivider(isDark: isDark),
          // App Lock
          FutureBuilder<bool>(
            future: AppLockService.isBiometricAvailable(),
            builder: (context, snapshot) {
              if (snapshot.data != true) return const SizedBox();
              return FutureBuilder<bool>(
                future: AppLockService.isLockEnabled(),
                builder: (context, lockSnapshot) {
                  final isEnabled = lockSnapshot.data ?? false;
                  return SettingsTile(
                    icon: Icons.fingerprint,
                    iconColor: AppColors.green,
                    title: l10n.appLock,
                    subtitle: isEnabled
                        ? l10n.faceId
                        : l10n.appLockDisabled,
                    isDark: isDark,
                    trailing: Switch(
                      value: isEnabled,
                      onChanged: (value) async {
                        if (value) {
                          final success = await AppLockService.authenticate(
                            reason: l10n.appLockAuthReason,
                          );
                          if (success) {
                            await AppLockService.setLockEnabled(true);
                            if (mounted) setState(() {});
                          }
                        } else {
                          await AppLockService.setLockEnabled(false);
                          if (mounted) setState(() {});
                        }
                      },
                      activeThumbColor: AppColors.primary,
                    ),
                  );
                },
              );
            },
          ),
          SettingsDivider(isDark: isDark),
          SmartAttendanceSettings(isDark: isDark),
          SettingsDivider(isDark: isDark),
          FutureBuilder<bool>(
            future: SyncService().isCloudBackupEnabled(),
            builder: (context, snapshot) {
              final isEnabled = snapshot.data ?? false;
              return SettingsTile(
                icon: Icons.cloud_upload,
                iconColor: AppColors.blue,
                title: l10n.cloudBackup,
                subtitle: isEnabled
                    ? l10n.encryptedBackupActive
                    : l10n.backupOffDefault,
                isDark: isDark,
                trailing: Switch(
                  value: isEnabled,
                  onChanged: (value) async {
                    final syncService = SyncService();
                    await syncService.setCloudBackupEnabled(value);
                    if (mounted) setState(() {});
                    HapticFeedback.mediumImpact();
                  },
                  activeThumbColor: AppColors.primary,
                ),
              );
            },
          ),
          SettingsDivider(isDark: isDark),
          MoodleSyncSettings(isDark: isDark),
        ],
      ),
    );
  }

  String _getLanguageDisplayName(String code, AppLocalizations l10n) {
    switch (code) {
      case 'tr':
        return l10n.languageTurkish;
      case 'es':
        return l10n.languageSpanish;
      case 'de':
        return l10n.languageGerman;
      case 'en':
      default:
        return l10n.languageEnglish;
    }
  }

  static List<_LangData> _getLanguages(AppLocalizations l10n) => [
    _LangData(code: 'en', name: 'English', nativeName: l10n.languageEnglish, flag: '🇺🇸'),
    _LangData(code: 'tr', name: 'Turkish', nativeName: l10n.languageTurkish, flag: '🇹🇷'),
    _LangData(code: 'es', name: 'Spanish', nativeName: l10n.languageSpanish, flag: '🇪🇸'),
    _LangData(code: 'de', name: 'German', nativeName: l10n.languageGerman, flag: '🇩🇪'),
  ];

  void _showLanguagePicker(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final currentCode = context.read<LanguageProvider>().locale.languageCode;
    final l10n = AppLocalizations.of(context)!;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: isDark ? AppColors.surfaceDark : Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle bar
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
              const SizedBox(height: 20),
              // Title
              Row(
                children: [
                  Icon(Icons.translate, color: AppColors.primary, size: 24),
                  const SizedBox(width: 10),
                  Text(
                    l10n.language,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: isDark
                          ? AppColors.textPrimaryDark
                          : AppColors.textPrimaryLight,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              // Language options
              ..._getLanguages(l10n).map((lang) {
                final isSelected = lang.code == currentCode;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(14),
                    onTap: () {
                      context.read<LanguageProvider>().setLocale(
                        Locale(lang.code),
                      );
                      HapticFeedback.lightImpact();
                      Navigator.pop(ctx);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.primary.withValues(alpha: 0.1)
                            : (isDark
                                  ? AppColors.backgroundDark
                                  : Colors.grey.shade50),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: isSelected
                              ? AppColors.primary.withValues(alpha: 0.5)
                              : (isDark
                                    ? Colors.grey.shade700
                                    : Colors.grey.shade200),
                          width: isSelected ? 2 : 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          Text(lang.flag, style: const TextStyle(fontSize: 28)),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  lang.nativeName,
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: isSelected
                                        ? FontWeight.w700
                                        : FontWeight.w500,
                                    color: isSelected
                                        ? AppColors.primary
                                        : (isDark
                                              ? AppColors.textPrimaryDark
                                              : AppColors.textPrimaryLight),
                                  ),
                                ),
                                Text(
                                  lang.name,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: isDark
                                        ? AppColors.textSecondaryDark
                                        : AppColors.textSecondaryLight,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (isSelected)
                            Container(
                              width: 24,
                              height: 24,
                              decoration: const BoxDecoration(
                                color: AppColors.primary,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.check,
                                color: Colors.white,
                                size: 16,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                );
              }),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }
}

class _LangData {
  final String code;
  final String name;
  final String nativeName;
  final String flag;

  const _LangData({
    required this.code,
    required this.name,
    required this.nativeName,
    required this.flag,
  });
}
