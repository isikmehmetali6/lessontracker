import 'package:flutter/material.dart';
import 'package:lesson_tracker/l10n/app_localizations.dart';
import '../../../services/moodle_background_service.dart';
import '../../../core/theme/app_colors.dart';
import 'settings_shared.dart';

/// Moodle Arka Plan Senkronizasyonu ayar widget'ı.
/// SettingsPreferencesSection içinde kullanılır.
class MoodleSyncSettings extends StatefulWidget {
  final bool isDark;
  const MoodleSyncSettings({super.key, required this.isDark});

  @override
  State<MoodleSyncSettings> createState() => _MoodleSyncSettingsState();
}

class _MoodleSyncSettingsState extends State<MoodleSyncSettings> {
  bool _isEnabled = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadState();
  }

  Future<void> _loadState() async {
    final enabled = await MoodleBackgroundService.isEnabled();
    if (mounted) {
      setState(() {
        _isEnabled = enabled;
        _isLoading = false;
      });
    }
  }

  Future<void> _toggle(bool value) async {
    setState(() => _isLoading = true);
    await MoodleBackgroundService.setEnabled(value);
    if (mounted) {
      setState(() {
        _isEnabled = value;
        _isLoading = false;
      });
      final l10n = AppLocalizations.of(context)!;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            value
                ? l10n.moodleSyncEnabled
                : l10n.moodleSyncDisabled,
          ),
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return SettingsTile(
      icon: Icons.cloud_sync_rounded,
      iconColor: AppColors.primary,
      title: l10n.moodleBackgroundSync,
      subtitle: _isEnabled
          ? l10n.moodleSyncNotifications
          : l10n.moodleSyncOff,
      isDark: widget.isDark,
      trailing: _isLoading
          ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : Switch(
              value: _isEnabled,
              onChanged: _toggle,
              activeThumbColor: AppColors.primary,
            ),
    );
  }
}
