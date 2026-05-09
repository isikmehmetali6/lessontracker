import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:lesson_tracker/l10n/app_localizations.dart';
import '../../../core/theme/app_colors.dart';
import '../../search/search_screen.dart';
import 'package:blur/blur.dart';
class HomeSearchBar extends StatelessWidget {
  const HomeSearchBar({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
      child: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            CupertinoPageRoute(builder: (_) => const SearchScreen()),
          );
        },
        child: Container(
          height: 56,
          decoration: BoxDecoration(
            color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              const SizedBox(width: 16),
              Icon(
                Icons.search,
                color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: IgnorePointer(
                  child: TextField(
                    readOnly: true,
                    decoration: InputDecoration(
                      hintText: AppLocalizations.of(context)!.searchPlaceholder, 
                      hintStyle: TextStyle(
                        fontSize: 15,
                        color: isDark 
                            ? AppColors.textPrimaryDark.withValues(alpha: 0.5) 
                            : AppColors.textPrimaryLight.withValues(alpha: 0.5),
                      ),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ).frosted(
          blur: 15,
          frostColor: isDark ? AppColors.surfaceDark.withValues(alpha: 0.2) : Colors.white.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(24),
        ),
      ),
    );
  }
}
