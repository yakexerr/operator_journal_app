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
      backgroundColor: Colors.white,
      appBar: MyAppBar(title: 'Профиль'),
      body: SafeArea(
        child: Center( 
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center, // выравниваем по центру
            children: [
              SizedBox(height: 40), // отступ сверху
              CircleAvatar(
                radius: 50, // радиус аватара
                backgroundImage: AssetImage('assets/_.jpeg'), // правильный путь до фото
              ),
              SizedBox(height: 20), // отступ между аватаром и текстом
              Text(
                'Name Lastname',
                style: TextStyle(fontSize: 25, color: Colors.black),
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