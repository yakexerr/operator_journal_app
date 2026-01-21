import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:operator_app/widgets/my_app_bar.dart';
import 'package:operator_app/models/calculation_model.dart';
import 'package:operator_app/repositories/local_db_repository.dart';
import 'package:operator_app/repositories/calculation_repository.dart';

class HidrostaticPressure extends StatefulWidget {
  const HidrostaticPressure({super.key});

  @override
  State<HidrostaticPressure> createState() => _HidrostaticPressureState();
}

class _HidrostaticPressureState extends State<HidrostaticPressure> {
  final TextEditingController roController = TextEditingController();
  final TextEditingController gController = TextEditingController();
  final TextEditingController hController = TextEditingController();
  final String formulaName = "Гидростатическое давление столба жидкости"; 
  double result = 0.0;

  // устраняем утечку памяти
  @override
  void dispose() {
    roController.dispose();
    gController.dispose();
    hController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[900],
      appBar: MyAppBar(title: formulaName),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Wrap( // Wrap для переноса формулы на новую строку если выйдет за границу экрана
            crossAxisAlignment: WrapCrossAlignment.center, //
            children: [
              Text("P = ", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.grey)),
              buildMathInput(roController, "ρ"),
              Text(" × ", style: TextStyle(fontSize: 24, color: Colors.grey)), 
              buildMathInput(gController, "g"),
              Text(" × ", style: TextStyle(fontSize: 24, color: Colors.grey)), 
              buildMathInput(hController, "h"),
              Text(" = ", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.grey)),
              Text("${result.toStringAsFixed(2)} Па", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.grey)),
            ],
          ),
        ),  
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.grey,
        // Пример для кнопки "Сохранить"
        onPressed: () async { // Делаем обработчик асинхронным
          
          // 1. Создаем репозиторий
          final CalculationRepository repository = LocalDbRepository();


          // 2. Создаем объект с тестовыми данными
          final newCalculation = Calculation(
            title: 'Расчет "$formulaName"',
            result: result,
            createdAt: DateTime.now().toIso8601String(), // Текущая дата и время
          );

          // 3. Вызываем метод для сохранения
          await repository.createCalculation(newCalculation);
          
          // 4. Показываем сообщение, что все получилось
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Расчет сохранен!'))
          );
        },
        child: Icon(
          Icons.save,
          color: Colors.white,
          semanticLabel: "Сохранить результат",
        )
        ),
    );
  }

  void _calculate() {
    // поскольку бывает что вместо запятой точка у некоторых клавиатур, может вернуть null, для этого пишем такую штуку
    double parseValue(String text) => double.tryParse(text.replaceAll(',', '.')) ?? 0;
    double ro = parseValue(roController.text);
    double g = parseValue(gController.text);
    double h = parseValue(hController.text);
    setState(() {
      result = ro*g*h;
    });
  }

  Widget buildMathInput(TextEditingController controller, String hint) {
    return Container(
      constraints: BoxConstraints(minWidth: 40, maxWidth: 120),
      padding: EdgeInsets.symmetric(horizontal: 4),
      child: TextField(
        controller: controller,
        keyboardType: TextInputType.numberWithOptions(decimal: true), // чтобы открывалась клава только для чисел
        inputFormatters: [
          FilteringTextInputFormatter.allow(RegExp(r'^\d*[.,]?\d*')),
        ],
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: 22, color: Colors.blueAccent, fontWeight: FontWeight.bold),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(color: Colors.grey.withOpacity(0.05)),
          border: UnderlineInputBorder(), // полоска внизу
          isDense: true, // лишние отступы
          contentPadding: EdgeInsets.symmetric(vertical: 5),
        ),
        onChanged: (val) => _calculate(),
      ),
    );
  }
}

