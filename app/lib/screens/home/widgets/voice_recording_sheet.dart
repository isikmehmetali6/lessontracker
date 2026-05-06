import 'dart:async';
import 'package:flutter/material.dart';
import 'package:lesson_tracker/l10n/app_localizations.dart';
import '../../../core/theme/app_colors.dart';
import '../../../providers/note_provider.dart';

/// Voice Recording Bottom Sheet for Quick Capture
class VoiceRecordingSheet extends StatefulWidget {
  final NoteProvider noteProvider;

  const VoiceRecordingSheet({super.key, required this.noteProvider});

  @override
  State<VoiceRecordingSheet> createState() => _VoiceRecordingSheetState();
}

class _VoiceRecordingSheetState extends State<VoiceRecordingSheet> {
  Timer? _timer;
  int _seconds = 0;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() => _seconds++);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  String get _formattedTime {
    final m = _seconds ~/ 60;
    final s = _seconds % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Center(
            child: Container(
              width: 40, height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Recording indicator
          Container(
            width: 80, height: 80,
            decoration: BoxDecoration(
              color: AppColors.red.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Container(
                width: 32, height: 32,
                decoration: BoxDecoration(
                  color: AppColors.red,
                  borderRadius: BorderRadius.circular(_seconds % 2 == 0 ? 16 : 8),
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),

          Text(
            l10n.recording,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _formattedTime,
            style: TextStyle(
              fontSize: 36,
              fontWeight: FontWeight.w300,
              fontFeatures: const [FontFeature.tabularFigures()],
              color: AppColors.red,
            ),
          ),
          const SizedBox(height: 32),

          // Action buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Cancel
              TextButton.icon(
                onPressed: () => Navigator.pop(context, false),
                icon: const Icon(Icons.close),
                label: Text(l10n.cancel),
                style: TextButton.styleFrom(
                  foregroundColor: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
              ),
              const SizedBox(width: 24),
              // Stop & Save
              FilledButton.icon(
                onPressed: () => Navigator.pop(context, true),
                icon: const Icon(Icons.stop),
                label: Text(l10n.stopAndSave),
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
