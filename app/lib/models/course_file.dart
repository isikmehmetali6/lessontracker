class CourseFile {
  final String id;
  final String courseId;
  final String path;
  final String name;
  final String type; // 'pdf', 'image', 'other'
  final DateTime createdAt;

  CourseFile({
    required this.id,
    required this.courseId,
    required this.path,
    required this.name,
    required this.type,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'courseId': courseId,
      'path': path,
      'name': name,
      'type': type,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory CourseFile.fromMap(Map<String, dynamic> map) {
    return CourseFile(
      id: map['id'],
      courseId: map['courseId'],
      path: map['path'],
      name: map['name'],
      type: map['type'],
      createdAt: DateTime.parse(map['createdAt']),
    );
  }
}
