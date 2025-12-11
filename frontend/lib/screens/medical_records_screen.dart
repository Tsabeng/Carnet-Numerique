import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/medical_record_provider.dart';
import '../providers/patient_provider.dart';
import 'create_record_screen.dart';

import '../models/medical_record.dart';

class MedicalRecordsScreen extends StatefulWidget {
  final String patientId;
  final String patientName;
  final bool isDoctorView;
  final List<MedicalRecord>? records;
  
  const MedicalRecordsScreen({
    super.key,
    required this.patientId,
    required this.patientName,
    this.isDoctorView = false,
    this.records,
  });

  @override
  State<MedicalRecordsScreen> createState() => _MedicalRecordsScreenState();
}

class _MedicalRecordsScreenState extends State<MedicalRecordsScreen> {
  // Initialiser les listes dans le constructeur ou dans initState
  late List<Map<String, dynamic>> _medicalRecords;
  late List<Map<String, dynamic>> _allergies;
  late List<Map<String, dynamic>> _treatments;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
  // Si des records sont fournis, les convertir
  if (widget.records != null) {
    _medicalRecords = widget.records!.map((record) {
      return {
        'date': record.formattedDate,
        'doctor': record.doctorName,
        'service': 'Service ${record.serviceId}',
        'diagnosis': record.diagnosis,
        'prescription': record.prescription,
        'type': record.visitType,
        'originalRecord': record, // Garder une référence
      };
    }).toList();
  } else {
    // Sinon, utiliser les données par défaut
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
    }

    _allergies = [
      {'name': 'Pénicilline', 'severity': 'Sévère', 'since': '2015'},
      {'name': 'Aspirine', 'severity': 'Modérée', 'since': '2018'},
    ];

    _treatments = [
      {'name': 'Atorvastatine', 'dosage': '20mg', 'frequency': '1x/jour soir'},
      {'name': 'Métoprolol', 'dosage': '50mg', 'frequency': '2x/jour'},
    ];
  }

  Future<void> _refreshData() async {
    setState(() {
      _isLoading = true;
    });
    
    await Future.delayed(const Duration(seconds: 1));
    
    setState(() {
      _isLoading = false;
      _loadData();
    });
  }

  @override
  Widget build(BuildContext context) {
    final patientProvider = Provider.of<PatientProvider>(context, listen: false);
    final patient = widget.patientId.isNotEmpty 
        ? patientProvider.getPatientById(widget.patientId)
        : null;
    
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            widget.patientName.isEmpty 
                ? 'Dossiers médicaux' 
                : widget.isDoctorView
                    ? 'Dossier de ${patient?.fullName ?? widget.patientName}'
                    : 'Mon dossier médical',
          ),
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
          actions: [
            if (widget.isDoctorView && widget.patientId.isNotEmpty)
              IconButton(
                icon: const Icon(Icons.add),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => CreateRecordScreen(
                        patientId: widget.patientId,
                      ),
                    ),
                  );
                },
              ),
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: _refreshData,
            ),
          ],
        ),
        body: _isLoading
            ? const Center(
                child: CircularProgressIndicator(),
              )
            : TabBarView(
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
    return RefreshIndicator(
      onRefresh: _refreshData,
      child: _medicalRecords.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.medical_services_outlined,
                    size: 64,
                    color: Colors.grey,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Aucune consultation',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                  ),
                  if (widget.isDoctorView && widget.patientId.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 16),
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => CreateRecordScreen(
                                patientId: widget.patientId,
                              ),
                            ),
                          );
                        },
                        child: const Text('Créer une consultation'),
                      ),
                    ),
                ],
              ),
            )
          : ListView.builder(
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
                                record['type'] ?? 'Consultation',
                                style: const TextStyle(color: Colors.white),
                              ),
                              backgroundColor: _getColorForType(record['type'] ?? 'Consultation'),
                            ),
                            Text(
                              record['date'] ?? '',
                              style: const TextStyle(
                                color: Colors.grey,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        if (record['doctor'] != null)
                          _buildInfoRow('Médecin:', record['doctor']),
                        if (record['service'] != null)
                          _buildInfoRow('Service:', record['service']),
                        const SizedBox(height: 16),
                        if (record['diagnosis'] != null) ...[
                          const Text(
                            'Diagnostic:',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.blue,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(record['diagnosis']),
                        ],
                        if (record['prescription'] != null) ...[
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
                        if (widget.isDoctorView) ...[
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              OutlinedButton(
                                onPressed: () {
                                  _editRecord(record);
                                },
                                child: const Text('Modifier'),
                              ),
                              const SizedBox(width: 8),
                              ElevatedButton(
                                onPressed: () {
                                  _showRecordDetails(record);
                                },
                                child: const Text('Détails'),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
  
  Widget _buildAllergiesTab() {
    return RefreshIndicator(
      onRefresh: _refreshData,
      child: SingleChildScrollView(
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
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Allergies Connues',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (widget.isDoctorView)
                          IconButton(
                            icon: const Icon(Icons.add),
                            onPressed: _addAllergy,
                          ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    if (_allergies.isEmpty)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 20),
                        child: Center(
                          child: Text(
                            'Aucune allergie déclarée',
                            style: TextStyle(color: Colors.grey),
                          ),
                        ),
                      )
                    else
                      ..._allergies.asMap().entries.map((entry) {
                        final index = entry.key;
                        final allergy = entry.value;
                        return Padding(
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
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          allergy['name'],
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        if (widget.isDoctorView)
                                          IconButton(
                                            icon: const Icon(Icons.delete, color: Colors.red, size: 20),
                                            onPressed: () => _removeAllergy(index),
                                          ),
                                      ],
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
                        );
                      }),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Précautions à prendre:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.red,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text('• Toujours informer le personnel médical'),
                    const Text('• Porter le bracelet d\'allergie'),
                    const Text('• Avoir l\'auto-injecteur d\'adrénaline sur soi'),
                    if (widget.isDoctorView)
                      Padding(
                        padding: const EdgeInsets.only(top: 16),
                        child: ElevatedButton(
                          onPressed: _addEmergencyNote,
                          child: const Text('Ajouter une note d\'urgence'),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildTreatmentsTab() {
    return RefreshIndicator(
      onRefresh: _refreshData,
      child: SingleChildScrollView(
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
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Traitements en cours',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (widget.isDoctorView)
                          IconButton(
                            icon: const Icon(Icons.add),
                            onPressed: _addTreatment,
                          ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    if (_treatments.isEmpty)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 20),
                        child: Center(
                          child: Text(
                            'Aucun traitement en cours',
                            style: TextStyle(color: Colors.grey),
                          ),
                        ),
                      )
                    else
                      ..._treatments.asMap().entries.map((entry) {
                        final index = entry.key;
                        final treatment = entry.value;
                        return Padding(
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
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          treatment['name'],
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        if (widget.isDoctorView)
                                          IconButton(
                                            icon: const Icon(Icons.delete, color: Colors.red, size: 20),
                                            onPressed: () => _removeTreatment(index),
                                          ),
                                      ],
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
                        );
                      }),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Instructions importantes:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.orange,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text('• Prendre les médicaments aux heures indiquées'),
                    const Text('• Ne pas arrêter sans avis médical'),
                    const Text('• Signaler tout effet secondaire'),
                    if (widget.isDoctorView)
                      Padding(
                        padding: const EdgeInsets.only(top: 16),
                        child: ElevatedButton(
                          onPressed: _addInstructions,
                          child: const Text('Ajouter des instructions'),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
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
      case 'Urgence':
        return Colors.red;
      case 'Suivi':
        return Colors.purple;
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
      case 'Légère':
        return Colors.yellow;
      default:
        return Colors.grey;
    }
  }

  // Méthodes pour les médecins
  void _editRecord(Map<String, dynamic> record) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Modifier la consultation'),
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

  void _showRecordDetails(Map<String, dynamic> record) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(record['type'] ?? 'Détails'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildInfoRow('Date', record['date'] ?? ''),
              _buildInfoRow('Médecin', record['doctor'] ?? ''),
              _buildInfoRow('Service', record['service'] ?? ''),
              const SizedBox(height: 10),
              const Text(
                'Diagnostic:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(record['diagnosis'] ?? ''),
              const SizedBox(height: 10),
              const Text(
                'Prescription:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(record['prescription'] ?? ''),
            ],
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

  void _addAllergy() {
    showDialog(
      context: context,
      builder: (context) {
        final nameController = TextEditingController();
        final severityController = TextEditingController();
        final sinceController = TextEditingController();
        
        return AlertDialog(
          title: const Text('Ajouter une allergie'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Nom de l\'allergie',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: severityController,
                  decoration: const InputDecoration(
                    labelText: 'Sévérité (Sévère/Modérée/Légère)',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: sinceController,
                  decoration: const InputDecoration(
                    labelText: 'Depuis (année)',
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Annuler'),
            ),
            ElevatedButton(
              onPressed: () {
                if (nameController.text.isNotEmpty && 
                    severityController.text.isNotEmpty) {
                  setState(() {
                    _allergies.add({
                      'name': nameController.text,
                      'severity': severityController.text,
                      'since': sinceController.text.isNotEmpty 
                          ? sinceController.text 
                          : DateTime.now().year.toString(),
                    });
                  });
                  Navigator.pop(context);
                }
              },
              child: const Text('Ajouter'),
            ),
          ],
        );
      },
    );
  }

  void _removeAllergy(int index) {
    setState(() {
      _allergies.removeAt(index);
    });
  }

  void _addTreatment() {
    showDialog(
      context: context,
      builder: (context) {
        final nameController = TextEditingController();
        final dosageController = TextEditingController();
        final frequencyController = TextEditingController();
        
        return AlertDialog(
          title: const Text('Ajouter un traitement'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Nom du médicament',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: dosageController,
                  decoration: const InputDecoration(
                    labelText: 'Dosage (ex: 20mg)',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: frequencyController,
                  decoration: const InputDecoration(
                    labelText: 'Fréquence (ex: 2x/jour)',
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Annuler'),
            ),
            ElevatedButton(
              onPressed: () {
                if (nameController.text.isNotEmpty && 
                    dosageController.text.isNotEmpty) {
                  setState(() {
                    _treatments.add({
                      'name': nameController.text,
                      'dosage': dosageController.text,
                      'frequency': frequencyController.text.isNotEmpty 
                          ? frequencyController.text 
                          : '1x/jour',
                    });
                  });
                  Navigator.pop(context);
                }
              },
              child: const Text('Ajouter'),
            ),
          ],
        );
      },
    );
  }

  void _removeTreatment(int index) {
    setState(() {
      _treatments.removeAt(index);
    });
  }

  void _addEmergencyNote() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Note d\'urgence'),
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

  void _addInstructions() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Instructions médicales'),
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