import 'package:operator_app/models/calculation_model.dart';

abstract class CalculationRepository {
  // сохранение нового расчёта
  Future<void> createCalculation(Calculation calc);
  // все расчёты в историю
  Future<List<Calculation>> getAllCalculations();
  // удаление расчёта (потом)
  Future<void> deleteCalculation(int id);
}