import 'package:flutter/material.dart';
import 'package:operator_app/pages/formuls/pump_efficiency.dart';
import 'package:operator_app/pages/formulas_list.dart';
import 'package:operator_app/pages/formuls/t_prok_trub_v.dart';
import 'package:operator_app/pages/formuls/t_prokach_all_v_shidk.dart';
import 'package:operator_app/pages/formuls/t_vim_zatrub_protsr.dart';
import 'package:operator_app/pages/formuls/universal_gas_formula.dart';
import 'package:operator_app/pages/formuls/v_metalla.dart';
import 'package:operator_app/pages/formuls/v_obsash_stvola.dart';
import 'package:operator_app/pages/formuls/v_otkr_stvola.dart';
import 'package:operator_app/pages/formuls/v_skv_bez_instr.dart';
import 'package:operator_app/pages/formuls/v_skv_s_instr.dart';
import 'package:operator_app/pages/formuls/v_v_instrum.dart';
import 'package:operator_app/pages/formuls/v_zatruba.dart';
import 'package:operator_app/pages/home.dart';
import 'package:operator_app/pages/login.dart';
import 'package:operator_app/pages/profile.dart';
import 'package:operator_app/pages/history.dart';
import 'package:operator_app/pages/report.dart';
import 'package:operator_app/utils/db_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'package:operator_app/pages/formuls/hidrostatic_pressure.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Обязательно для асинхронного main
  databaseFactory = databaseFactoryFfi;

  final user = await DBProvider.getCurrentUser(); 
  final bool isLogin = user != null;

  runApp(
    MaterialApp (
      debugShowCheckedModeBanner: false,
      initialRoute: isLogin ? '/' : '/login',
      routes: {
        '/': (context) => Home(),
        '/login': (context) => LoginPage(),
        '/formulas_list' : (context) => FormulasList(),
        '/profile' : (context) => Profile(),
        '/history': (context) => History(),
        '/report': (context) => Report(),
        '/hidrostatic_pressure': (context) => HidrostaticPressure(),
        '/universal_gas_formula': (context) => UniversalGasFormula(),
        '/pump_efficiency' : (context) => PumpEfficiency(), 
        '/v_obsash_stvola' : (context) => VObsStvola(),
        '/v_otkr_stvola' : (context) => VOtkrStvola(),
        '/v_skv_bez_instr' : (context) => VSkvBezInstr(),
        '/v_skv_s_instr' : (context) => VSkvSInstr(),
        '/v_zatruba' : (context) => VZatruba(),
        '/t_prok_trub_v' : (context) => TProkachTrubV(),
        '/t_prokach_all_v_shidk': (context) => TProkachAllVSkash(),
        '/t_vim_zatrub_protsr': (context) => TVimZatrubProstr(),
        '/v_v_instrum': (context) => VVInstr(),
        '/v_metalla' : (content) => VMetalla(),
      },
    )
  );
}