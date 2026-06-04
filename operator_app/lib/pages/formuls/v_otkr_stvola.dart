import 'package:flutter/material.dart';
import 'package:operator_app/widgets/base_calculation_page.dart';
import 'package:operator_app/widgets/math_input_field.dart';
// import 'package:operator_app/widgets/pop_score.dart';

class VOtkrStvola extends StatefulWidget {
  const VOtkrStvola({super.key});

  @override
  State<VOtkrStvola> createState() => _VOtkrStvolaState();
}

class _VOtkrStvolaState extends State<VOtkrStvola> {
  final _val1Controller = TextEditingController();
  final _val2Controller = TextEditingController();
  final _val3Controller = TextEditingController();
  String _result = "0";

  void _calculate() {
    double v1 = double.tryParse(_val1Controller.text) ?? 0;
    double v2 = double.tryParse(_val2Controller.text) ?? 0;
    double v3 = double.tryParse(_val3Controller.text) ?? 0;
    setState(() {
      _result = ((v1*v1) * 0.785 * v2 * v3).toStringAsFixed(2);
    });
  }

  @override
  Widget build(BuildContext context) {
    return BaseCalculationPage(
      controllers: [_val1Controller, _val2Controller], 
        title: "Объём открытого ствола скважины (Voт)",
        formulaId: "v_otkr_stvola",
        formulaName: "Расчет объёма открытого ствола скважины (Voт)",
        result: _result,
        unit: "м³",
        onCalculate: _calculate,
        inputs: [
          MathInputField(
            controller: _val1Controller,
            label: "Диаметр долота (Dд)",
            unit: "м",
          ),
          MathInputField(
            controller: _val2Controller,
            label: "Длина открытого ствола скважины (Нок)",
            unit: "м",
          ),
          MathInputField(
            controller: _val3Controller,
            label: "Коэффициент кавернозности (Ка)",
            icon: Icons.percent,
          ),
        ],
    );
  }
}