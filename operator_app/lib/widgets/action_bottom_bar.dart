import 'package:flutter/material.dart';

class ActionBottomBar extends StatelessWidget{
  
  // список id, которые нужно обработать
  final Set<int> selectedIds;
  
  // ФУНКЦИЯ-КОЛБЭК, которая вызовется при нажатии "удалить"
  final VoidCallback onDelete; 

  
  const ActionBottomBar({
    super.key,
    required this.selectedIds,
    required this.onDelete,
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
                Text('Удалить', style: TextStyle(color: const Color.fromARGB(255, 0, 0, 0))),
              ],
            ),
          ),
        ],
      ),
    );

  }
}