import 'package:flutter/material.dart';
import 'package:lesson_tracker/l10n/app_localizations.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/database/database_helper.dart';
import '../storage_screen.dart';
import '../help_support_screen.dart';
import '../transcript_screen.dart';
import 'settings_shared.dart';

class SettingsDataSection extends StatefulWidget {
  const SettingsDataSection({super.key});

  @override
  State<SettingsDataSection> createState() => _SettingsDataSectionState();
}

class _SettingsDataSectionState extends State<SettingsDataSection> {
  String _storageSize = '';

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

    if (mounted) {
      setState(() {
        _storageSize = formatted;
      });
    }
  }



  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
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
          SettingsDivider(isDark: isDark),
          SettingsTile(
            icon: Icons.school,
            iconColor: AppColors.emerald,
            title: l10n.transcript,
            isDark: isDark,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const TranscriptScreen()),
              );
            },
          ),
        ],
      ),
    );
  }
}


