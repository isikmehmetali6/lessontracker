import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lesson_tracker/l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../models/moodle/moodle_account.dart';
import '../../providers/moodle_provider.dart';
import '../../providers/language_provider.dart';
import '../../core/utils/moodle_utils.dart';
import 'widgets/add_moodle_account_sheet.dart';

/// Moodle hesaplarını yönetme ekranı — eklenen hesapları listeler ve çıkış yapma imkanı sunar.
class MoodleAccountsScreen extends StatelessWidget {
  const MoodleAccountsScreen({super.key});

  static Future<void> push(BuildContext context) {
    return Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const MoodleAccountsScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final provider = context.watch<MoodleProvider>();

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      appBar: AppBar(
        title: Text(
          l10n.moodleAccountsManage,
          style: const TextStyle(fontWeight: FontWeight.w800),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: SafeArea(
        child: provider.accounts.isEmpty
            ? _buildEmptyState(context, isDark)
            : _buildAccountsList(context, isDark, provider.accounts),
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: SizedBox(
            width: double.infinity,
            height: 54,
            child: FilledButton.icon(
              onPressed: () => _showAddAccount(context),
              icon: const Icon(Icons.add_rounded, color: Colors.white),
              label: Text(
                l10n.moodleAccountAdd,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, bool isDark) {
    final l10n = AppLocalizations.of(context)!;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.person_outline_rounded,
              size: 64,
              color: isDark ? Colors.grey.shade600 : Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              l10n.moodleNoAccounts,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              l10n.moodleNoAccountsDesc,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAccountsList(
    BuildContext context,
    bool isDark,
    List<MoodleAccount> accounts,
  ) {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
      itemCount: accounts.length,
      itemBuilder: (context, index) {
        final account = accounts[index];
        return _AccountCard(
          account: account,
          isDark: isDark,
          onSignOut: () => _confirmSignOut(context, account),
        );
      },
    );
  }

  Future<void> _confirmSignOut(BuildContext context, MoodleAccount account) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        final langCode = ctx.read<LanguageProvider>().locale.languageCode;
        return AlertDialog(
          title: Text(AppLocalizations.of(ctx)!.moodleLogout),
          content: Text(
            AppLocalizations.of(ctx)!.moodleLogoutConfirm(
              MoodleUtils.parseMultilang(account.siteTitle, langCode),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: Text(AppLocalizations.of(ctx)!.cancel),
            ),
            TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              style: TextButton.styleFrom(foregroundColor: AppColors.red),
              child: Text(AppLocalizations.of(ctx)!.moodleLogout),
            ),
          ],
        );
      },
    );

    if (confirmed == true && context.mounted) {
      await context.read<MoodleProvider>().removeAccount(account.id);
      HapticFeedback.mediumImpact();
      if (context.mounted) {
        final langCode = context.read<LanguageProvider>().locale.languageCode;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.moodleLogoutDone(
              MoodleUtils.parseMultilang(account.siteTitle, langCode),
            )),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    }
  }

  Future<void> _showAddAccount(BuildContext context) async {
    final added = await AddMoodleAccountSheet.show(context);
    if (added == true && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.moodleConnected),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    }
  }
}

class _AccountCard extends StatelessWidget {
  final MoodleAccount account;
  final bool isDark;
  final VoidCallback onSignOut;

  const _AccountCard({
    required this.account,
    required this.isDark,
    required this.onSignOut,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      color: isDark ? AppColors.surfaceDark : Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: isDark ? Colors.white10 : Colors.grey.shade200,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.school_rounded,
                color: AppColors.primary,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    MoodleUtils.parseMultilang(
                      account.siteTitle,
                      context.watch<LanguageProvider>().locale.languageCode,
                    ),
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    account.fullName,
                    style: TextStyle(
                      fontSize: 14,
                      color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    account.username,
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark ? Colors.grey.shade600 : Colors.grey.shade500,
                    ),
                  ),
                ],
              ),
            ),
            TextButton.icon(
              onPressed: onSignOut,
              icon: const Icon(Icons.logout_rounded, size: 18, color: AppColors.red),
              label: Text(
                l10n.moodleLogout,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: AppColors.red,
                  fontSize: 13,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
