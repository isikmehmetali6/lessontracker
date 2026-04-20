import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/deadline.dart';
import '../../providers/course_provider.dart';
import '../../core/theme/app_colors.dart';
import 'package:lesson_tracker/l10n/app_localizations.dart';

class AddDeadlineDialog extends StatefulWidget {
  final Function(String title, String courseId, DateTime date, DeadlineType type, bool addToCalendar) onSave;
  final Deadline? deadlineToEdit;

  const AddDeadlineDialog({super.key, required this.onSave, this.deadlineToEdit});

  @override
  State<AddDeadlineDialog> createState() => _AddDeadlineDialogState();
}

class _AddDeadlineDialogState extends State<AddDeadlineDialog> {
  final _titleController = TextEditingController();
  String? _selectedCourseId;
  DateTime _selectedDate = DateTime.now().add(const Duration(days: 7));
  DeadlineType _selectedType = DeadlineType.exam;
  bool _addToCalendar = false;
  bool _isSaving = false;

  bool get _isEditing => widget.deadlineToEdit != null;

  @override
  void initState() {
    super.initState();
    if (widget.deadlineToEdit != null) {
      _titleController.text = widget.deadlineToEdit!.title;
      _selectedCourseId = widget.deadlineToEdit!.courseId;
      _selectedDate = widget.deadlineToEdit!.date;
      _selectedType = widget.deadlineToEdit!.type;
    } else {
      final courses = context.read<CourseProvider>().courses;
      if (courses.isNotEmpty) {
        _selectedCourseId = courses.first.id;
      }
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  void _save() {
    if (_isSaving) return;
    if (_titleController.text.isEmpty || _selectedCourseId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.fillAllFields)),
      );
      return;
    }
    setState(() => _isSaving = true);

    widget.onSave(
      _titleController.text,
      _selectedCourseId!,
      _selectedDate,
      _selectedType,
      _addToCalendar,
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final courses = context.select((CourseProvider p) => p.courses);

    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 24,
        right: 24,
        top: 32,
      ),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E2E) : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        boxShadow: [
           BoxShadow(
              color: Colors.black.withValues(alpha: 0.2),
              blurRadius: 20,
              offset: const Offset(0, -5),
           )
        ]
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
             child: Container(
                width: 40,
                height: 5,
                decoration: BoxDecoration(
                   color: isDark ? Colors.white24 : Colors.grey.shade300,
                   borderRadius: BorderRadius.circular(2.5),
                ),
             ),
          ),
          const SizedBox(height: 24),
          Text(
            _isEditing
                ? AppLocalizations.of(context)!.editDeadline
                : AppLocalizations.of(context)!.addDeadlineTitle,
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w800,
              color: isDark ? Colors.white : AppColors.textPrimaryLight,
            ),
          ),
          const SizedBox(height: 28),

          // Title
          TextField(
            controller: _titleController,
            decoration: InputDecoration(
              hintText: AppLocalizations.of(context)!.titleHint,
              hintStyle: TextStyle(color: isDark ? Colors.grey.shade600 : Colors.grey.shade400),
              filled: true,
              fillColor: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.grey.shade50,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(color: isDark ? Colors.white12 : Colors.grey.shade200),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(color: isDark ? Colors.white12 : Colors.grey.shade200),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(color: AppColors.primary, width: 2),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            ),
            style: TextStyle(
              color: isDark ? Colors.white : AppColors.textPrimaryLight,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),

          // Course Selector
          if (courses.isEmpty)
             Text(AppLocalizations.of(context)!.noCoursesAvailable, style: const TextStyle(color: AppColors.red))
          else
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.grey.shade50,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: isDark ? Colors.white12 : Colors.grey.shade200),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _selectedCourseId,
                  hint: Text(AppLocalizations.of(context)!.selectCourse),
                  isExpanded: true,
                  icon: Icon(Icons.keyboard_arrow_down, color: isDark ? Colors.white70 : Colors.grey.shade600),
                  dropdownColor: isDark ? AppColors.surfaceDark : Colors.white,
                  items: courses.map((course) {
                    return DropdownMenuItem(
                      value: course.id,
                      child: Row(
                        children: [
                          Container(
                            width: 14,
                            height: 14,
                            decoration: BoxDecoration(
                              color: course.color,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              course.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: isDark ? Colors.white : AppColors.textPrimaryLight,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                  onChanged: (val) => setState(() => _selectedCourseId = val),
                ),
              ),
            ),
          const SizedBox(height: 16),

          // Date Picker
          GestureDetector(
            onTap: _pickDate,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
              decoration: BoxDecoration(
                color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.grey.shade50,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: isDark ? Colors.white12 : Colors.grey.shade200),
              ),
              child: Row(
                children: [
                  Icon(Icons.calendar_month_rounded, color: isDark ? Colors.white70 : AppColors.textSecondaryLight),
                  const SizedBox(width: 12),
                  Text(
                    '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white : AppColors.textPrimaryLight,
                    ),
                  ),
                  const Spacer(),
                  Icon(Icons.edit_calendar, size: 20, color: AppColors.primary),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Type Selector
          Text(
            "DEADLINE TYPE",
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.2,
              color: isDark ? Colors.white54 : Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: DeadlineType.values.map((type) {
                final isSelected = _selectedType == type;
                return Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: GestureDetector(
                    onTap: () => setState(() => _selectedType = type),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      decoration: BoxDecoration(
                        color: isSelected ? AppColors.primary : (isDark ? Colors.white.withValues(alpha: 0.05) : Colors.grey.shade100),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isSelected ? AppColors.primary : (isDark ? Colors.white12 : Colors.grey.shade300),
                        ),
                      ),
                      child: Text(
                        type.name.toUpperCase(),
                        style: TextStyle(
                          color: isSelected ? Colors.white : (isDark ? Colors.white70 : Colors.grey.shade700),
                          fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          
          const SizedBox(height: 28),

          // Add to Calendar Switch
          Container(
             padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
             decoration: BoxDecoration(
                color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.blue.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(16),
             ),
             child: SwitchListTile(
               contentPadding: EdgeInsets.zero,
               title: Text(
                 AppLocalizations.of(context)!.addToCalendar,
                 style: TextStyle(
                   fontWeight: FontWeight.w600,
                   color: isDark ? Colors.white : AppColors.textPrimaryLight,
                 ),
               ),
               subtitle: Text(
                 AppLocalizations.of(context)!.saveToDeviceCalendar,
                 style: TextStyle(
                   fontSize: 12,
                   color: isDark ? Colors.white54 : AppColors.textSecondaryLight,
                 ),
               ),
               value: _addToCalendar,
               onChanged: (val) => setState(() => _addToCalendar = val),
               activeThumbColor: AppColors.primary,
               inactiveTrackColor: isDark ? Colors.white24 : Colors.grey.shade300,
             ),
          ),
          
          const SizedBox(height: 32),
          
          // Save Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isSaving ? null : _save,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(vertical: 18),
                elevation: 4,
                shadowColor: AppColors.primary.withValues(alpha: 0.4),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              ),
              child: _isSaving
                  ? const SizedBox(
                      height: 22,
                      width: 22,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : Text(
                _isEditing
                    ? AppLocalizations.of(context)!.updateDeadline
                    : AppLocalizations.of(context)!.addDeadlineTitle,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}
