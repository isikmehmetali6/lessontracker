import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:lesson_tracker/core/theme/app_colors.dart';
import 'package:lesson_tracker/models/course.dart';
import 'package:lesson_tracker/providers/course_provider.dart';
import 'package:lesson_tracker/providers/deadline_provider.dart';
import 'package:lesson_tracker/screens/course_detail/course_detail_screen.dart';

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

    return Consumer2<CourseProvider, DeadlineProvider>(
      builder: (context, courseProvider, deadlineProvider, _) {
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
                child: Column(
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
            
            // --- DEADLINES SECTION ---
            if (deadlines.isNotEmpty) ...[
               SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 8, 24, 8),
                  child: Row(
                    children: [
                       Icon(Icons.flag, size: 18, color: AppColors.red),
                        const SizedBox(width: 8),
                       const Text(
                        'Deadlines',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.red,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final deadline = deadlines[index];
                      // Find course for color
                      final course = courseProvider.courses.firstWhere(
                        (c) => c.id == deadline.courseId,
                        orElse: () => courseProvider.courses.isNotEmpty 
                            ? courseProvider.courses.first
                            : Course(
                                id: '', name: '', color: Colors.grey, 
                                scheduleDays: [], 
                                startTime: TimeOfDay.now(), 
                                endTime: TimeOfDay.now()
                              ), 
                      );
                      
                      return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: isDark ? AppColors.surfaceDark : Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border(left: BorderSide(color: AppColors.red, width: 4)),
                          ),
                          child: Row(
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    deadline.title,
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                      color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                                    ),
                                  ),
                                  Text(
                                    course.name,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                                    ),
                                  ),
                                ],
                              ),
                              const Spacer(),
                              Text(
                                deadline.type.name.toUpperCase(),
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                  color: AppColors.red,
                                ),
                              ),
                            ],
                          ),
                      );
                    },
                    childCount: deadlines.length,
                  ),
                ),
              ),
            ],

            // --- COURSES SECTION ---
            if (courses.isNotEmpty) ...[
               SliverToBoxAdapter(
                 child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
                  child: Row(
                    children: [
                       Icon(Icons.class_, size: 18, color: AppColors.primary),
                       const SizedBox(width: 8),
                       Text(
                        'Classes',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 100),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final course = courses[index];
                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => CourseDetailScreen(course: course),
                            ),
                          );
                        },
                        child: Hero(
                          tag: 'course_${course.id}_plan', // Unique tag for plan screen
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: isDark ? AppColors.surfaceDark : Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              border: Border(
                                left: BorderSide(
                                  color: course.color,
                                  width: 4,
                                ),
                              ),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 48,
                                  height: 48,
                                  decoration: BoxDecoration(
                                    color: course.color.withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Icon(
                                    Icons.school,
                                    color: course.color,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        course.name,
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                          decoration: TextDecoration.none,
                                          color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        '${course.startTime.format(context)} - ${course.endTime.format(context)}',
                                        style: TextStyle(
                                          fontSize: 13,
                                           decoration: TextDecoration.none,
                                          color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                if (course.location != null)
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: isDark ? Colors.black26 : Colors.grey.shade100,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Row(
                                      children: [
                                        Icon(Icons.location_on, size: 14, color: isDark ? Colors.grey.shade400 : Colors.grey.shade600),
                                        const SizedBox(width: 4),
                                        Text(
                                          course.location!,
                                          style: TextStyle(
                                            fontSize: 12,
                                             decoration: TextDecoration.none,
                                            color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                    childCount: courses.length,
                  ),
                ),
              ),
            ] else if (deadlines.isEmpty) ...[
                 // EMPTY STATE FOR BOTH
                 SliverToBoxAdapter(
                      child: Container(
                        padding: const EdgeInsets.all(32),
                        margin: const EdgeInsets.only(top: 24, left: 24, right: 24),
                        decoration: BoxDecoration(
                          color: isDark ? AppColors.surfaceDark : Colors.white,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Column(
                          children: [
                            Icon(
                              Icons.event_available,
                              size: 64,
                              color: isDark ? Colors.grey.shade600 : Colors.grey.shade300,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Nothing scheduled',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Enjoy your free time!',
                              style: TextStyle(
                                fontSize: 14,
                                color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
            ],
            
            // Bottom Padding
            const SliverToBoxAdapter(child: SizedBox(height: 100)),
          ],
        );
      },
    );
  }
}
