import 'package:flutter/material.dart';
import 'package:lesson_tracker/core/theme/app_colors.dart';

/// Search field for the notes tab. Extracted per plan 3.1.5 (P1).
class NotesSearchField extends StatelessWidget {
  final TextEditingController controller;
  final String query;
  final bool isDark;
  final String hintText;
  final void Function(String) onChanged;
  final VoidCallback onClear;

  const NotesSearchField({
    super.key,
    required this.controller,
    required this.query,
    required this.isDark,
    required this.hintText,
    required this.onChanged,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        decoration: InputDecoration(
          hintText: hintText,
          prefixIcon: const Icon(Icons.search, size: 20),
          suffixIcon: query.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear, size: 18),
                  onPressed: onClear,
                )
              : null,
          filled: true,
          fillColor: isDark ? AppColors.surfaceDark : Colors.grey.shade50,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(vertical: 12),
        ),
      ),
    );
  }
}