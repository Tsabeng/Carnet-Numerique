import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/patient_provider.dart';
import '../providers/user_provider.dart';
import 'medical_records_screen.dart';

class PatientCodeAccessScreen extends StatefulWidget {
  const PatientCodeAccessScreen({super.key});

  @override
  State<PatientCodeAccessScreen> createState() => _PatientCodeAccessScreenState();
}

class _PatientCodeAccessScreenState extends State<PatientCodeAccessScreen> {
  final _formKey = GlobalKey<FormState>();
  final _patientCodeController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;

  void _accessPatientRecord() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      await Future.delayed(const Duration(seconds: 1));

      final patientCode = _patientCodeController.text.trim().toUpperCase();
      final patientProvider = Provider.of<PatientProvider>(context, listen: false);

      final patient = patientProvider.getPatientById(patientCode);

      if (patient != null) {
        if (mounted) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => MedicalRecordsScreen(
                patientId: patient.id,
                patientName: patient.fullName,
                isDoctorView: true,
              ),
            ),
          );
        }
      } else {
        setState(() {
          _errorMessage = 'Aucun patient trouvé avec ce code';
          _isLoading = false;
        });
      }
    }
  }

  void _scanQRCode() {
    // TODO: Implémenter le scan QR code
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Scan QR Code'),
        content: const Text('Cette fonctionnalité sera disponible prochainement.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Accès dossier patient'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.qr_code_scanner),
            onPressed: _scanQRCode,
            tooltip: 'Scanner QR Code',
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // En-tête
                const SizedBox(height: 30),
                const Center(
                  child: Column(
                    children: [
                      Icon(
                        Icons.medical_information,
                        size: 80,
                        color: Colors.blue,
                      ),
                      SizedBox(height: 20),
                      Text(
                        'Accès au dossier médical',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 10),
                      Text(
                        'Entrez le code patient pour accéder à son dossier',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 40),
                
                // Information médecin
                Card(
                  color: Colors.blue.shade50,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        const CircleAvatar(
                          backgroundColor: Colors.blue,
                          child: Icon(Icons.person, color: Colors.white),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Dr. ${userProvider.currentUserName ?? ''}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(height: 4),
                              const Text(
                                'Accès professionnel',
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                
                const SizedBox(height: 30),
                
                // Champ code patient
                TextFormField(
                  controller: _patientCodeController,
                  decoration: const InputDecoration(
                    labelText: 'Code patient',
                    prefixIcon: Icon(Icons.person_pin),
                    border: OutlineInputBorder(),
                    hintText: 'Ex: PAT001',
                    helperText: 'Le code patient est généralement affiché sur la carte patient',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Veuillez entrer le code patient';
                    }
                    if (value.length < 4) {
                      return 'Le code doit contenir au moins 4 caractères';
                    }
                    return null;
                  },
                ),
                
                const SizedBox(height: 10),
                
                // Bouton pour voir les codes disponibles
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {
                      _showAvailablePatients();
                    },
                    child: const Text('Voir les codes disponibles'),
                  ),
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
                
                // Bouton d'accès
                const SizedBox(height: 40),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _accessPatientRecord,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: _isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.lock_open),
                              SizedBox(width: 10),
                              Text(
                                'ACCÉDER AU DOSSIER',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                  ),
                ),
                
                // QR Code section
                const SizedBox(height: 40),
                Card(
                  elevation: 3,
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        const Icon(
                          Icons.qr_code,
                          size: 60,
                          color: Colors.blue,
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Scan QR Code',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Scannez le QR code sur la carte patient pour un accès rapide',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.grey),
                        ),
                        const SizedBox(height: 20),
                        OutlinedButton.icon(
                          onPressed: _scanQRCode,
                          icon: const Icon(Icons.qr_code_scanner),
                          label: const Text('SCANNER QR CODE'),
                        ),
                      ],
                    ),
                  ),
                ),
                
                // Information légale
                const SizedBox(height: 30),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Informations importantes:',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.grey,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        '• L\'accès aux dossiers patients est soumis à la confidentialité médicale\n'
                        '• Toute consultation est enregistrée dans l\'historique\n'
                        '• Respectez le secret professionnel',
                        style: TextStyle(fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showAvailablePatients() {
    final patientProvider = Provider.of<PatientProvider>(context, listen: false);
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Patients disponibles'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: patientProvider.patients.length,
            itemBuilder: (context, index) {
              final patient = patientProvider.patients[index];
              return ListTile(
                leading: const CircleAvatar(
                  backgroundColor: Colors.blue,
                  child: Icon(Icons.person, color: Colors.white, size: 20),
                ),
                title: Text(patient.fullName),
                subtitle: Text('Code: ${patient.id}'),
                trailing: IconButton(
                  icon: const Icon(Icons.copy, size: 20),
                  onPressed: () {
                    _patientCodeController.text = patient.id;
                    Navigator.pop(context);
                  },
                ),
                onTap: () {
                  _patientCodeController.text = patient.id;
                  Navigator.pop(context);
                },
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Fermer'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _patientCodeController.dispose();
    super.dispose();
  }
}