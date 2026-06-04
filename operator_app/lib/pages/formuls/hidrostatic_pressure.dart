// hidrostatic_pressure.dart
import 'package:flutter/material.dart';
import 'package:operator_app/widgets/base_calculation_page.dart';
import 'package:operator_app/widgets/math_input_field.dart';
class HidrostaticPressure extends StatefulWidget {
  const HidrostaticPressure({super.key});
  @override
  State<HidrostaticPressure> createState() => _HidrostaticPressureState();
}
class _HidrostaticPressureState extends State<HidrostaticPressure> {
  final _val1Controller = TextEditingController();
  final _val2Controller = TextEditingController();
  String _result = "0";
  void _calculate() {
    double v1 = double.tryParse(_val1Controller.text) ?? 0;
    double v2 = double.tryParse(_val2Controller.text) ?? 0;
    setState(() {
      _result = (v1 * v2 * 9.81).toStringAsFixed(2);
    });
  }
  @override
  Widget build(BuildContext context) {
    return BaseCalculationPage(
        title: "Гидростатическое давление (p)",
        controllers: [_val1Controller, _val2Controller],
        formulaId: "hidrostatic_pressure",
        formulaName: "Расчет гидростатического давления (p)",
        result: _result,
        unit: "Па",
        onCalculate: _calculate,
        inputs: [
          MathInputField(
            controller: _val1Controller,
            label: "Плотность жидкости",
            unit: "кг/м³",
          ),
          MathInputField(
            controller: _val2Controller,
            label: "Высота столба жидкости",
            unit: "м",
          ),
        ],
    );
  }
}