import 'package:flutter/material.dart';

void onBottomNavTaped(BuildContext context, int index) {
  switch(index) {
    case 0:
      Navigator.pushReplacementNamed(context, '/');
      break;
    case 1:
      Navigator.pushReplacementNamed(context, '/formulas_list');
      break;
    case 2:
      Navigator.pushReplacementNamed(context, '/history');
      break;
    case 3:
      Navigator.pushReplacementNamed(context, '/report');
      break;
    case 4:
      Navigator.pushReplacementNamed(context, '/profile');
      break;
  }
}