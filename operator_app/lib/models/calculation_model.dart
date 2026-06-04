// calculation_model.dart
class Calculation {
  final int? id;
  final String title;
  final double result;
  final String createdAt;
  final int objectId;
  final String formulaId;
  int? reportId;
  // Конструктор
  Calculation({
    this.id,
    required this.title,
    required this.result,
    required this.createdAt,
    required this.objectId,
    required this.formulaId,
    this.reportId,
  });
  // Метод "toMap": превращает объект Calculation в Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'result': result,
      'created_at': createdAt,
      'objectId': objectId,
      'formulaId': formulaId,
      'reportId': reportId
    };
  }
  // Метод "fromMap": превращает Map в объект Calculation.
  factory Calculation.fromMap(Map<String, dynamic> map) {
    return Calculation(
      id: map['id'],
      title: map['title'] ?? '',
      result: (map['result'] as num).toDouble(), 
      createdAt: map['created_at'] ?? '',
      objectId: map['objectId'] ?? 0,
      formulaId: map['formulaId'] ?? '',
      reportId: map['reportId'],
    );
  }
}