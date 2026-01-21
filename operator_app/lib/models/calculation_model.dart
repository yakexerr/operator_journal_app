// тут типа переводчика для данных в SQLite (он глупенький и кроме текст (TEXT), числа (INTEGER, REAL)) 
// ничего не знает
class Calculation {
  int? id; // id может быть null до сохранения в БД
  String title;
  double result;
  String createdAt;
  int isSynced;

  // Конструктор
  Calculation({
    this.id,
    required this.title,
    required this.result,
    required this.createdAt,
    this.isSynced = 0, // По умолчанию 0
  });

  // Метод "toMap": превращает объект Calculation в Map.
  // Нужно для сохранения в БД.
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'result': result,
      'created_at': createdAt,
      'is_synced': isSynced,
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
      isSynced: map['is_synced'],
    );
  }
}