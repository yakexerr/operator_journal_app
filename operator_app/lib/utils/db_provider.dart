// db_provider.dart
import 'package:operator_app/models/equipment_object_model.dart';
import 'package:operator_app/models/report_model.dart';
import 'package:operator_app/models/user.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'dart:io';
import 'package:path/path.dart';
import 'package:operator_app/models/calculation_model.dart';
class DBProvider {
  DBProvider._();
  static final DBProvider db = DBProvider._();
  static Database? _database; 
  // Метод для удаления записи
  static Future<int> deleteCalculation(int id) async {
    final db = await database; // получаем базу данных
    return await db.delete(
      'Calculations',
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
    await db.update(
      CALC_TABLE_NAME,
      {'reportId': reportId},
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
  static Future<Database> get database async { // "обещает", что в будущем вернёт объект типа Database
    if(_database != null) return _database!;
    _database = await initDB();
    return _database!; // в dart работает Null-safety и при помощи "!" клянёмся что не будет тут null иначе не будет работать
  }
  static Future<Database> initDB() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, DB_NAME);
    return await openDatabase(path, version: 1,
      onCreate: (Database db, int version) async {
        await db.execute(CREATE_REPORTS_TABLE);
        await db.execute(CREATE_CALC_TABLE);
        await db.execute(CREATE_USERS_TABLE);
        await db.execute(CONSTS_TABLE);
        await db.execute(g_insert_query);
        await db.execute(pi_insert_query);
        await db.execute(usniversal_gas_constant);
        await db.execute(CREATE_OBJECTS_TABLE);
        await db.execute("INSERT INTO Objects (name, type) VALUES ('Тестовая Скважина', 'Well')");
      }
    );
  }
  static Future<void> newCalculation(Calculation calc) async {
    final db = await database; // Получаем доступ к БД
    var resultId = await db.insert(
      CALC_TABLE_NAME,
      calc.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace, // Если запись с таким id уже есть - заменить
    );
  }
  static Future<List<Calculation>> getAllCalculations() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(CALC_TABLE_NAME, orderBy: 'id DESC');
    return List.generate(maps.length, (i) {
      return Calculation.fromMap(maps[i]);
    });
  }
  static Future<void> deleteCalculations(List<int> ids) async {
    if (ids.isEmpty) return;
    final db = await database;
    await db.delete(
      CALC_TABLE_NAME,
      where: 'id IN (${ids.map((_) => '?').join(',')})',
      whereArgs: ids,
    );
  }
  static const String DB_NAME = "operator_journal.db";
  static const String CALC_TABLE_NAME = "Calculations";
  static const String CREATE_CALC_TABLE = '''
    CREATE TABLE Calculations (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      title TEXT NOT NULL,
      result REAL NOT NULL,
      created_at TEXT NOT NULL,
      objectId INTEGER NOT NULL,
      formulaId TEXT NOT NULL,
      reportId INTEGER -- Имя должно совпадать с запросом выше!
    )
  ''';
  static const String CONSTS_TABLE_NAME = 'Constants';
  static const String CONSTS_TABLE = '''
  CREATE TABLE $CONSTS_TABLE_NAME (
  name TEXT PRIMARY KEY,
  value REAL NOT NULL
  )
  ''';
  static const String g_insert_query = '''
  INSERT INTO $CONSTS_TABLE_NAME (name, value) VALUES ('g', ${9.81})
  ''';
  static const String pi_insert_query = '''
  INSERT INTO $CONSTS_TABLE_NAME (name, value) VALUES ('pi', ${3.14159}) 
  ''';
  static const String usniversal_gas_constant = '''
  INSERT INTO $CONSTS_TABLE_NAME (name, value) VALUES ('R', ${8.314})
  ''';
  // автоподстановка
  static Future<List<Calculation>> findFreshCalculations({
    required int objectId, 
    required List<String> requiredFormulaIds,
    required int currentReportId, // Добавляем ID текущего отчета
  }) async {
    final db = await database;
    final dayAgo = DateTime.now().toUtc().subtract(const Duration(hours: 24)).toUtc().toIso8601String();
    final List<Map<String, dynamic>> maps = await db.query(
      'Calculations',
      where: 'objectId = ? AND created_at > ? AND (reportId IS NULL OR reportId != ?) AND formulaId IN (${requiredFormulaIds.map((_) => '?').join(',')})',
      whereArgs: [objectId, dayAgo, currentReportId, ...requiredFormulaIds],
      orderBy: 'created_at DESC',
    );
    return maps.map((e) => Calculation.fromMap(e)).toList();
  }
  // ----- ОТЧЁТЫ
  static const String REPORTS_TABLE_NAME = "Reports";
  static const String CREATE_REPORTS_TABLE = '''
      CREATE TABLE $REPORTS_TABLE_NAME (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        taskId INTEGER NOT NULL, -- НОВОЕ ПОЛЕ
        title TEXT NOT NULL,
        status TEXT NOT NULL DEFAULT 'draft',
        description TEXT NOT NULL,
        objectId INTEGER NOT NULL
      )
  ''';
  static Future<void> deleteReport(int id) async {
    final db = await database;
    await db.delete(
      REPORTS_TABLE_NAME,
      where: 'id = ?',
      whereArgs: [id],
    );
  }
  static Future<void> deleteReports(List<int> ids) async {
    if (ids.isEmpty) return;
    final db = await database;
    await db.delete(
      REPORTS_TABLE_NAME,
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
      CALC_TABLE_NAME, {'reportId': null},
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
  static Future<void> createReport(int taskId, String title, String description, int objectId) async {
    final db = await database;
    await db.insert(
      REPORTS_TABLE_NAME,
      {
        'taskId': taskId,
        'title': title,
        'status': 'draft',
        'description': description,
        'objectId': objectId,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }
  static Future<List<Calculation>> getCalculationsByReportId(int reportId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'Calculations',
      where: 'reportId = ?', 
      whereArgs: [reportId],
    );
    return List.generate(maps.length, (i) => Calculation.fromMap(maps[i]));
  }
  static Future<List<Report>> getReportsByStatus(String status) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      REPORTS_TABLE_NAME,
      where: 'status = ?',
      whereArgs: [status],
      orderBy: "id DESC"
    );
    return List.generate(maps.length, (i) => Report.fromMap(maps[i]));
  }
  static Future<List<Report>> getHomeReports() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      REPORTS_TABLE_NAME,
      where: "status IN ('generated', 'send')",
      orderBy: "id DESC"
    );
    return List.generate(maps.length, (i) => Report.fromMap(maps[i]));
  }
  static const String OBJECTS_TABLE_NAME = "Objects";
  static const String CREATE_OBJECTS_TABLE = '''
    CREATE TABLE $OBJECTS_TABLE_NAME (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      name TEXT NOT NULL,
      type TEXT NOT NULL 
    )
  ''';
  static Future<void> saveObjects(List<EquipmentObject> objects) async {
    final db = await database;
    // Используем транзакцию, чтобы если что-то пойдет не так, данные не удалились в никуда
    await db.transaction((txn) async {
      // удаляем все старые объекты (чтобы справочник всегда был актуальным)
      await txn.delete(OBJECTS_TABLE_NAME);
      for (var obj in objects) {
        await txn.insert(
          OBJECTS_TABLE_NAME, 
          obj.toMap(),
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
    });
  }
  // ПОЛЬЗОВАТЕЛИ
  static const String USER_TABLE_NAME = "Users";
  static const String CREATE_USERS_TABLE = '''
  CREATE TABLE $USER_TABLE_NAME (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    name TEXT NOT NULL,
    lastname TEXT NOT NULL,
    position TEXT NOT NULL,
    login TEXT NOT NULL,
    password TEXT NOT NULL,
    objectId INTEGER -- ДОБАВЬ ЭТО
  )''';
  static Future<User> getUserById(int id) async {
    final db = await database;
    final List<Map<String, dynamic>> res = await db.query(
      USER_TABLE_NAME, 
      where: 'id = ?', 
      whereArgs: [id]
    );
    if (res.isNotEmpty) {
      // превращаем первый найденный результат в объект User
      return User.fromMap(res.first); 
    } else {
      throw Exception('Пользователь с ID $id не найден');
    }
  }
  static Future<User?> getCurrentUser() async {
    final db = await database;
    // Делаем запрос к таблице пользователей
    final List<Map<String, dynamic>> res = await db.query(USER_TABLE_NAME, limit: 1);
    if (res.isNotEmpty) {
      return User.fromMap(res.first);
    }
    return null; // Если таблица пустая
  }
  static Future<void> logout() async {
    final db = await database;
    await db.delete(USER_TABLE_NAME);
  }
  static Future<void> saveUser(User user) async {
    final db = await database;
    // сначала удаляем всех старых юзеров (выходим из прошлых сессий)
    await db.delete(USER_TABLE_NAME);
    // записываем нового
    await db.insert(
      USER_TABLE_NAME, 
      user.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }
}