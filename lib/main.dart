import 'package:flutter/material.dart';
import 'main_screen.dart'; // Import main_screen.dart

void main() {
  runApp(FinanceTrackerApp());
}

class FinanceTrackerApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: FinanceTrackerScreen(), // Panggil screen dari file terpisah
      ),
    );
  }
}
