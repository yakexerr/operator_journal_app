import 'package:flutter/material.dart';
import 'package:operator_app/widgets/base_calculation_page.dart';
import 'package:operator_app/widgets/math_input_field.dart';
import 'package:operator_app/widgets/pop_score.dart';

class VMetalla extends StatefulWidget {
  const VMetalla({super.key});

  @override
  State<VMetalla> createState() => _VMetallaState();
}

class _VMetallaState extends State<VMetalla> {
  final _val1Controller = TextEditingController();
  final _val2Controller = TextEditingController();
  final _val3Controller = TextEditingController();
  final _val4Controller = TextEditingController();
  final _val5Controller = TextEditingController();
  final _val6Controller = TextEditingController();
  String _result = "0";

  void _calculate() {
    double v1 = double.tryParse(_val1Controller.text) ?? 0; // F7
    double v2 = double.tryParse(_val2Controller.text) ?? 0; // E9
    double v3 = double.tryParse(_val3Controller.text) ?? 0; // F8
    double v4 = double.tryParse(_val4Controller.text) ?? 0; // F10
    double v5 = double.tryParse(_val5Controller.text) ?? 0; // E12
    double v6 = double.tryParse(_val6Controller.text) ?? 0; // F11
    setState(() {
      _result = ((v1*v1*0.785*v2-v3*v3*0.785*v2) + (v4*v4*0.785*v5-v6*v6*0.785*v5)).toStringAsFixed(2);
    });
  }

  @override
  Widget build(BuildContext context) {
    return FormulaPopScope(
      controllers: [_val1Controller, _val2Controller], 
      child: BaseCalculationPage(
        title: "Объём металла (V(мет))",
        formulaId: "v_metalla",
        formulaName: "Расчет объёма металла (V(мет))",
        result: _result,
        unit: "м³",
        onCalculate: _calculate,
        inputs: [
          MathInputField(
            controller: _val1Controller, // F7
            label: "Внешний диаметр инструмента 1 (Dв1)",
            unit: "м",
          ),
          MathInputField(
            controller: _val2Controller, // E9
            label: "Длинна инструмента 1 (Ни1)",
            unit: "м",
          ),
          MathInputField(
            controller: _val3Controller, // F8
            label: "Внутренний диаметр инструмента 1 (Dвн1)",
            unit: "м",
          ),
          MathInputField(
            controller: _val4Controller, // F10
            label: "Внешний диаметр инструмента 2 (Dв2)",
            unit: "м",
          ),
          MathInputField(
            controller: _val5Controller,// E12
            label: "Длинна инструмента 2 (Ни2)",
            unit: "м",
          ),
          MathInputField(
            controller: _val6Controller, // F11
            label: "Внутренний диаметр инструмента 2 (Dвн2)",
            unit: "м",
          ),
        ],
      )
    );
  }
}