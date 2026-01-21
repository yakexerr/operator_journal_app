import 'package:flutter/material.dart';
import 'package:operator_app/models/calculation_model.dart';
import 'package:operator_app/repositories/local_db_repository.dart';
import 'package:operator_app/repositories/calculation_repository.dart';

class TestPage extends StatefulWidget {
  const TestPage({super.key});

  @override
  State<TestPage> createState() => _TestPageState();
}

class _TestPageState extends State<TestPage> {
  
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[900],
      appBar: AppBar(
        title: Text('Test Page'),
        centerTitle: true,
        
      ),
      
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.greenAccent,
        // Пример для кнопки "Сохранить"
        onPressed: () async { // Делаем обработчик асинхронным
          
          // 1. Создаем репозиторий
          final CalculationRepository repository = LocalDbRepository();


          // 2. Создаем объект с тестовыми данными
          final newCalculation = Calculation(
            title: 'Тестовый расчет насоса',
            result: 123.45,
            createdAt: DateTime.now().toIso8601String(), // Текущая дата и время
          );

          // 3. Вызываем метод для сохранения
          await repository.createCalculation(newCalculation);
          
          // 4. Показываем сообщение, что все получилось
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Тестовый расчет сохранен!'))
          );
        },
        child: Icon(
          Icons.add_box,
          color: Colors.white,
        )
        ),
    );
  }
}
