import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import 'package:lesson_tracker/l10n/app_localizations.dart';
import '../../../providers/moodle_provider.dart';

class HomeBottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTabSelected;

  const HomeBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTabSelected,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final bottomInset = MediaQuery.of(context).padding.bottom;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        border: Border(
          top: BorderSide(
            color: isDark ? Colors.white.withValues(alpha: 0.08) : Colors.grey.shade200,
          ),
        ),
      ),
      // İçerik home indicator'ın üzerinde, arka plan ekranın dibine kadar
      padding: EdgeInsets.only(bottom: bottomInset),
      child: SizedBox(
        height: 60,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
                Expanded(
                  child: _HomeNavItem(
                    icon: Icons.home,
                    label: AppLocalizations.of(context)?.homeParams ?? 'Home',
                    isSelected: currentIndex == 0,
                    onTap: () => onTabSelected(0),
                  ),
                ),
                Expanded(
                  child: _HomeNavItem(
                    icon: Icons.calendar_today,
                    label: AppLocalizations.of(context)?.planParams ?? 'Plan',
                    isSelected: currentIndex == 1,
                    onTap: () => onTabSelected(1),
                  ),
                ),
                Expanded(
                  child: _HomeNavItem(
                    icon: Icons.view_week,
                    label: AppLocalizations.of(context)?.weeklySchedule ?? 'Schedule',
                    isSelected: currentIndex == 2,
                    onTap: () => onTabSelected(2),
                  ),
                ),
                Expanded(
                  child: _HomeNavItem(
                    icon: Icons.settings,
                    label: AppLocalizations.of(context)?.settingsParams ?? 'Settings',
                    isSelected: currentIndex == 3,
                    onTap: () => onTabSelected(3),
                  ),
                ),
                Expanded(
                  child: Consumer<MoodleProvider>(
                    builder: (context, moodle, _) => _HomeNavItemBadge(
                      icon: Icons.school_rounded,
                      label: 'Moodle',
                      isSelected: currentIndex == 4,
                      badgeCount: moodle.unreadCount,
                      onTap: () => onTabSelected(4),
                    ),
                  ),
                ),
              ],
            ),
          ),
    );
  }
}

class _HomeNavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _HomeNavItem({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        padding: EdgeInsets.symmetric(
          horizontal: isSelected ? 12 : 8,
          vertical: 8,
        ),
        decoration: BoxDecoration(
          color: isSelected 
              ? AppColors.primary.withValues(alpha: 0.15) 
              : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isSelected
                  ? AppColors.primary
                  : (isDark ? Colors.grey.shade500 : Colors.grey.shade400),
              size: isSelected ? 24 : 26,
            ),
            if (isSelected) ...[
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                   color: AppColors.primary,
                  ),
                ),
              ),
            ]
          ],
        ),
      ),
    );
  }
}

/// Nav item with an unread badge overlay — used for Moodle tab
class _HomeNavItemBadge extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final int badgeCount;
  final VoidCallback onTap;

  const _HomeNavItemBadge({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.badgeCount,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        _HomeNavItem(
          icon: icon,
          label: label,
          isSelected: isSelected,
          onTap: onTap,
        ),
        if (badgeCount > 0)
          Positioned(
            right: -2,
            top: -2,
            child: Container(
              padding: const EdgeInsets.all(3),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.error,
                shape: BoxShape.circle,
              ),
              constraints:
                  const BoxConstraints(minWidth: 16, minHeight: 16),
              child: Text(
                badgeCount > 9 ? '9+' : '$badgeCount',
                style: TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.w800,
                  color: Theme.of(context).colorScheme.onError,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
      ],
    );
  }
}
