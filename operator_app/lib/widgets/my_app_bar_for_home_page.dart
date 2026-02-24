import 'package:flutter/material.dart';

class MyAppBarForHomePage extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  // Объявляем параметр для функции
  final VoidCallback onRefresh; 

  const MyAppBarForHomePage({
    super.key, 
    required this.title, 
    required this.onRefresh, // требуем передать её при создании
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(title),
      centerTitle: true,
      backgroundColor: const Color.fromARGB(255, 133, 212, 248),
      actions: [
        IconButton(
          // вызываем переданную функцию
          onPressed: onRefresh, 
          icon: const Icon(Icons.refresh),
        )
      ]
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}