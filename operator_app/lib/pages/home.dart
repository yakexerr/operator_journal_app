import 'package:flutter/material.dart';
import 'package:operator_app/widgets/my_app_bar.dart';
import 'package:operator_app/widgets/my_bottom_bar.dart';
import 'package:operator_app/utils/navigation_helper.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[900],
      appBar: MyAppBar(title: 'Главная'),
      body: Center( // Center, чтобы текст был по центру
        child: Text(
          'Это главная страница',
          style: TextStyle(fontSize: 25, color: Colors.white),
        ),
      ),
      // Не забудьте добавить BottomBar!
      bottomNavigationBar: MyBottomBar(
        currentIndex: 0, // У главной страницы индекс 0
        onTap: (index) {
          if (index != 0) {
            onBottomNavTaped(context, index);
          }
        },
      ),
    );
  }
}