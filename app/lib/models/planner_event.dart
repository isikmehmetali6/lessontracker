import 'package:flutter/material.dart';

enum PlannerEventType { study, meeting, coffee, personal, other }

class PlannerEvent {
  final String id;
  final String title;
  final PlannerEventType type;
  final DateTime startTime;
  final DateTime endTime;
  final Color color;
  final String? notes;

  PlannerEvent({
    required this.id,
    required this.title,
    required this.type,
    required this.startTime,
    required this.endTime,
    required this.color,
    this.notes,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'type': type.index,
      'startTime': startTime.toIso8601String(),
      'endTime': endTime.toIso8601String(),
      'color': color.toARGB32(),
      'notes': notes,
    };
  }

  factory PlannerEvent.fromMap(Map<String, dynamic> map) {
    return PlannerEvent(
      id: map['id'],
      title: map['title'],
      type: PlannerEventType.values[map['type'] as int? ?? 4],
      startTime: DateTime.parse(map['startTime']),
      endTime: DateTime.parse(map['endTime']),
      color: Color(map['color'] as int? ?? Colors.blue.toARGB32()),
      notes: map['notes'],
    );
  }

  PlannerEvent copyWith({
    String? id,
    String? title,
    PlannerEventType? type,
    DateTime? startTime,
    DateTime? endTime,
    Color? color,
    String? notes,
  }) {
    return PlannerEvent(
      id: id ?? this.id,
      title: title ?? this.title,
      type: type ?? this.type,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      color: color ?? this.color,
      notes: notes ?? this.notes,
    );
  }
}
