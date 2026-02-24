import 'package:flutter/material.dart';
import 'package:operator_app/models/task.dart';
import 'package:operator_app/repositories/calculation_repository.dart';
import 'package:operator_app/models/report_model.dart' as model;
import 'package:operator_app/repositories/local_db_repository.dart';
import 'package:operator_app/utils/navigation_helper.dart';
import 'package:operator_app/widgets/my_app_bar_for_home_page.dart';
import 'package:operator_app/widgets/my_bottom_bar.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}
//final String url = 'http://192.168.1.10:3000/task';

class _HomeState extends State<Home> {
  final CalculationRepository repository = LocalDbRepository();
  List<Task> _tasks = [];
  late Future<List<model.Report>> _homeReportsFuture;

  @override
  void initState() {
    super.initState();
    
    _fetchTasksFromServer();
    _loadReports();
  }

  void _loadReports() {
    setState(() {
      _homeReportsFuture = repository.getHomeReports();
    });
  }

    // для сбора с сервера
  Future<void> _fetchTasksFromServer() async {
    final String url = 'http://localhost:3000/task'; 

    try {
      print("--- Пытаюсь загрузить задачи... ---");
      final response = await http.get(Uri.parse(url));

      print("--- Статус ответа: ${response.statusCode} ---");
      
      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(response.body);
        print("--- Данные получены: $data ---");
        
        setState(() {
          _tasks = data.map((json) => Task.fromMap(json)).toList();
        });
        print("--- Список _tasks успешно обновлен! ---");
      }
    } catch (e) {
      print('--- КРИТИЧЕСКАЯ ОШИБКА: $e ---');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: MyAppBarForHomePage(
        title: 'Главная',
        onRefresh: _fetchTasksFromServer,
        ),
      body: Row(
        children: <Widget>[
          // ЛЕВАЯ КОЛОНКА: ВЫПОЛНЕННО
          Expanded(
            child: Column(
              children: [
                const Padding(
                  padding: EdgeInsets.all(12.0),
                  child: Text("ФИНАЛИЗИРОВАНО", 
                    style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blueGrey)),
                ),
                const Divider(height: 1),
                Expanded(
                  child: FutureBuilder<List<model.Report>>(
                    future: _homeReportsFuture,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      
                      final reports = snapshot.data ?? [];
                      if (reports.isEmpty) {
                        return const Center(child: Text("Нет готовых\nотчетов", 
                          textAlign: TextAlign.center, style: TextStyle(color: Colors.grey, fontSize: 12)));
                      }

                      return ListView.builder(
                        itemCount: reports.length,
                        itemBuilder: (context, index) {
                          final rep = reports[index];
                          // send - зеленая галочка, generated - оранжевое облако
                          bool isSent = rep.status == 'send';

                          return Card(
                            elevation: 2,
                            margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            child: ListTile(
                              contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                              leading: Icon(
                                isSent ? Icons.check_circle : Icons.cloud_upload,
                                color: isSent ? Colors.green : Colors.orange,
                                size: 20,
                              ),
                              title: Text(rep.title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                              subtitle: Text(isSent ? "Отправлено" : "В очереди", 
                                style: TextStyle(fontSize: 10, color: isSent ? Colors.green : Colors.orange)),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),

          // РАЗДЕЛИТЕЛЬ
          VerticalDivider(color: Colors.grey[300], thickness: 2, width: 1),

          // ПРАВАЯ КОЛОНКА: ЗАДАЧИ (пока мокаю из памяти)
          Expanded(
            child: Column(
              children: [
                const Padding(
                  padding: EdgeInsets.all(12.0),
                  child: Text("НОВЫЕ ЗАДАЧИ", 
                    style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blueGrey)),
                ),
                const Divider(height: 1),
                Expanded(
                  child: _tasks.isEmpty
                      ? const Center(child: Text("Задач нет", style: TextStyle(color: Colors.grey, fontSize: 12)))
                      : ListView.builder(
                          itemCount: _tasks.length,
                          itemBuilder: (context, index) {
                            final task = _tasks[index];
                            return Card(
                              elevation: 2,
                              margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              color: Colors.blue[50], // новые задачи выделяем цветом
                              child: ListTile(
                                title: Text(task.title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                                subtitle: Text(task.objectName, style: const TextStyle(fontSize: 11)),
                                trailing: const Icon(Icons.arrow_forward_ios, size: 14),
                                onTap: () => _showTaskInfo(task),
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: MyBottomBar(
        currentIndex: 0,
        onTap: (index) {
          if (index != 0) onBottomNavTaped(context, index);
        },
      ),
      floatingActionButton: SizedBox(
        width: 70,
        height: 70,
        child: FloatingActionButton(
          backgroundColor: const Color.fromARGB(255, 133, 212, 248),
          onPressed: _showCreateTaskDialog,
          child: const Icon(Icons.add_task, size: 30),
        ),
      ),
    );
  }


  void _showCreateTaskDialog() {
    final TextEditingController titleController = TextEditingController();
    final TextEditingController objectNameController = TextEditingController();
    final TextEditingController reqController = TextEditingController(); // для требований

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Имитация нового запроса"),
          content: SingleChildScrollView( // чтобы клавиатура не перекрыла поля
            child: Column(
              mainAxisSize: MainAxisSize.min, // чтобы диалог был компактным
              children: [
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(labelText: "Что сделать (название)"),
                  autofocus: true,
                ),
                TextField(
                  controller: objectNameController,
                  decoration: const InputDecoration(labelText: "Название объекта (скважины)"),
                ),
                TextField(
                  controller: reqController,
                  decoration: const InputDecoration(labelText: "Инструкция/Требования"),
                  maxLines: 2, // чтобы было удобнее писать текст
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              child: const Text("Отмена"),
              onPressed: () => Navigator.of(context).pop(),
            ),
            ElevatedButton(
              child: const Text("Создать задачу"),
              onPressed: () {
                if (titleController.text.isNotEmpty) {
                  // создаем новый объект Task (пока просто в память списка)
                  final newTask = Task(
                    id: DateTime.now().toUtc().millisecondsSinceEpoch, // временный ID
                    title: titleController.text,
                    objectName: objectNameController.text,
                    objectId: 1, // пока захардкодил, или вытащу из БД позже
                    description: reqController.text,
                    createdAt: DateTime.now().toUtc().toIso8601String(),
                  );

                  setState(() {
                    _tasks.add(newTask); // добавляем в твой локальный список на Home
                  });

                  Navigator.of(context).pop();
                }
              },
            ),
          ],
        );
      },
    );
  }


  // чё я написал

  void _acceptTask(Task task) async {
    // создаем отчет на основе задачи
    await repository.createReport(task.title, task.description); 
    
    // удаляем задачу из списка новых, так как она принята
    setState(() {
      _tasks.removeWhere((t) => t.id == task.id);
    });

    // показываем сообщение
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Отчет '${task.title}' создан в черновиках"))
    );

    // можно сразу перекинуть пользователя на вкладку Отчеты
    // но для начала просто уведомления хватит
  }

  void _showTaskInfo(Task task) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(task.title),
      content: Text("Объект: ${task.objectName}\n\nИнструкция:\n${task.description}"),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text("Закрыть")),
        ElevatedButton(
          onPressed: () {
            Navigator.pop(context);
            _acceptTask(task);
          }, 
          child: const Text("ПРИНЯТЬ В РАБОТУ")
        ),
      ],
    ),
  );
}
}