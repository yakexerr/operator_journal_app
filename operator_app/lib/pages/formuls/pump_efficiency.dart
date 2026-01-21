import 'package:flutter/material.dart';

class PumpEfficiency extends StatefulWidget {
  const PumpEfficiency({super.key});

  @override
  State<PumpEfficiency> createState() => _PumpEfficiencyState();
}

class _PumpEfficiencyState extends State<PumpEfficiency> {
  List todoList = []; // сюда будем записывать дела, следовательно осюда и количество берём
  String _userTODO = '';


  @override
  void initState() {
    super.initState();
    todoList.addAll(['buy Milk', 'go a walk', 'посуду помой']);
  }

  void _menuOpen() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (BuildContext context) {
        return Scaffold(
          appBar: AppBar(title: Text('Меню'),),
          body: Row(
            children: [
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
                }, 
                child: Text('На главную')),
                Text('Простое меню')
            ],),
        );
      })
    );
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[900],
      appBar: AppBar(
        title: Text('TODO List'),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: _menuOpen, 
            icon: Icon(Icons.menu_outlined)
            )
        ],
      ),
      body: ListView.builder( // благодаря нему именно в формате списка
        itemCount: todoList.length, // сколько элеменов в списке
        itemBuilder: (BuildContext context, int index) {
          return Dismissible( // создаём список дел, пункты которого можно смахнуть
            key: Key(todoList[index]), 
            child: Card(
              child: ListTile(
                title: Text(todoList[index]),
                trailing: IconButton(
                  onPressed: () {
                    setState(() {
                      todoList.removeAt(index);
                    });
                  }, 
                  icon: Icon(
                    Icons.delete_sweep,
                    color: Colors.deepOrange,
                    ),
                  ),
                ),
            ), // можем создать что-то вроде карточки
            onDismissed: (direction){
              // if(direction == DismissDirection.endToStart)
              setState(() {
                todoList.removeAt(index);
              });
            } // что делаем после смахивания
            );
        } // как будет построен список
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.greenAccent,
        onPressed: () {
          showDialog(context: context, builder: (BuildContext context){
            return AlertDialog(
              title:  Text('Добавить элемент'),
              content: TextField(
                onChanged: (String value){
                  _userTODO = value;
                },
              ),
              actions: [
                ElevatedButton(onPressed: () {
                  setState(() {
                    todoList.add(_userTODO);
                  });

                  Navigator.of(context).pop();
                },
                child: Text('Добавить'),)
              ],
            );
          });
        },
        child: Icon(
          Icons.add_box,
          color: Colors.white,
        )
        ),
    );
  }
}