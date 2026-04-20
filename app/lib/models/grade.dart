class Grade {
  final String id;
  final String courseId;
  final String name; // e.g. "Midterm", "Final"
  final double score; // e.g. 85.0
  final double maxScore; // e.g. 100.0
  final double weight; // e.g. 30.0 (percent)
  final DateTime createdAt;

  Grade({
    required this.id,
    required this.courseId,
    required this.name,
    required this.score,
    this.maxScore = 100.0,
    required this.weight,
    required this.createdAt,
  });

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

  Grade copyWith({
    String? id,
    String? courseId,
    String? name,
    double? score,
    double? maxScore,
    double? weight,
    DateTime? createdAt,
  }) {
    return Grade(
      id: id ?? this.id,
      courseId: courseId ?? this.courseId,
      name: name ?? this.name,
      score: score ?? this.score,
      maxScore: maxScore ?? this.maxScore,
      weight: weight ?? this.weight,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is Grade && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
