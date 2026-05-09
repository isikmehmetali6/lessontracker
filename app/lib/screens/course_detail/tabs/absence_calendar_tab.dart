import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:uuid/uuid.dart';
import 'package:lesson_tracker/l10n/app_localizations.dart';
import '../../../repositories/absence_repository.dart';
import '../../../core/theme/app_colors.dart';
import '../../../models/course.dart';

class AbsenceCalendarTab extends StatefulWidget {
  final String courseId;
  final bool isDark;
  final Course? course;

  const AbsenceCalendarTab({
    super.key,
    required this.courseId,
    required this.isDark,
    this.course,
  });

  @override
  State<AbsenceCalendarTab> createState() => _AbsenceCalendarTabState();
}

class _AbsenceCalendarTabState extends State<AbsenceCalendarTab> {
  final AbsenceRepository _absenceRepo = AbsenceRepository();
  Map<DateTime, List<Map<String, dynamic>>> _absenceEvents = {};
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  bool _isLoading = true;

  static const Map<String, Color> reasonColors = {
    'unexcused': AppColors.red,
    'medical': Colors.blue,
    'excused': AppColors.emerald,
    'personal': AppColors.orange,
  };

  static const Map<String, IconData> reasonIcons = {
    'unexcused': Icons.cancel,
    'medical': Icons.local_hospital,
    'excused': Icons.check_circle,
    'personal': Icons.person,
  };

  int get totalAbsences => _absenceEvents.values.fold(0, (sum, list) => sum + list.length);

  @override
  void initState() {
    super.initState();
    _loadAbsences();
  }

  Future<void> _loadAbsences() async {
    final absences = await _absenceRepo.getAbsencesWithReasonByCourse(widget.courseId);
    final events = <DateTime, List<Map<String, dynamic>>>{};
    for (final a in absences) {
      final dateStr = a['date'];
      final date = dateStr is DateTime ? dateStr : DateTime.parse(dateStr as String);
      final normalizedDate = DateTime(date.year, date.month, date.day);
      events.putIfAbsent(normalizedDate, () => []).add(a);
    }
    if (mounted) {
      setState(() {
        _absenceEvents = events;
        _isLoading = false;
      });
    }
  }

  List<Map<String, dynamic>> _getEventsForDay(DateTime day) {
    final normalized = DateTime(day.year, day.month, day.day);
    return _absenceEvents[normalized] ?? [];
  }

  String _reasonLabel(String reason) {
    final l10n = AppLocalizations.of(context)!;
    switch (reason) {
      case 'unexcused': return l10n.absenceUnexcused;
      case 'medical': return l10n.absenceMedical;
      case 'excused': return l10n.absenceExcused;
      case 'personal': return l10n.absencePersonal;
      default: return reason;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    final l10n = AppLocalizations.of(context)!;
    final absenceLimit = widget.course?.absenceLimit ?? 0;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Summary card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: widget.isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.absenceOverview,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: widget.isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        absenceLimit > 0
                            ? '$totalAbsences / $absenceLimit ${l10n.absencesUsed}'
                            : '$totalAbsences ${l10n.totalAbsences}',
                        style: TextStyle(
                          fontSize: 13,
                          color: totalAbsences >= absenceLimit && absenceLimit > 0
                              ? AppColors.red
                              : (widget.isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight),
                        ),
                      ),
                    ],
                  ),
                ),
                if (absenceLimit > 0) ...[
                  SizedBox(
                    width: 56,
                    height: 56,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        CircularProgressIndicator(
                          value: absenceLimit > 0 ? (totalAbsences / absenceLimit).clamp(0.0, 1.0) : 0,
                          backgroundColor: widget.isDark ? Colors.grey.shade800 : Colors.grey.shade200,
                          color: totalAbsences >= absenceLimit ? AppColors.red : AppColors.primary,
                          strokeWidth: 6,
                        ),
                        Text(
                          '$totalAbsences',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: totalAbsences >= absenceLimit ? AppColors.red : AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Calendar
          Container(
            decoration: BoxDecoration(
              color: widget.isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: TableCalendar(
              firstDay: DateTime.now().subtract(const Duration(days: 365)),
              lastDay: DateTime.now().add(const Duration(days: 365)),
              focusedDay: _focusedDay,
              selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
              eventLoader: _getEventsForDay,
              calendarStyle: CalendarStyle(
                todayDecoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.3),
                  shape: BoxShape.circle,
                ),
                selectedDecoration: const BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
                markersMaxCount: 3,
                markerDecoration: const BoxDecoration(
                  color: AppColors.red,
                  shape: BoxShape.circle,
                ),
                defaultTextStyle: TextStyle(
                  color: widget.isDark ? Colors.white : Colors.black,
                ),
                weekendTextStyle: TextStyle(
                  color: widget.isDark ? Colors.white70 : Colors.black54,
                ),
              ),
              headerStyle: HeaderStyle(
                formatButtonVisible: false,
                titleCentered: true,
                titleTextStyle: TextStyle(
                  color: widget.isDark ? Colors.white : Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
                leftChevronIcon: Icon(Icons.chevron_left, color: widget.isDark ? Colors.white : Colors.black),
                rightChevronIcon: Icon(Icons.chevron_right, color: widget.isDark ? Colors.white : Colors.black),
              ),
              calendarBuilders: CalendarBuilders(
                markerBuilder: (context, day, events) {
                  if (events.isEmpty) return null;
                  final absenceList = events.cast<Map<String, dynamic>>();
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: absenceList.take(3).map((a) {
                      final reason = (a['reason'] as String?) ?? 'unexcused';
                      return Container(
                        width: 7,
                        height: 7,
                        margin: const EdgeInsets.symmetric(horizontal: 1),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: reasonColors[reason] ?? AppColors.red,
                        ),
                      );
                    }).toList(),
                  );
                },
              ),
              onDaySelected: (selectedDay, focusedDay) {
                setState(() {
                  _selectedDay = selectedDay;
                  _focusedDay = focusedDay;
                });
              },
              onPageChanged: (focusedDay) {
                _focusedDay = focusedDay;
              },
            ),
          ),
          const SizedBox(height: 16),

          // Add absence button
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => _showAddAbsenceSheet(context),
              icon: const Icon(Icons.add),
              label: Text(l10n.addAbsence),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                side: BorderSide(color: AppColors.primary.withValues(alpha: 0.5)),
              ),
            ),
          ),
          const SizedBox(height: 16),

          _buildLegend(),

          if (_selectedDay != null) ...[
            const SizedBox(height: 16),
            _buildSelectedDayDetails(),
          ],
        ],
      ),
    );
  }

  Widget _buildLegend() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: widget.isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Wrap(
        spacing: 16,
        runSpacing: 8,
        children: reasonColors.entries.map((e) {
          return Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: e.value,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                _reasonLabel(e.key),
                style: TextStyle(
                  fontSize: 12,
                  color: widget.isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                ),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _buildSelectedDayDetails() {
    final l10n = AppLocalizations.of(context)!;
    final events = _getEventsForDay(_selectedDay!);
    if (events.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: widget.isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          l10n.noAbsencesOnDay,
          style: TextStyle(
            color: widget.isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: widget.isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: events.map((a) {
          final reason = (a['reason'] as String?) ?? 'unexcused';
          final color = reasonColors[reason] ?? AppColors.red;
          final icon = reasonIcons[reason] ?? Icons.cancel;
          final id = a['id'] as String?;
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              children: [
                Icon(icon, color: color, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _reasonLabel(reason),
                    style: TextStyle(
                      color: widget.isDark ? Colors.white : Colors.black,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                if (id != null) ...[
                  IconButton(
                    icon: Icon(Icons.edit_outlined, size: 18, color: AppColors.primary),
                    onPressed: () => _showEditReasonSheet(id, reason),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.delete_outline, size: 18, color: AppColors.red),
                    onPressed: () => _confirmDelete(id),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  void _showAddAbsenceSheet(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final selectedDate = _selectedDay ?? DateTime.now();
    String selectedReason = 'unexcused';

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setSheetState) {
            return Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: widget.isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40, height: 4,
                      decoration: BoxDecoration(color: widget.isDark ? Colors.grey.shade600 : Colors.grey.shade300, borderRadius: BorderRadius.circular(2)),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    l10n.addAbsence,
                      style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: widget.isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${selectedDate.day}/${selectedDate.month}/${selectedDate.year}',
                    style: TextStyle(
                      fontSize: 14,
                      color: widget.isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    l10n.selectReason,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: widget.isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ...reasonColors.entries.map((e) {
                    final isSelected = selectedReason == e.key;
                    return GestureDetector(
                      onTap: () => setSheetState(() => selectedReason = e.key),
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? e.value.withValues(alpha: 0.15)
                              : (widget.isDark ? Colors.grey.shade800 : Colors.grey.shade50),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isSelected ? e.value : Colors.transparent,
                            width: 2,
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(reasonIcons[e.key], color: e.value, size: 22),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                _reasonLabel(e.key),
                                style: TextStyle(
                                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                                  color: widget.isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                                ),
                              ),
                            ),
                            if (isSelected)
                              Icon(Icons.check_circle, color: e.value, size: 22),
                          ],
                        ),
                      ),
                    );
                  }),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () async {
                        final id = const Uuid().v4();
                        await _absenceRepo.insertAbsence(id, widget.courseId, selectedDate, reason: selectedReason);
                        HapticFeedback.mediumImpact();
                        if (mounted) Navigator.pop(ctx);
                        _loadAbsences();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: Text(l10n.save),
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showEditReasonSheet(String absenceId, String currentReason) {
    final l10n = AppLocalizations.of(context)!;
    String selectedReason = currentReason;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setSheetState) {
            return Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: widget.isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40, height: 4,
                      decoration: BoxDecoration(color: widget.isDark ? Colors.grey.shade600 : Colors.grey.shade300, borderRadius: BorderRadius.circular(2)),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    l10n.editAbsence,
                      style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: widget.isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ...reasonColors.entries.map((e) {
                    final isSelected = selectedReason == e.key;
                    return GestureDetector(
                      onTap: () => setSheetState(() => selectedReason = e.key),
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? e.value.withValues(alpha: 0.15)
                              : (widget.isDark ? Colors.grey.shade800 : Colors.grey.shade50),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isSelected ? e.value : Colors.transparent,
                            width: 2,
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(reasonIcons[e.key], color: e.value, size: 22),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                _reasonLabel(e.key),
                                style: TextStyle(
                                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                                  color: widget.isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                                ),
                              ),
                            ),
                            if (isSelected)
                              Icon(Icons.check_circle, color: e.value, size: 22),
                          ],
                        ),
                      ),
                    );
                  }),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () async {
                        await _absenceRepo.updateAbsenceReason(absenceId, selectedReason);
                        HapticFeedback.mediumImpact();
                        if (mounted) Navigator.pop(ctx);
                        _loadAbsences();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    child: Text(l10n.save),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _confirmDelete(String absenceId) async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.deleteAbsence),
        content: Text(l10n.thisActionCannotBeUndone),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(
              l10n.delete,
              style: const TextStyle(color: AppColors.red),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _absenceRepo.deleteAbsence(absenceId);
      HapticFeedback.mediumImpact();
      _loadAbsences();
    }
  }
}
