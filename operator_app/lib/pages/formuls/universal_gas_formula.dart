import 'package:flutter/material.dart';
import 'package:operator_app/widgets/base_calculation_page.dart';
import 'package:operator_app/widgets/math_input_field.dart';
// import 'package:operator_app/widgets/pop_score.dart';

class UniversalGasFormula extends StatefulWidget {
  const UniversalGasFormula({super.key});

  @override
  State<UniversalGasFormula> createState() => _UniversalGasFormulaState();
}

class _UniversalGasFormulaState extends State<UniversalGasFormula> {
  final _val1Controller = TextEditingController();
  final _val2Controller = TextEditingController();
  String _result = "0";

  void _calculate() {
    double v1 = double.tryParse(_val1Controller.text) ?? 0;
    double v2 = double.tryParse(_val2Controller.text) ?? 0;
    setState(() {
      _result = (v1 * v2 * 8.32).toStringAsFixed(2);
    });
  }

  @override
  Widget build(BuildContext context) {
    return BaseCalculationPage(
      controllers: [_val1Controller, _val2Controller], 
        title: "Универсальная газовая формула (Pv)",
        formulaId: "universal_gas_formula",
        formulaName: "Расчет ун. газовой формулы (Pv)",
        result: _result,
        unit: "Дж/(моль·К)",
        onCalculate: _calculate,
        inputs: [
          MathInputField(
            controller: _val1Controller,
            label: "Количество веществ",
            unit: "моль",
          ),
          MathInputField(
            controller: _val2Controller,
            label: "Абсолютная температура",
            unit: "К",
          ),
        ],
    );
  }
}