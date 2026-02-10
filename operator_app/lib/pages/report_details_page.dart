import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:operator_app/models/calculation_model.dart';
import 'package:operator_app/models/report_model.dart' as model;
import 'package:operator_app/repositories/calculation_repository.dart';
import 'package:operator_app/repositories/local_db_repository.dart';
import 'package:operator_app/utils/pdf_generator.dart';
import 'package:operator_app/widgets/my_app_bar.dart';

class ReportDetailsPage extends StatefulWidget {
  final model.Report report;
  const ReportDetailsPage({super.key, required this.report});

  @override
  State<ReportDetailsPage> createState() => _ReportDetailsPageState();
}

class _ReportDetailsPageState extends State<ReportDetailsPage> {
  bool _isLoading = true; // флаг, который говорит, идет ли загрузка
  String? _error; // переменная для хранения текста ошибки
  List<Calculation> _calculations = []; // здесь будет лежать готовый список

  final CalculationRepository repository = LocalDbRepository();
  final Set<int> _selectedIds = {};
  bool _isSelectionMode = false;

  @override
  void initState() {
    super.initState();
    _loadCalculations(); // Запускаем загрузку данных
  }

  Future<void> _loadCalculations() async {
    if (mounted) setState(() => _isLoading = true);

    try {
      final loadedCalculations = await repository.getCalculationsByReportId(widget.report.id!);
      if (mounted) {
        setState(() {
          _calculations = loadedCalculations;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[900],
      appBar: _isSelectionMode
          ? _buildSelectionAppBar()
          : MyAppBar(title: "Отчёт '${widget.report.title}'"),
      
      body: _buildBody(),

      bottomNavigationBar: _isSelectionMode ? _buildActionBottomBar() : _saveBottobBar(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return Center(child: CircularProgressIndicator());
    }
    if (_error != null) {
      return Center(child: Text("Ошибка загрузки данных: $_error"));
    }
    if (_calculations.isEmpty) {
      return Center(child: Text("В отчёте пока нет формул"));
    }

    return ListView.builder(
      itemCount: _calculations.length,
      itemBuilder: (context, index) {
        final calc = _calculations[index];
        final isSelected = _selectedIds.contains(calc.id);
        return Dismissible(
          key: ValueKey(calc.id),
          direction: _isSelectionMode ? DismissDirection.none : DismissDirection.endToStart,
          onDismissed: (direction) async {
            await repository.deleteCalculationFromReport(calc.id!);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Формула "${calc.title}" удалена из отчёта')),
            );
            _loadCalculations(); // перезагружаем список
          },
          background: Container(
            color: Colors.red,
            alignment: Alignment.centerRight,
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Icon(Icons.delete, color: Colors.white),
          ),
          child: Card(
            color: isSelected ? Colors.blueGrey[700] : null,
            child: ListTile(
              title: Text(calc.title),
              subtitle: Text("Результат: ${calc.result}"), // добавил для наглядности
              onLongPress: () {
                if (!_isSelectionMode) {
                  setState(() {
                    _isSelectionMode = true;
                    _selectedIds.add(calc.id!);
                  });
                }
              },
              onTap: () {
                if (_isSelectionMode) {
                  setState(() {
                    if (isSelected) {
                      _selectedIds.remove(calc.id!);
                    } else {
                      _selectedIds.add(calc.id!);
                    }
                  });
                }
              },
            ),
          ),
        );
      },
    );
  }

  Widget _saveBottobBar() {
    return Container(
      height: 60,
      color: Colors.blueGrey[800],
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          InkWell(
            onTap: () async {
              print("Началать генерация pdf в память");
              final Uint8List pdfData = await PdfGenerator.generateReport(widget.report.title, _calculations);
              print("Сгенерировал, меняю статус");
              await repository.changeReportStatusToGenerated([widget.report.id!]);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text("Отчёт '${widget.report.title}' готов и ждёт на главной!"))
              );
            },
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.save, color: Colors.white),
                Text("Создать отчёт", style: TextStyle(color: Colors.white)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionBottomBar() {
    return Container(
      height: 60,
      color: Colors.blueGrey[800],
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          InkWell(
            onTap: () async {
              await repository.deleteCalculationFromReportAsList(_selectedIds.toList());
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text("${_selectedIds.length} записей удалено из отчета")),
              );
              // выходим из режима выбора и перезагружаем данные
              setState(() {
                _isSelectionMode = false;
                _selectedIds.clear();
              });
              _loadCalculations();
            },
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.delete, color: Colors.white),
                Text('Удалить', style: TextStyle(color: Colors.white)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  AppBar _buildSelectionAppBar() {
    return AppBar(
      leading: IconButton(
        icon: Icon(Icons.close),
        onPressed: () {
          setState(() {
            _isSelectionMode = false;
            _selectedIds.clear();
          });
        },
      ),
      title: Text('${_selectedIds.length} выбрано'),
    );
  }
}