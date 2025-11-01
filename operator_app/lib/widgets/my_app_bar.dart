import 'package:flutter/material.dart';

class MyAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  const MyAppBar({super.key, required this.title}); // required - параметр обязателен

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(title),
      centerTitle: true,
      backgroundColor: Colors.blueGrey,
    );
  }

  // это как и то что после implements нужно, чтобы я мог использовать в других местах мой AppBar
  // поскольку Scaffold должен знать высоту каждого виджета
  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
