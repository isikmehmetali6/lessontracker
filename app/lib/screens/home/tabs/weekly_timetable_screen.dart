import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../providers/course_provider.dart';
import '../../course_detail/course_detail_screen.dart';

class WeeklyTimetableScreen extends StatefulWidget {
  const WeeklyTimetableScreen({super.key});

  @override
  State<WeeklyTimetableScreen> createState() => _WeeklyTimetableScreenState();
}

class _WeeklyTimetableScreenState extends State<WeeklyTimetableScreen> {
  final double _hourHeight = 60.0;
  final double _timeColumnWidth = 50.0;
  final int _startHour = 8;
  final int _endHour = 22;

  late final ScrollController _scrollController;
  
  // To highlight today
  final int _todayWeekday = DateTime.now().weekday - 1; // 0=Mon, 6=Sun

  @override
  void initState() {
    super.initState();
    // Start scrolled to a reasonable time (e.g. 08:00 is at top, maybe scroll a bit if needed)
    _scrollController = ScrollController();
    Future.microtask(() {
       // Optional: Scroll to current time
       final currentHour = DateTime.now().hour;
       if (currentHour > _startHour && currentHour < _endHour) {
         final offset = (currentHour - _startHour) * _hourHeight - 100; // -100 to show some context above
         if (offset > 0 && _scrollController.hasClients) {
            _scrollController.jumpTo(offset);
         }
       }
    });
  }
  
  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final weekDays = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : const Color(0xFFF5F7FA), // Light grey bg for grid
      appBar: AppBar(
        title: Text(
          'Weekly Timetable',
          style: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 24,
            color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
      ),
      body: Consumer<CourseProvider>(
        builder: (context, provider, _) {
          final courses = provider.courses;

          return Column(
            children: [
              // Header Days Row
              Container(
                margin: EdgeInsets.only(left: _timeColumnWidth),
                padding: const EdgeInsets.only(bottom: 8),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: isDark ? Colors.grey.shade800 : Colors.grey.shade300,
                    ),
                  ),
                ),
                child: Row(
                  children: List.generate(7, (index) {
                    final isToday = index == _todayWeekday;
                    return Expanded(
                      child: Column(
                        children: [
                          Text(
                            weekDays[index],
                            style: TextStyle(
                              color: isToday 
                                  ? AppColors.primary 
                                  : (isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight),
                              fontWeight: isToday ? FontWeight.bold : FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Container(
                            width: 24,
                            height: 24,
                            decoration: isToday ? const BoxDecoration(
                              color: AppColors.primary,
                              shape: BoxShape.circle,
                            ) : null,
                            alignment: Alignment.center,
                            child: Text(
                               _getDateForWeekday(index).day.toString(),
                               style: TextStyle(
                                 fontSize: 12,
                                 fontWeight: FontWeight.bold,
                                 color: isToday 
                                     ? Colors.white 
                                     : (isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight),
                               ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                ),
              ),

              // Timetable Grid
              Expanded(
                child: SingleChildScrollView(
                  controller: _scrollController,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Time Column
                      SizedBox(
                        width: _timeColumnWidth,
                        child: Column(
                          children: List.generate(_endHour - _startHour + 1, (index) {
                            final hour = _startHour + index;
                            return SizedBox(
                              height: _hourHeight,
                              child: Transform.translate(
                                offset: const Offset(0, -8), // Align text with line
                                child: Text(
                                  '$hour:00',
                                  textAlign: TextAlign.right,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                                  ),
                                ),
                              ),
                            );
                          }),
                        ),
                      ),

                      // Grid Body
                      Expanded(
                        child: LayoutBuilder(
                          builder: (context, constraints) {
                            final columnWidth = constraints.maxWidth / 7;
                            final totalHeight = (_endHour - _startHour) * _hourHeight;

                            return SizedBox(
                              height: totalHeight + _hourHeight, // buffer
                              child: Stack(
                                children: [
                                  // Horizontal Lines
                                  ...List.generate(_endHour - _startHour + 1, (index) {
                                      return Positioned(
                                        top: index * _hourHeight,
                                        left: 0,
                                        right: 0,
                                        child: Divider(
                                          height: 1,
                                          color: isDark ? Colors.grey.shade800 : Colors.grey.shade300,
                                        ),
                                      );
                                  }),

                                  // Vertical Lines (Optional, maybe lighter)
                                  ...List.generate(7, (index) {
                                      return Positioned(
                                        top: 0,
                                        bottom: 0,
                                        left: index * columnWidth,
                                        child: VerticalDivider(
                                          width: 1,
                                          color: isDark ? Colors.grey.shade900 : Colors.grey.shade200,
                                        ),
                                      );
                                  }),
                                  
                                  // Current Time Indicator (Red Line)
                                  _buildCurrentTimeIndicator(columnWidth),

                                  // Courses
                                  ...courses.expand((course) {
                                    return course.scheduleDays.map((dayIndex) {
                                      // Calculate Position
                                      final startMinutes = (course.startTime.hour - _startHour) * 60 + course.startTime.minute;
                                      final durationMinutes = (course.endTime.hour * 60 + course.endTime.minute) - (course.startTime.hour * 60 + course.startTime.minute);
                                      
                                      final top = (startMinutes / 60) * _hourHeight;
                                      final height = (durationMinutes / 60) * _hourHeight;
                                      final left = dayIndex * columnWidth;

                                      if (top < 0) return const SizedBox(); // Before start time

                                      return Positioned(
                                        top: top,
                                        left: left + 2, // padding
                                        width: columnWidth - 4,
                                        height: height,
                                        child: GestureDetector(
                                          onTap: () {
                                            Navigator.push(
                                              context, 
                                              MaterialPageRoute(builder: (_) => CourseDetailScreen(course: course))
                                            );
                                          },
                                          child: Container(
                                            padding: const EdgeInsets.all(4),
                                            decoration: BoxDecoration(
                                              color: course.color.withValues(alpha: 0.9),
                                              borderRadius: BorderRadius.circular(8),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Colors.black.withValues(alpha: 0.2),
                                                  blurRadius: 4,
                                                  offset: const Offset(0, 2),
                                                ),
                                              ],
                                            ),
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Text(
                                                  course.name,
                                                  maxLines: 2, // Allow wrapping
                                                  overflow: TextOverflow.ellipsis,
                                                  style: const TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 10,
                                                    fontWeight: FontWeight.bold,
                                                    height: 1.1,
                                                  ),
                                                ),
                                                if (height > 40) ...[
                                                  const SizedBox(height: 2),
                                                  Text(
                                                    course.location ?? '',
                                                    maxLines: 1,
                                                    overflow: TextOverflow.ellipsis,
                                                    style: TextStyle(
                                                      color: Colors.white.withValues(alpha: 0.9),
                                                      fontSize: 8,
                                                    ),
                                                  ),
                                                ]
                                              ],
                                            ),
                                          ),
                                        ),
                                      );
                                    });
                                  }),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildCurrentTimeIndicator(double columnWidth) {
    if (_todayWeekday < 0 || _todayWeekday > 6) return const SizedBox();
    
    final now = DateTime.now();
    final minutesSinceStart = (now.hour - _startHour) * 60 + now.minute;
    
    if (minutesSinceStart < 0) return const SizedBox();

    final top = (minutesSinceStart / 60) * _hourHeight;
    final left = _todayWeekday * columnWidth;

    return Positioned(
      top: top,
      left: 0,
      right: 0,
      child: Row(
        children: [
          // Left of day
          SizedBox(width: left),
          // Dot
          Container(
            width: 8, // slightly overlapping left
            height: 8,
            margin: const EdgeInsets.only(left: 0), 
            decoration: const BoxDecoration(
              color: AppColors.red,
              shape: BoxShape.circle,
            ),
          ),
          // Line through day
          Container(
            width: columnWidth, // width calculation might need small adjustment
            height: 2,
            color: AppColors.red,
          ),
        ],
      ),
    );
  }

  DateTime _getDateForWeekday(int weekdayIndex) {
    // 0 = mon, 6 = sun
    // Find monday of this week
    final now = DateTime.now();
    final currentWeekday = now.weekday - 1; // 0=mon
    final diff = weekdayIndex - currentWeekday;
    return now.add(Duration(days: diff));
  }
}
