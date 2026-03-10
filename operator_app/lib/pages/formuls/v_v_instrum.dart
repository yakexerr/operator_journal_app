import 'package:flutter/material.dart';
import 'package:operator_app/widgets/base_calculation_page.dart';
import 'package:operator_app/widgets/math_input_field.dart';
import 'package:operator_app/widgets/pop_score.dart';

class VVInstr extends StatefulWidget {
  const VVInstr({super.key});

  @override
  State<VVInstr> createState() => _VVInstrState();
}

class _VVInstrState extends State<VVInstr> {
  final _val1Controller = TextEditingController();
  final _val2Controller = TextEditingController();
  final _val3Controller = TextEditingController();
  final _val4Controller = TextEditingController();
  String _result = "0";

  void _calculate() {
    double v1 = double.tryParse(_val1Controller.text) ?? 0; // F8
    double v2 = double.tryParse(_val2Controller.text) ?? 0; // E9
    double v3 = double.tryParse(_val3Controller.text) ?? 0; // F11
    double v4 = double.tryParse(_val4Controller.text) ?? 0; // E12
    setState(() {
      _result = ((v1*v1) * 0.785 * v2 + v3*v3*0.785*v4).toStringAsFixed(2);
    });
  }

  @override
  Widget build(BuildContext context) {
    return FormulaPopScope(
      controllers: [_val1Controller, _val2Controller], 
      child: BaseCalculationPage(
        title: "Объём в инструменте (V(инстр))",
        formulaId: "v_v_instrum",
        formulaName: "Расчет объёма в инструменте (V(инстр))",
        result: _result,
        unit: "м³",
        onCalculate: _calculate,
        inputs: [
          MathInputField(
            controller: _val1Controller,
            label: "Внутренний диаметр инструмента 1 (Dвн1)",
            unit: "м",
          ),
          MathInputField(
            controller: _val2Controller,
            label: "Длинна инструмента 1 (Ни1)",
            unit: "м",
          ),
          MathInputField(
            controller: _val3Controller,
            label: "Внутренний диаметр инструмента 2 (Dвн2)",
            unit: "м",
          ),
          MathInputField(
            controller: _val4Controller,
            label: "Длинна инструмента 2 (Ни2)",
            unit: "м",
          ),
        ],
      )
    );
  }
}