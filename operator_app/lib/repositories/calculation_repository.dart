import 'package:operator_app/models/calculation_model.dart';
import 'package:operator_app/models/report_model.dart';


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
  Future<void> createReport(String title);
  Future<List<Calculation>> getCalculationsByReportId(int reportId);
  Future<void> deleteCalculationFromReport(int calculationId);
  Future<void> deleteCalculationFromReportAsList(List<int> calculationIds);
  Future<List<Report>> getReportsByStatus(String status);
  Future<void> changeReportStatusToDraft(List<int> reportIds);
  // TODO: исправить на единичные id, так как списками отчёты не всегда получится перекидывать, 
  Future<void> changeReportStatusToSend(List<int> reportIds);
  Future<void> changeReportStatusToGenerated(List<int> reportIds);

}