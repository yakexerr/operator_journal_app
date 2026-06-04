import 'package:flutter/material.dart';
import 'package:operator_app/models/report_model.dart' as model;
import 'package:operator_app/pages/report_details_page.dart';
import 'package:operator_app/repositories/calculation_repository.dart';
import 'package:operator_app/repositories/local_db_repository.dart';
import 'package:operator_app/utils/navigation_helper.dart';
import 'package:operator_app/widgets/action_bottom_bar.dart';
import 'package:operator_app/widgets/my_app_bar.dart';
import 'package:operator_app/widgets/my_bottom_bar.dart';
import 'package:operator_app/widgets/selection_app_bar.dart';

class Report extends StatefulWidget {
  const Report({super.key});

  @override
  State<Report> createState() => _ReportState();
}

class _ReportState extends State<Report> {
  final CalculationRepository repository = LocalDbRepository();
  final Set<int> _selectedIds = {};
  bool _isSelectionMode = false;

  final _searchController = TextEditingController();
  List<model.Report> _allReports = [];      // Все отчеты из БД
  List<model.Report> _filteredReports = []; // Отфильтрованные поиском
  bool _isLoading = true;                   // Флаг для индикатора загрузки

  @override
  void initState() {
    super.initState();
    _loadReports(); // Загружаем данные при старте
  }

  // Загружаем данные один раз из БД в локальный список
  void _loadReports() async {
    setState(() => _isLoading = true);
    
    final reports = await repository.getReportsByStatus('draft');
    
    setState(() {
      _allReports = reports;
      _filteredReports = reports; // В начале отфильтрованный список равен всем данным
      _isLoading = false;
    });
  }

  // Логика поиска (фильтруем уже имеющийся в памяти список)
  void _filterReports(String query) {
    setState(() {
      _filteredReports = _allReports
          .where((report) => report.title.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
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
              })
          : MyAppBar(title: 'Задача'),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator()) // Ждем загрузку из БД
          : Column(
              children: [
                // ПОЛЕ ПОИСКА
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextField(
                    controller: _searchController,
                    onChanged: _filterReports, // Фильтруем при каждом нажатии клавиши
                    decoration: const InputDecoration(
                      labelText: 'Поиск задач',
                      prefixIcon: Icon(Icons.search),
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                
                // СПИСОК (уже отфильтрованный)
                Expanded(
                  child: _filteredReports.isEmpty
                      ? const Center(child: Text("Ничего не найдено", style: TextStyle(color: Colors.grey, fontSize: 24),))
                      : ListView.builder(
                          itemCount: _filteredReports.length,
                          itemBuilder: (context, index) {
                            final rep = _filteredReports[index];
                            final isSelected = _selectedIds.contains(rep.id);
                            
                            return Card(
                                color: isSelected ? Colors.blueGrey[700] : null,
                                shape: RoundedRectangleBorder(
                                  side: BorderSide(
                                    color: Colors.grey.withOpacity(0.5),
                                    width: 3
                                  ),
                                  borderRadius: BorderRadius.circular(12.0)
                                ),
                                child: ListTile(
                                  title: Text('Задача "${rep.title}"'),
                                  onTap: () async {
                                    final result = await Navigator.push(
                                      context,
                                      MaterialPageRoute(builder: (context) => ReportDetailsPage(report: rep)),
                                    );
                                    if (result == true) _loadReports();
                                  },
                                ),
                              );
                            
                          },
                        ),
                ),
              ],
            ),
      bottomNavigationBar: _isSelectionMode ? _buildSelectionBottomBar() : MyBottomBar(currentIndex: 3, onTap: (i) => onBottomNavTaped(context, i)),
    );
  }
  Widget _buildSelectionBottomBar() {
  return ActionBottomBar(
    selectedIds: _selectedIds,
    onDelete: () async {
      await repository.deleteReports(_selectedIds.toList());
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("${_selectedIds.length} отчетов удалено")),
        );
      }

      setState(() {
        _isSelectionMode = false;
        _selectedIds.clear();
      });
      _loadReports(); 
    },
  );
}
}