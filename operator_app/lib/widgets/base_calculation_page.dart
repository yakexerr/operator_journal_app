import 'package:flutter/material.dart';
import 'package:operator_app/models/calculation_model.dart';
import 'package:operator_app/repositories/calculation_repository.dart';
import 'package:operator_app/repositories/local_db_repository.dart';
import 'package:operator_app/widgets/pop_score.dart';

class BaseCalculationPage extends StatefulWidget {
  final String title;
  final String formulaId;
  final List<Widget> inputs;
  final VoidCallback onCalculate;
  final String result;
  final String unit;
  final String formulaName;
  final List<TextEditingController> controllers; 

  const BaseCalculationPage({
    super.key,
    required this.title,
    required this.formulaId,
    required this.inputs,
    required this.onCalculate,
    required this.result,
    required this.unit,
    required this.formulaName,
    required this.controllers,
  });

  @override
  State<BaseCalculationPage> createState() => _BaseCalculationPageState();
}

class _BaseCalculationPageState extends State<BaseCalculationPage> {
  final CalculationRepository repository = LocalDbRepository();
  bool _isDirty = false;

  @override
  void initState() {
    super.initState();
    // Проходим по всем контроллерам из списка и подписываемся на изменения
    for (var controller in widget.controllers) {
      controller.addListener(() {
        if (!_isDirty && controller.text.isNotEmpty) {
          setState(() => _isDirty = true);
        }
      });
    }
  }


  void _saveToHistory() async {
    if (widget.result == "0" || widget.result.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Сначала произведите расчет")),
      );
      return;
    }

    /*
    Достаем ID отчета, если мы пришли из страницы Задачи
    Если пришли просто из вкладки "Формулы", тут будет null
     */
    final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    final int? reportIdFromArgs = args?['reportId'];
    final int? objectIdFromArgs = args?['objectId'];

    final calc = Calculation(
      title: widget.formulaName,
      result: double.tryParse(widget.result) ?? 0,
      createdAt: DateTime.now().toUtc().toIso8601String(), // Сразу UTC сделаем
      objectId: objectIdFromArgs?? 1,
      formulaId: widget.formulaId, 
      reportId: reportIdFromArgs,
    );

    await repository.createCalculation(calc);
    setState(() => _isDirty = false);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Расчет сохранен в историю")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return FormulaPopScope(
      controllers: widget.controllers,
      isDirty: _isDirty,
      child: Scaffold(
        appBar: AppBar(title: Text(widget.title)),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              ...widget.inputs,
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: widget.onCalculate,
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                ),
                child: const Text("РАССЧИТАТЬ"),
              ),
              const SizedBox(height: 30),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.blueGrey[50],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text("РЕЗУЛЬТАТ:", style: TextStyle(fontWeight: FontWeight.bold)),
                    Text("${widget.result} ${widget.unit}", style: const TextStyle(fontSize: 20, color: Colors.blue)),
                  ],
                ),
              ),
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: _saveToHistory,
          child: const Icon(Icons.save),
        ),
      ),
    );
  }
}