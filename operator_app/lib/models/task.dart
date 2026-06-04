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

    // Метод "toMap": превращает объект Calculation в Map
  // Нужно для сохранения в БД
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

  // Метод "fromMap": превращает Map в объект Calculation
  // Нужно для чтения из БД
  factory Task.fromMap(Map<String, dynamic> map) {
    return Task(
      // пытаемся взять taskId, если нет - id, если нет - 0
      id: map['taskId'] ?? map['id'] ?? 0, 
      
      title: map['title'] ?? 'Без названия',
      
      // если названия объекта нет, пишем его ID
      objectName: map['objectName'] ?? "Объект №${map['objectId']}", 
      
      // если даты нет, ставим текущую (в формате UTC, как просил препод)
      createdAt: map['created_at'] ?? DateTime.now().toUtc().toIso8601String(),
      
      objectId: map['objectId'] ?? 0,
      description: map['description'] ?? '',
    );
  }
}