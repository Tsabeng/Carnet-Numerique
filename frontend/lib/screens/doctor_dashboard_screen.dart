import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';
import '../providers/medical_record_provider.dart';
import '../providers/patient_provider.dart';
import 'create_record_screen.dart';
import 'medical_records_screen.dart';

class DoctorDashboardScreen extends StatelessWidget {
  const DoctorDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final recordProvider = Provider.of<MedicalRecordProvider>(context);
    final patientProvider = Provider.of<PatientProvider>(context);
    
    final doctorRecords = recordProvider.getRecordsByDoctorId(userProvider.currentUserId ?? '');
    
    return Scaffold(
      appBar: AppBar(
        title: Text('Dr. ${userProvider.currentUserName ?? ''}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              // TODO: Implémenter recherche
            },
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'logout') {
                userProvider.logout();
                Navigator.pushNamedAndRemoveUntil(
                  context, '/', (route) => false);
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'profile',
                child: Row(
                  children: [
                    Icon(Icons.person, size: 20),
                    SizedBox(width: 8),
                    Text('Mon profil'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'settings',
                child: Row(
                  children: [
                    Icon(Icons.settings, size: 20),
                    SizedBox(width: 8),
                    Text('Paramètres'),
                  ],
                ),
              ),
              const PopupMenuDivider(),
              const PopupMenuItem(
                value: 'logout',
                child: Row(
                  children: [
                    Icon(Icons.logout, size: 20, color: Colors.red),
                    SizedBox(width: 8),
                    Text('Déconnexion', style: TextStyle(color: Colors.red)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          // En-tête avec statistiques
          Container(
            padding: const EdgeInsets.all(20),
            color: Colors.blue.shade50,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Bonjour Docteur',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue.shade800,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'Votre tableau de bord médical',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.blue.shade600,
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    _buildStatCard('Patients', patientProvider.patients.length.toString(), Icons.people, Colors.blue),
                    const SizedBox(width: 10),
                    _buildStatCard('Dossiers', recordProvider.records.length.toString(), Icons.folder, Colors.green),
                    const SizedBox(width: 10),
                    _buildStatCard('Aujourd\'hui', '0', Icons.today, Colors.orange),
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
              crossAxisSpacing: 15,
              mainAxisSpacing: 15,
              childAspectRatio: 1.2,
              children: [
                _buildMenuCard(
                  context,
                  'Nouveau Dossier',
                  Icons.add_circle,
                  Colors.blue,
                  () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const CreateRecordScreen(),
                      ),
                    );
                  },
                ),
                _buildMenuCard(
                  context,
                  'Mes Patients',
                  Icons.people,
                  Colors.green,
                  () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => MedicalRecordsScreen(
                          patientId: '',
                          patientName: 'Tous les patients',
                        ),
                      ),
                    );
                  },
                ),
                _buildMenuCard(
                  context,
                  'Dossiers Récents',
                  Icons.history,
                  Colors.orange,
                  () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => MedicalRecordsScreen(
                          patientId: '',
                          patientName: 'Dossiers récents',
                          records: doctorRecords,
                        ),
                      ),
                    );
                  },
                ),
                _buildMenuCard(
                  context,
                  'Calendrier',
                  Icons.calendar_today,
                  Colors.purple,
                  () {
                    _showComingSoon(context, 'Calendrier');
                  },
                ),
                _buildMenuCard(
                  context,
                  'Ordonnances',
                  Icons.description,
                  Colors.teal,
                  () {
                    _showComingSoon(context, 'Ordonnances');
                  },
                ),
                _buildMenuCard(
                  context,
                  'Analyses',
                  Icons.science,
                  Colors.red,
                  () {
                    _showComingSoon(context, 'Analyses');
                  },
                ),
              ],
            ),
          ),
          
          // Liste des derniers dossiers
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border(top: BorderSide(color: Colors.grey.shade300)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Dossiers récents',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Voir tout',
                      style: TextStyle(
                        color: Colors.blue,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                SizedBox(
                  height: 120,
                  child: doctorRecords.isEmpty
                      ? const Center(
                          child: Text(
                            'Aucun dossier créé',
                            style: TextStyle(color: Colors.grey),
                          ),
                        )
                      : ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: doctorRecords.take(5).length,
                          itemBuilder: (context, index) {
                            final record = doctorRecords[index];
                            final patient = patientProvider.getPatientById(record.patientId);
                            return Container(
                              width: 200,
                              margin: const EdgeInsets.only(right: 10),
                              child: Card(
                                child: InkWell(
                                  onTap: () {
                                    // TODO: Voir détail du dossier
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.all(10),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          patient?.fullName ?? 'Patient inconnu',
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const SizedBox(height: 5),
                                        Text(
                                          record.visitType,
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey.shade600,
                                          ),
                                        ),
                                        const SizedBox(height: 5),
                                        Text(
                                          record.formattedDateOnly,
                                          style: const TextStyle(
                                            fontSize: 12,
                                          ),
                                        ),
                                        const Spacer(),
                                        Text(
                                          record.diagnosis,
                                          style: const TextStyle(
                                            fontSize: 12,
                                            color: Colors.blue,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const CreateRecordScreen(),
            ),
          );
        },
        backgroundColor: Colors.blue,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
  
  Widget _buildStatCard(String label, String value, IconData icon, Color color) {
    return Expanded(
      child: Card(
        elevation: 3,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 30, color: color),
              const SizedBox(height: 8),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ),
      ),
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
      elevation: 3,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Padding(
          padding: const EdgeInsets.all(15),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(25),
                ),
                child: Icon(icon, size: 30, color: color),
              ),
              const SizedBox(height: 15),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
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
}