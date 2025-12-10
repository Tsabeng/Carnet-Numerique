import 'package:flutter/material.dart';

class MedicalRecordsScreen extends StatefulWidget {
  final String patientId;
  final String patientName;
  
  const MedicalRecordsScreen({
    super.key,
    required this.patientId,
    required this.patientName,
  });

  @override
  State<MedicalRecordsScreen> createState() => _MedicalRecordsScreenState();
}

class _MedicalRecordsScreenState extends State<MedicalRecordsScreen> {
  // Initialiser les listes dans le constructeur ou dans initState
  late List<Map<String, dynamic>> _medicalRecords;
  late List<Map<String, dynamic>> _allergies;
  late List<Map<String, dynamic>> _treatments;

  @override
  void initState() {
    super.initState();
    
    // Initialiser les données
    _medicalRecords = [
      {
        'date': '15/01/2024',
        'doctor': 'Dr. Martin',
        'service': 'Cardiologie',
        'diagnosis': 'Contrôle annuel - Tout va bien',
        'prescription': 'Continuer le traitement habituel',
        'type': 'Consultation',
      },
      {
        'date': '10/12/2023',
        'doctor': 'Dr. Dubois',
        'service': 'Radiologie',
        'diagnosis': 'Radio thoracique normale',
        'prescription': 'Aucune',
        'type': 'Examen',
      },
      {
        'date': '25/11/2023',
        'doctor': 'Dr. Petit',
        'service': 'Médecine Générale',
        'diagnosis': 'Grippe saisonnière',
        'prescription': 'Paracétamol 1g 3x/jour pendant 5 jours\nRepos',
        'type': 'Consultation',
      },
      {
        'date': '15/10/2023',
        'doctor': 'Dr. Leroy',
        'service': 'Laboratoire',
        'diagnosis': 'Analyses sanguines dans les normes',
        'prescription': 'Aucune',
        'type': 'Analyse',
      },
    ];

    _allergies = [
      {'name': 'Pénicilline', 'severity': 'Sévère', 'since': '2015'},
      {'name': 'Aspirine', 'severity': 'Modérée', 'since': '2018'},
    ];

    _treatments = [
      {'name': 'Atorvastatine', 'dosage': '20mg', 'frequency': '1x/jour soir'},
      {'name': 'Métoprolol', 'dosage': '50mg', 'frequency': '2x/jour'},
    ];
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: Text('Dossier de ${widget.patientName}'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Consultations'),
              Tab(text: 'Allergies'),
              Tab(text: 'Traitements'),
            ],
          ),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: TabBarView(
          children: [
            // Tab 1: Consultations
            _buildConsultationsTab(),
            
            // Tab 2: Allergies
            _buildAllergiesTab(),
            
            // Tab 3: Traitements
            _buildTreatmentsTab(),
          ],
        ),
      ),
    );
  }
  
  Widget _buildConsultationsTab() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _medicalRecords.length,
      itemBuilder: (context, index) {
        final record = _medicalRecords[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Chip(
                      label: Text(
                        record['type'],
                        style: const TextStyle(color: Colors.white),
                      ),
                      backgroundColor: _getColorForType(record['type']),
                    ),
                    Text(
                      record['date'],
                      style: const TextStyle(
                        color: Colors.grey,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _buildInfoRow('Médecin:', record['doctor']),
                _buildInfoRow('Service:', record['service']),
                const SizedBox(height: 16),
                const Text(
                  'Diagnostic:',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
                const SizedBox(height: 8),
                Text(record['diagnosis']),
                const SizedBox(height: 16),
                const Text(
                  'Prescription:',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
                const SizedBox(height: 8),
                Text(record['prescription']),
              ],
            ),
          ),
        );
      },
    );
  }
  
  Widget _buildAllergiesTab() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Allergies Connues',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ..._allergies.map((allergy) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Row(
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: _getSeverityColor(allergy['severity']),
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                allergy['name'],
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                'Sévérité: ${allergy['severity']} - Depuis ${allergy['since']}',
                                style: const TextStyle(
                                  color: Colors.grey,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  )),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          const Card(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Précautions à prendre:',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.red,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text('• Toujours informer le personnel médical'),
                  Text('• Porter le bracelet d\'allergie'),
                  Text('• Avoir l\'auto-injecteur d\'adrénaline sur soi'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildTreatmentsTab() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Traitements en cours',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ..._treatments.map((treatment) => Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: Colors.blue.shade100,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.medical_services,
                            color: Colors.blue,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                treatment['name'],
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                '${treatment['dosage']} - ${treatment['frequency']}',
                                style: const TextStyle(
                                  color: Colors.grey,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  )),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          const Card(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Instructions importantes:',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.orange,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text('• Prendre les médicaments aux heures indiquées'),
                  Text('• Ne pas arrêter sans avis médical'),
                  Text('• Signaler tout effet secondaire'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
  
  Color _getColorForType(String type) {
    switch (type) {
      case 'Consultation':
        return Colors.blue;
      case 'Examen':
        return Colors.green;
      case 'Analyse':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }
  
  Color _getSeverityColor(String severity) {
    switch (severity) {
      case 'Sévère':
        return Colors.red;
      case 'Modérée':
        return Colors.orange;
      default:
        return Colors.yellow;
    }
  }
}