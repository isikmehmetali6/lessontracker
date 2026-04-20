import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../providers/course_provider.dart';
import '../../models/course.dart';
import 'package:lesson_tracker/l10n/app_localizations.dart';

class NotificationSettingsScreen extends StatelessWidget {
  const NotificationSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          AppLocalizations.of(context)!.notifications,
          style: TextStyle(
            color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
            fontWeight: FontWeight.w700,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Consumer<CourseProvider>(
        builder: (context, provider, _) {
          return ListView(
            padding: const EdgeInsets.all(24),
            children: [
              // Master Switch
              _buildSection(
                context: context,
                isDark: isDark,
                title: 'General',
                children: [
                   SwitchListTile.adaptive(
                    title: Text(
                      AppLocalizations.of(context)!.notifications,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                      ),
                    ),
                    subtitle: Text(
                      'Turn off all app notifications',
                      style: TextStyle(
                         color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                         fontSize: 13,
                      ),
                    ),
                    value: provider.notificationsEnabled,
                    activeTrackColor: AppColors.primary,
                    onChanged: (value) {
                      provider.toggleNotifications(value);
                    },
                    contentPadding: EdgeInsets.zero,
                  ),
                ],
              ),
              
              const SizedBox(height: 24),
              
              if (provider.notificationsEnabled) ...[
                // Reminder Timing
                _buildSection(
                  context: context, 
                  isDark: isDark, 
                  title: 'Reminder Timing',
                  children: [
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(
                        'Remind me before class',
                         style: TextStyle(
                            fontWeight: FontWeight.w500,
                             color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                         ),
                      ),
                      trailing: DropdownButton<int>(
                        value: provider.reminderMinutes,
                        dropdownColor: isDark ? AppColors.surfaceDark : Colors.white,
                        underline: const SizedBox(),
                        items: const [
                          DropdownMenuItem(value: 5, child: Text('5 minutes')),
                          DropdownMenuItem(value: 10, child: Text('10 minutes')),
                          DropdownMenuItem(value: 15, child: Text('15 minutes')),
                          DropdownMenuItem(value: 30, child: Text('30 minutes')),
                          DropdownMenuItem(value: 60, child: Text('1 hour')),
                          DropdownMenuItem(value: 120, child: Text('2 hours')),
                        ],
                        onChanged: (value) {
                          if (value != null) {
                            provider.setReminderMinutes(value);
                          }
                        },
                      ),
                    ),
                  ]
                ),
                
                 const SizedBox(height: 24),
                 
                 _buildSection(
                    context: context,
                    isDark: isDark,
                    title: 'Course Customization',
                    children: [
                       ...provider.courses.map((course) {
                         return SwitchListTile.adaptive(
                           title: Text(
                             course.name,
                             style: TextStyle(
                               fontWeight: FontWeight.w500,
                               color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                             ),
                           ),
                           subtitle: Text(
                              _getNotificationTime(course, provider.reminderMinutes),
                              style: TextStyle(
                                fontSize: 12,
                                color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                              ),
                           ),
                           value: !provider.isCourseMuted(course.id),
                           activeTrackColor: course.color,
                           onChanged: (val) {
                             provider.toggleCourseMute(course.id);
                           },
                           contentPadding: EdgeInsets.zero,
                         );
                       }),
                    ],
                 ),
              ],
            ],
          );
        },
      ),
    );
  }

  String _getNotificationTime(Course course, int minutesBefore) {
     int h = course.startTime.hour;
     int m = course.startTime.minute - minutesBefore;
     while (m < 0) {
       m += 60;
       h -= 1;
     }
     if (h < 0) h += 24;
     final timeStr = '${h.toString().padLeft(2,'0')}:${m.toString().padLeft(2,'0')}';
     return 'Alert at $timeStr';
  }

  Widget _buildSection({
    required BuildContext context, 
    required bool isDark, 
    required String title, 
    required List<Widget> children
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title.toUpperCase(),
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.2,
            color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDark ? AppColors.surfaceDark : Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: children,
          ),
        ),
      ],
    );
  }
}
