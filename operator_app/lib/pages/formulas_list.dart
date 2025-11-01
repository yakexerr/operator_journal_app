import 'package:flutter/material.dart';
import 'package:operator_app/widgets/my_app_bar.dart';
import 'package:operator_app/widgets/my_bottom_bar.dart';
import 'package:operator_app/utils/navigation_helper.dart';


class FormulasList extends StatefulWidget {
  const FormulasList({super.key});

  @override
  State<FormulasList> createState() => _FormulasListState();
}

class Formula {
    final String title;
    final String routeName;

    Formula({required this.title, required this.routeName});
  }


class _FormulasListState extends State<FormulasList> {

  final List<Formula> formulaList = [
    Formula (
      title: 'Проба',
      routeName: '/pump_efficiency'),
    Formula(
      title:'Рассчёт эффективности насоса',
      routeName: 'formuls/pump_efficiency', 
      ),

    Formula(
      title: 'Рассчёт давления на входе',
      routeName: 'formuls/input_pressure', 
      ),

    Formula(
      title: 'Рассчёт дебит скаважины',
      routeName: 'formuls/input_pressure', 
      ),
  ];

  List<Formula> _filtredFormulaList = []; // его показываем юзеру
  final _searchController = TextEditingController(); // для поиска контроллер

  @override
  void initState() {
    super.initState();
      _filtredFormulaList = formulaList; // фильтров нет, значит без изменений
  }

  @override
  void dispose() // закрыл программу - почистил контроллер (зачем?)
  {
    _searchController.dispose();
    super.dispose();
  }


  void _fiterFormulas(String query) {
    List<Formula> filtredList = [];
    if(query.isNotEmpty) {
      for(var formula in formulaList) {
        if(formula.title.toLowerCase().contains(query.toLowerCase())) {
          filtredList.add(formula);
        }
      }
    } else {filtredList = formulaList;}
    setState(() { // обновляю интерфейс
      _filtredFormulaList = filtredList;
    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[900],
      appBar: MyAppBar(title: 'Формулы'),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column (
          children: [
            // поле для поиска
            TextField(
              controller: _searchController,
              style: TextStyle(
                color: Colors.white54,
              ),
              decoration: InputDecoration(
                label: Text('Поиск'),
                hint: Text('Введите формулу'),
                prefix: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: (query) {
                _fiterFormulas(query);
              },
            ),
            SizedBox(height: 10,),
            // список
            Expanded(
              child: ListView.builder(
                itemCount: _filtredFormulaList.length,
                itemBuilder: (BuildContext content, int index) {
                  final formula = _filtredFormulaList[index];
                  return Card(
                    child: ListTile(
                      title: Text(formula.title),
                      trailing: Icon(Icons.arrow_forward),
                      onTap: () {
                        Navigator.pushNamed(context, formula.routeName);
                      }
                    ),
                  );
                },
              ),
            ),
          ],
        )
      ),
      bottomNavigationBar: MyBottomBar(
        currentIndex: 1, 
        onTap: (index) {
          if (index != 1)
            onBottomNavTaped(context, index);
        }
        ),     
    );
  }
}