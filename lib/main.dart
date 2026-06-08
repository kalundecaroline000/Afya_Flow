import 'package:flutter/material.dart';
import 'screens/patient_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
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
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
        scaffoldBackgroundColor: const Color(0xFFF8F9FA),
      ),
      home: const PatientScreen(),
    );
  }
}