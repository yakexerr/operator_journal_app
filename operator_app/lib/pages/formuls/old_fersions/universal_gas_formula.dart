import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:operator_app/models/calculation_model.dart';
import 'package:operator_app/repositories/calculation_repository.dart';
import 'package:operator_app/repositories/local_db_repository.dart';
import 'package:operator_app/widgets/my_app_bar.dart';
import 'package:operator_app/widgets/pop_score.dart';

class UniversalGasFormula extends StatefulWidget {
  const UniversalGasFormula({super.key});

  @override
  State<UniversalGasFormula> createState() => _UniversalGasFormulaState();
}

// pV=nRT измеряется в паскалях на метрк кубический (Па*м**3)

class _UniversalGasFormulaState extends State<UniversalGasFormula> {
  final TextEditingController nController = TextEditingController();
  final TextEditingController TController = TextEditingController();
  final String formulaName = "Универсальная газовая формула";

  final CalculationRepository repository = LocalDbRepository();
  late final Future<double> RFuture;

  double result = 0.0;

  @override
  void dispose() {
    nController.dispose();
    TController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    RFuture = _loadGConstant();
  }

  Future<double> _loadGConstant() async {
    return await repository.getConstantByName('R');
  }

  @override
  Widget build(BuildContext context) {
    return FormulaPopScope(
      controllers: [nController, TController], 
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: MyAppBar(title: formulaName),
        body: FutureBuilder(future: RFuture, 
        builder: (context, snapshot) {
          if(snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {return Center(child: Text("Ошибка загрузки: ${snapshot.error}", style: TextStyle(fontSize: 24, color: Colors.grey),));}
          if (snapshot.hasData) {
            final double RValue = snapshot.data!;
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0), 
                child: Wrap(
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Text("pV = ", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black)),
                    buildMathInput(nController, "n", (val) {_calculate(RValue);}),
                    Text(" × ", style: TextStyle(fontSize: 24, color: Colors.black)),
                    Text(RValue.toString(), style: TextStyle(fontSize: 24, color: Colors.black)),  
                    Text(" × ", style: TextStyle(fontSize: 24, color: Colors.black)), 
                    buildMathInput(TController, "T", (val) {_calculate(RValue);}),
                    Text(" = ${result.toStringAsFixed(2)} Па", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black)),

                  ],
                ), 
              ),
            );
          }
          return Center(child: Text("Нет данных"));
        } 
        ),
        floatingActionButton: SizedBox(
          width: 80.0,
          height: 80.0,
          child: FloatingActionButton(
            backgroundColor: Colors.lightBlueAccent,
            onPressed: () async {
              
              final CalculationRepository repository = LocalDbRepository();
              final newCalculation = Calculation(
                title: 'Рассчёт "${formulaName}"', 
                formulaId: "universal_gas_formula",
                result: result, 
                createdAt: DateTime.now().toUtc().toIso8601String(),
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
              color:  Colors.white,
              semanticLabel: "Сохранить результат",
            ),
          ),
        )
      )
    );
  }

  void _calculate(double RValue) {
  double parseValue(String text) => double.tryParse(text.replaceAll(',', '.')) ?? 0;
  double n = parseValue(nController.text);
  double T = parseValue(TController.text);
  setState(() {
    result = n*RValue*T;
  });
  }

  Widget buildMathInput(TextEditingController controller, String hint, Function(String) onChangedCallback) {
    return Container(
      constraints: BoxConstraints(minWidth: 40, maxWidth: 120),
      padding: EdgeInsets.symmetric(horizontal: 4),
      child: TextField(
        controller: controller,
        keyboardType: TextInputType.numberWithOptions(decimal: true),
        inputFormatters: [
          FilteringTextInputFormatter.allow(RegExp(r'^\d*[.,]?\d*')),
        ],
        textAlign: TextAlign.center,
        style: TextStyle(color: Colors.blueAccent, fontSize: 22, fontWeight: FontWeight.bold),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(color: Colors.grey[500]),
          border: UnderlineInputBorder(),
          isDense: true,
          contentPadding: EdgeInsets.symmetric(vertical: 5),
        ),
        onChanged: onChangedCallback,
      ),
    );
  } 
}
