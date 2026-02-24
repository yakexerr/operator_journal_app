import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:operator_app/widgets/my_app_bar.dart';
import 'package:operator_app/models/calculation_model.dart';
import 'package:operator_app/repositories/local_db_repository.dart';
import 'package:operator_app/repositories/calculation_repository.dart';
import 'package:operator_app/widgets/pop_score.dart';

class HidrostaticPressure extends StatefulWidget {
  const HidrostaticPressure({super.key});

  @override
  State<HidrostaticPressure> createState() => _HidrostaticPressureState();
}

class _HidrostaticPressureState extends State<HidrostaticPressure> {
  final TextEditingController roController = TextEditingController();
  // final TextEditingController gController = TextEditingController();
  final TextEditingController hController = TextEditingController();
// 
  final CalculationRepository repository = LocalDbRepository();
  late final Future<double> gFuture;

  final String formulaName = "Гидростатическое давление столба жидкости"; 
  double result = 0.0;

  // устраняем утечку памяти - явно освобождаем тяжёлые ресурсы
  @override
  void dispose() { // сам dispose помогает вручную прибираться перед уничтожением stateful виджетов
    roController.dispose(); // юлагодаря dispose при завершении работы как бы очищает все подписки контроллера
    // gController.dispose();
    hController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    gFuture = _loadGConstant();
  }

  Future<double> _loadGConstant() async {
    return await repository.getConstantByName('g');
  }
  
  @override
  Widget build(BuildContext context) {
    return FormulaPopScope(
      controllers: [roController, hController], 
      child: Scaffold(
      backgroundColor: Colors.white,
      appBar: MyAppBar(title: formulaName),
      body: FutureBuilder<double>( // это для того чтобы успеть вытянуть g из базы, ведь build вызывается раньше чем выгрузиться из бд и мы можем что-то зделать пока не дойдёт, например показать загрузку
        future: gFuture, 
        builder: (context, snapshot) {
          if(snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if(snapshot.hasError) {return Center(child: Text('Ошибка загрузки: ${snapshot.error}', style: TextStyle(fontSize: 24, color: Colors.grey)));}
          if (snapshot.hasData) {
            final double gValue = snapshot.data!;
            TextStyle style2 = TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black);
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Wrap( // Wrap для переноса формулы на новую строку если выйдет за границу экрана
                  crossAxisAlignment: WrapCrossAlignment.center, //
                  children: [
                    Text("P = ", style: style2),
                    buildMathInput(roController, "ρ", (val) {_calculate(gValue);}),
                    Text(" × ", style: TextStyle(fontSize: 24, color: Colors.black)), 
                    // buildMathInput(gController, "g"),
                    Text(gValue.toString(), style: TextStyle(fontSize: 24, color: Colors.black)),
                    Text(" × ", style: TextStyle(fontSize: 24, color: Colors.black)), 
                    buildMathInput(hController, "h", (val) {_calculate(gValue);}),
                    Text(" = ", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black)),
                    Text("${result.toStringAsFixed(2)} Па", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black)),
                  ],
                ),
              ),  
            );
          }
          return Center(child: Text("Нет данных"));
        }
      ),
  
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.lightBlueAccent,
        // Пример для кнопки "Сохранить"
        onPressed: () async { // Делаем обработчик асинхронным
          
          final CalculationRepository repository = LocalDbRepository();


          final newCalculation = Calculation(
            title: 'Рассчёт "$formulaName"',
            formulaId: "hidrostatic_pressure",
            result: result,
            createdAt: DateTime.now().toUtc().toIso8601String(), // Текущая дата и время
            objectId: 1,
          );

          await repository.createCalculation(newCalculation);
          
          if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Рассчёт сохранён!'))
              );

            }
        },
        child: Icon(
          Icons.save,
          color: Colors.white,
          semanticLabel: "Сохранить результат",
        )
        ),
    )
    );
  }

  void _calculate(double gValue) {
    // поскольку бывает что вместо запятой точка у некоторых клавиатур, может вернуть null, для этого пишем такую штуку
    double parseValue(String text) => double.tryParse(text.replaceAll(',', '.')) ?? 0;
    double ro = parseValue(roController.text);
    // double g = parseValue(gController.text);
    double h = parseValue(hController.text);
    setState(() {
      result = ro*gValue*h;
    });
  }

  Widget buildMathInput(TextEditingController controller, String hint, Function(String) onChangedCallback) {
    return Container(
      constraints: BoxConstraints(minWidth: 40, maxWidth: 120),
      padding: EdgeInsets.symmetric(horizontal: 4),
      child: TextField(
        controller: controller,
        keyboardType: TextInputType.numberWithOptions(decimal: true), // чтобы открывалась клава только для чисел
        inputFormatters: [
          FilteringTextInputFormatter.allow(RegExp(r'^\d*[.,]?\d*')), //TODO: конец строки
        ],
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: 22, color: Colors.blueAccent, fontWeight: FontWeight.bold),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(color: Colors.grey[500]),
          border: UnderlineInputBorder(), // полоска внизу
          isDense: true, // лишние отступы
          contentPadding: EdgeInsets.symmetric(vertical: 5),
        ),
        onChanged: onChangedCallback,
      ),
    );
  }
}

