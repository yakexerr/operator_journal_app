import 'package:flutter/material.dart';
import 'package:operator_app/utils/navigation_helper.dart';
import 'package:operator_app/widgets/my_app_bar.dart';
import 'package:operator_app/widgets/my_bottom_bar.dart';

class Report extends StatefulWidget {
  const Report({super.key});

  @override
  State<Report> createState() => _ReportState();
}

class _ReportState extends State<Report> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[900],
      appBar: MyAppBar(title: 'Отчёт'),
      
      bottomNavigationBar: MyBottomBar(
        currentIndex: 3, 
        onTap: (index) {
          if (index != 3)
            onBottomNavTaped(context, index);
        }
        ),  
    ); 
  }
}