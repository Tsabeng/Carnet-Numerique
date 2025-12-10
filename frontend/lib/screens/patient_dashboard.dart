import 'package:flutter/material.dart';
import 'medical_records_screen.dart';

class PatientDashboard extends StatelessWidget {
  final String patientId;
  final String patientName;
  final Map<String, dynamic> patientData;
  
  const PatientDashboard({
    super.key,
    required this.patientId,
    required this.patientName,
    required this.patientData,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mon Carnet Médical'),
        actions: [
          IconButton(
            icon: const Icon(Icons.exit_to_app),
            onPressed: () {
              Navigator.pushNamedAndRemoveUntil(
                context, '/', (route) => false);
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // En-tête patient
          Container(
            color: Colors.blue.shade50,
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Bonjour, $patientName',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    _buildInfoItem('ID Patient', patientId),
                    const SizedBox(width: 30),
                    _buildInfoItem('Groupe sanguin', patientData['bloodType']),
                    const SizedBox(width: 30),
                    _buildInfoItem('Date de naissance', patientData['birthDate']),
                  ],
                ),
              ],
            ),
          ),
          
          // Menu principal
          Expanded(
            child: GridView.count(
              padding: const EdgeInsets.all(20),
              crossAxisCount: 2,
              crossAxisSpacing: 20,
              mainAxisSpacing: 20,
              childAspectRatio: 1.2,
              children: [
                _buildMenuCard(
                  context,
                  'Dossier Médical',
                  Icons.medical_services,
                  Colors.blue,
                  () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => MedicalRecordsScreen(
                          patientId: patientId,
                          patientName: patientName,
                        ),
                      ),
                    );
                  },
                ),
                _buildMenuCard(
                  context,
                  'Ordonnances',
                  Icons.description,
                  Colors.green,
                  () {
                    _showComingSoon(context, 'Ordonnances');
                  },
                ),
                _buildMenuCard(
                  context,
                  'Rendez-vous',
                  Icons.calendar_today,
                  Colors.orange,
                  () {
                    _showComingSoon(context, 'Rendez-vous');
                  },
                ),
                _buildMenuCard(
                  context,
                  'Analyses',
                  Icons.science,
                  Colors.purple,
                  () {
                    _showComingSoon(context, 'Résultats d\'analyses');
                  },
                ),
                _buildMenuCard(
                  context,
                  'Vaccinations',
                  Icons.medical_information,
                  Colors.red,
                  () {
                    _showComingSoon(context, 'Carnet de vaccination');
                  },
                ),
                _buildMenuCard(
                  context,
                  'Contact',
                  Icons.contact_phone,
                  Colors.teal,
                  () {
                    _showContactInfo(context);
                  },
                ),
              ],
            ),
          ),
          
          // Pied de page
          Container(
            padding: const EdgeInsets.all(15),
            color: Colors.grey.shade100,
            child: const Column(
              children: [
                Text(
                  'Dernière mise à jour: Aujourd\'hui 14:30',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
                SizedBox(height: 5),
                Text(
                  'Données sécurisées et chiffrées',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildInfoItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
  
  Widget _buildMenuCard(
    BuildContext context,
    String title,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(15),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, size: 32, color: color),
              ),
              const SizedBox(height: 15),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  void _showComingSoon(BuildContext context, String feature) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(feature),
        content: Text('Cette fonctionnalité sera disponible prochainement.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
  
  void _showContactInfo(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Contact & Urgences'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('En cas d\'urgence :', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              _buildContactItem('SAMU', '15'),
              _buildContactItem('Pompiers', '18'),
              _buildContactItem('Urgence Européenne', '112'),
              const SizedBox(height: 20),
              const Text('Votre médecin traitant :', style: TextStyle(fontWeight: FontWeight.bold)),
              _buildContactItem('Dr. Martin', '01 23 45 67 89'),
              const SizedBox(height: 20),
              const Text('Service informatique :', style: TextStyle(fontWeight: FontWeight.bold)),
              _buildContactItem('Support technique', 'support@hopital.fr'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('FERMER'),
          ),
        ],
      ),
    );
  }
  
  Widget _buildContactItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          Expanded(child: Text(label)),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}