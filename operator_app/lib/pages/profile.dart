import 'package:flutter/material.dart';
import 'package:operator_app/models/user.dart';
import 'package:operator_app/repositories/calculation_repository.dart';
import 'package:operator_app/repositories/local_db_repository.dart';
import 'package:operator_app/utils/navigation_helper.dart';
import 'package:operator_app/widgets/my_app_bar.dart';
import 'package:operator_app/widgets/my_bottom_bar.dart';

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  
  final CalculationRepository repository = LocalDbRepository();
  late Future<User?> _userInfoFuture;

  @override
  void initState() {
    super.initState();
    _loadUserInfo(); 
  }

  void _loadUserInfo() {
    setState(() {
      _userInfoFuture = repository.getCurrentUser();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: MyAppBar(title: 'Профиль'),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.account_circle, size: 100, color: Colors.blueGrey),
            const SizedBox(height: 20),
            Expanded(
              child: FutureBuilder<User?>(
                future: _userInfoFuture, 
                builder: (context, snapshot) {
                  if(snapshot.connectionState == ConnectionState.waiting){
                    return Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Text("Ошибка: ${snapshot.error}");
                  } else if (!snapshot.hasData || snapshot.data == null) {
                    return const Text("Пользователь не найден");
                  } else {
                    final user = snapshot.data;
                    return Column(children: [
                      Text(
                        "${user!.name} ${user.lastname}",
                        style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                        ),
                      const SizedBox(height: 20),
                      Text(
                        "Закрепленный объект: ${user.objectId ?? 'Не назначен'}",
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      )
                    ],);
                  }
                }
              )
            ),
            
            // КНОПКА ВЫХОДА
            Padding(
              padding: EdgeInsetsGeometry.only(bottom: 40),
              child: ElevatedButton.icon(
                onPressed: _handleLogout,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red[50],
                  foregroundColor: Colors.red,
                  minimumSize: const Size(200, 50),
                  side: const BorderSide(color: Colors.red),
                ),
                icon: const Icon(Icons.logout),
                label: const Text("ВЫЙТИ ИЗ АККАУНТА"),
                
              ),
              
            )
          ],
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

  void _handleLogout() async {
    // стираем из БД
    await repository.logout();

    if (mounted) {
      // переходим на логин и ОЧИЩАЕМ всю историю переходов
      Navigator.pushNamedAndRemoveUntil(
        context, 
        '/login', 
        (route) => false, // это удаляет все предыдущие маршруты из памяти
      );
    }
  }

}