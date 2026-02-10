class Report {
  final int? id;
  final String title;

  Report({this.id, required this.title});

  Map<String, dynamic> toMap() => {'id': id, 'title': title};

  factory Report.fromMap(Map<String, dynamic> map) {
    return Report(id: map['id'], title: map['title']);
  }
}