import 'package:operator_app/models/report_model.dart';
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

  static Future<List<Report>> getAllReports() async {
    final db = await database;
    final maps = await db.query(REPORTS_TABLE_NAME);
    return List.generate(maps.length, (i) => Report.fromMap(maps[i]));
  }

  static Future<void> addCalculationsToReport(List<int> calculationIds, int reportId) async {
    final db = await database;
    // SQL-команда UPDATE, которая для всех нужных id проставит report_id
    await db.update(
      CALC_TABLE_NAME,
      {'report_id': reportId},
      where: 'id IN (${calculationIds.map((_) => '?').join(',')})',
      whereArgs: calculationIds,
    );
  }

  static Future<double> getConstantByName(String name) async {
  final db = await database;
  
  final List<Map<String, dynamic>> result = await db.rawQuery(
    'SELECT * FROM $CONSTS_TABLE_NAME WHERE name = ?', [name]
  );

  if (result.isNotEmpty) {
    return result.first['value'] as double;
  } else {
    throw Exception('Константа с именем $name не найдена в базе данных');
  }
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

    print("--- [DB_PROVIDER] ПУТЬ К БАЗЕ ДАННЫХ: $path ---");

    return await openDatabase(path, version: 1,
      onCreate: (Database db, int version) async {

        print("--- [DB_PROVIDER] ON_CREATE: Создаю таблицу $CALC_TABLE_NAME ---");
        await db.execute(CREATE_CALC_TABLE);
        await db.execute(CREATE_REPORTS_TABLE);

        print("--- [DB_PROVIDER] ON_CREATE: Создаю таблицу $CONSTS_TABLE_NAME ---");
        await db.execute(CONSTS_TABLE);

        print("--- [DB_PROVIDER] ON_CREATE: Заплняю таблицы данными ---");
        await db.execute(g_insert_query);
        await db.execute(pi_insert_query);
        await db.execute(usniversal_gas_constant);

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

  // Внутри класса DBProvider

  static Future<void> deleteCalculations(List<int> ids) async {
    // Если список ID пуст, ничего не делаем
    if (ids.isEmpty) return;

    final db = await database;
    
    // SQL-запрос будет выглядеть как 'DELETE FROM Calculations WHERE id IN (?, ?, ?)'
    await db.delete(
      CALC_TABLE_NAME,
      // Создаем строку 'id IN (?,?,?)' с нужным количеством знаков вопроса
      where: 'id IN (${ids.map((_) => '?').join(',')})',
      whereArgs: ids,
    );
  }

  static const String DB_NAME = "operator_journal.db";
  static const String CALC_TABLE_NAME = "Calculations";
  static const String CREATE_CALC_TABLE = '''
    CREATE TABLE $CALC_TABLE_NAME (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      title TEXT NOT NULL,
      result REAL NOT NULL,
      created_at TEXT NOT NULL,
      is_synced INTEGER NOT NULL DEFAULT 0,
      report_id INTEGER NULL -- <-- НОВАЯ КОЛОНКА (может быть пустой)
    )
  ''';
  static const String CONSTS_TABLE_NAME = 'Constants';
  static const String CONSTS_TABLE = '''
  CREATE TABLE $CONSTS_TABLE_NAME (
  name TEXT PRIMARY KEY,
  value REAL NOT NULL
  )
  ''';

  // --- инсерты ---
  static const String g_insert_query = '''
  INSERT INTO $CONSTS_TABLE_NAME (name, value) VALUES ('g', ${9.81})
  ''';

  static const String pi_insert_query = '''
  INSERT INTO $CONSTS_TABLE_NAME (name, value) VALUES ('pi', ${3.14159}) 
  ''';

  static const String usniversal_gas_constant = '''
  INSERT INTO $CONSTS_TABLE_NAME (name, value) VALUES ('R', ${8.314})
  ''';



  // ----- ОТЧЁТЫ
  static const String REPORTS_TABLE_NAME = "Reports";
  static const String CREATE_REPORTS_TABLE = '''
    CREATE TABLE $REPORTS_TABLE_NAME (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      title TEXT NOT NULL,
      status TEXT NOT NULL DEFAULT 'draft'
    )
  ''';



  static Future<void> deleteReport(int id) async {
    final db = await database;
    await db.delete(
      REPORTS_TABLE_NAME,
      where: 'id = ?',
      whereArgs: [id],
    );
    print("--- [DB_PROVIDER] Успешно удален отчет с ID: $id ---");
  }

  static Future<void> deleteReports(List<int> ids) async {
    // Если список ID пуст, ничего не делаем
    if (ids.isEmpty) return;

    final db = await database;
    
    // SQL-запрос будет выглядеть как 'DELETE FROM Calculations WHERE id IN (?, ?, ?)'
    await db.delete(
      REPORTS_TABLE_NAME,
      // Создаем строку 'id IN (?,?,?)' с нужным количеством знаков вопроса
      where: 'id IN (${ids.map((_) => '?').join(',')})',
      whereArgs: ids,
    );
  }

  static Future<void> deleteCalculationFromReport(int calculationId) async {
    await deleteCalculationFromReportAsList([calculationId]);
  }

  static Future<void> deleteCalculationFromReportAsList(List<int> calculationIds) async {
    if(calculationIds.isEmpty) return;
    final db = await database;
    await db.update(
      CALC_TABLE_NAME, {'report_id': null},
      where: 'id IN (${calculationIds.map((_) => '?').join(',')})',
      whereArgs: calculationIds
      );
  }

  static Future<void> changeReportStatusToGenerated(List<int> reportIds) async {
    final db = await database;
    await db.update(
      REPORTS_TABLE_NAME, 
      {'status': 'generated'},
      where: 'id IN (${reportIds.map((_) => '?').join(',')})',
      whereArgs: reportIds
    );
  }

  static Future<void> changeReportStatusToSend(List<int> reportIds) async {
    final db = await database;
    await db.update(
      REPORTS_TABLE_NAME, 
      {'status': 'send'},
      where: 'id IN (${reportIds.map((_) => '?').join(',')})',
      whereArgs: reportIds
    );
  }

  static Future<void> changeReportStatusToDraft(List<int> reportIds) async {
    final db = await database;
    await db.update(
      REPORTS_TABLE_NAME, 
      {'status': 'draft'},
      where: 'id IN (${reportIds.map((_) => '?').join(',')})',
      whereArgs: reportIds
    );
  }


  static Future<void> createReport(String title) async {
    final db = await database;
    await db.insert(
      REPORTS_TABLE_NAME, 
      {'title': title},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    print("--- [DB_PROVIDER] Успешно создан отчет с названием: $title ---");
  }

  static Future<List<Calculation>> getCalculationsByReportId(int reportId) async {
    final db = await database;
    
    // Выполняем SELECT ... FROM Calculations WHERE report_id = ?
    final List<Map<String, dynamic>> maps = await db.query(
      CALC_TABLE_NAME,
      where: 'report_id = ?', // Условие
      whereArgs: [reportId], // Значение для условия (защита от SQL-инъекций)
    );
    
    return List.generate(maps.length, (i) => Calculation.fromMap(maps[i]));
  }

  static Future<List<Report>> getReportsByStatus(String status) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      REPORTS_TABLE_NAME,
      where: 'status = ?',
      whereArgs: [status]
    );
    return List.generate(maps.length, (i) => Report.fromMap(maps[i]));
  }

}