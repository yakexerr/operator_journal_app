import 'package:operator_app/models/calculation_model.dart';
import 'package:operator_app/utils/db_provider.dart';
import 'calculation_repository.dart';

class LocalDbRepository implements CalculationRepository{
  final dbProvider = DBProvider.db;
  @override
  Future<void> deleteCalculation(int id) async {
    await DBProvider.deleteCalculation(id);
  }
  @override
  Future<void> createCalculation(Calculation calc)  {
    return DBProvider.newCalculation(calc);
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
}
