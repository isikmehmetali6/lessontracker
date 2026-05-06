import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/theme/app_colors.dart';
import 'package:lesson_tracker/l10n/app_localizations.dart';

class ScheduleItemData {
  int day;
  TimeOfDay startTime;
  TimeOfDay endTime;
  String? location;
  String? professor;

  ScheduleItemData({
    required this.day,
    required this.startTime,
    required this.endTime,
  });
}

class CourseScheduleForm extends StatelessWidget {
  final List<ScheduleItemData> scheduleItems;
  final VoidCallback onAddSchedule;
  final void Function(int) onRemoveSchedule;
  final void Function(int, int) onDayChanged;
  final void Function(int, TimeOfDay) onStartTimeChanged;
  final void Function(int, TimeOfDay) onEndTimeChanged;
  final void Function(int, String?) onLocationChanged;
  final void Function(int, String?) onProfessorChanged;
  final bool isDark;

  const CourseScheduleForm({
    super.key,
    required this.scheduleItems,
    required this.onAddSchedule,
    required this.onRemoveSchedule,
    required this.onDayChanged,
    required this.onStartTimeChanged,
    required this.onEndTimeChanged,
    required this.onLocationChanged,
    required this.onProfessorChanged,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final dayNames = [
      l10n.dayMon, l10n.dayTue, l10n.dayWed, l10n.dayThu, l10n.dayFri, l10n.daySat, l10n.daySun
    ];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.access_time_filled, color: AppColors.primary),
                  const SizedBox(width: 8),
                  Text(
                    AppLocalizations.of(context)!.classSchedule,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                    ),
                  ),
                ],
              ),
              IconButton(
                onPressed: () {
                  HapticFeedback.lightImpact();
                  onAddSchedule();
                },
                icon: const Icon(Icons.add_circle, color: AppColors.primary),
                tooltip: AppLocalizations.of(context)!.addTimeSlot,
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          if (scheduleItems.isEmpty)
            Center(
               child: Text(
                 AppLocalizations.of(context)!.noClassTimesAdded,
                 style: TextStyle(
                   color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                 ),
               ),
             ),

          ...scheduleItems.asMap().entries.map((entry) {
            final index = entry.key;
            final item = entry.value;
            
            return Container(
              key: ObjectKey(item),
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isDark ? Colors.white10 : Colors.grey.shade200,
                ),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: isDark ? AppColors.surfaceDark : Colors.white,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<int>(
                            value: item.day,
                            dropdownColor: isDark ? AppColors.surfaceDark : Colors.white,
                            items: List.generate(7, (i) {
                              return DropdownMenuItem(
                                value: i,
                                child: Text(
                                  dayNames[i],
                                  style: TextStyle(
                                                            fontSize: 14,
                                                            fontWeight: FontWeight.w600,
                                                            color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                                                          ),
                                ),
                              );
                            }),
                            onChanged: (val) {
                              if (val != null) {
                                onDayChanged(index, val);
                              }
                            },
                          ),
                        ),
                      ),
                      const Spacer(),
                      if (scheduleItems.length > 1)
                        IconButton(
                          icon: const Icon(Icons.delete_outline, size: 20, color: Colors.red),
                          onPressed: () => onRemoveSchedule(index),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  
                  Row(
                    children: [
                      _TimePickerField(
                        label: 'Start',
                        time: item.startTime,
                        isDark: isDark,
                        onTap: () async {
                          final picked = await showTimePicker(
                            context: context,
                            initialTime: item.startTime,
                            builder: (context, child) {
                              return MediaQuery(
                                data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
                                child: child!,
                              );
                            },
                          );
                          if (picked != null) {
                            onStartTimeChanged(index, picked);
                          }
                        },
                      ),
                      const SizedBox(width: 12),
                      Icon(Icons.arrow_forward, size: 20, color: Colors.grey.shade400),
                      const SizedBox(width: 12),
                      _TimePickerField(
                        label: 'End',
                        time: item.endTime,
                        isDark: isDark,
                        onTap: () async {
                          final picked = await showTimePicker(
                            context: context,
                            initialTime: item.endTime,
                            builder: (context, child) {
                              return MediaQuery(
                                data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
                                child: child!,
                              );
                            },
                          );
                          if (picked != null) {
                            onEndTimeChanged(index, picked);
                          }
                        },
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 16),
                  
                  Row(
                    children: [
                      Expanded(
                        child: _TextField(
                          hintText: AppLocalizations.of(context)!.classroomHint,
                          icon: Icons.location_on,
                          initialValue: item.location,
                          onChanged: (val) => onLocationChanged(index, val.trim().isEmpty ? null : val.trim()),
                          isDark: isDark,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _TextField(
                          hintText: AppLocalizations.of(context)!.professorHint,
                          icon: Icons.person,
                          initialValue: item.professor,
                          onChanged: (val) => onProfessorChanged(index, val.trim().isEmpty ? null : val.trim()),
                          isDark: isDark,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}

class _TimePickerField extends StatelessWidget {
  final String label;
  final TimeOfDay time;
  final VoidCallback onTap;
  final bool isDark;

  const _TimePickerField({
    required this.label,
    required this.time,
    required this.onTap,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isDark ? AppColors.surfaceDark : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isDark ? Colors.grey.shade800 : Colors.grey.shade300,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.access_time, size: 18, color: AppColors.primary),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 10,
                    color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _formatTime(time),
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatTime(TimeOfDay time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }
}

class _TextField extends StatelessWidget {
  final String hintText;
  final IconData icon;
  final String? initialValue;
  final ValueChanged<String> onChanged;
  final bool isDark;

  const _TextField({
    required this.hintText,
    required this.icon,
    this.initialValue,
    required this.onChanged,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: TextFormField(
        initialValue: initialValue,
        onChanged: onChanged,
        style: TextStyle(
          fontSize: 14,
          color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
        ),
        decoration: InputDecoration(
          hintText: hintText,
          prefixIcon: Icon(icon, size: 18, color: AppColors.primary),
          contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 12),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          hintStyle: TextStyle(
            fontSize: 13,
            color: isDark ? Colors.grey.shade600 : Colors.grey.shade400,
          ),
        ),
      ),
    );
  }
}