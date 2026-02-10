import 'package:flutter/material.dart';
import 'package:operator_app/models/calculation_model.dart';
import 'package:operator_app/models/report_model.dart';
import 'package:operator_app/repositories/local_db_repository.dart';
import 'package:operator_app/utils/navigation_helper.dart';
import 'package:operator_app/widgets/my_app_bar.dart';
import 'package:operator_app/widgets/my_bottom_bar.dart';
import 'package:operator_app/repositories/calculation_repository.dart';

class History extends StatefulWidget {
  const History({super.key});

  @override
  State<History> createState() => _HistoryState();
}

class _HistoryState extends State<History> {

  @override
  void initState() {
    super.initState(); // Всегда вызывайте super.initState() в самом начале
    
    // ВЫПОЛНЯЕМ "ОБЕЩАНИЕ":
    // Запускаем загрузку данных один раз, когда страница создается.
    _calculationsFuture = repository.getAllCalculations(); 
  }


  bool _isSelectinMode = false;
  final Set<int> _selectedIds = {};

  late Future<List<Calculation>> _calculationsFuture;

  final CalculationRepository repository = LocalDbRepository();

  Widget _buildActionBottomBar() {
    return Container(
      height: 60,
      color: Colors.blueGrey[800],
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly, // равномерное распределение кнопок
        children: [
          InkWell( // делаем область кликабельной для кнопки удаления
            onTap:() async {
              await repository.deleteCalculations(_selectedIds.toList());

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text("${_selectedIds.length} записей удалено"))
              );

              setState(() {
                _calculationsFuture = repository.getAllCalculations();
              });

              _isSelectinMode = false;
              _selectedIds.clear();
            },
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.delete, color: Colors.white),
                Text('Удалить', style: TextStyle(color: Colors.white)),
              ],
            ),
          ),
          // кнопка добавления
          InkWell(
            onTap: () {
              _showReportSelectionSheet(context, _selectedIds);
            },
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.add_to_photos, color: Colors.white), 
                Text("В отчет", style: TextStyle(color: Colors.white)),
              ],
            ),
          )
        ]
        ),
    );
  }

  // это панелька с отчётами в которые можно добавить формулы
  // В _HistoryState
  void _showReportSelectionSheet(BuildContext context, Set<int> selectedIds) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext bc) {
        // Используем FutureBuilder, чтобы загрузить список отчетов
        return FutureBuilder<List<Report>>(
          future: repository.getAllReports(), // Вызываем метод из репозитория
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

  // В _HistoryState
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
              onPressed: () async { // Делаем асинхронным
                // Выполняем основное действие!
                await repository.addCalculationsToReport(selectedIds.toList(), report.id!);
                Navigator.of(context).pop(); // Закрываем диалог
                
                // Очищаем выбор и выходим из режима выбора
                setState(() {
                  _isSelectinMode = false;
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

  // режимный appbar
  AppBar _buildSelectionAppBar() {
    return AppBar(
      leading:  IconButton(
        icon: Icon(Icons.close),
        onPressed: () {
          setState(() {
            _isSelectinMode = false;
            _selectedIds.clear();
          });
        },
      ),
      title: Text('${_selectedIds.length} выбрано'),
      actions: [],
    );
  }
  

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[900],
      appBar: _isSelectinMode
        ? _buildSelectionAppBar()
        : MyAppBar(title: 'История'),
      body: FutureBuilder<List<Calculation>>
      (
        future: _calculationsFuture, 
        builder: (BuildContext context, AsyncSnapshot<List<Calculation>> snapshot){
          if(snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          else if (snapshot.hasError) {
            return Center(child: Text("Ошибка загрузки данных: ${snapshot.error}"));
          }
          else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text("История пока пуста"));
          }
          else {
            final calculations = snapshot.data!;
            return ListView.builder(
              itemCount: calculations.length,
              itemBuilder: (context, index) {
                final calc = calculations[index]; // берем текущий расчет
                final isSelected = _selectedIds.contains(calc.id);

                // оборачиваем нашу карточку в Dismissible
                return Dismissible(
                  
                  // флатер должен уникально идентифицировать каждый элемент, чтобы правильно
                  // его анимировать и удалить, получилось что ID из базы данных самый идеальный ключ
                  key: ValueKey(calc.id),

                  direction: _isSelectinMode ? DismissDirection.none // если в режиме выбора то смахивать нельзя
                  : DismissDirection.endToStart, // иначе можно

                  // ЧТО ДЕЛАТЬ ПОСЛЕ СМАХИВАНИЯ (onDismissed)
                  // эта функция вызовется, когда анимация смахивания завершится
                  onDismissed: (direction) async { // делаем ее асинхронной
                    
                    // вызываем метод удаления из нашего репозитория
                    await repository.deleteCalculation(calc.id!); // calc.id может быть null, '!' говорит, что мы уверены, что он есть

                    // показываем сообщение об успехе
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Расчет "${calc.title}" удален'))
                    );

                    // обновляем UI, чтобы элемент исчез из списка
                    // самый простой способ это удалить элемент из локального списка и вызвать setState
                    setState(() {
                      _calculationsFuture = repository.getAllCalculations();
                    });
                  },

                  // ФОН
                  // это то, что пользователь видит ПОД карточкой, когда смахивает ее
                  background: Container(
                    color: Colors.red,
                    alignment: Alignment.centerRight,
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    child: Icon(Icons.delete, color: Colors.white),
                  ),

                  // ДОЧЕРНИЙ ЭЛЕМЕНТ
                  // это обычный виджет, который можно смахнуть

                  child: Card(
                    color: isSelected ? Colors.blueGrey[700] : null,
                    child: ListTile(
                      title: Text(calc.title),
                      subtitle: Text("Результат: ${calc.result}"),
                      // trailing: Text(calc.createdAt.substring(0, 10)),
                      onLongPress: () {
                        if(!_isSelectinMode) {
                          setState(() {
                            _isSelectinMode = true;
                            _selectedIds.add(calc.id!);
                          });
                        }
                      },
                      onTap: () {
                        if (_isSelectinMode) {
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
        }),
      
      bottomNavigationBar: _isSelectinMode ? _buildActionBottomBar()
      : MyBottomBar(
        currentIndex: 2, 
        onTap: (index) {
          if (index != 2)
            onBottomNavTaped(context, index);
        }
        ),  
    ); 
  }
}