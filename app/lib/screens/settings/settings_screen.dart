import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lesson_tracker/l10n/app_localizations.dart';
import '../../core/theme/app_colors.dart';
import '../../providers/theme_provider.dart';

import 'widgets/settings_profile_section.dart';
import 'widgets/settings_preferences_section.dart';
import 'widgets/settings_data_section.dart';
import 'widgets/settings_about_section.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          AppLocalizations.of(context)!.settingsParams,
          style: TextStyle(
            color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: Consumer<ThemeProvider>(
        builder: (context, themeProvider, _) {
          return CustomScrollView(
            slivers: [
              // Header
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        AppLocalizations.of(context)!.settingsSubHeader,
                        style: TextStyle(
                          fontSize: 14,
                          color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Sections
              const SliverToBoxAdapter(child: SettingsProfileSection()),
              const SliverToBoxAdapter(child: SizedBox(height: 24)),
              
              const SliverToBoxAdapter(child: SettingsPreferencesSection()),
              const SliverToBoxAdapter(child: SizedBox(height: 16)),
              
              const SliverToBoxAdapter(child: SettingsDataSection()),
              const SliverToBoxAdapter(child: SizedBox(height: 16)),
              
              const SliverToBoxAdapter(child: SettingsAboutSection()),
              const SliverToBoxAdapter(child: SizedBox(height: 60)),
            ],
          );
        },
      ),
    );
  }
}
