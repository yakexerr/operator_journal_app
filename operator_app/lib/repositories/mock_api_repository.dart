// Файл: lib/repositories/mock_api_repository.dart
import 'package:operator_app/repositories/api_repository.dart';

class MockApiRepository implements ApiRepository {
  @override
  Future<void> sendReport(String jsonReport) async {
    print("--- [MockAPI] Имитация отправки данных на сервер... ---");
    await Future.delayed(const Duration(seconds: 2));
    print("--- [MockAPI] Данные успешно отправлены! ---");
    print("Отправленный JSON: $jsonReport");
  }
}
