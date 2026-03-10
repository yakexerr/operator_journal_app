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
    Formula(
      title:'Рассчёт эффективности насоса',
      routeName: '/pump_efficiency', 
      ),


    Formula(
      title: 'Гидростатическое давление столба жидкости',
      routeName: '/hidrostatic_pressure', 
      ),

    Formula(
      title: 'Универсальная газовая формула',
      routeName: '/universal_gas_formula', 
      ),

    Formula(
      title: 'Объём обсаженного ствола скважины',
      routeName: '/v_obsash_stvola', 
      ),

    Formula(
      title: 'Объём открытого ствола скважины',
      routeName: '/v_otkr_stvola', 
      ),

    Formula(
      title: 'Объём скважины без инструмента',
      routeName: '/v_skv_bez_instr', 
      ),

    Formula(
      title: 'Объём скважины с инструментом',
      routeName: '/v_skv_s_instr', 
      ),

    Formula(
      title: 'Объём затруба',
      routeName: '/v_zatruba', 
      ),

    Formula(
      title: 'Время прокачивания трубного объёма',
      routeName: '/t_prok_trub_v', 
      ),

    Formula(
      title: 'Время прокачивания всего объёма скважины объёма',
      routeName: '/t_prokach_all_v_shidk', 
      ),

    Formula(
      title: 'Время вымыва затрубного пространства',
      routeName: '/t_vim_zatrub_protsr', 
      ),

    Formula(
      title: 'Объём в инструменте (V инстр)',
      routeName: '/v_v_instrum', 
      ),
    Formula(
      title: 'Объём металла (Vмет)',
      routeName: '/v_metalla', 
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
      backgroundColor: Colors.white,
      appBar: MyAppBar(title: 'Формулы'),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column (
          children: [
            // поле для поиска
            Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextField(
                    controller: _searchController,
                    onChanged: _fiterFormulas, // Фильтруем при каждом нажатии клавиши
                    decoration: const InputDecoration(
                      labelText: 'Поиск формул',
                      prefixIcon: Icon(Icons.search),
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
            SizedBox(height: 10,),
            // список
            Expanded(
              child: _filtredFormulaList.isEmpty 
              ? const Center(child: Text("Ничего не найдено", style: TextStyle(color: Colors.grey, fontSize: 24),))
              : ListView.builder(
                itemCount: _filtredFormulaList.length,
                itemBuilder: (BuildContext content, int index) {
                  final formula = _filtredFormulaList[index];
                  return Card(
                    // elevation: 4.0,
                    shape: RoundedRectangleBorder(
                      side: BorderSide(
                        color: Colors.grey.withOpacity(0.5),
                        width: 3,
                      ),
                      borderRadius: BorderRadius.circular(12.0)
                    ),
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