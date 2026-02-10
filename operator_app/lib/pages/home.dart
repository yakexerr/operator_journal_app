import 'package:flutter/material.dart';
import 'package:operator_app/repositories/calculation_repository.dart';
import 'package:operator_app/repositories/local_db_repository.dart';
import 'package:operator_app/utils/navigation_helper.dart';
import 'package:operator_app/utils/pdf_generator.dart';
import 'package:operator_app/widgets/my_app_bar.dart';
import 'package:operator_app/models/report_model.dart' as model;
import 'package:operator_app/widgets/my_bottom_bar.dart';
import 'package:printing/printing.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  late Future<List<model.Report>> _reportsFuture;
  final Set<int> _selectedIds = {};
  bool _isSelectionMode = false;
  final CalculationRepository repository = LocalDbRepository();

  @override
  void initState() {
    super.initState();
    _loadReports();
  }

  void _loadReports() {
    setState(() {
      _reportsFuture = repository.getReportsByStatus('generated');
    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[900],
      appBar: _isSelectionMode ? _buildSelectionAppBar() : MyAppBar(title: 'Главная'),
      body: FutureBuilder<List<model.Report>>(
        future: repository.getReportsByStatus('generated'), 
        builder: (BuildContext context, AsyncSnapshot<List<model.Report>> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text("Ошибка загрузки данных: ${snapshot.error}"));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text("Список отчётов пока пуст"));
          } else {
            final reports = snapshot.data!;
            return ListView.builder(
              itemCount: reports.length,
              itemBuilder: (context, index) {
                final rep = reports[index];
                final isSelected = _selectedIds.contains(rep.id);
                return Dismissible(
                  key: ValueKey(rep.id),
                  direction: _isSelectionMode ? DismissDirection.none : DismissDirection.endToStart,
                  onDismissed: (direction) async {
                    await repository.changeReportStatusToDraft([rep.id!]);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Отчет "${rep.title}" удален')),
                    );
                    _loadReports(); // Перезагружаем список
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
                      title: Text(rep.title),
                      onLongPress: () {
                        if (!_isSelectionMode) {
                          setState(() {
                            _isSelectionMode = true;
                            _selectedIds.add(rep.id!);
                          });
                        }
                      },
                      onTap: () {
                        if (_isSelectionMode) {
                          setState(() {
                            if (isSelected) {
                              _selectedIds.remove(rep.id!);
                            } else {
                              _selectedIds.add(rep.id!);
                            }
                          });
                        }
                        else {
                          _showPdfPreview(rep);
                        }
                      },
                    ),
                  ),
                );
              },
            );
          }
        }
        ),
        bottomNavigationBar: _isSelectionMode ? _buildActionBottomBar() : MyBottomBar(
                currentIndex: 0,
                onTap: (index) {
                  if (index != 0) onBottomNavTaped(context, index);
                },
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
              // ИСПРАВЛЕНО: Вызываем правильный метод deleteReports
              await repository.deleteReports(_selectedIds.toList());
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text("${_selectedIds.length} отчетов удалено")),
              );
              setState(() {
                _isSelectionMode = false;
                _selectedIds.clear();
              });
              _loadReports(); // Перезагружаем список
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

  Future<void> _showPdfPreview(model.Report report) async {
    // получаем список расчетов для этого отчета
    final calculations = await repository.getCalculationsByReportId(report.id!);
    // генерируем PDF
    final pdfData = await PdfGenerator.generateReport(report.title, calculations);
    // показываем экран предпросмотра
    await Printing.layoutPdf(
      onLayout: (format) => pdfData,
    );

    // (на будущее надо сделать) после того, как пользователь закроет предпросмотр,
    // можно спросить "Пометить отчет как отправленный?" и сменить статус на 'sent'
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