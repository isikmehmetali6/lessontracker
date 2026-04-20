import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lesson_tracker/l10n/app_localizations.dart';
import '../../../core/theme/app_colors.dart';
import '../../../providers/auth_provider.dart';
import '../../../core/services/sync_service.dart';
import '../privacy_policy_screen.dart';
import '../terms_of_service_screen.dart';
import '../cookie_policy_screen.dart';
import '../consent_management_screen.dart';
import '../delete_account_dialog.dart';
import 'settings_shared.dart';

class SettingsAboutSection extends StatelessWidget {
  const SettingsAboutSection({super.key});

  void _showDeleteAccountDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => DeleteAccountDialog(
        onDeleteConfirmed: () async {
          Navigator.pop(dialogContext);
          await _performAccountDeletion(context);
        },
        onCancel: () => Navigator.pop(dialogContext),
      ),
    );
  }

  Future<void> _performAccountDeletion(BuildContext context) async {
    final authProvider = context.read<AuthProvider>();
    final syncService = SyncService();

    try {
      // Show loading
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => Center(
          child: Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: Theme.of(ctx).brightness == Brightness.dark
                  ? AppColors.surfaceDark
                  : Colors.white,
              borderRadius: BorderRadius.circular(24),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CircularProgressIndicator(),
                const SizedBox(height: 24),
                Text(
                  'Hesap siliniyor...',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
        ),
      );

      // Delete all user data via SyncService
      await syncService.deleteAllUserData();

      // Delete account locally
      await authProvider.deleteAccount();

      // Close loading dialog
      if (context.mounted) {
        Navigator.of(context).popUntil((route) => route.isFirst);
      }
    } catch (e) {
      // Close loading if still open
      if (context.mounted) {
        Navigator.of(context).popUntil((route) => route.isFirst);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Hesap silme hatası: $e'),
            backgroundColor: AppColors.red,
          ),
        );
      }
    }
  }

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
          child: Column(
            children: [
              SettingsTile(
                icon: Icons.privacy_tip,
                iconColor: AppColors.blue,
                title: 'Gizlilik Politikası',
                isDark: isDark,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const PrivacyPolicyScreen(),
                    ),
                  );
                },
              ),
              SettingsDivider(isDark: isDark),
              SettingsTile(
                icon: Icons.description,
                iconColor: AppColors.orange,
                title: 'Kullanım Şartları',
                isDark: isDark,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const TermsOfServiceScreen(),
                    ),
                  );
                },
              ),
              SettingsDivider(isDark: isDark),
              SettingsTile(
                icon: Icons.cookie,
                iconColor: AppColors.amber,
                title: 'Çerez Politikası',
                isDark: isDark,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const CookiePolicyScreen(),
                    ),
                  );
                },
              ),
              SettingsDivider(isDark: isDark),
              SettingsTile(
                icon: Icons.tune,
                iconColor: AppColors.purple,
                title: 'Rıza Yönetimi',
                subtitle: 'KVKK Açık Rıza Tercihleriniz',
                isDark: isDark,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const ConsentManagementScreen(),
                    ),
                  );
                },
              ),
              SettingsDivider(isDark: isDark),
              SettingsTile(
                icon: Icons.delete_forever,
                iconColor: AppColors.red,
                title: 'Hesabımı Sil',
                subtitle: 'KVKK Madde 7 - Silme Hakkı',
                isDark: isDark,
                titleColor: AppColors.red,
                onTap: () => _showDeleteAccountDialog(context),
              ),
              SettingsDivider(isDark: isDark),
              SettingsTile(
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
                      backgroundColor: isDark
                          ? AppColors.surfaceDark
                          : Colors.white,
                      title: Text(
                        loc.signOut,
                        style: TextStyle(
                          color: isDark
                              ? AppColors.textPrimaryDark
                              : AppColors.textPrimaryLight,
                        ),
                      ),
                      content: Text(
                        loc.signOutConfirmation,
                        style: TextStyle(
                          color: isDark
                              ? AppColors.textSecondaryDark
                              : AppColors.textSecondaryLight,
                        ),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(ctx),
                          child: Text(loc.cancel),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.pop(ctx);
                            context.read<AuthProvider>().signOut();
                            Navigator.of(
                              context,
                            ).popUntil((route) => route.isFirst);
                          },
                          child: Text(
                            loc.signOut,
                            style: const TextStyle(color: AppColors.red),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
        ),

        Padding(
          padding: const EdgeInsets.all(24),
          child: Center(
            child: Text(
              'Lesson Tracker v1.0.0',
              style: TextStyle(
                fontSize: 12,
                color: isDark
                    ? AppColors.textSecondaryDark
                    : AppColors.textSecondaryLight,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
