import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:lesson_tracker/l10n/app_localizations.dart';
import '../../../core/theme/app_colors.dart';
import '../../../models/course.dart';
import '../../../providers/course_provider.dart';
import 'absence_reason.dart' show absenceReasonColors, absenceReasonIcons;
import 'widgets/absence_day_details.dart';
import 'widgets/absence_legend.dart';
import 'widgets/absence_confirm_delete.dart';

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
  Map<DateTime, List<Map<String, dynamic>>> _absenceEvents = {};
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  bool _isLoading = true;

  int get totalAbsences => _absenceEvents.values.fold(0, (sum, list) => sum + list.length);

  @override
  void initState() {
    super.initState();
    _loadAbsences();
  }

  Future<void> _loadAbsences() async {
    final absences = await context
        .read<CourseProvider>()
        .loadAbsencesForCourse(widget.courseId);
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
                          color: absenceReasonColors[reason] ?? AppColors.red,
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
    return AbsenceLegend(isDark: widget.isDark, reasonLabel: _reasonLabel);
  }

  Widget _buildSelectedDayDetails() {
    final events = _getEventsForDay(_selectedDay!);
    return AbsenceDayDetails(
      isDark: widget.isDark,
      events: events,
      reasonLabel: _reasonLabel,
      onEditReason: _showEditReasonSheet,
      onConfirmDelete: (id) async {
        if (!mounted) return;
        final ok = await confirmAbsenceDelete(context);
        if (!ok) return;
        if (!mounted) return;
        if (!context.mounted) return;
        final provider = context.read<CourseProvider>();
        await provider.removeAbsenceById(widget.courseId, id);
        HapticFeedback.mediumImpact();
        if (!mounted) return;
        if (!context.mounted) return;
        _loadAbsences();
      },
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
                  ...absenceReasonColors.entries.map((e) {
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
                            Icon(absenceReasonIcons[e.key], color: e.value, size: 22),
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
                        final provider = context.read<CourseProvider>();
                        await provider.addAbsenceAt(
                          widget.courseId,
                          selectedDate,
                          reason: selectedReason,
                        );
                        HapticFeedback.mediumImpact();
                        if (!mounted) return;
                        if (!context.mounted) return;
                        Navigator.pop(ctx);
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
                  ...absenceReasonColors.entries.map((e) {
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
                            Icon(absenceReasonIcons[e.key], color: e.value, size: 22),
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
                        final provider = context.read<CourseProvider>();
                        await provider.updateAbsenceReasonById(
                            absenceId, selectedReason);
                        HapticFeedback.mediumImpact();
                        if (!mounted) return;
                        if (!context.mounted) return;
                        Navigator.pop(ctx);
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

}
