import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';

class NoteMetaTags extends StatelessWidget {
  final String? courseName;
  final List<String> noteTags;
  final bool isDark;

  const NoteMetaTags({
    super.key,
    required this.courseName,
    required this.noteTags,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      children: [
        if (courseName != null && courseName!.isNotEmpty)
          _MetaChip(
            label: courseName!,
            icon: Icons.school_rounded,
            color: AppColors.primary,
            isDark: isDark,
          ),
        if (noteTags.isNotEmpty)
          ...noteTags.map(
            (tag) => _MetaChip(
              label: '#$tag',
              icon: Icons.tag_rounded,
              color: AppColors.amber,
              isDark: isDark,
            ),
          ),
      ],
    );
  }
}

class _MetaChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final bool isDark;

  const _MetaChip({
    required this.label,
    required this.icon,
    required this.color,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}