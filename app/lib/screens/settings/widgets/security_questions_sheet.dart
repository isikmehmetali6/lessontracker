import 'package:flutter/material.dart';
import 'package:lesson_tracker/core/services/security_questions_service.dart';
import 'package:lesson_tracker/core/theme/app_colors.dart';
import 'package:lesson_tracker/l10n/app_localizations.dart';

class SecurityQuestionsSheet extends StatefulWidget {
  final bool isDark;

  const SecurityQuestionsSheet({super.key, required this.isDark});

  @override
  State<SecurityQuestionsSheet> createState() => _SecurityQuestionsSheetState();
}

class _SecurityQuestionsSheetState extends State<SecurityQuestionsSheet> {
  final List<TextEditingController> _answerControllers = [
    TextEditingController(),
    TextEditingController(),
    TextEditingController(),
  ];

  int _selectedQuestion1 = 0;
  int _selectedQuestion2 = 1;
  int _selectedQuestion3 = 2;
  bool _isSaving = false;
  bool _hasQuestions = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadStatus();
  }

  Future<void> _loadStatus() async {
    try {
      final hasQuestions = await SecurityQuestionsService.hasSecurityQuestions();
      setState(() {
        _hasQuestions = hasQuestions;
      });
    } catch (e) {
      debugPrint('Error loading security questions status: $e');
    }
  }

  @override
  void dispose() {
    for (final c in _answerControllers) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _saveQuestions() async {
    final loc = AppLocalizations.of(context)!;
    for (final c in _answerControllers) {
      if (c.text.trim().isEmpty) {
        setState(() => _error = loc.allAnswersRequired);
        return;
      }
    }

    setState(() {
      _isSaving = true;
      _error = null;
    });

    try {
      await SecurityQuestionsService.setupSecurityQuestions(
        [
          _selectedQuestion1,
          _selectedQuestion2,
          _selectedQuestion3,
        ],
        _answerControllers.map((c) => c.text.trim()).toList(),
      );
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(loc.questionsSaved),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      setState(() => _error = loc.questionsSaveFailed);
    } finally {
      setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    return Container(
      padding: EdgeInsets.fromLTRB(
        24,
        24,
        24,
        MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      decoration: BoxDecoration(
        color: widget.isDark ? AppColors.surfaceDark : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: widget.isDark
                      ? Colors.grey.shade700
                      : Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Text(
              loc.securityQuestions,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: widget.isDark ? Colors.white : AppColors.textHeadingLight,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              loc.setUpSecurityQuestions,
              style: TextStyle(
                fontSize: 14,
                color: widget.isDark
                    ? Colors.grey.shade400
                    : Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 24),
            if (_hasQuestions) ...[
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.emerald.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.check_circle, color: AppColors.emerald),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        loc.questionsAlreadyConfigured,
                        style: TextStyle(
                          color: widget.isDark
                              ? Colors.white
                              : AppColors.textHeadingLight,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    await SecurityQuestionsService.deleteSecurityQuestions();
                    setState(() => _hasQuestions = false);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: Text(
                    loc.resetQuestions,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ] else ...[
              if (_error != null) ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    _error!,
                    style: const TextStyle(color: Colors.red, fontSize: 13),
                  ),
                ),
                const SizedBox(height: 16),
              ],
              _buildQuestionDropdown(0),
              const SizedBox(height: 12),
              _buildAnswerField(0),
              const SizedBox(height: 16),
              _buildQuestionDropdown(1),
              const SizedBox(height: 12),
              _buildAnswerField(1),
              const SizedBox(height: 16),
              _buildQuestionDropdown(2),
              const SizedBox(height: 12),
              _buildAnswerField(2),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isSaving ? null : _saveQuestions,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: _isSaving
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : Text(
                          loc.saveQuestions,
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildQuestionDropdown(int index) {
    final loc = AppLocalizations.of(context)!;
    final selectedIndex = index == 0
        ? _selectedQuestion1
        : (index == 1 ? _selectedQuestion2 : _selectedQuestion3);

    return DropdownButtonFormField<int>(
      initialValue: selectedIndex,
      decoration: InputDecoration(
        labelText: loc.questionLabel(index + 1),
        filled: true,
        fillColor: widget.isDark
            ? AppColors.backgroundDark
            : AppColors.backgroundLight,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
      ),
      items: SecurityQuestionsService.availableQuestions(loc)
          .asMap()
          .entries
          .map((entry) {
        return DropdownMenuItem(
          value: entry.key,
          child: Text(entry.value, style: const TextStyle(fontSize: 14)),
        );
      }).toList(),
      onChanged: (value) {
        if (value == null) return;
        setState(() {
          if (index == 0) {
            _selectedQuestion1 = value;
          } else if (index == 1) {
            _selectedQuestion2 = value;
          } else {
            _selectedQuestion3 = value;
          }
        });
      },
    );
  }

  Widget _buildAnswerField(int index) {
    final loc = AppLocalizations.of(context)!;
    return TextField(
      controller: _answerControllers[index],
      style: TextStyle(color: widget.isDark ? Colors.white : Colors.black87),
      decoration: InputDecoration(
        labelText: loc.yourAnswer,
        filled: true,
        fillColor: widget.isDark
            ? AppColors.backgroundDark
            : AppColors.backgroundLight,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
      ),
    );
  }
}