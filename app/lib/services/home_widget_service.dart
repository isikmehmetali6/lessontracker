import 'package:flutter/material.dart';
import 'dart:io';
import 'package:home_widget/home_widget.dart';
import '../../models/course.dart';
import '../../models/deadline.dart';

import 'package:flutter/foundation.dart';

class HomeWidgetService {
  static const String appGroupId = 'group.com.lessontracker.app';
  static const String iOSWidgetName = 'LessonTrackerWidget';
  static const String androidWidgetName = 'LessonTrackerWidget';

  /// Bir sonraki ders bilgisini widget'a gönderir
  static Future<void> updateNextLesson(Course? nextCourse) async {
    if (kIsWeb) return;
    if (Platform.isMacOS || Platform.isLinux || Platform.isWindows) return;
    try {
      if (Platform.isIOS) {
        await HomeWidget.setAppGroupId(appGroupId);
      }
      
      if (nextCourse != null) {
        await HomeWidget.saveWidgetData<String>('courseName', nextCourse.name);
        await HomeWidget.saveWidgetData<String>('courseLocation', nextCourse.location ?? 'Online/Unknown');
        await HomeWidget.saveWidgetData<String>('courseTime', 
          '${_formatTime(nextCourse.startTime)} - ${_formatTime(nextCourse.endTime)}');
        await HomeWidget.saveWidgetData<String>('courseColor', nextCourse.color.toARGB32().toRadixString(16));
        await HomeWidget.saveWidgetData<bool>('hasCourse', true);
      } else {
        await HomeWidget.saveWidgetData<String>('courseName', 'No upcoming classes');
        await HomeWidget.saveWidgetData<String>('courseLocation', '');
        await HomeWidget.saveWidgetData<String>('courseTime', 'Relax & Recharge');
        await HomeWidget.saveWidgetData<bool>('hasCourse', false);
      }
      
      await HomeWidget.updateWidget(
        iOSName: iOSWidgetName,
        androidName: androidWidgetName,
      );
      
      debugPrint('Widget Updated for: ${nextCourse?.name ?? "No Course"}');
    } catch (e) {
      debugPrint('Error updating widget: $e');
    }
  }

  /// Yaklaşan deadline'ları widget'a gönder
  static Future<void> updateDeadlines(List<Deadline> deadlines) async {
    if (kIsWeb) return;
    if (Platform.isMacOS || Platform.isLinux || Platform.isWindows) return;
    try {
      if (Platform.isIOS) {
        await HomeWidget.setAppGroupId(appGroupId);
      }
      
      final upcoming = deadlines.where((d) {
        final daysLeft = d.date.difference(DateTime.now()).inDays;
        return daysLeft >= 0 && daysLeft <= 7;
      }).take(3).toList();

      await HomeWidget.saveWidgetData<int>('deadlineCount', upcoming.length);
      for (var i = 0; i < 3; i++) {
        if (i < upcoming.length) {
          final d = upcoming[i];
          final daysLeft = d.date.difference(DateTime.now()).inDays;
          await HomeWidget.saveWidgetData<String>('deadline${i}Title', d.title);
          await HomeWidget.saveWidgetData<String>('deadline${i}Days', '${daysLeft}d');
        } else {
          await HomeWidget.saveWidgetData<String>('deadline${i}Title', '');
          await HomeWidget.saveWidgetData<String>('deadline${i}Days', '');
        }
      }

      await HomeWidget.updateWidget(
        iOSName: iOSWidgetName,
        androidName: androidWidgetName,
      );
    } catch (e) {
      debugPrint('Error updating deadline widget: $e');
    }
  }

  /// Bugünkü çalışma süresini widget'a gönder
  static Future<void> updateStudyTime(int minutesToday) async {
    if (kIsWeb) return;
    if (Platform.isMacOS || Platform.isLinux || Platform.isWindows) return;
    try {
      if (Platform.isIOS) {
        await HomeWidget.setAppGroupId(appGroupId);
      }
      
      final hours = minutesToday ~/ 60;
      final mins = minutesToday % 60;
      await HomeWidget.saveWidgetData<String>('studyTime', '${hours}h ${mins}m');
      await HomeWidget.saveWidgetData<int>('studyMinutes', minutesToday);

      await HomeWidget.updateWidget(
        iOSName: iOSWidgetName,
        androidName: androidWidgetName,
      );
    } catch (e) {
      debugPrint('Error updating study time widget: $e');
    }
  }

  static String _formatTime(TimeOfDay time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }
}
