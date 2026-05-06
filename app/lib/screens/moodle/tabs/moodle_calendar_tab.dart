import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../../models/moodle/moodle_calendar_event.dart';
import '../../../providers/moodle_provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/moodle_utils.dart';
import '../../../../providers/language_provider.dart';

class MoodleCalendarTab extends StatefulWidget {
  const MoodleCalendarTab({super.key});

  @override
  State<MoodleCalendarTab> createState() => _MoodleCalendarTabState();
}

class _MoodleCalendarTabState extends State<MoodleCalendarTab> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  List<MoodleCalendarEvent> _eventsForDay(
      List<MoodleCalendarEvent> all, DateTime day) {
    return all.where((e) {
      return e.timeStart.year == day.year &&
          e.timeStart.month == day.month &&
          e.timeStart.day == day.day;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final provider = context.watch<MoodleProvider>();
    final allEvents = provider.allEvents;

    final selectedEvents = _eventsForDay(
        allEvents, _selectedDay ?? _focusedDay);

    return Column(
      children: [
        TableCalendar<MoodleCalendarEvent>(
          firstDay: DateTime.now().subtract(const Duration(days: 30)),
          lastDay: DateTime.now().add(const Duration(days: 180)),
          focusedDay: _focusedDay,
          selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
          eventLoader: (day) => _eventsForDay(allEvents, day),
          onDaySelected: (selectedDay, focusedDay) {
            setState(() {
              _selectedDay = selectedDay;
              _focusedDay = focusedDay;
            });
          },
          calendarStyle: CalendarStyle(
            markerDecoration: BoxDecoration(
              color: AppColors.primary,
              shape: BoxShape.circle,
            ),
            selectedDecoration: BoxDecoration(
              color: AppColors.primary,
              shape: BoxShape.circle,
            ),
            todayDecoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            todayTextStyle: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold),
          ),
          headerStyle: HeaderStyle(
            formatButtonVisible: false,
            titleCentered: true,
            titleTextStyle: theme.textTheme.titleMedium!
                .copyWith(fontWeight: FontWeight.w700),
          ),
          calendarFormat: CalendarFormat.month,
        ),
        const Divider(height: 1),
        Expanded(
          child: selectedEvents.isEmpty
              ? Center(
                  child: Text(
                    'Bu gün için etkinlik yok',
                    style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant),
                  ),
                )
              : ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: selectedEvents.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 8),
                  itemBuilder: (context, i) =>
                      _EventTile(event: selectedEvents[i]),
                ),
        ),
      ],
    );
  }
}

class _EventTile extends StatelessWidget {
  final MoodleCalendarEvent event;
  const _EventTile({required this.event});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final langCode = context.watch<LanguageProvider>().locale.languageCode;

    final typeIcon = switch (event.eventType) {
      'course' => Icons.menu_book_rounded,
      'user' => Icons.person_rounded,
      _ => Icons.event_rounded,
    };

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? Colors.white.withValues(alpha: 0.1) : Colors.grey.shade200,
        ),
        boxShadow: [
          if (!isDark)
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(typeIcon,
                color: AppColors.primary, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                    MoodleUtils.parseMultilang(
                      event.name,
                      langCode,
                    ),
                    style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis),
                const SizedBox(height: 2),
                if (event.courseName != null)
                  Text(
                      MoodleUtils.parseMultilang(
                        event.courseName!,
                        langCode,
                      ),
                      style: theme.textTheme.bodySmall?.copyWith(
                          color: AppColors.primary)),
                Text(
                  event.isAllDay
                      ? 'Tüm gün'
                      : DateFormat('HH:mm', 'tr').format(event.timeStart),
                  style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
