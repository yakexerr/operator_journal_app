import 'package:flutter/material.dart';
import 'package:operator_app/widgets/base_calculation_page.dart';
import 'package:operator_app/widgets/math_input_field.dart';
// import 'package:operator_app/widgets/pop_score.dart';

class PumpEfficiency extends StatefulWidget {
  const PumpEfficiency({super.key});

  @override
  State<PumpEfficiency> createState() => _PumpEfficiencyState();
}

class _PumpEfficiencyState extends State<PumpEfficiency> {
  final _val1Controller = TextEditingController();
  final _val2Controller = TextEditingController();
  String _result = "0";

  void _calculate() {
    double v1 = double.tryParse(_val1Controller.text) ?? 0;
    double v2 = double.tryParse(_val2Controller.text) ?? 0;
    setState(() {
      _result = (v1 * v2).toStringAsFixed(2);
    });
  }

  @override
  Widget build(BuildContext context) {
    return BaseCalculationPage(
      controllers: [_val1Controller, _val2Controller], 
        title: "Эффективность насоса",
        formulaId: "pump_efficiency",
        formulaName: "Расчет эффективности",
        result: _result,
        unit: "%",
        onCalculate: _calculate,
        inputs: [
          MathInputField(
            controller: _val1Controller,
            label: "Подача насоса",
            unit: "м³/сут",
          ),
          MathInputField(
            controller: _val2Controller,
            label: "Коэффициент наполнения",
            icon: Icons.percent,
          ),
        ],
    );
  }
}