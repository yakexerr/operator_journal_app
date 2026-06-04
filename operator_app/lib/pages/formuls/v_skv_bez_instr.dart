import 'package:flutter/material.dart';
import 'package:operator_app/widgets/base_calculation_page.dart';
import 'package:operator_app/widgets/math_input_field.dart';
// import 'package:operator_app/widgets/pop_score.dart';

class VSkvBezInstr extends StatefulWidget {
  const VSkvBezInstr({super.key});

  @override
  State<VSkvBezInstr> createState() => _VSkvBezInstrState();
}

class _VSkvBezInstrState extends State<VSkvBezInstr> {
  final _val1Controller = TextEditingController();
  final _val2Controller = TextEditingController();
  String _result = "0";

  void _calculate() {
    double v1 = double.tryParse(_val1Controller.text) ?? 0;
    double v2 = double.tryParse(_val2Controller.text) ?? 0;
    setState(() {
      _result = (v1 + v2).toStringAsFixed(2);
    });
  }

  @override
  Widget build(BuildContext context) {
    return BaseCalculationPage(
      controllers: [_val1Controller, _val2Controller], 
        title: "Объём скважины без инструмента (V(без инст))",
        formulaId: "v_skv_bez_instr",
        formulaName: "Расчет объёма скважины без инструмента (V(без инст))",
        result: _result,
        unit: "м³",
        onCalculate: _calculate,
        inputs: [
          MathInputField(
            controller: _val1Controller,
            label: "Объём обсаженного ствола скважины (Vo)",
            unit: "м³",
          ),
          MathInputField(
            controller: _val2Controller,
            label: "Объём открытого ствола скважины (Vот)",
            unit: "м³",
          ),
        ],
    );
  }
}