import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lesson_tracker/l10n/app_localizations.dart';
import '../../../core/theme/app_colors.dart';
import '../../../providers/auth_provider.dart';
import 'settings_shared.dart';

class SettingsAboutSection extends StatelessWidget {
  const SettingsAboutSection({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      children: [
         Container(
          margin: const EdgeInsets.symmetric(horizontal: 24),
          decoration: BoxDecoration(
            color: isDark ? AppColors.surfaceDark : Colors.white,
            borderRadius: BorderRadius.circular(24),
          ),
          child: SettingsTile(
            icon: Icons.logout,
            iconColor: AppColors.red,
            title: AppLocalizations.of(context)!.signOut,
            isDark: isDark,
            titleColor: AppColors.red,
            onTap: () {
                 final loc = AppLocalizations.of(context)!;
                 showDialog(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    backgroundColor: isDark ? AppColors.surfaceDark : Colors.white,
                    title: Text(loc.signOut, style: TextStyle(color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight)),
                    content: Text(loc.signOutConfirmation, style: TextStyle(color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight)),
                    actions: [
                      TextButton(onPressed: () => Navigator.pop(ctx), child: Text(loc.cancel)),
                      TextButton(
                        onPressed: () {
                          Navigator.pop(ctx);
                          context.read<AuthProvider>().signOut();
                          Navigator.of(context).popUntil((route) => route.isFirst);
                        }, 
                        child: Text(loc.signOut, style: const TextStyle(color: AppColors.red))
                      ),
                    ],
                  )
                );
            },
          ),
        ),
        
        Padding(
          padding: const EdgeInsets.all(24),
          child: Center(
            child: Text(
              'Lesson Tracker v1.0.0',
              style: TextStyle(
                fontSize: 12,
                color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
