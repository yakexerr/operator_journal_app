class ApiRepository {
  Future<void> sendReport(String jsonReport) async {
    if(jsonReport.isNotEmpty) {
      print("--- Данные успешно отправлены! ---");
      print("Отправленный JSON: $jsonReport");
    }
    else {
      print("--- Ошибка отправки! ---");
    }
    
  }
}