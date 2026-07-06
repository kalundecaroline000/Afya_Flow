import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'firebase_options.dart';
import 'screens/patient_screen.dart';
import 'screens/patient_dashboard.dart';
import 'screens/doctor_dashboard.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
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
      initialRoute: '/login',
      routes: {
        '/login': (context) => const PatientScreen(),
        '/patient_dashboard': (context) => const PatientDashboard(),
        '/doctor_dashboard': (context) => const DoctorDashboard(),
      },
    );
  }
}
