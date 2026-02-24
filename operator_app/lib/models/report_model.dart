class Report {
  final int? id;
  final String title;
  final String status;
  final String description;

  Report({this.id, required this.title, this.status = 'draft', required this.description});

  Map<String, dynamic> toMap() => {
    'id': id, 
    'title': title,
    'status' : status,
    'description': description,
    };

  factory Report.fromMap(Map<String, dynamic> map) {
    return Report(
      id: map['id'], 
      title: map['title'],
      status: map['status'] ?? 'draft',
      description: map['description'] ?? '',
      );
  }

  
}