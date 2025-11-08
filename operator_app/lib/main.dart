import 'package:flutter/material.dart';
import 'package:operator_app/pages/formuls/pump_efficiency.dart';
import 'package:operator_app/pages/formulas_list.dart';
import 'package:operator_app/pages/home.dart';
import 'package:operator_app/pages/profile.dart';
import 'package:operator_app/pages/history.dart';
import 'package:operator_app/pages/report.dart';

void main() => runApp(MaterialApp(
  initialRoute: '/',
  routes: {
    '/': (context) => Home(),
    '/formulas_list' : (context) => FormulasList(),
    '/profile' : (context) => Profile(),
    '/history': (context) => History(),
    '/report': (context) => Report(),

    '/pump_efficiency' : (context) => PumpEfficiency(), 
  }
));