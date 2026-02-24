// import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:operator_app/repositories/api_repository.dart';

class HttpApiRepository implements ApiRepository {

  @override
  Future<void> sendReport(String jsonReport) async {
    final url = Uri.parse('http://192.168.1.10:3000/reports');
    print(" --- [HTTP] отправка отчёта на сервер ---");
    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json', // это чтобы веб знал тчо я даю именно json
        },
        body: jsonReport,
      );

      if(response.statusCode == 201 || response.statusCode == 200) {
        print(" --- [HTTP] Успешная отправка, ответ: ${response.statusCode} --- ");

      } else {
        throw Exception("Ошибка сервера: ${response.statusCode}");
      }
    } catch (e) {
      print(" --- [HTTP] Ошибка сети $e ---");
      rethrow; // прокидываем ошибку для отработки ui
    }
  }
}