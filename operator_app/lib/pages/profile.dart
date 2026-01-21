import 'package:flutter/material.dart';
import 'package:operator_app/utils/navigation_helper.dart';
import 'package:operator_app/widgets/my_app_bar.dart';
import 'package:operator_app/widgets/my_bottom_bar.dart';

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[900],
      appBar: MyAppBar(title: 'Профиль'),
      body: SafeArea(
        child: Center( // Обернем в Center, чтобы все было по центру
          child: Column( // Используем Column для вертикального расположения
            crossAxisAlignment: CrossAxisAlignment.center, // Выравниваем по центру
            children: [
              SizedBox(height: 40), // Отступ сверху
              CircleAvatar(
                radius: 50, // Зададим радиус аватару
                backgroundImage: AssetImage('assets/_.jpeg'), // Укажите правильный путь
              ),
              SizedBox(height: 20), // Отступ между аватаром и текстом
              Text(
                'Name Lastname',
                style: TextStyle(fontSize: 25, color: Colors.white),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: MyBottomBar(
        currentIndex: 4, 
        onTap: (index) {
          if (index != 4)
            onBottomNavTaped(context, index);
        }
        ),  
    ); 
  }
}