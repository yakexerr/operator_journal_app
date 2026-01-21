import 'package:flutter/material.dart';
import 'package:operator_app/pages/formuls/pump_efficiency.dart';
import 'package:operator_app/pages/formulas_list.dart';
import 'package:operator_app/pages/formuls/test_page.dart';
import 'package:operator_app/pages/home.dart';
import 'package:operator_app/pages/profile.dart';
import 'package:operator_app/pages/history.dart';
import 'package:operator_app/pages/report.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'package:operator_app/pages/formuls/hidrostatic_pressure.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Обязательно для асинхронного main
  databaseFactory = databaseFactoryFfi;
  runApp(MaterialApp(
    initialRoute: '/',
    routes: {
      '/': (context) => Home(),
      '/formulas_list' : (context) => FormulasList(),
      '/profile' : (context) => Profile(),
      '/history': (context) => History(),
      '/report': (context) => Report(),
      '/test': (context) => TestPage(),
      '/hidrostatic_pressure': (context) => HidrostaticPressure(),
      '/pump_efficiency' : (context) => PumpEfficiency(), 
      
  },
));
}