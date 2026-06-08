import 'package:flutter/material.dart';
import 'screens/patient_screen.dart'; // Updated to match current file name

void main() {
  runApp(const AfyaFlowApp());
}

class AfyaFlowApp extends StatelessWidget {
  const AfyaFlowApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AfyaFlow',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.teal,
          primary: Colors.teal,
        ),
        scaffoldBackgroundColor: const Color(0xFFF8F9FA),
      ),
      home: const LoginScreen(),
    );
  }
}