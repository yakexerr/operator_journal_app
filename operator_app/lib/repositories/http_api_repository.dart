// import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:operator_app/repositories/api_repository.dart';
import 'package:operator_app/widgets/settings.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HttpApiRepository implements ApiRepository {

  @override
  Future<void> sendReport(String jsonReport) async {
    final url = Uri.parse('${Settings.url}/reports');

    // Сначала достаем токен из памяти
    final prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString('jwt_token');
    print(" --- [HTTPS] отправка отчёта на сервер ---");
    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json', // это чтобы веб знал тчо я даю именно json
          'Authorization': 'Bearer $token', // ПЕРЕДАЕМ ТОКЕН
        },
        body: jsonReport,
      );

      if(response.statusCode == 201 || response.statusCode == 200) {
        print(" --- [HTTPS] Успешная отправка, ответ: ${response.statusCode} --- ");

      } else {
        throw Exception("Ошибка сервера: ${response.statusCode}");
      }
    } catch (e) {
      print(" --- [HTTPS] Ошибка сети $e ---");
      rethrow; // прокидываем ошибку для отработки ui
    }
  }
}