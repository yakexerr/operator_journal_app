import 'package:flutter/material.dart';
import 'package:operator_app/utils/navigation_helper.dart';
import 'package:operator_app/widgets/my_app_bar.dart';
import 'package:operator_app/widgets/my_bottom_bar.dart';

class History extends StatefulWidget {
  const History({super.key});

  @override
  State<History> createState() => _HistoryState();
}

class _HistoryState extends State<History> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[900],
      appBar: MyAppBar(title: 'История'),
      
      bottomNavigationBar: MyBottomBar(
        currentIndex: 2, 
        onTap: (index) {
          if (index != 2)
            onBottomNavTaped(context, index);
        }
        ),  
    ); 
  }
}