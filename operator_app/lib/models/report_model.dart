class Report {
  final int? id;
  final int taskId; // ДОБАВИТЬ
  final String title;
  final String status;
  final String description;
  final int objectId;

  Report({
    this.id, 
    required this.taskId, // ДОБАВИТЬ
    required this.title, 
    this.status = 'draft', 
    required this.description, 
    required this.objectId
  });

  Map<String, dynamic> toMap() => {
    'id': id, 
    'taskId': taskId, // ДОБАВИТЬ
    'title': title, 
    'status' : status,
    'description': description,
    'objectId': objectId,
  };

  factory Report.fromMap(Map<String, dynamic> map) {
    return Report(
      id: map['id'], 
      taskId: map['taskId'] ?? 0, // ДОБАВИТЬ
      title: map['title'],
      status: map['status'] ?? 'draft',
      description: map['description'] ?? '',
      objectId: map['objectId'] ?? 0,
    );
  }
}