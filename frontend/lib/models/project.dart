class Project {
  final String id;
  final String title;
  final DateTime createdAt;

  Project({
    required this.id,
    required this.title,
    required this.createdAt,
  });

  factory Project.create(String title) {
    return Project(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      createdAt: DateTime.now(),
    );
  }
} 