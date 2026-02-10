import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:flutter/services.dart' show rootBundle;
import 'package:printing/printing.dart';
import 'package:operator_app/models/calculation_model.dart';

class PdfGenerator {
  
  // метод, который создает простейший пдф с русским текстом
  static Future<Uint8List> generateReport(String title, List<Calculation> calculations) async {
    
    // Создаем сам пдф документ в памяти
    final doc = pw.Document();

    // загружаем наш шрифт из ассетов
    final fontData = await rootBundle.load("assets/fonts/DejaVuSansMono.ttf");
    final ttf = pw.Font.ttf(fontData);

    doc.addPage(
      pw.Page(
        // Применяем наш шрифт ко всей странице
        theme: pw.ThemeData.withFont(base: ttf),
        
        // Строим содержимое страницы
        build: (pw.Context context) {
          return pw.Center(
            child: pw.Text(
              'Привет, мир! Это мой первый PDF.',
              style: pw.TextStyle(fontSize: 24),
            ),
          ); 
        },
      ),
    ); 

    // сохраняю документ в виде набора байтов и возвращаем его
    return doc.save();
  }

  static Future<void> createAndShowPdf(String title, List<Calculation> calculations) async {
    // генерируем данные то есть вызываем свой же метод
    final Uint8List pdfData = await generateReport(title, calculations);
    
    // показываем предпросмотр
    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdfData,
    );
  }
}