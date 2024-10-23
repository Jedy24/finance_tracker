import 'package:flutter/material.dart';
import 'screen/main_screen.dart'; 

void main() {
  runApp(const FinanceTrackerApp());
}

class FinanceTrackerApp extends StatelessWidget {
  const FinanceTrackerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: FinanceTrackerScreen(),
      ),
    );
  }
}
