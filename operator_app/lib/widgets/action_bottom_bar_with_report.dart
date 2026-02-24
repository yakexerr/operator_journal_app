import 'package:flutter/material.dart';

class ActionBottomBarWithReport extends StatelessWidget {
  // список id, которые нужно обработать
  final Set<int> selectedIds;
  
  // ФУНКЦИЯ-КОЛБЭК, которая вызовется при нажатии "удалить"
  final VoidCallback onDelete; 

  // ФУНКЦИЯ-КОЛБЭК, которая вызовется при нажатии "в отчет".
  final VoidCallback onAddToReport;
  
  const ActionBottomBarWithReport({
    super.key,
    required this.selectedIds,
    required this.onDelete,
    required this.onAddToReport,
    });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 60,
      color: const Color.fromARGB(255, 133, 212, 248),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          InkWell(
            onTap: onDelete,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.delete, color: const Color.fromARGB(255, 0, 0, 0)),
                Text('Удалить', style: TextStyle(color: const Color.fromARGB(255, 0, 0, 0),)),
              ],
            ),
          ),
          InkWell(
            onTap: onAddToReport,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.add_to_photos, color: const Color.fromARGB(255, 0, 0, 0),), 
                Text("В отчет", style: TextStyle(color: const Color.fromARGB(255, 0, 0, 0),)),
              ],
            ),
          )
        ],
      ),
    );

  }
}