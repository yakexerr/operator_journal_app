import 'package:flutter/material.dart';
import 'package:operator_app/models/calculation_model.dart';
import 'package:operator_app/models/report_model.dart';
import 'package:operator_app/repositories/local_db_repository.dart';
import 'package:operator_app/utils/navigation_helper.dart';
import 'package:operator_app/widgets/action_bottom_bar_with_report.dart';
import 'package:operator_app/widgets/my_app_bar.dart';
import 'package:operator_app/widgets/my_bottom_bar.dart';
import 'package:operator_app/repositories/calculation_repository.dart';
import 'package:operator_app/widgets/selection_app_bar.dart';

class History extends StatefulWidget {
  const History({super.key});

  @override
  State<History> createState() => _HistoryState();
}

class _HistoryState extends State<History> {

  @override
  void initState() {
    super.initState();
    _loadCalcs(); // Этого достаточно
  }


  bool _isSelectionMode = false;
  final Set<int> _selectedIds = {};
  // late Future<List<Calculation>> _calculationsFuture;
  final CalculationRepository repository = LocalDbRepository();


  // для поиска
  final _searchController = TextEditingController();
  List<Calculation> _allCalcs = [];      // Все отчеты из БД
  List<Calculation> _filteredCalcs = []; // Отфильтрованные поиском
  bool _isLoading = true;                // Флаг для индикатора загрузки


  void _loadCalcs() async {
    setState(() {
      _isLoading = true;
    });
    final calcs = await repository.getAllCalculations();

    setState(() {
      _allCalcs = calcs;
      _filteredCalcs = calcs;
      _isLoading = false;
    });
  }


  // это панелька с отчётами в которые можно добавить формулы
  // В _HistoryState
  void _showReportSelectionSheet(BuildContext context, Set<int> selectedIds) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext bc) {
        // Используем FutureBuilder, чтобы загрузить список отчетов
        return FutureBuilder<List<Report>>(
          future: repository.getReportsByStatus('draft'), // Вызываем метод из репозитория
          builder: (context, snapshot) {
            if (!snapshot.hasData) return Center(child: CircularProgressIndicator());
            
            final reports = snapshot.data!;
            
            return ListView.builder(
              itemCount: reports.length,
              itemBuilder: (context, index) {
                final report = reports[index];
                return ListTile(
                  leading: Icon(Icons.description),
                  title: Text(report.title),
                  onTap: () {
                    Navigator.pop(context); // Сначала закрываем окошко
                    // Вызываем следующее действие - подтверждение
                    _showConfirmationDialog(context, selectedIds, report);
                  },
                );
              },
            );
          },
        );
      },
    );
  }

  void _showConfirmationDialog(BuildContext context, Set<int> selectedIds, Report report) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Подтверждение"),
          content: Text("Вы уверены, что хотите добавить ${selectedIds.length} расчетов в отчет '${report.title}'?"),
          actions: <Widget>[
            TextButton(
              child: Text("Нет"),
              onPressed: () => Navigator.of(context).pop(), // Просто закрыть диалог
            ),
            TextButton(
              child: Text("Да"),
              onPressed: () async { // делаем асинхронным
                // выполняем основное действие
                await repository.addCalculationsToReport(selectedIds.toList(), report.id!);
                Navigator.of(context).pop(); // закрываем диалог
                
                // очищаем выбор и выходим из режима выбора
                setState(() {
                  _isSelectionMode = false;
                  _selectedIds.clear();
                });

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Расчеты добавлены в отчет!'))
                );
              },
            ),
          ],
        );
      },
    );
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
          : MyAppBar(title: 'История'),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column( 
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextField(
                    controller: _searchController,
                    onChanged: _filteredCalculations,
                    decoration: const InputDecoration(
                      labelText: 'Поиск результатов',
                      prefixIcon: Icon(Icons.search),
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                
                Expanded(
                  child: _allCalcs.isEmpty
                      ? const Center(child: Text("История пока пуста", style: TextStyle(color: Colors.grey, fontSize: 24)))
                      : _filteredCalcs.isEmpty
                          ? const Center(child: Text("Ничего не найдено", style: TextStyle(color: Colors.grey, fontSize: 24)))
                          : ListView.builder(
                              itemCount: _filteredCalcs.length,
                              itemBuilder: (context, index) {
                                final calc = _filteredCalcs[index];
                                final isSelected = _selectedIds.contains(calc.id);

                                // логика определения: нужен ли заголовок?
                                bool showHeader = false;
                                DateTime currentDay = DateTime.parse(calc.createdAt).toLocal();

                                if (index == 0) {
                                  showHeader = true;
                                } else {
                                  DateTime previousDay = DateTime.parse(_filteredCalcs[index - 1].createdAt).toLocal();
                                  if (currentDay.day != previousDay.day || 
                                      currentDay.month != previousDay.month || 
                                      currentDay.year != previousDay.year) {
                                    showHeader = true;
                                  }
                                }

                                // переделал на COLUMN, чтобы заголовок встал над карточкой
                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.start, // прижать заголовок влево
                                  children: [
                                    if (showHeader)
                                      Padding(
                                        padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
                                        child: Text(
                                          
                                          _formatDate(calc.createdAt).toUpperCase(),
                                          style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.blueGrey[400],
                                            letterSpacing: 1.2,
                                          ),
                                        ),
                                      ),
                                    
                                    
                                    Dismissible(
                                      key: ValueKey(calc.id),
                                      direction: _isSelectionMode ? DismissDirection.none : DismissDirection.endToStart,
                                      onDismissed: (direction) async {
                                        await repository.deleteCalculation(calc.id!);
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(content: Text('Расчет "${calc.title}" удален'))
                                        );
                                        _loadCalcs();
                                      },
                                      background: Container(
                                        color: Colors.red,
                                        alignment: Alignment.centerRight,
                                        padding: const EdgeInsets.symmetric(horizontal: 20),
                                        child: const Icon(Icons.delete, color: Colors.white),
                                      ),
                                      child: Card(
                                        color: isSelected ? Colors.blueGrey[700] : null,
                                        shape: RoundedRectangleBorder(
                                          side: BorderSide(color: Colors.grey.withOpacity(0.5), width: 1), // Сделал чуть тоньше
                                          borderRadius: BorderRadius.circular(12.0)
                                        ),
                                        child: ListTile(
                                          title: Text(calc.title),
                                          // Добавим время замера
                                          subtitle: Text("Результат: ${calc.result} | ${calc.createdAt.substring(11, 16)}"),
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
                                                  if (_selectedIds.isEmpty) _isSelectionMode = false;
                                                } else {
                                                  _selectedIds.add(calc.id!);
                                                }
                                              });
                                            }
                                          },
                                        ),
                                      ),
                                    ),
                                  ],
                                );
                              },
                            ),
                )
              ],
            ),
      bottomNavigationBar: _isSelectionMode
          ? ActionBottomBarWithReport(
              selectedIds: _selectedIds,
              onDelete: () async {
                await repository.deleteCalculations(_selectedIds.toList());
                ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("${_selectedIds.length} записей удалено"))
                );
                _loadCalcs(); 
                setState(() {
                  _isSelectionMode = false;
                  _selectedIds.clear();
                });
              },
              onAddToReport: () {
                _showReportSelectionSheet(context, _selectedIds);
              },
            )
          : MyBottomBar(
              currentIndex: 2,
              onTap: (index) {
                if (index != 2) onBottomNavTaped(context, index);
              }),
    );
  }

  void _filteredCalculations(String query) {
    setState(() {
      _filteredCalcs = _allCalcs.where(
        (calc) => calc.title.toLowerCase().contains(query.toLowerCase())
      ).toList();
    });
  }


  // для красивой даты
  String _formatDate(String isoDate) {
    DateTime date = DateTime.parse(isoDate).toLocal();
    List<String> months = ['января', 'февраля', 'марта',
    'апреля', 'мая', 'июня', 'июля', 'авгуса', 'сентября',
    'октября', 'ноября' , 'декабря'];

    // проверка на "Сегодня" для пущего эффекта
    DateTime now = DateTime.now();
    if (date.day == now.day && date.month == now.month && date.year == now.year) {
      return "Сегодня";
    }

    return "${date.day} ${months[date.month - 1]}";
  }

}