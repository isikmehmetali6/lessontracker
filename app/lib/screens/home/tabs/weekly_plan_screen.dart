import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:lesson_tracker/core/theme/app_colors.dart';
import 'package:lesson_tracker/models/course.dart';
import 'package:lesson_tracker/models/deadline.dart';
import 'package:lesson_tracker/providers/course_provider.dart';
import 'package:lesson_tracker/providers/deadline_provider.dart';
import 'package:lesson_tracker/providers/planner_event_provider.dart';
import 'package:lesson_tracker/models/planner_event.dart';
import 'package:lesson_tracker/screens/course_detail/course_detail_screen.dart';
import 'package:lesson_tracker/screens/deadlines/deadline_screen.dart';
import 'package:lesson_tracker/screens/home/widgets/add_planner_event_sheet.dart';

enum AgendaItemType { course, deadline, event }

class DayAgendaItem {
  final DateTime time;
  final AgendaItemType type;
  final Course? course;
  final Deadline? deadline;
  final PlannerEvent? event;

  DayAgendaItem({
    required this.time,
    required this.type,
    this.course,
    this.deadline,
    this.event,
  });
}

class WeeklyPlanScreen extends StatefulWidget {
  const WeeklyPlanScreen({super.key});

  @override
  State<WeeklyPlanScreen> createState() => _WeeklyPlanScreenState();
}

class _WeeklyPlanScreenState extends State<WeeklyPlanScreen> {
  DateTime _selectedDate = DateTime.now();
  final int _daysToShow = 14; // Show 2 weeks

  @override
  void initState() {
    super.initState();
    // Ensure deadlines are loaded
    Future.microtask(() => context.read<DeadlineProvider>().loadDeadlines());
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final now = DateTime.now();
    final weekDays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

    return Consumer3<CourseProvider, DeadlineProvider, PlannerEventProvider>(
      builder: (context, courseProvider, deadlineProvider, plannerEventProvider, _) {
        // Filter courses for selected date
        final selectedDayIndex = _selectedDate.weekday - 1; // 0 = Mon
        final courses = courseProvider.courses.where((c) {
          return c.status == 'active' && c.scheduleDays.contains(selectedDayIndex);
        }).toList();
        
        // Sort courses by time
        courses.sort((a, b) {
          final aMinutes = a.startTime.hour * 60 + a.startTime.minute;
          final bMinutes = b.startTime.hour * 60 + b.startTime.minute;
          return aMinutes.compareTo(bMinutes);
        });

        // Filter deadlines for selected date
        final deadlines = deadlineProvider.deadlines.where((d) {
          return d.date.year == _selectedDate.year &&
                 d.date.month == _selectedDate.month &&
                 d.date.day == _selectedDate.day;
        }).toList();

        // Sort deadlines by title
        deadlines.sort((a, b) => a.title.compareTo(b.title));

        final dateFormatter = "${weekDays[_selectedDate.weekday - 1]}, ${_selectedDate.day}";

        return CustomScrollView(
          slivers: [
            // Header
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Daily Plan',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.w700,
                            color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Your schedule at a glance',
                          style: TextStyle(
                            fontSize: 14,
                            color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                          ),
                        ),
                      ],
                    ),
                    TextButton.icon(
                      icon: const Icon(Icons.add_circle, color: AppColors.primary, size: 24),
                      label: Text(
                        'Add Plan',
                        style: TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                        ),
                      ),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      onPressed: () {
                         showModalBottomSheet(
                           context: context,
                           isScrollControlled: true,
                           backgroundColor: Colors.transparent,
                           builder: (_) => AddPlannerEventSheet(initialDate: _selectedDate),
                         );
                      },
                    ),
                  ],
                ),
              ),
            ),

            // Hafta Günleri (Horizontal Calendar)
            SliverToBoxAdapter(
              child: Container(
                height: 80,
                margin: const EdgeInsets.symmetric(vertical: 16),
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  itemCount: _daysToShow,
                  itemBuilder: (context, index) {
                    final day = now.add(Duration(days: index));
                    final isSelected = day.year == _selectedDate.year &&
                                     day.month == _selectedDate.month &&
                                     day.day == _selectedDate.day;
                    
                    final isToday = day.year == now.year &&
                                  day.month == now.month &&
                                  day.day == now.day;

                    // Calculate if this day has deadlines (for the tiny dot indicator)
                    final hasDeadlines = deadlineProvider.deadlines.any((d) => 
                        d.date.year == day.year && 
                        d.date.month == day.month && 
                        d.date.day == day.day
                    );

                    return GestureDetector(
                      onTap: () {
                        HapticFeedback.selectionClick();
                        setState(() {
                          _selectedDate = day;
                        });
                      },
                      child: Container(
                        width: 56,
                        margin: const EdgeInsets.only(right: 12),
                        decoration: BoxDecoration(
                          color: isSelected 
                              ? AppColors.primary 
                              : (isDark ? AppColors.surfaceDark : Colors.white),
                          borderRadius: BorderRadius.circular(16),
                          border: isToday && !isSelected 
                              ? Border.all(color: AppColors.primary, width: 2) 
                              : null,
                          boxShadow: isSelected ? [
                            BoxShadow(
                              color: AppColors.primary.withValues(alpha: 0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ] : null,
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              weekDays[day.weekday - 1],
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: isSelected 
                                    ? Colors.white.withValues(alpha: 0.8)
                                    : (isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${day.day}',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w700,
                                color: isSelected 
                                    ? Colors.white 
                                    : (isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight),
                              ),
                            ),
                            if (hasDeadlines)
                              Container(
                                margin: const EdgeInsets.only(top: 4),
                                width: 4, height: 4,
                                decoration: BoxDecoration(
                                  color: isSelected ? Colors.white : AppColors.red,
                                  shape: BoxShape.circle,
                                ),
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),

            // Section Header: Date
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 8, 24, 12),
                child: Text(
                  'Schedule for $dateFormatter',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                  ),
                ),
              ),
            ),
            
            // --- TIMELINE AGENDA SECTION ---
            Builder(
              builder: (context) {
                // Combine and sort courses and deadlines
                List<DayAgendaItem> agenda = [];
                
                for (var course in courses) {
                  final startTime = DateTime(
                    _selectedDate.year, _selectedDate.month, _selectedDate.day, 
                    course.startTime.hour, course.startTime.minute
                  );
                  agenda.add(DayAgendaItem(time: startTime, type: AgendaItemType.course, course: course));
                }
                
                for (var deadline in deadlines) {
                  agenda.add(DayAgendaItem(time: deadline.date, type: AgendaItemType.deadline, deadline: deadline));
                }

                final plannerEvents = plannerEventProvider.events.where((e) {
                  return e.startTime.year == _selectedDate.year &&
                         e.startTime.month == _selectedDate.month &&
                         e.startTime.day == _selectedDate.day;
                }).toList();

                for (var event in plannerEvents) {
                  agenda.add(DayAgendaItem(time: event.startTime, type: AgendaItemType.event, event: event));
                }

                agenda.sort((a, b) => a.time.compareTo(b.time));

                if (agenda.isEmpty) {
                  return SliverToBoxAdapter(
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 32),
                        margin: const EdgeInsets.only(top: 24, left: 24, right: 24),
                        decoration: BoxDecoration(
                          color: isDark ? AppColors.surfaceDark : AppColors.backgroundLight,
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(color: Colors.grey.withValues(alpha: 0.1)),
                        ),
                        child: Column(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: AppColors.primary.withValues(alpha: 0.1),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.sentiment_very_satisfied_rounded,
                                size: 56,
                                color: AppColors.primary,
                              ),
                            ),
                            const SizedBox(height: 24),
                            Text(
                              'It\'s a Free Day!',
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w800,
                                color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'You have no classes or deadlines scheduled. Enjoy your time off or plan ahead.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 14,
                                height: 1.5,
                                color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                              ),
                            ),
                          ],
                        ),
                      ),
                  );
                }

                // Render Timeline
                return SliverPadding(
                  padding: const EdgeInsets.fromLTRB(24, 0, 24, 100),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final item = agenda[index];
                        final isLast = index == agenda.length - 1;
                        
                        return Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // 1. Time Column
                            SizedBox(
                              width: 50,
                              child: Padding(
                                padding: const EdgeInsets.only(top: 12),
                                child: Text(
                                  '${item.time.hour.toString().padLeft(2, '0')}:${item.time.minute.toString().padLeft(2, '0')}',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                    color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                                  ),
                                ),
                              ),
                            ),
                            
                            // 2. Timeline Line & Card combined
                            Expanded(
                              child: Stack(
                                clipBehavior: Clip.none,
                                children: [
                                  // The Line Wrapper (Border Left)
                                  Container(
                                    margin: const EdgeInsets.only(left: 13, top: 14),
                                    decoration: BoxDecoration(
                                      border: isLast ? null : Border(
                                        left: BorderSide(
                                          color: isDark ? Colors.white.withValues(alpha: 0.1) : Colors.black.withValues(alpha: 0.05),
                                          width: 2,
                                        ),
                                      ),
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.only(bottom: 24.0, left: 28.0),
                                      child: item.type == AgendaItemType.deadline 
                                        ? _buildDeadlineCard(item.deadline!, courseProvider, isDark)
                                        : item.type == AgendaItemType.event
                                            ? _buildPlannerEventCard(item.event!, isDark)
                                            : _buildCourseCard(item.course!, context, isDark),
                                    ),
                                  ),
                                  
                                  // The Node
                                  Positioned(
                                    left: 7,
                                    top: 14,
                                    child: Container(
                                      width: 14,
                                      height: 14,
                                      decoration: BoxDecoration(
                                        color: item.type == AgendaItemType.deadline 
                                            ? AppColors.red 
                                            : item.type == AgendaItemType.event 
                                                ? item.event!.color 
                                                : (item.course?.color ?? AppColors.primary),
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
                                          width: 3,
                                        ),
                                        boxShadow: [
                                          BoxShadow(
                                            color: (item.type == AgendaItemType.deadline 
                                                ? AppColors.red 
                                                : item.type == AgendaItemType.event 
                                                    ? item.event!.color 
                                                    : (item.course?.color ?? AppColors.primary)).withValues(alpha: 0.5),
                                            blurRadius: 4,
                                            spreadRadius: 1,
                                          ),
                                        ]
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        );
                      },
                      childCount: agenda.length,
                    ),
                  ),
                );
              }
            ),
            
            // Bottom Padding
            const SliverToBoxAdapter(child: SizedBox(height: 100)),
          ],
        );
      },
    );
  }

  Widget _buildCourseCard(Course course, BuildContext context, bool isDark) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => CourseDetailScreen(course: course),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? AppColors.surfaceDark : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: course.color.withValues(alpha: 0.3)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: course.color.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(Icons.school, color: course.color, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    course.name,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                    ),
                  ),
                ),
              ],
            ),
            if (course.location != null) ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(Icons.location_on, size: 14, color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight),
                  const SizedBox(width: 6),
                  Text(
                    course.location!,
                    style: TextStyle(
                      fontSize: 13,
                      color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                    ),
                  ),
                ],
              ),
            ]
          ],
        ),
      ),
    );
  }

  Widget _buildDeadlineCard(Deadline deadline, CourseProvider courseProvider, bool isDark) {
    // Find course for color
    final course = courseProvider.courses.firstWhere(
      (c) => c.id == deadline.courseId,
      orElse: () => courseProvider.courses.isNotEmpty 
          ? courseProvider.courses.first
          : Course(
              id: '', name: 'Unknown', color: Colors.grey, 
              scheduleDays: [], 
              startTime: TimeOfDay.now(), 
              endTime: TimeOfDay.now()
            ), 
    );

    return GestureDetector(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (_) => const DeadlineScreen()));
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? AppColors.surfaceDark : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.red.withValues(alpha: 0.3)),
          boxShadow: [
            BoxShadow(
              color: AppColors.red.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.red.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    deadline.type.name.toUpperCase(),
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      color: AppColors.red,
                    ),
                  ),
                ),
                const Spacer(),
                Icon(Icons.flag, size: 16, color: AppColors.red),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              deadline.title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              course.name,
              style: TextStyle(
                fontSize: 13,
                color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlannerEventCard(PlannerEvent event, bool isDark) {
    IconData icon;
    switch (event.type) {
      case PlannerEventType.study: icon = Icons.menu_book; break;
      case PlannerEventType.meeting: icon = Icons.people; break;
      case PlannerEventType.coffee: icon = Icons.local_cafe; break;
      case PlannerEventType.personal: icon = Icons.person; break;
      case PlannerEventType.other: icon = Icons.event; break;
    }

    return GestureDetector(
      onLongPress: () {
        // Option to delete
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Delete Event?'),
            content: Text('Do you want to delete "${event.title}"?'),
            actions: [
              TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
              TextButton(
                onPressed: () {
                  context.read<PlannerEventProvider>().deleteEvent(event.id);
                  Navigator.pop(ctx);
                },
                child: const Text('Delete', style: TextStyle(color: AppColors.red)),
              ),
            ],
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? AppColors.surfaceDark : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: event.color.withValues(alpha: 0.3)),
          boxShadow: [
            BoxShadow(
              color: event.color.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: event.color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(icon, size: 12, color: event.color),
                      const SizedBox(width: 4),
                      Text(
                        event.type.name.toUpperCase(),
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          color: event.color,
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                Icon(Icons.more_horiz, size: 20, color: isDark ? Colors.grey.shade600 : Colors.grey.shade400),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              event.title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
              ),
            ),
            if (event.notes != null) ...[
              const SizedBox(height: 4),
              Text(
                event.notes!,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 13,
                  color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                ),
              ),
            ],
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.access_time, size: 14, color: isDark ? Colors.grey.shade400 : Colors.grey.shade500),
                const SizedBox(width: 6),
                Text(
                  '${TimeOfDay.fromDateTime(event.startTime).format(context)} - ${TimeOfDay.fromDateTime(event.endTime).format(context)}',
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
