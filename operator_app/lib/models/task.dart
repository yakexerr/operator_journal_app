class Task {
  final int id;
  final String title;
  final String objectName;
  final int objectId;
  final String description;
  final String createdAt;

  Task({
    required this.id,
    required this.title,
    required this.objectName,
    required this.objectId,
    this.description = "",
    required this.createdAt,
  });

    // Метод "toMap": превращает объект Calculation в Map.
  // Нужно для сохранения в БД.
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'objectName': objectName,
      'created_at': createdAt,
      'objectId': objectId,
      'description': description,
    };
  }

  // Метод "fromMap": превращает Map в объект Calculation.
  // Нужно для чтения из БД.
  factory Task.fromMap(Map<String, dynamic> map) {
    return Task(
      id: map['id'],
      title: map['title'],
      objectName: map['objectName'],
      createdAt: map['created_at'] ?? DateTime.now().toIso8601String(),
      objectId: map['objectId'] ?? 1,
      description: map['description'],
    );
  }
}