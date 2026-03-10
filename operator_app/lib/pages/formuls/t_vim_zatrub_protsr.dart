import 'package:flutter/material.dart';
import 'package:operator_app/widgets/base_calculation_page.dart';
import 'package:operator_app/widgets/math_input_field.dart';
import 'package:operator_app/widgets/pop_score.dart';

class TVimZatrubProstr extends StatefulWidget {
  const TVimZatrubProstr({super.key});

  @override
  State<TVimZatrubProstr> createState() => _TVimZatrubProstrState();
}

class _TVimZatrubProstrState extends State<TVimZatrubProstr> {
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
    return FormulaPopScope(
      controllers: [_val1Controller, _val2Controller], 
      child: BaseCalculationPage(
        title: "Время вымыва затрубного пространства (t(затр))",
        formulaId: "t_vim_zatrub_protsr",
        formulaName: "Расчет времени вымыва затрубного пространства (t(затр))",
        result: _result,
        unit: "мин",
        onCalculate: _calculate,
        inputs: [
          MathInputField(
            controller: _val1Controller,
            label: "Объём затруба (V(с затр))",
            unit: "м³",
          ),
          MathInputField(
            controller: _val2Controller,
            label: "Литраж буровых насосов (Q)",
            unit: "м³/мин",
          ),
        ],
      )
    );
  }
}