import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lesson_tracker/core/theme/app_colors.dart';

class QuickCaptureButtons extends StatelessWidget {
  final VoidCallback onScanTap;

  const QuickCaptureButtons({super.key, required this.onScanTap});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Row(
      children: [
        Expanded(
          child: _QuickCaptureButton(
            icon: Icons.document_scanner,
            title: 'Scan Notes',
            subtitle: 'OCR Import',
            color: AppColors.primary,
            isHighlighted: true,
            onTap: onScanTap,
            isDark: isDark,
          ),
        ),
      ],
    );
  }
}

class _QuickCaptureButton extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final bool isHighlighted;
  final VoidCallback onTap;
  final bool isDark;

  const _QuickCaptureButton({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.isHighlighted,
    required this.onTap,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: isHighlighted
          ? AppColors.primary.withValues(alpha: 0.15)
          : (isDark ? AppColors.surfaceDark : Colors.grey.shade100),
      borderRadius: BorderRadius.circular(24),
      child: InkWell(
        onTap: () {
          HapticFeedback.lightImpact();
          onTap();
        },
        borderRadius: BorderRadius.circular(24),
        child: Container(
          height: 140,
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Icon(
                  icon,
                  color: isHighlighted ? AppColors.primaryDark : color,
                  size: 28,
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: isDark
                          ? AppColors.textPrimaryDark
                          : AppColors.textPrimaryLight,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark
                          ? AppColors.textSecondaryDark
                          : AppColors.textSecondaryLight,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}