import 'package:flutter/material.dart';
import 'package:operator_app/widgets/base_calculation_page.dart';
import 'package:operator_app/widgets/math_input_field.dart';
import 'package:operator_app/widgets/pop_score.dart';

class VZatruba extends StatefulWidget {
  const VZatruba({super.key});

  @override
  State<VZatruba> createState() => _VZatrubaState();
}

class _VZatrubaState extends State<VZatruba> {
  final _val1Controller = TextEditingController();
  final _val2Controller = TextEditingController();
  String _result = "0";

  void _calculate() {
    double v1 = double.tryParse(_val1Controller.text) ?? 0;
    double v2 = double.tryParse(_val2Controller.text) ?? 0;
    setState(() {
      _result = (v1 - v2).toStringAsFixed(2);
    });
  }

  @override
  Widget build(BuildContext context) {
    return FormulaPopScope(
      controllers: [_val1Controller, _val2Controller], 
      child: BaseCalculationPage(
        title: "Объём затруба (V(затр))",
        formulaId: "v_zatruba",
        formulaName: "Расчет объёма затруба (V(затр))",
        result: _result,
        unit: "м³",
        onCalculate: _calculate,
        inputs: [
          MathInputField(
            controller: _val1Controller,
            label: "Объём скважины с инструментом (V(с инст))",
            unit: "м³",
          ),
          MathInputField(
            controller: _val2Controller,
            label: "Объём в инструменте (V(инстр))",
            unit: "м³",
          ),
        ],
      )
    );
  }
}