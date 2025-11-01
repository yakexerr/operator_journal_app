import 'package:flutter/material.dart';

class MyBottomBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;
  const MyBottomBar({
    super.key,
    required this.currentIndex,
    required this.onTap
    });

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      backgroundColor: Colors.grey,
      items: const <BottomNavigationBarItem> [
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: 'Главная'
          ),
        BottomNavigationBarItem(
          icon: Icon(Icons.superscript),
          label: 'Формулы'
          ),
        BottomNavigationBarItem(
          icon: Icon(Icons.history),
          label: 'История'
          ),
        BottomNavigationBarItem(
          icon: Icon(Icons.file_copy),
          label: 'Отчёт'
          ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person),
          label: 'Профиль'
          ),
      ],
      currentIndex: this.currentIndex,
      selectedItemColor: Colors.grey[800],
      onTap: (index) => this.onTap(index),
      type: BottomNavigationBarType.fixed,
      unselectedItemColor: const Color.fromARGB(255, 70, 62, 62),
    );
  }
}