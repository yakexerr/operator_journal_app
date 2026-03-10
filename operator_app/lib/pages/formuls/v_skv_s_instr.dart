import 'package:flutter/material.dart';
import 'package:operator_app/widgets/base_calculation_page.dart';
import 'package:operator_app/widgets/math_input_field.dart';
import 'package:operator_app/widgets/pop_score.dart';

class VSkvSInstr extends StatefulWidget {
  const VSkvSInstr({super.key});

  @override
  State<VSkvSInstr> createState() => _VSkvSInstrState();
}

class _VSkvSInstrState extends State<VSkvSInstr> {
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
        title: "Объём скважины с инструментом (V(с инст))",
        formulaId: "v_skv_s_instr",
        formulaName: "Расчет объёма скважины с инструментом (V(с инст))",
        result: _result,
        unit: "м³",
        onCalculate: _calculate,
        inputs: [
          MathInputField(
            controller: _val1Controller,
            label: "Объём скважины без инструмента (V(без инст))",
            unit: "м³",
          ),
          MathInputField(
            controller: _val2Controller,
            label: "Объём металла (Vмет)",
            unit: "м³",
          ),
        ],
      )
    );
  }
}