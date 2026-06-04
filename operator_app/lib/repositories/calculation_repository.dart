import 'package:operator_app/models/calculation_model.dart';
import 'package:operator_app/models/equipment_object_model.dart';
import 'package:operator_app/models/report_model.dart';
import 'package:operator_app/models/user.dart';


abstract class CalculationRepository {
  // сохранение нового расчёта
  Future<void> createCalculation(Calculation calc);

  Future<List<Report>> getAllReports(); // получает все существующие отчёты
  // для привязки рассчётов к конкретному отчёту
  Future<void> addCalculationsToReport(List<int> calculationIds, int reportId);

  // все расчёты в историю
  Future<List<Calculation>> getAllCalculations();
  // удаление расчёта (потом)
  Future<void> deleteCalculation(int id);

  Future<void> deleteCalculations(List<int> ids);


  Future<double> getConstantByName(String name);


  // -------------------------- ОТЧЁТЫ
  Future<void> deleteReport(int id);
  Future<void> deleteReports(List<int> ids);
  Future<void> createReport(int taskId, String title, String description, int objectId);  Future<List<Calculation>> getCalculationsByReportId(int reportId);
  Future<void> deleteCalculationFromReport(int calculationId);
  Future<void> deleteCalculationFromReportAsList(List<int> calculationIds);
  Future<List<Report>> getReportsByStatus(String status);
  Future<List<Report>> getHomeReports();
  Future<void> changeReportStatusToDraft(List<int> reportIds);
  Future<void> changeReportStatusToSend(List<int> reportIds);
  Future<void> changeReportStatusToGenerated(List<int> reportIds);

  Future<List<Calculation>> findFreshCalculations({required int objectId, required List<String> requiredFormulaIds, required int currentReportId});
  Future<void> saveObjects(List<EquipmentObject> objects);
  Future<User> getUserById(int id);
  Future<User?> getCurrentUser();
  Future<void> logout();
  Future<void> saveUser(User user);

}