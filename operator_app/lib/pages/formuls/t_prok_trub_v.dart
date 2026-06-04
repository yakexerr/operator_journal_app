import 'package:flutter/material.dart';
import 'package:operator_app/widgets/base_calculation_page.dart';
import 'package:operator_app/widgets/math_input_field.dart';
// import 'package:operator_app/widgets/pop_score.dart';

class TProkachTrubV extends StatefulWidget {
  const TProkachTrubV({super.key});

  @override
  State<TProkachTrubV> createState() => _TProkachTrubVState();
}

class _TProkachTrubVState extends State<TProkachTrubV> {
  final _val1Controller = TextEditingController();
  final _val2Controller = TextEditingController();
  String _result = "0";

  void _calculate() {
    double v1 = double.tryParse(_val1Controller.text) ?? 0;
    double v2 = double.tryParse(_val2Controller.text) ?? 0;
    setState(() {
      _result = (v1 / v2).toStringAsFixed(2);
    });
  }

  @override
  Widget build(BuildContext context) {
    return BaseCalculationPage(
      controllers: [_val1Controller, _val2Controller], 
        title: "Время прокачивания трубного объёма (t(труб))",
        formulaId: "t_prok_trub_v",
        formulaName: "Расчет времени прокачивания трубного объёма (t(труб))",
        result: _result,
        unit: "мин",
        onCalculate: _calculate,
        inputs: [
          MathInputField(
            controller: _val1Controller,
            label: "Объём в инструменте (V(инст))",
            unit: "м³",
          ),
          MathInputField(
            controller: _val2Controller,
            label: "Литраж буровых насосов (Q)",
            unit: "м³/мин",
          ),
        ],
    );
  }
}