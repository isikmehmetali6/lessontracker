import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../widgets/common/common_widgets.dart';
import 'package:lesson_tracker/l10n/app_localizations.dart';

class AddGradeDialog extends StatefulWidget {
  final Function(String name, double score, double maxScore, double weight) onSave;

  const AddGradeDialog({
    super.key,
    required this.onSave,
  });

  @override
  State<AddGradeDialog> createState() => _AddGradeDialogState();
}

class _AddGradeDialogState extends State<AddGradeDialog> {
  final _nameController = TextEditingController();
  final _scoreController = TextEditingController();
  final _maxScoreController = TextEditingController(text: '100');
  final _weightController = TextEditingController();

  bool _isSaving = false;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: isDark ? AppColors.surfaceDark : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              AppLocalizations.of(context)!.addGrade,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
              ),
            ),
            const SizedBox(height: 16),
            
            // Name Input
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                hintText: AppLocalizations.of(context)!.assignmentNameHint,
                filled: true,
                fillColor: isDark ? Colors.grey.shade800 : Colors.grey.shade100,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 12),

            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _scoreController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      hintText: AppLocalizations.of(context)!.score,
                      filled: true,
                      fillColor: isDark ? Colors.grey.shade800 : Colors.grey.shade100,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text('/', style: TextStyle(fontSize: 20, color: Colors.grey.shade400)),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: _maxScoreController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      hintText: AppLocalizations.of(context)!.max,
                      filled: true,
                      fillColor: isDark ? Colors.grey.shade800 : Colors.grey.shade100,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Weight Input
             TextField(
              controller: _weightController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                hintText: AppLocalizations.of(context)!.weightPercent,
                filled: true,
                fillColor: isDark ? Colors.grey.shade800 : Colors.grey.shade100,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                suffixText: '%',
              ),
            ),
            const SizedBox(height: 24),

            PrimaryButton(
              text: AppLocalizations.of(context)!.saveGrade,
              icon: Icons.check,
              isLoading: _isSaving,
              onPressed: _save,
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  void _save() {
    final name = _nameController.text.trim();
    final score = double.tryParse(_scoreController.text.trim());
    final maxScore = double.tryParse(_maxScoreController.text.trim());
    final weight = double.tryParse(_weightController.text.trim());

    if (name.isEmpty || score == null || maxScore == null || weight == null) {
      // Show error? For now just return
       // We should ideally show a snackbar or error text
       return;
    }

    setState(() => _isSaving = true);
    widget.onSave(name, score, maxScore, weight);
    Navigator.pop(context);
  }
}
