import 'package:flutter/material.dart';
import 'screens/login_screen.dart';
import 'screens/patient_login_screen.dart';
import 'screens/patient_dashboard.dart';
import 'screens/medical_records_screen.dart';

void main() {
  runApp(const MedicalApp());
}

class MedicalApp extends StatelessWidget {
  const MedicalApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Carnet Médical',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      routes: {
        '/': (context) => const LoginScreen(),
        '/patient-login': (context) => const PatientLoginScreen(),
      },
      onGenerateRoute: (settings) {
        // Gérer les routes avec paramètres
        switch (settings.name) {
          case '/patient-dashboard':
            final args = settings.arguments as Map<String, dynamic>;
            return MaterialPageRoute(
              builder: (context) => PatientDashboard(
                patientId: args['patientId'],
                patientName: args['patientName'],
                patientData: args['patientData'],
              ),
            );
          case '/medical-records':
            final args = settings.arguments as Map<String, dynamic>;
            return MaterialPageRoute(
              builder: (context) => MedicalRecordsScreen(
                patientId: args['patientId'],
                patientName: args['patientName'],
              ),
            );
          default:
            return null;
        }
      },
    );
  }
}