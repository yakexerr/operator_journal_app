import 'package:flutter/material.dart';
import 'package:operator_app/models/report_model.dart' as model;
import 'package:operator_app/pages/report_details_page.dart';
import 'package:operator_app/repositories/calculation_repository.dart';
import 'package:operator_app/repositories/local_db_repository.dart';
import 'package:operator_app/utils/navigation_helper.dart';
import 'package:operator_app/widgets/my_app_bar.dart';
import 'package:operator_app/widgets/my_bottom_bar.dart';

class Report extends StatefulWidget {
  const Report({super.key});

  @override
  State<Report> createState() => _ReportState();
}

class _ReportState extends State<Report> {
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
      _reportsFuture = repository.getAllReports();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[900],
      appBar: _isSelectionMode ? _buildSelectionAppBar() : MyAppBar(title: 'Отчёт'),
      body: FutureBuilder<List<model.Report>>(
        future: repository.getReportsByStatus('draft'),
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
                    await repository.deleteReport(rep.id!);
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
                          Navigator.push(
                            context, 
                            MaterialPageRoute(
                              builder: (context) => ReportDetailsPage(report: rep),
                              )
                            );
                        }
                      },
                    ),
                  ),
                );
              },
            );
          }
        },
      ),
      bottomNavigationBar: _isSelectionMode ? _buildActionBottomBar() : MyBottomBar(
        currentIndex: 3,
        onTap: (index) {
          if (index != 3) onBottomNavTaped(context, index);
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.grey,
        onPressed: () {
          _showCreateReportDialog();
        },
        child: Icon(Icons.add),
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

  // Метод для отображения диалогового окна создания отчета
  void _showCreateReportDialog() {
    final TextEditingController titleController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Создать новый отчет"),
          content: TextField(
            controller: titleController,
            decoration: InputDecoration(hintText: "Название отчета"),
            autofocus: true,
          ),
          actions: [
            TextButton(
              child: Text("Отмена"),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: Text("Создать"),
              onPressed: () async {
                final title = titleController.text;
                if (title.isNotEmpty) {
                  await repository.createReport(title);
                  Navigator.of(context).pop();
                  _loadReports(); // Перезагружаем список, чтобы увидеть новый отчет
                }
              },
            ),
          ],
        );
      },
    );
  }
}