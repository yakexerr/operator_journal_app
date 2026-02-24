// тут типа переводчика для данных в SQLite (он глупенький и кроме текст (TEXT), числа (INTEGER, REAL)) 
// ничего не знает
class Calculation {
  final int? id; // id может быть null до сохранения в БД
  final String title;
  final double result;
  final String createdAt;
  final int objectId;
  final String formulaId; // добавил - тут будет, например, "pump_efficiency"
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

  // Метод "toMap": превращает объект Calculation в Map.
  // Нужно для сохранения в БД.
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
  // Нужно для чтения из БД.
  factory Calculation.fromMap(Map<String, dynamic> map) {
    return Calculation(
      id: map['id'],
      title: map['title'],
      result: map['result'],
      createdAt: map['created_at'],
      objectId: map['objectId'],
      formulaId: map['formulaId'],
      reportId: map['reportId']
    );
  }
}