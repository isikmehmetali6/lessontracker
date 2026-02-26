import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'course.freezed.dart';

/// Ders modeli
@freezed
abstract class Course with _$Course {
  const Course._();

  const factory Course({
    required String id,
    required String name,
    String? subtitle,
    String? professor,
    String? location,
    required Color color,
    required List<int> scheduleDays, // 0 = Pazartesi, 6 = Pazar
    required TimeOfDay startTime,
    required TimeOfDay endTime,
    @Default(3) int absenceLimit,
    @Default(0) int currentAbsences,
    @Default(0.0) double progress,
    String? iconName,
    DateTime? createdAt,
    DateTime? nextExamDate,
    @Default(3) int credits,
    @Default('active') String status, // 'active', 'completed', 'archived'
    @Default([]) List<DateTime> absenceDates,
    double? latitude,
    double? longitude,
  }) = _Course;

  /// Bugün bu ders var mı?
  bool get isScheduledToday {
    final today = DateTime.now().weekday - 1; // 0 = Pazartesi
    return scheduleDays.contains(today);
  }

  /// Devamsızlık limiti aşıldı mı?
  bool get isAbsenceLimitExceeded => currentAbsences >= absenceLimit;

  /// Geri mi kalınmış?
  bool get isBehind => progress < 50.0 && status == 'active';

  /// Sınav yaklaşıyor mu?
  bool get hasUpcomingExam {
    if (nextExamDate == null) return false;
    final daysUntilExam = nextExamDate!.difference(DateTime.now()).inDays;
    return daysUntilExam >= 0 && daysUntilExam <= 7;
  }

  /// Map'e dönüştür (veritabanı için)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'subtitle': subtitle,
      'professor': professor,
      'location': location,
      'color': color.toARGB32(), // Use toARGB32() instead of value in newer Flutter
      'scheduleDays': scheduleDays.join(','),
      'startTimeHour': startTime.hour,
      'startTimeMinute': startTime.minute,
      'endTimeHour': endTime.hour,
      'endTimeMinute': endTime.minute,
      'absenceLimit': absenceLimit,
      'currentAbsences': currentAbsences,
      'progress': progress,
      'iconName': iconName,
      'createdAt': (createdAt ?? DateTime.now()).toIso8601String(),
      'nextExamDate': nextExamDate?.toIso8601String(),
      'credits': credits,
      'status': status,
      'latitude': latitude,
      'longitude': longitude,
      // absenceDates is stored in separate table, not here
    };
  }

  /// Map'ten oluştur
  factory Course.fromMap(Map<String, dynamic> map) {
    return Course(
      id: map['id'] as String,
      name: map['name'] as String,
      subtitle: map['subtitle'] as String?,
      professor: map['professor'] as String?,
      location: map['location'] as String?,
      color: Color(map['color'] as int),
      scheduleDays: (map['scheduleDays'] as String)
          .split(',')
          .where((s) => s.isNotEmpty)
          .map((s) => int.parse(s))
          .toList(),
      startTime: TimeOfDay(
        hour: map['startTimeHour'] as int,
        minute: map['startTimeMinute'] as int,
      ),
      endTime: TimeOfDay(
        hour: map['endTimeHour'] as int,
        minute: map['endTimeMinute'] as int,
      ),
      absenceLimit: map['absenceLimit'] as int,
      currentAbsences: map['currentAbsences'] as int,
      progress: (map['progress'] as num).toDouble(),
      iconName: map['iconName'] as String?,
      createdAt: DateTime.parse(map['createdAt'] as String),
      nextExamDate: map['nextExamDate'] != null
          ? DateTime.parse(map['nextExamDate'] as String)
          : null,
      credits: map['credits'] as int,
      status: map['status'] as String,
      absenceDates: const [], // Populated separately or via join
      latitude: map['latitude'] as double?,
      longitude: map['longitude'] as double?,
    );
  }
}
