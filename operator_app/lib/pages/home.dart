import 'package:flutter/material.dart';
import 'package:operator_app/models/equipment_object_model.dart';
import 'package:operator_app/models/task.dart';
import 'package:operator_app/repositories/api_repository.dart';
import 'package:operator_app/repositories/calculation_repository.dart';
import 'package:operator_app/models/report_model.dart' as model;
import 'package:operator_app/repositories/http_api_repository.dart';
import 'package:operator_app/repositories/local_db_repository.dart';
import 'package:operator_app/utils/navigation_helper.dart';
import 'package:operator_app/widgets/my_app_bar_for_home_page.dart';
import 'package:operator_app/widgets/my_bottom_bar.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:operator_app/widgets/settings.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}
//final String url = 'https://${Settings.url}/task';

class _HomeState extends State<Home> {
  final CalculationRepository repository = LocalDbRepository();
  List<Task> _tasks = [];
  late Future<List<model.Report>> _homeReportsFuture;
  
  @override
  void initState() {
    super.initState();
    
    _fetchTasksFromServer();
    _loadReports();
    _syncObjects();
  }

  void _loadReports() {
    setState(() {
      _homeReportsFuture = repository.getHomeReports();
    });
  }

    // для сбора с сервера
  Future<void> _fetchTasksFromServer() async {
    final String url = '${Settings.url}/task';

    // Сначала достаем токен из памяти
    final prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString('jwt_token');

    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token', // ПЕРЕДАЕМ ТОКЕН
        }
      );
      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(response.body);
        
        // достаем из локальной БД все задачи (Reports), которые мы уже приняли
        // нужны их айдишки
        final localReports = await repository.getAllReports();
        final acceptedTaskIds = localReports.map((r) => r.taskId).toSet();

        final seenIds = <int>{};
        final List<Task> uniqueAndNewTasks = [];

        for (var json in data) {
          final task = Task.fromMap(json);
          print("--- [DEBUG] Пришла задача с сервера: ID ${task.id}, Title: ${task.title}");

          bool alreadyInDb = acceptedTaskIds.contains(task.id);
          print("--- [DEBUG] Она уже есть в локальной базе? $alreadyInDb");

          if (!seenIds.contains(task.id) && !alreadyInDb) {
              uniqueAndNewTasks.add(task);
              print("--- [DEBUG] Задача добавлена в список на экране");
          }
        } 

        setState(() {
          _tasks = uniqueAndNewTasks;
        });
      }
    } catch (e) {
      print('Ошибка: $e');
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
                              trailing: isSent ? null : IconButton(
                                onPressed: () => _resendReport(rep), 
                                icon: Icon(Icons.refresh, color: Colors.blue,) 
                              ),
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

          VerticalDivider(color: Colors.grey[300], thickness: 2, width: 1),

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

    );
  }

  Future<void> _syncObjects() async {
    final url = Uri.parse('${Settings.url}/objects');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(response.body);
        // Очищаем старые объекты и записываем новые в SQLite
        // В репозитории должен быть метод saveObjects
        await repository.saveObjects(data.map((obj) => EquipmentObject.fromMap(obj)).toList());
        print("--- [SYNC] Объекты обновлены ---");
      }
    } catch (e) {
      print("--- [SYNC] Ошибка синхронизации объектов: $e ---");
    }
  }


  void _acceptTask(Task task) async {
    // создаем отчет локально
    await repository.createReport(task.id, task.title, task.description, task.objectId);

    // Сначала достаем токен из памяти
    final prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString('jwt_token');
    // уведомляем patch запросом
    try {
      await http.patch(
        Uri.parse('${Settings.url}/task/${task.id}'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({'status': 'in_progress'}), // Меняем статус на сервере
      );
      print("--- [HTTP] Статус задачи обновлен на 'in_progress' ---");
    } catch (e) {
      print("--- [HTTP] Ошибка уведомления сервера: $e ---");
    }

    setState(() {
      _tasks.removeWhere((t) => t.id == task.id);
    });
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

  Future<void> _resendReport(model.Report report) async {
    try {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Попытка отправки '${report.title}'..."), duration: Duration(seconds: 1)),
      );
      final calcs = await repository.getCalculationsByReportId(report.id!);
      final Map<String, dynamic> reportData = {
        'task_id': report.taskId, 
        'report_id': report.id,
        'report_title': report.title,
        'objectId': report.objectId,
        'comment': "Повторная отправка", // можно так и оставить
        'created_at': DateTime.now().toUtc().toIso8601String(),
        'calculations': calcs.map((calc) => calc.toMap()).toList(),
      };
      String jsonString = jsonEncode(reportData);


      final ApiRepository api = HttpApiRepository();
      await api.sendReport(jsonString);
      await repository.changeReportStatusToSend([report.id!]);
      _loadReports();

      if(mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Отправка прошла успешно!"))
        );
      }
    } catch (e) {
      if(mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Ошибка: Сервер не доступен"), backgroundColor: Colors.red,),
        );
      }
    }
  }
}