import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'screens/login_screen.dart';
import 'screens/patient_login_screen.dart';
import 'screens/doctor_login_screen.dart';
import 'screens/patient_dashboard.dart';
import 'screens/doctor_dashboard_screen.dart';
import 'screens/medical_records_screen.dart';
import 'screens/create_record_screen.dart';
import 'screens/patient_search_screen.dart';
import 'screens/patient_records_screen.dart';
import 'providers/medical_record_provider.dart';
import 'providers/patient_provider.dart';
import 'providers/user_provider.dart';

void main() {
  runApp(const MedicalApp());
}

class MedicalApp extends StatelessWidget {
  const MedicalApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UserProvider()),
        ChangeNotifierProvider(create: (_) => PatientProvider()),
        ChangeNotifierProvider(create: (_) => MedicalRecordProvider()),
      ],
      child: MaterialApp(
        title: 'Carnet Médical - Hôpital Général',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          colorScheme: ColorScheme.fromSwatch(
            primarySwatch: Colors.blue,
            accentColor: Colors.green,
            backgroundColor: Colors.white,
          ),
          appBarTheme: const AppBarTheme(
            elevation: 2,
            centerTitle: true,
            titleTextStyle: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          cardTheme: CardTheme(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          inputDecorationTheme: InputDecorationTheme(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Colors.grey),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Colors.blue, width: 2),
            ),
            filled: true,
            fillColor: Colors.grey.shade50,
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              textStyle: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          visualDensity: VisualDensity.adaptivePlatformDensity,
          useMaterial3: true,
        ),
        debugShowCheckedModeBanner: false,
        initialRoute: '/',
        routes: {
          '/': (context) => const LoginScreen(),
          '/patient-login': (context) => const PatientLoginScreen(),
          '/doctor-login': (context) => const DoctorLoginScreen(),
          '/patient-search': (context) => const PatientSearchScreen(),
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
              
            case '/doctor-dashboard':
              return MaterialPageRoute(
                builder: (context) => const DoctorDashboardScreen(),
              );
              
            case '/medical-records':
              final args = settings.arguments as Map<String, dynamic>;
              return MaterialPageRoute(
                builder: (context) => MedicalRecordsScreen(
                  patientId: args['patientId'],
                  patientName: args['patientName'],
                ),
              );
              
            case '/patient-records':
              final args = settings.arguments as Map<String, dynamic>;
              return MaterialPageRoute(
                builder: (context) => PatientRecordsScreen(
                  patientId: args['patientId'],
                  patientName: args['patientName'],
                  doctorId: args['doctorId'],
                ),
              );
              
            case '/create-record':
              final args = settings.arguments as Map<String, dynamic>?;
              return MaterialPageRoute(
                builder: (context) => CreateRecordScreen(
                  patientId: args?['patientId'],
                ),
              );
              
            default:
              // Retourner une page d'erreur 404
              return MaterialPageRoute(
                builder: (context) => Scaffold(
                  appBar: AppBar(title: const Text('Page non trouvée')),
                  body: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.error_outline,
                          size: 80,
                          color: Colors.grey,
                        ),
                        const SizedBox(height: 20),
                        const Text(
                          '404',
                          style: TextStyle(
                            fontSize: 48,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'Page non trouvée: ${settings.name}',
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.grey,
                          ),
                        ),
                        const SizedBox(height: 30),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.pushNamedAndRemoveUntil(
                              context, '/', (route) => false);
                          },
                          child: const Text('Retour à l\'accueil'),
                        ),
                      ],
                    ),
                  ),
                ),
              );
          }
        },
        // Gérer les routes non trouvées
        onUnknownRoute: (settings) {
          return MaterialPageRoute(
            builder: (context) => Scaffold(
              appBar: AppBar(title: const Text('Erreur')),
              body: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.warning,
                      size: 80,
                      color: Colors.orange,
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Route inconnue',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Impossible de charger: ${settings.name}',
                      style: const TextStyle(color: Colors.grey),
                    ),
                    const SizedBox(height: 30),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pushNamedAndRemoveUntil(
                          context, '/', (route) => false);
                      },
                      child: const Text('Retour à l\'accueil'),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

// Widget de chargement global
class LoadingOverlay extends StatelessWidget {
  final bool isLoading;
  final Widget child;
  
  const LoadingOverlay({
    super.key,
    required this.isLoading,
    required this.child,
  });
  
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        if (isLoading)
          Container(
            color: Colors.black.withOpacity(0.5),
            child: const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            ),
          ),
      ],
    );
  }
}

// Widget pour afficher les messages d'erreur globaux
class ErrorHandler {
  static void showError(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white),
            const SizedBox(width: 10),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }
  
  static void showSuccess(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 10),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }
}