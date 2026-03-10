import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:operator_app/models/calculation_model.dart';
import 'package:operator_app/models/report_model.dart' as model;
import 'package:operator_app/repositories/api_repository.dart';
import 'package:operator_app/repositories/calculation_repository.dart';
import 'package:operator_app/repositories/http_api_repository.dart';
import 'package:operator_app/repositories/local_db_repository.dart';
import 'package:operator_app/widgets/action_bottom_bar.dart';
import 'package:operator_app/widgets/my_app_bar.dart';
import 'package:operator_app/widgets/selection_app_bar.dart';

class ReportDetailsPage extends StatefulWidget {
  final model.Report report;
  const ReportDetailsPage({super.key, required this.report});

  @override
  State<ReportDetailsPage> createState() => _ReportDetailsPageState();
}

class _ReportDetailsPageState extends State<ReportDetailsPage> {
  // словарик для праильного отображения задач
  final Map<String, String> formulaNames = {
    'pump_efficiency': 'Эффективность насоса',
    'hidrostatic_pressure': 'Гидростатическое давление столба жидкости',
    'universal_gas_formula': 'универсальное газовое значение',
    'v_obsash_stvola' : 'Объём обсаженного ствола скважины',
    'v_otkr_stvola' : 'Объём открытого ствола скважины',
    'v_skv_bez_instr' : 'Объём скважины без инструмента',
    'v_skv_s_instr' : 'Объём скважины с инструментом',
    'v_zatruba' : 'Объём затруба',
    't_prok_trub_v' : 'Время прокачивания трубного объёма',
    't_vim_zatrub_protsr' : 'Время вымыва затрубного пространства',
    't_prokach_all_v_shidk' : 'Время прокачивания всего объёма скважины',
    'v_v_instrum' : 'Объём в инструменте',
    'v_metalla' : 'Объём металла',
  };


  // для перехода напрямую к формуле
  final Map<String, String> formulaRoutes = {
    'pump_efficiency': '/pump_efficiency',
    'hidrostatic_pressure': '/hidrostatic_pressure',
    'universal_gas_formula': '/universal_gas_formula',
    'v_obsash_stvola' : '/v_obsash_stvola',
    'v_otkr_stvola' : '/v_otkr_stvola',
    'v_skv_bez_instr' : '/v_skv_bez_instr',
    'v_skv_s_instr' : '/v_skv_s_instr',
    'v_zatruba' : '/v_zatruba',
    't_prok_trub_v' : '/t_prok_trub_v',
    't_vim_zatrub_protsr' : '/t_vim_zatrub_protsr',
    't_prokach_all_v_shidk' : '/t_prokach_all_v_shidk',
    'v_v_instrum' : '/v_v_instrum',
    'v_metalla' : '/v_metalla',
  };


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
    _checkAutoFill(); // автопроверку запускаем сразу
  }

  void _checkAutoFill() async {
    if (widget.report.description.isEmpty) return;
    
    List<String> requiredIds = widget.report.description.split(', '); 

    final freshCalcs = await repository.findFreshCalculations(
      objectId: widget.report.objectId,
      requiredFormulaIds: requiredIds,
      currentReportId: widget.report.id!, // ПЕРЕДАЕМ ID ТЕКУЩЕГО ОТЧЕТА
    );

    if (freshCalcs.isNotEmpty && mounted) {
      _showAutoFillDialog(freshCalcs);
    }
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
      backgroundColor: Colors.white,
      appBar: _isSelectionMode
          ? SelectionAppBar(
              selectionCount: _selectedIds.length, 
              onClearSelection: () {
                setState(() {
                  _isSelectionMode = false;
                  _selectedIds.clear();
                });
              }
            )
          : MyAppBar(title: "Отчёт '${widget.report.title}'"),
      
      body: _buildBody(),

      bottomNavigationBar: _isSelectionMode 
      ? ActionBottomBar(
        selectedIds: _selectedIds,
        onDelete: () async {
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
      ) 
      : _saveBottomBar(),
    );
  }

  Widget _buildBody() {
  if (_isLoading) {
    return const Center(child: CircularProgressIndicator());
  }
  if (_error != null) {
    return Center(child: Text("Ошибка загрузки данных: $_error"));
  }

  // для того чтобы подсвечивать лишнее в задаче
  // trim лишние пробелы по бокам отстринает
  List<String> plannedIds = widget.report.description
  .split(',').map((e) => e.trim()).toList();

  //
  // List<String> ids = widget.report.description.split(',').map((e) => e.trim()).toList();

  return Column(
    children: [
      // БЛОК ТРЕБОВАНИЙ (показывается один раз наверху)
      Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: Colors.blueGrey[50],
          border: Border(bottom: BorderSide(color: Colors.grey[300]!)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "ТРЕБОВАНИЯ И ИНСТРУКЦИИ",
              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blueGrey, fontSize: 12),
            ),
            const SizedBox(height: 8),
            // Text(
            //   // Проверяем, есть ли описание, если нет - пишем "Не указаны"
            //   (widget.report.description.isNotEmpty)
            //       ? ids.map((id) => formulaNames[id] ?? id).join(', ')
            //       : "Инструкции к выполнению не указаны",
            //   style: const TextStyle(fontSize: 14, color: Colors.black87),
            // ),
            _buildRequirementsLinks(),
          ],
        ),
      ),

      Expanded(
        child: _calculations.isEmpty
            ? const Center(child: Text("В отчёте пока нет формул"))
            : ListView.builder(
                itemCount: _calculations.length,
                itemBuilder: (context, index) {
                  final calc = _calculations[index];
                  final isSelected = _selectedIds.contains(calc.id);

                  // продолжения для подсвечивания лишнего
                  bool isExtra = !plannedIds.contains(calc.formulaId);
                  
                  return Dismissible(
                    key: ValueKey(calc.id),
                    direction: _isSelectionMode ? DismissDirection.none : DismissDirection.endToStart,
                    onDismissed: (direction) async {
                      await repository.deleteCalculationFromReport(calc.id!);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Формула "${calc.title}" удалена')),
                      );
                      _loadCalculations();
                    },
                    background: Container(
                      color: Colors.red,
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: const Icon(Icons.delete, color: Colors.white),
                    ),
                    child: Card(
                      color: isExtra ? Colors.red[50] : (isSelected ? Colors.blueGrey[700] : null),
                      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      shape: RoundedRectangleBorder(
                        side: BorderSide(
                          color: isExtra ? Colors.red : Colors.grey, 
                          width: isExtra ? 2 : 1
                          ),
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                      child: ListTile(
                        title: Text(calc.title, style: TextStyle(color: isSelected ? Colors.white : Colors.black87)),
                        subtitle: Text(
                          "Результат: ${calc.result}",
                          style: TextStyle(color: isSelected ? Colors.white70 : Colors.black54),
                        ),
                        trailing: isExtra ? const Tooltip(
                          message: "Этого замера нет в задании",
                          child: Icon(Icons.warning_amber_rounded, color: Colors.red,),
                          ) : null,
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
              ),
      ),
    ],
  );
}

  Widget _saveBottomBar() {
    return Container(
      height: 60,
      color: Colors.blueGrey[800],
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          InkWell(
            onTap: () async {
              // просто тут прописать логику собирания в json (вынеси если что)
              
              _handleSendClick();
            },
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.save, color: Colors.white),
                Text("Отправить отчёт", style: TextStyle(color: Colors.white)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  

  Future<void> _processReportSending({String? extraComment}) async {
  try {
    final calculationsForReport = await repository.getCalculationsByReportId(widget.report.id!);
    
    final Map<String, dynamic> reportData = {
      'task_id': widget.report.taskId,
      'report_id': widget.report.id,
      'report_title': widget.report.title,
      'objectId': widget.report.objectId,
      'comment': extraComment ?? "По плану",
      'created_at': DateTime.now().toUtc().toIso8601String(),
      'calculations': calculationsForReport.map((calc) => calc.toMap()).toList(),
    };

    String jsonString = jsonEncode(reportData);

    final ApiRepository api = HttpApiRepository();
    
    // 1. Пытаемся отправить
    await api.sendReport(jsonString);
    print("--- [DEBUG] 1. API запрос завершен успешно ---");

    // 2. Меняем статус в базе
    await repository.changeReportStatusToSend([widget.report.id!]);
    print("--- [DEBUG] 2. Статус в БД изменен на 'send' ---");

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Отчёт успешно отправлен!"), backgroundColor: Colors.green),
      );
      // 3. Закрываем саму страницу деталей
      print("--- [DEBUG] 3. Вызываю Navigator.pop для закрытия страницы ---");
      Navigator.pop(context, true); 
    }

  } catch (e) {
    print("--- [DEBUG] ОШИБКА ПРИ ОТПРАВКЕ: $e ---");
    
    // ЕСЛИ ОШИБКА (например, сервер упал ПОСЛЕ того как мы начали слать)
    await repository.changeReportStatusToGenerated([widget.report.id!]);
    
    if (mounted) {
       ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Ошибка сети. Сохранено локально."), backgroundColor: Colors.orange),
      );
      Navigator.pop(context, true);
    }
  }
}

  void _showSendConfirmationDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Подтверждение отправки"),
          content: Text("Вы уверены, что хотите отправить отчёт '${widget.report.title}'? "
              "После отправки он будет доступен диспетчеру на сайте и его нельзя будет изменить."),
          actions: <Widget>[
            TextButton(
              child: const Text("Отмена"),
              onPressed: () => Navigator.of(context).pop(),
            ),
            ElevatedButton( 
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white),
              child: const Text("Да"),
              onPressed: () {
                Navigator.pop(context); 
                _processReportSending(); 
              },
            ),
          ],
        );
      },
    );
  }

  void _showAutoFillDialog(List<Calculation> freshCalcs) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Найдены свежие данные"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text("В истории найдены недавние замеры для этого объекта:"),
            const SizedBox(height: 10),
            // Показываем список того, что нашли
            ...freshCalcs.map((c) => ListTile(
              title: Text(c.title),
              subtitle: Text("Результат: ${c.result}"),
              dense: true,
            )),
            const SizedBox(height: 10),
            const Text("Добавить их в эту задачу?"),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("ОТМЕНА"),
          ),
          ElevatedButton(
            onPressed: () async {
              // Привязываем найденные расчеты к текущему отчету (задаче)
              final ids = freshCalcs.map((c) => c.id!).toList();
              await repository.addCalculationsToReport(ids, widget.report.id!);
              
              if (mounted) {
                Navigator.pop(context);
                _loadCalculations(); // Перезагружаем список на странице
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Данные подтянуты из истории")),
                );
              }
            },
            child: const Text("ДОБАВИТЬ ВСЕ"),
          ),
        ],
      ),
    );
  }

  // для лишних полей
  void _handleSendClick() {
    List<String> planndeIds = widget.report.description
    .split(',').map((e) => e.trim()).toList();
    bool hasExtra = _calculations.any((calc) => !planndeIds.contains(calc.formulaId));

    if (hasExtra) {
      _showExtraDataWarning();
    } else {
      _showSendConfirmationDialog();
    }
  }

  void _showExtraDataWarning() {
    final TextEditingController commentController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.warning, color: Colors.orange),
            SizedBox(width: 10),
            Text("Внеплановые данные"),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text("В отчете есть замеры, которых не было в задании. Пожалуйста, укажите причину добавления:"),
            const SizedBox(height: 10),
            TextField(
              controller: commentController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: "Например: Заметил шум в насосе",
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("ОТМЕНА")),
          ElevatedButton(
            onPressed: () {
              String comment = commentController.text;
              if (comment.isEmpty) {
                // Можно запретить отправку без комментария
                return;
              }
              Navigator.pop(context);
              _processReportSending(extraComment: comment); // Передаем коммент в отправку
            },
            child: const Text("ОТПРАВИТЬ С ПОЯСНЕНИЕМ"),
          ),
        ],
      ),
    );
  }

  Widget _buildRequirementsLinks() {
    List<String> ids = widget.report.description.split(',').map((e) => e.trim()).toList();

    return Wrap(
      spacing: 8.0,
      runSpacing: 4.0,
      children: ids.map((id) {
        final String label = formulaNames[id] ?? id;
        final String? route = formulaRoutes[id];

        return ActionChip(
          avatar: Icon(Icons.calculate_outlined, size: 16, color: Colors.blue[700]),
          label: Text(label, style: const TextStyle(color: Colors.blue)),
          backgroundColor: Colors.blue[50],
          onPressed: route == null 
            ? null 
            : () async {
                // ПЕРЕХОДИМ К ФОРМУЛЕ
                // передаем ID отчета через arguments
                await Navigator.pushNamed(
                  context, 
                  route, 
                  arguments: {
                    'reportId': widget.report.id,
                    'objectId': widget.report.objectId,
                  },
                );
                
                // когда оператор вернется назад (нажмет кнопку "Назад"),
                // мы должны обновить список расчетов в текущем отчете,
                // чтобы новый расчет мгновенно появился в списке.
                _loadCalculations(); 
              },
        );
      }).toList(),
    );
  }

}