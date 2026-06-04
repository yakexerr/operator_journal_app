import 'package:shared_preferences/shared_preferences.dart';

class Settings {
  static const String currentHost = "localhost:3000";

  static String get url {
    if (currentHost.contains("onrender.com")) {
      return "https://$currentHost"; 
    } else {
      return "http://$currentHost"; 
    }
  }

  static Future<Map<String, String>> getHeaders() async {
    final prefs = await SharedPreferences.getInstance();
    // Берем токен, который сохранил при логине
    final String? token = prefs.getString('jwt_token'); 

    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token', // Bearer-токен для проверки на сервере
    };
  }
}