import 'package:flutter/material.dart';
import 'package:operator_app/widgets/base_calculation_page.dart';
import 'package:operator_app/widgets/math_input_field.dart';
// import 'package:operator_app/widgets/pop_score.dart';

class TProkachAllVSkash extends StatefulWidget {
  const TProkachAllVSkash({super.key});

  @override
  State<TProkachAllVSkash> createState() => _TProkachAllVSkashState();
}

class _TProkachAllVSkashState extends State<TProkachAllVSkash> {
  final _val1Controller = TextEditingController();
  final _val2Controller = TextEditingController();
  String _result = "0";

  void _calculate() {
    double v1 = double.tryParse(_val1Controller.text) ?? 0;
    double v2 = double.tryParse(_val2Controller.text) ?? 0;
    setState(() {
      _result = (v1 / v2).toStringAsFixed(2);
    });
  }

  @override
  Widget build(BuildContext context) {
    return BaseCalculationPage(
      controllers: [_val1Controller, _val2Controller], 
        title: "Время прокачивания всего объёма скважины объёма (t(цикл))",
        formulaId: "t_prokach_all_v_shidk",
        formulaName: "Расчет времени прокачивания всего объёма скважины объёма (t(цикл))",
        result: _result,
        unit: "мин",
        onCalculate: _calculate,
        inputs: [
          MathInputField(
            controller: _val1Controller,
            label: "Объём скважины с инструментом (V(с инст))",
            unit: "м³",
          ),
          MathInputField(
            controller: _val2Controller,
            label: "Литраж буровых насосов (Q)",
            unit: "м³/мин",
          ),
        ],
    );
  }
}