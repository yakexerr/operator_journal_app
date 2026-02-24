class EquipmentObject {
  final int? id;
  final String name;
  final String type;

  // Конструктор
  EquipmentObject({
    this.id,
    required this.name,
    required this.type,
  });

  // Метод "toMap": превращает объект в Map
  // Нужно для сохранения в БД
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'type': type,
    };
  }

  // Метод "fromMap": превращает Map в объект 
  // Нужно для чтения из БД
  factory EquipmentObject.fromMap(Map<String, dynamic> map) {
    return EquipmentObject(
      id: map['id'],
      name: map['name'],
      type: map['type'],
    );
  }
}