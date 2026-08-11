import 'package:freezed_annotation/freezed_annotation.dart';

part 'grade.freezed.dart';

@freezed
abstract class Grade with _$Grade {
  const Grade._();

  const factory Grade({
    required String id,
    required String courseId,
    required String name, // e.g. "Midterm", "Final"
    required double score, // e.g. 85.0
    @Default(100.0) double maxScore, // e.g. 100.0
    required double weight, // e.g. 30.0 (percent)
    required DateTime createdAt,
  }) = _Grade;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'courseId': courseId,
      'name': name,
      'score': score,
      'maxScore': maxScore,
      'weight': weight,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory Grade.fromMap(Map<String, dynamic> map) {
    return Grade(
      id: map['id'] as String,
      courseId: map['courseId'] as String,
      name: map['name'] as String,
      score: (map['score'] as num?)?.toDouble() ?? 0.0,
      maxScore: (map['maxScore'] as num?)?.toDouble() ?? 100.0,
      weight: (map['weight'] as num?)?.toDouble() ?? 0.0,
      createdAt: DateTime.parse(map['createdAt'] as String),
    );
  }
}
