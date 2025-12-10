import 'package:flutter/material.dart';
import 'patient_dashboard.dart';

class PatientLoginScreen extends StatefulWidget {
  const PatientLoginScreen({super.key});

  @override
  State<PatientLoginScreen> createState() => _PatientLoginScreenState();
}

class _PatientLoginScreenState extends State<PatientLoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _patientIdController = TextEditingController();
  final _passwordController = TextEditingController();
  
  bool _isLoading = false;
  bool _obscurePassword = true;
  String? _errorMessage;
  
  // Base de données patients fictive (en attendant le backend)
  final Map<String, Map<String, dynamic>> _patientsDatabase = {
    'PAT001': {
      'password': 'patient123',
      'name': 'Jean Dupont',
      'birthDate': '15/05/1979',
      'bloodType': 'O+',
    },
    'PAT002': {
      'password': 'sante2024',
      'name': 'Marie Martin',
      'birthDate': '22/08/1992',
      'bloodType': 'A+',
    },
    'PAT003': {
      'password': 'med789',
      'name': 'Pierre Durand',
      'birthDate': '30/03/1966',
      'bloodType': 'B+',
    },
    'admin': {
      'password': 'admin123',
      'name': 'Administrateur Test',
      'birthDate': '01/01/1980',
      'bloodType': 'AB+',
    },
  };

  void _login() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      await Future.delayed(const Duration(seconds: 1));

      final patientId = _patientIdController.text.trim().toUpperCase();
      final password = _passwordController.text.trim();

      if (_patientsDatabase.containsKey(patientId) &&
          _patientsDatabase[patientId]!['password'] == password) {
        // Connexion réussie
        final patientData = _patientsDatabase[patientId]!;
        
        Navigator.pushReplacement(
  context,
  MaterialPageRoute(
    builder: (context) => PatientDashboard(
      patientId: patientId,
      patientName: patientData['name'],
      patientData: patientData,
    ),
  ),
);
      } else {
        setState(() {
          _errorMessage = 'Identifiant ou mot de passe incorrect';
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Connexion Patient'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 30),
                
                // Titre
                const Text(
                  'Accès à votre carnet médical',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  'Entrez vos identifiants pour accéder à votre dossier',
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 40),
                
                // Champ identifiant
                TextFormField(
                  controller: _patientIdController,
                  decoration: const InputDecoration(
                    labelText: 'Numéro de patient',
                    prefixIcon: Icon(Icons.person_outline),
                    border: OutlineInputBorder(),
                    hintText: 'Ex: PAT001',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Veuillez entrer votre numéro de patient';
                    }
                    return null;
                  },
                ),
                
                const SizedBox(height: 20),
                
                // Champ mot de passe
                TextFormField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  decoration: InputDecoration(
                    labelText: 'Mot de passe',
                    prefixIcon: const Icon(Icons.lock_outline),
                    border: const OutlineInputBorder(),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility_off
                            : Icons.visibility,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Veuillez entrer votre mot de passe';
                    }
                    if (value.length < 6) {
                      return 'Le mot de passe doit contenir au moins 6 caractères';
                    }
                    return null;
                  },
                ),
                
                // Message d'erreur
                if (_errorMessage != null) ...[
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.red.shade200),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.error_outline, color: Colors.red),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            _errorMessage!,
                            style: const TextStyle(color: Colors.red),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                
                // Bouton de connexion
                const SizedBox(height: 40),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _login,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: _isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text(
                            'SE CONNECTER',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),
                
                // Informations de test
                const SizedBox(height: 30),
                Card(
                  color: Colors.blue.shade50,
                  child: Padding(
                    padding: const EdgeInsets.all(15),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Identifiants de test :',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.blue,
                          ),
                        ),
                        const SizedBox(height: 10),
                        _buildTestCredential('PAT001', 'patient123', 'Jean Dupont'),
                        _buildTestCredential('PAT002', 'sante2024', 'Marie Martin'),
                        _buildTestCredential('admin', 'admin123', 'Admin Test'),
                      ],
                    ),
                  ),
                ),
                
                // Aide
                const SizedBox(height: 30),
                const Center(
                  child: Text(
                    'Problème de connexion ? Contactez le service informatique',
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 14,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
  
  Widget _buildTestCredential(String id, String password, String name) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          const Icon(Icons.person, size: 16, color: Colors.blue),
          const SizedBox(width: 8),
          Text(
            '$id / $password - $name',
            style: const TextStyle(fontSize: 13),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _patientIdController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}