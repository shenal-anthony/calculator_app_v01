import 'package:calculator_app_v01/calculator_v01.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Calculator app',
      theme: ThemeData.dark(),
      home: const CalculatorScreen(),
      debugShowCheckedModeBanner: false, // Hides the debug banner
    );
  }
}

