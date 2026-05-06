import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lesson_tracker/core/theme/app_colors.dart';
import 'package:lesson_tracker/l10n/app_localizations.dart';
import 'package:lesson_tracker/models/planner_event.dart';
import 'package:lesson_tracker/providers/planner_event_provider.dart';
import 'package:uuid/uuid.dart';

class AddPlannerEventSheet extends StatefulWidget {
  final DateTime initialDate;

  const AddPlannerEventSheet({super.key, required this.initialDate});

  @override
  State<AddPlannerEventSheet> createState() => _AddPlannerEventSheetState();
}

class _AddPlannerEventSheetState extends State<AddPlannerEventSheet> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _notesController = TextEditingController();

  PlannerEventType _selectedType = PlannerEventType.personal;
  late TimeOfDay _startTime;
  late TimeOfDay _endTime;
  Color _selectedColor = AppColors.blue;

  final List<Color> _colors = [
    AppColors.blue,
    AppColors.primary,
    AppColors.orange,
    AppColors.purple,
    AppColors.red,
    Colors.teal,
  ];

  @override
  void initState() {
    super.initState();
    _startTime = TimeOfDay.now();
    _endTime = TimeOfDay(hour: (_startTime.hour + 1) % 24, minute: _startTime.minute);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _selectTime(bool isStart) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: isStart ? _startTime : _endTime,
    );
    if (picked != null) {
      setState(() {
        if (isStart) {
          _startTime = picked;
          // Auto adjust end time if it's before start time
          if (_endTime.hour < _startTime.hour || (_endTime.hour == _startTime.hour && _endTime.minute <= _startTime.minute)) {
            _endTime = TimeOfDay(hour: (_startTime.hour + 1) % 24, minute: _startTime.minute);
          }
        } else {
          _endTime = picked;
        }
      });
    }
  }

  void _saveEvent() {
    if (!_formKey.currentState!.validate()) return;

    final startDateTime = DateTime(
      widget.initialDate.year,
      widget.initialDate.month,
      widget.initialDate.day,
      _startTime.hour,
      _startTime.minute,
    );

    final endDateTime = DateTime(
      widget.initialDate.year,
      widget.initialDate.month,
      widget.initialDate.day,
      _endTime.hour,
      _endTime.minute,
    );

    final newEvent = PlannerEvent(
      id: const Uuid().v4(),
      title: _titleController.text.trim(),
      type: _selectedType,
      startTime: startDateTime,
      endTime: endDateTime,
      color: _selectedColor,
      notes: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
    );

    context.read<PlannerEventProvider>().addEvent(newEvent);
    Navigator.pop(context);
  }

  String _getTypeName(PlannerEventType type) {
    switch (type) {
      case PlannerEventType.study: return AppLocalizations.of(context)!.eventStudy;
      case PlannerEventType.meeting: return AppLocalizations.of(context)!.eventMeeting;
      case PlannerEventType.coffee: return AppLocalizations.of(context)!.eventCoffee;
      case PlannerEventType.personal: return AppLocalizations.of(context)!.eventPersonal;
      case PlannerEventType.other: return AppLocalizations.of(context)!.eventOther;
    }
  }

  IconData _getTypeIcon(PlannerEventType type) {
    switch (type) {
      case PlannerEventType.study: return Icons.menu_book;
      case PlannerEventType.meeting: return Icons.people;
      case PlannerEventType.coffee: return Icons.local_cafe;
      case PlannerEventType.personal: return Icons.person;
      case PlannerEventType.other: return Icons.event;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: EdgeInsets.only(
        top: 24,
        left: 24,
        right: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40, height: 4,
                  decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2)),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                AppLocalizations.of(context)!.addPlanEvent,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                ),
              ),
              const SizedBox(height: 24),

              // Title Field
              TextFormField(
                controller: _titleController,
                style: TextStyle(color: isDark ? Colors.white : Colors.black87),
                decoration: InputDecoration(
                  labelText: AppLocalizations.of(context)!.eventTitleHint,
                  prefixIcon: const Icon(Icons.title),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                ),
                validator: (val) => val == null || val.trim().isEmpty ? AppLocalizations.of(context)!.eventTitleRequired : null,
              ),
              const SizedBox(height: 16),

              // Event Type Dropdown
              DropdownButtonFormField<PlannerEventType>(
                initialValue: _selectedType,
                decoration: InputDecoration(
                  labelText: AppLocalizations.of(context)!.eventType,
                  prefixIcon: Icon(_getTypeIcon(_selectedType)),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                ),
                dropdownColor: isDark ? AppColors.surfaceDark : Colors.white,
                items: PlannerEventType.values.map((type) {
                  return DropdownMenuItem(
                    value: type,
                    child: Text(_getTypeName(type), style: TextStyle(color: isDark ? Colors.white : Colors.black87)),
                  );
                }).toList(),
                onChanged: (val) {
                  if (val != null) setState(() => _selectedType = val);
                },
              ),
              const SizedBox(height: 16),

              // Time Selection
              Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: () => _selectTime(true),
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade400),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.access_time, size: 20, color: Colors.grey),
                            const SizedBox(width: 8),
                            Text(
                              AppLocalizations.of(context)!.startLabel(_startTime.format(context)),
                              style: TextStyle(color: isDark ? Colors.white : Colors.black87),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: InkWell(
                      onTap: () => _selectTime(false),
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade400),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.access_time_filled, size: 20, color: Colors.grey),
                            const SizedBox(width: 8),
                            Text(
                              AppLocalizations.of(context)!.endLabel(_endTime.format(context)),
                              style: TextStyle(color: isDark ? Colors.white : Colors.black87),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Colors
              Text(
                AppLocalizations.of(context)!.colorLabel,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white70 : Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: _colors.map((color) {
                  return GestureDetector(
                    onTap: () => setState(() => _selectedColor = color),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                        border: _selectedColor == color
                            ? Border.all(color: Colors.white, width: 3)
                            : null,
                        boxShadow: [
                          if (_selectedColor == color)
                            BoxShadow(
                              color: color.withValues(alpha: 0.5),
                              blurRadius: 8,
                              spreadRadius: 2,
                            ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),
              
              // Notes
              TextFormField(
                controller: _notesController,
                maxLines: 3,
                style: TextStyle(color: isDark ? Colors.white : Colors.black87),
                decoration: InputDecoration(
                  labelText: AppLocalizations.of(context)!.notesOptional,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                  alignLabelWithHint: true,
                ),
              ),
              const SizedBox(height: 24),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _saveEvent,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: Text(AppLocalizations.of(context)!.saveEvent, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
