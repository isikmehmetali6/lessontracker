import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lesson_tracker/l10n/app_localizations.dart';
import '../../../core/theme/app_colors.dart';
import '../../../providers/theme_provider.dart';
import '../../../providers/course_provider.dart';
import '../../../providers/language_provider.dart';
import '../../../core/services/app_lock_service.dart';
import '../notification_settings_screen.dart';
import 'settings_shared.dart';

class SettingsPreferencesSection extends StatefulWidget {
  const SettingsPreferencesSection({super.key});

  @override
  State<SettingsPreferencesSection> createState() => _SettingsPreferencesSectionState();
}

class _SettingsPreferencesSectionState extends State<SettingsPreferencesSection> {
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final themeProvider = context.read<ThemeProvider>();

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
            title: AppLocalizations.of(context)!.darkMode,
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
                title: AppLocalizations.of(context)!.notifications,
                isDark: isDark,
                subtitle: courseProvider.notificationsEnabled 
                    ? 'On • ${courseProvider.reminderMinutes}m before' 
                    : 'Off',
                onTap: () {
                  Navigator.push(
                    context, 
                    MaterialPageRoute(builder: (_) => const NotificationSettingsScreen())
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
                title: AppLocalizations.of(context)!.language,
                subtitle: _getLanguageName(languageProvider.locale.languageCode),
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
                    title: 'App Lock',
                    subtitle: isEnabled ? 'Face ID / Touch ID' : 'Disabled',
                    isDark: isDark,
                    trailing: Switch(
                      value: isEnabled,
                      onChanged: (value) async {
                        if (value) {
                          final success = await AppLockService.authenticate(
                            reason: 'Authenticate to enable app lock',
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
        ],
      ),
    );
  }

  String _getLanguageName(String code) {
    switch (code) {
      case 'tr': return 'Türkçe';
      case 'es': return 'Español';
      case 'de': return 'Deutsch';
      case 'en': 
      default: return 'English';
    }
  }

  void _showLanguagePicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: isDark ? AppColors.surfaceDark : Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                AppLocalizations.of(context)!.language,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                ),
              ),
              const SizedBox(height: 16),
              _LanguageOption(code: 'en', name: 'English', flag: '🇺🇸'),
              _LanguageOption(code: 'tr', name: 'Türkçe', flag: '🇹🇷'),
              _LanguageOption(code: 'es', name: 'Español', flag: '🇪🇸'),
              _LanguageOption(code: 'de', name: 'Deutsch', flag: '🇩🇪'),
            ],
          ),
        );
      },
    );
  }
}

class _LanguageOption extends StatelessWidget {
  final String code;
  final String name;
  final String flag;

  const _LanguageOption({
    required this.code,
    required this.name,
    required this.flag,
  });

  @override
  Widget build(BuildContext context) {
    final isSelected = context.select((LanguageProvider p) => p.locale.languageCode == code);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ListTile(
      leading: Text(flag, style: const TextStyle(fontSize: 24)),
      title: Text(
        name,
        style: TextStyle(
          color: isSelected 
              ? AppColors.primary 
              : (isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight),
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      trailing: isSelected ? const Icon(Icons.check, color: AppColors.primary) : null,
      onTap: () {
        context.read<LanguageProvider>().setLocale(Locale(code));
        Navigator.pop(context);
      },
    );
  }
}
