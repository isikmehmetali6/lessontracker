class CourseFile {
  final String id;
  final String courseId;
  final String path;
  final String name;
  final String type; // 'pdf', 'image', 'other'
  final DateTime createdAt;
  final String? url;
  final String? cloudPath;

  CourseFile({
    required this.id,
    required this.courseId,
    required this.path,
    required this.name,
    required this.type,
    required this.createdAt,
    this.url,
    this.cloudPath,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'courseId': courseId,
      'path': path,
      'name': name,
      'type': type,
      'createdAt': createdAt.toIso8601String(),
      'url': url,
      'cloudPath': cloudPath,
    };
  }

  factory CourseFile.fromMap(Map<String, dynamic> map) {
    return CourseFile(
      id: map['id'] as String,
      courseId: map['courseId'] as String,
      path: map['path'] as String,
      name: map['name'] as String,
      type: map['type'] as String,
      createdAt: DateTime.parse(map['createdAt'] as String),
      url: map['url'] as String?,
      cloudPath: map['cloudPath'] as String?,
    );
  }

  CourseFile copyWith({
    String? id,
    String? courseId,
    String? path,
    String? name,
    String? type,
    DateTime? createdAt,
    String? url,
    String? cloudPath,
  }) {
    return CourseFile(
      id: id ?? this.id,
      courseId: courseId ?? this.courseId,
      path: path ?? this.path,
      name: name ?? this.name,
      type: type ?? this.type,
      createdAt: createdAt ?? this.createdAt,
      url: url ?? this.url,
      cloudPath: cloudPath ?? this.cloudPath,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CourseFile && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
