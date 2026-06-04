import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:operator_app/models/user.dart';
import 'package:operator_app/repositories/calculation_repository.dart';
import 'package:operator_app/repositories/local_db_repository.dart';
import 'package:http/http.dart' as http;
import 'package:operator_app/widgets/settings.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _loginController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false; // Чтобы показывать крутилку во время входа

  final CalculationRepository repository = LocalDbRepository();

  @override
  void dispose() {
    _loginController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // сохраняем в памяти телефона токен полученный
  Future<void> _saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('jwt_token', token);
    print("--- [AUTH] Токен сохранён ---");
  }

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('jwt_token'); 
  }

  // Метод, который мы напишем следующим
  void _handleLogin() async {
    final String login = _loginController.text.trim();
    final String password = _passwordController.text.trim();

    if (login.isEmpty || password.isEmpty) return;

    setState(() => _isLoading = true); // Включаем крутилку

    try {
      final response = await http.post(
        Uri.parse("${Settings.url}/login"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "login": login,
          "password": password,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        // Сервер должен прислать JSON с данными юзера (id, name, lastname, position и т.д.)
        final Map<String, dynamic> userData = jsonDecode(response.body);
        

        // достаю jws токен
        String token = userData['token'];


        // Создаем объект и сохраняем в БД
        final Map<String, dynamic> userMap = userData['user']; 
        final user = User.fromMap(userMap);

        // сохраняем данные и токен
        await repository.saveUser(user);
        await _saveToken(token);
        print("Получен токен: $token");

        if (mounted) {
          // Уходим на главную и очищаем историю навигации (чтобы нельзя было вернуться назад к логину)
          Navigator.pushReplacementNamed(context, '/');
        }
      } else {
        // Ошибка авторизации (неверный пароль и т.д.)
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Ошибка входа: проверьте логин или пароль")),
          );
        }
      }
    } catch (e) {
      print("Ошибка сети: $e");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(title: Text("Авторизация"),
        automaticallyImplyLeading: false,
      ),
      body: Center( // Центрируем форму
        child: SingleChildScrollView( // Защита от перекрытия клавиатурой
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.lock_person, size: 80, color: Colors.blueAccent),
              const SizedBox(height: 30),
              
              TextField(
                controller: _loginController,
                decoration: const InputDecoration(
                  labelText: "Логин",
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person),
                ),
              ),
              const SizedBox(height: 16), // Отступ между полями
              
              TextField(
                controller: _passwordController,
                obscureText: true, // Прячем пароль
                decoration: const InputDecoration(
                  labelText: "Пароль",
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.password),
                ),
              ),
              const SizedBox(height: 24),
              
              _isLoading 
                ? const CircularProgressIndicator() // Показываем лоадер, если грузимся
                : ElevatedButton(
                    onPressed: _handleLogin,
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 55),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text("ВОЙТИ В СИСТЕМУ"),
                  ),
            ],
          ),
        ),
      ),
    );
  }
}