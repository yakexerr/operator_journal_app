import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'dart:io';
import 'package:path/path.dart';
import 'package:operator_app/models/calculation_model.dart';

class DBProvider {
  DBProvider._(); // _ означает приватное поле, то есть именованый конструктор теперь приватный
  static final DBProvider db = DBProvider._();
  static Database? _database; // не экземпляро, но переменная которая будет хранит БД

  // Метод для удаления записи
  static Future<int> deleteCalculation(int id) async {
    final db = await database; // получаем базу данных
    return await db.delete(
      'Calculations', // ПРОВЕРЬ: имя таблицы должно совпадать с тем, что в БД
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // async как бы помечает что ф-я умеет работат с future
  static Future<Database> get database async { // "обещает", что в будущем вернёт объект типа Database
    if(_database != null) return _database!;
    _database = await initDB(); // await "распаковывает" рез-т future
    return _database!; // в dart работает Null-safety и при помощи "!" клянёмся что не будет тут null иначе не будет работать
  }

  static Future<Database> initDB() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, DB_NAME);
    return await openDatabase(path, version: 1,
      onCreate: (Database db, int version) async {
        print("--- [DB_PROVIDER] ON_CREATE: Создаю таблицу $CALC_TABLE_NAME ---");
        await db.execute(CREATE_CALC_TABLE);
      }
    );
  }

  static Future<void> newCalculation(Calculation calc) async {
    final db = await database; // Получаем доступ к БД
    // Используем метод toMap() для преобразования объекта в Map
    print("--- [DB_PROVIDER] NEW_CALC: Пытаюсь сохранить: ${calc.toMap()} ---");
    var resultId = await db.insert(
      CALC_TABLE_NAME,
      calc.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace, // Если запись с таким id уже есть - заменить
    );
    print("--- [DB_PROVIDER] NEW_CALC: Сохранение завершено. ID новой записи: $resultId ---");
  }

  static Future<List<Calculation>> getAllCalculations() async {
  final db = await database;
  print("--- [DB_PROVIDER] GET_ALL: Пытаюсь прочитать все из таблицы $CALC_TABLE_NAME ---");
  final List<Map<String, dynamic>> maps = await db.query(CALC_TABLE_NAME);
  print("--- [DB_PROVIDER] GET_ALL: Получено ${maps.length} записей. Вот они: $maps ---");
  return List.generate(maps.length, (i) {
    return Calculation.fromMap(maps[i]);
  });

  
}

  static const String DB_NAME = "operator_journal.db";
  static const String CALC_TABLE_NAME = "Calculations";
  static const String CREATE_CALC_TABLE = '''
    CREATE TABLE $CALC_TABLE_NAME (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      title TEXT NOT NULL,
      result REAL NOT NULL,
      created_at TEXT NOT NULL,
      is_synced INTEGER NOT NULL DEFAULT 0
    )
  ''';


}