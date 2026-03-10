import 'package:flutter/material.dart';
import 'package:operator_app/widgets/base_calculation_page.dart';
import 'package:operator_app/widgets/math_input_field.dart';
import 'package:operator_app/widgets/pop_score.dart';

class VObsStvola extends StatefulWidget {
  const VObsStvola({super.key});

  @override
  State<VObsStvola> createState() => _VObsStvolaState();
}

class _VObsStvolaState extends State<VObsStvola> {
  final _val1Controller = TextEditingController();
  final _val2Controller = TextEditingController();
  String _result = "0";

  void _calculate() {
    double v1 = double.tryParse(_val1Controller.text) ?? 0;
    double v2 = double.tryParse(_val2Controller.text) ?? 0;
    setState(() {
      _result = ((v1*v1) * 0.785 * v2).toStringAsFixed(2);
    });
  }

  @override
  Widget build(BuildContext context) {
    return FormulaPopScope(
      controllers: [_val1Controller, _val2Controller], 
      child: BaseCalculationPage(
        title: "Объём обсаженного ствола скважины (Vo)",
        formulaId: "v_obsash_stvola",
        formulaName: "Расчет объёма обсаженного ствола скважины (Vo)",
        result: _result,
        unit: "м³",
        onCalculate: _calculate,
        inputs: [
          MathInputField(
            controller: _val1Controller,
            label: "Диаметр обсаженной колонны (Do)",
            unit: "м",
          ),
          MathInputField(
            controller: _val2Controller,
            label: "Глубина обсаженной колонны (Но)",
            unit: "м",
          ),
        ],
      )
    );
  }
}