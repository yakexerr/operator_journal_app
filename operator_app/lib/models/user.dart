class User {
  final int id;
  final String name;
  final String lastname;
  final String position;
  final String login;
  final String password;
  final int objectId;

  User({
    required this.id,
    required this.name,
    required this.lastname,
    required this.position,
    required this.login,
    required this.password,
    required this.objectId
  });

    // Метод "toMap": превращает объект Calculation в Map.
  // Нужно для сохранения в БД.
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'lastname': lastname,
      'position': position,
      'login': login,
      'password': password,
      'objectId': objectId
    };
  }

  // Метод "fromMap": превращает Map в объект Calculation.
  // Нужно для чтения из БД.
  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'] ?? 0,
      name: map['name'] ?? '',
      lastname: map['lastname'] ?? '',
      position: map['position'] ?? '',
      login: map['login'] ?? '',
      password: map['password'] ?? '',
      objectId: map['objectId'] ?? 0,
    );
  }
}