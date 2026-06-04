import 'package:operator_app/models/calculation_model.dart';
import 'package:operator_app/models/equipment_object_model.dart';
import 'package:operator_app/models/report_model.dart';
import 'package:operator_app/models/user.dart';
import 'package:operator_app/utils/db_provider.dart';
import 'calculation_repository.dart';

class LocalDbRepository implements CalculationRepository{
  @override
  Future<void> deleteCalculation(int id) async {
    await DBProvider.deleteCalculation(id);
  }
  @override
  Future<void> createCalculation(Calculation calc)  {
    return DBProvider.newCalculation(calc);
  }

  @override
  Future<double> getConstantByName(String name) async {
    return await DBProvider.getConstantByName(name);
  }

  @override
  Future<List<Report>> getAllReports() async {
    // Мы, как "Менеджер", просто передаем эту задачу "Рабочему"
    // и ждем от него результат.
    return await DBProvider.getAllReports();
  }

  // То же самое для второго метода
  @override
  Future<void> addCalculationsToReport(List<int> calculationIds, int reportId) async {
    // Просто передаем задачу дальше
    await DBProvider.addCalculationsToReport(calculationIds, reportId);
  }

  @override
  Future<List<Calculation>> getAllCalculations() async {
    /*
    тут надо написать вызов метода для получения данных,
    который добавить надо в DBProvider
    что-то типа
    return await dbProvider.getAllCalculations();
     */
    print("Запрос всех рассчётов из локальной БД");
    return await DBProvider.getAllCalculations();
  }

  @override
  Future<void> deleteCalculations(List<int> ids) async {
    // Просто "прокидываем" вызов дальше
    await DBProvider.deleteCalculations(ids);
  }

  // ---------------
  @override
  Future<void> deleteReport(int id) async {
    await DBProvider.deleteReport(id);
  }

  @override
  Future<void> deleteReports(List<int> ids) async {
    await DBProvider.deleteReports(ids);
  }

  @override
  Future<void> createReport(int taskId, String title, String description, int objectId) async {
    // Просто прокидываем вызов дальше в DBProvider
    await DBProvider.createReport(taskId, title, description, objectId);
  }

  @override
  Future<List<Calculation>> getCalculationsByReportId(int reportId) async {
    return await DBProvider.getCalculationsByReportId(reportId);
  }

  @override
  Future<void> deleteCalculationFromReport(int calculationId) async {
    return await DBProvider.deleteCalculationFromReport(calculationId);
  }

  @override
  Future<void> deleteCalculationFromReportAsList(List<int> calculationIds) async {
    return await DBProvider.deleteCalculationFromReportAsList(calculationIds);
  }

  @override
  Future<List<Report>> getReportsByStatus(String status) async {
    return await DBProvider.getReportsByStatus(status);
  }

  @override
  Future<void> changeReportStatusToDraft(List<int> reportIds) async {
    return await DBProvider.changeReportStatusToDraft(reportIds);
  }

  @override
  Future<void> changeReportStatusToSend(List<int> reportIds) async {
    return await DBProvider.changeReportStatusToSend(reportIds);
  }

  @override
  Future<void> changeReportStatusToGenerated(List<int> reportIds) async {
    return await DBProvider.changeReportStatusToGenerated(reportIds);
  }

  @override
  Future<List<Report>> getHomeReports() async {
    return await DBProvider.getHomeReports();
  }

  @override
  Future<List<Calculation>> findFreshCalculations({
    required int objectId, 
    required List<String> requiredFormulaIds, 
    required int currentReportId
  }) {
    return DBProvider.findFreshCalculations(
      objectId: objectId, 
      requiredFormulaIds: requiredFormulaIds, 
      currentReportId: currentReportId
    );
  }

  @override
  Future<void> saveObjects(List<EquipmentObject> objects) async {
    // Просто перенаправляем вызов в DBProvider
    await DBProvider.saveObjects(objects);
  }

  @override
  Future<User> getUserById(int id) async {
    return await DBProvider.getUserById(id);
  }

  @override
  Future<User?> getCurrentUser() async {
    return await DBProvider.getCurrentUser();
  }

  @override
  Future<void> logout() async {
    return await DBProvider.logout();
  }

  @override
  Future<void> saveUser(User user) async {
    await DBProvider.saveUser(user);
  }
}
