import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';

class DoctorLoginScreen extends StatefulWidget {
  const DoctorLoginScreen({super.key});

  @override
  State<DoctorLoginScreen> createState() => _DoctorLoginScreenState();
}

class _DoctorLoginScreenState extends State<DoctorLoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  
  bool _isLoading = false;
  bool _obscurePassword = true;
  String? _errorMessage;
  
  void _login() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });
      
      // Simulation de connexion
      await Future.delayed(const Duration(seconds: 1));
      
      final email = _emailController.text.trim();
      final password = _passwordController.text.trim();
      
      // Base de données fictive des médecins
      final doctorsDatabase = [
        {
          'id': 'DOC001',
          'name': 'Dr. Martin',
          'email': 'martin@hopital.fr',
          'specialty': 'Cardiologue',
        },
        {
          'id': 'DOC002',
          'name': 'Dr. Sophie',
          'email': 'sophie@hopital.fr',
          'specialty': 'Généraliste',
        },
        {
          'id': 'DOC003',
          'name': 'Dr. Jean',
          'email': 'jean@hopital.fr',
          'specialty': 'Chirurgien',
        },
      ];
      
      final doctor = doctorsDatabase.firstWhere(
        (doc) => doc['email'] == email && password == 'password123',
        orElse: () => {},
      );
      
      if (doctor.isNotEmpty) {
        Provider.of<UserProvider>(context, listen: false).loginAsDoctor(
          doctor['id'] as String,
          doctor['name'] as String,
        );
        
        if (mounted) {
          Navigator.pushReplacementNamed(context, '/doctor-dashboard');
        }
      } else {
        setState(() {
          _errorMessage = 'Email ou mot de passe incorrect';
          _isLoading = false;
        });
      }
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Connexion Personnel'),
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
                
                // Logo et titre
                const Center(
                  child: Column(
                    children: [
                      Icon(
                        Icons.medical_services,
                        size: 80,
                        color: Colors.blue,
                      ),
                      SizedBox(height: 20),
                      Text(
                        'ACCÈS PERSONNEL',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 40),
                
                // Email
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    labelText: 'Email professionnel',
                    prefixIcon: Icon(Icons.email),
                    border: OutlineInputBorder(),
                    hintText: 'exemple@hopital.fr',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Veuillez entrer votre email';
                    }
                    if (!value.contains('@')) {
                      return 'Email invalide';
                    }
                    return null;
                  },
                ),
                
                const SizedBox(height: 20),
                
                // Mot de passe
                TextFormField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  decoration: InputDecoration(
                    labelText: 'Mot de passe',
                    prefixIcon: const Icon(Icons.lock),
                    border: const OutlineInputBorder(),
                    suffixIcon: IconButton(
                      icon: Icon(_obscurePassword 
                          ? Icons.visibility_off 
                          : Icons.visibility),
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
                      backgroundColor: Colors.green,
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
                  color: Colors.green.shade50,
                  child: Padding(
                    padding: const EdgeInsets.all(15),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Identifiants de test :',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                        const SizedBox(height: 10),
                        _buildTestCredential('martin@hopital.fr', 'password123', 'Dr. Martin (Cardio)'),
                        _buildTestCredential('sophie@hopital.fr', 'password123', 'Dr. Sophie (Généraliste)'),
                        _buildTestCredential('jean@hopital.fr', 'password123', 'Dr. Jean (Chirurgie)'),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
  
  Widget _buildTestCredential(String email, String password, String role) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          const Icon(Icons.person, size: 16, color: Colors.green),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              '$email / $password - $role',
              style: const TextStyle(fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }
  
  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}