import 'package:flutter/material.dart';
import 'package:lesson_tracker/models/note.dart';

/// Horizontal scroll of filter chips for the notes tab. Extracted
/// per plan 3.1.5 (P1).
class NoteFilterChips extends StatelessWidget {
  final NoteType? selectedType;
  final bool isDark;
  final void Function(NoteType?) onSelect;

  final String viewAllLabel;
  final String textLabel;
  final String imageLabel;
  final String ocrLabel;
  final String drawingLabel;
  final Widget? trailing;

  const NoteFilterChips({
    super.key,
    required this.selectedType,
    required this.isDark,
    required this.onSelect,
    required this.viewAllLabel,
    required this.textLabel,
    required this.imageLabel,
    required this.ocrLabel,
    required this.drawingLabel,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 44,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 24),
        children: [
          _NoteFilterChip(
            label: viewAllLabel,
            icon: Icons.list,
            type: null,
            isDark: isDark,
            isSelected: selectedType == null,
            onTap: () => onSelect(null),
          ),
          const SizedBox(width: 8),
          _NoteFilterChip(
            label: textLabel,
            icon: Icons.text_snippet_outlined,
            type: NoteType.text,
            isDark: isDark,
            isSelected: selectedType == NoteType.text,
            onTap: () => onSelect(NoteType.text),
          ),
          const SizedBox(width: 8),
          _NoteFilterChip(
            label: imageLabel,
            icon: Icons.image_outlined,
            type: NoteType.image,
            isDark: isDark,
            isSelected: selectedType == NoteType.image,
            onTap: () => onSelect(NoteType.image),
          ),
          const SizedBox(width: 8),
          _NoteFilterChip(
            label: ocrLabel,
            icon: Icons.document_scanner_outlined,
            type: NoteType.ocr,
            isDark: isDark,
            isSelected: selectedType == NoteType.ocr,
            onTap: () => onSelect(NoteType.ocr),
          ),
          const SizedBox(width: 8),
          _NoteFilterChip(
            label: drawingLabel,
            icon: Icons.draw_outlined,
            type: NoteType.drawing,
            isDark: isDark,
            isSelected: selectedType == NoteType.drawing,
            onTap: () => onSelect(NoteType.drawing),
          ),
          if (trailing != null) ...[
            const SizedBox(width: 8),
            trailing!,
          ],
        ],
      ),
    );
  }
}

class _NoteFilterChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final NoteType? type;
  final bool isDark;
  final bool isSelected;
  final VoidCallback onTap;

  const _NoteFilterChip({
    required this.label,
    required this.icon,
    required this.type,
    required this.isDark,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.15)
              : (isDark ? Theme.of(context).colorScheme.surface : Colors.grey.shade100),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected
                ? Theme.of(context).colorScheme.primary
                : Colors.transparent,
            width: 1.5,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: isSelected ? Theme.of(context).colorScheme.primary : null),
            const SizedBox(width: 6),
            Text(label, style: TextStyle(fontSize: 12)),
          ],
        ),
      ),
    );
  }
}