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
      id: map['id'],
      courseId: map['courseId'],
      name: map['name'],
      score: map['score']?.toDouble() ?? 0.0,
      maxScore: map['maxScore']?.toDouble() ?? 100.0,
      weight: map['weight']?.toDouble() ?? 0.0,
      createdAt: DateTime.parse(map['createdAt']),
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
}
