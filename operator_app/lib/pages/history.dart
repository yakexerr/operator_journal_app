import 'package:flutter/material.dart';
import 'package:operator_app/models/calculation_model.dart';
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
  Widget build(BuildContext context) {
    final CalculationRepository repository = LocalDbRepository();
    return Scaffold(
      backgroundColor: Colors.grey[900],
      appBar: MyAppBar(title: 'История'),
      body: FutureBuilder<List<Calculation>>
      (
        future: repository.getAllCalculations(), 
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

                // оборачиваем нашу карточку в Dismissible
                return Dismissible(
                  
                  // флатер должен уникально идентифицировать каждый элемент, чтобы правильно
                  // его анимировать и удалить, получилось что ID из базы данных самый идеальный ключ
                  key: ValueKey(calc.id),

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
                      calculations.removeAt(index);
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
                    child: ListTile(
                      title: Text(calc.title),
                      subtitle: Text("Результат: ${calc.result}"),
                      trailing: Text(calc.createdAt.substring(0, 10)),
                    ),
                  ),
                );
              },
            );
          }
        }),
      
      bottomNavigationBar: MyBottomBar(
        currentIndex: 2, 
        onTap: (index) {
          if (index != 2)
            onBottomNavTaped(context, index);
        }
        ),  
    ); 
  }
}