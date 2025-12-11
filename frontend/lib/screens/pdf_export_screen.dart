import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../services/pdf_service.dart';
import '../providers/patient_provider.dart';
import '../providers/user_provider.dart';

class PDFExportScreen extends StatefulWidget {
  const PDFExportScreen({super.key});

  @override
  State<PDFExportScreen> createState() => _PDFExportScreenState();
}

class _PDFExportScreenState extends State<PDFExportScreen> {
  String? _selectedPatientId;
  String _exportType = 'medical_record'; // medical_record, appointment_report
  DateTime _startDate = DateTime.now().subtract(const Duration(days: 30));
  DateTime _endDate = DateTime.now();
  bool _includeAllergies = true;
  bool _includeTreatments = true;
  bool _includeConsultations = true;
  bool _isExporting = false;

  @override
  Widget build(BuildContext context) {
    final patientProvider = Provider.of<PatientProvider>(context);
    final userProvider = Provider.of<UserProvider>(context);
    
    final selectedPatient = _selectedPatientId != null
        ? patientProvider.getPatientById(_selectedPatientId!)
        : null;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Export PDF'),
        actions: [
          if (_isExporting)
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: CircularProgressIndicator(),
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Type d'export
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Type d\'export',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      children: [
                        ChoiceChip(
                          label: const Text('Dossier médical'),
                          selected: _exportType == 'medical_record',
                          onSelected: (selected) {
                            setState(() => _exportType = 'medical_record');
                          },
                        ),
                        ChoiceChip(
                          label: const Text('Rapport rendez-vous'),
                          selected: _exportType == 'appointment_report',
                          onSelected: (selected) {
                            setState(() => _exportType = 'appointment_report');
                          },
                        ),
                        ChoiceChip(
                          label: const Text('Ordonnance'),
                          selected: _exportType == 'prescription',
                          onSelected: (selected) {
                            setState(() => _exportType = 'prescription');
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Sélection patient
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Patient',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      value: _selectedPatientId,
                      decoration: const InputDecoration(
                        labelText: 'Sélectionner un patient',
                        border: OutlineInputBorder(),
                      ),
                      items: [
                        const DropdownMenuItem(
                          value: null,
                          child: Text('Tous les patients'),
                        ),
                        ...patientProvider.patients.map((patient) {
                          return DropdownMenuItem(
                            value: patient.id,
                            child: Text(patient.fullName),
                          );
                        }).toList(),
                      ],
                      onChanged: (value) {
                        setState(() => _selectedPatientId = value);
                      },
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Période (pour les rapports)
            if (_exportType == 'appointment_report')
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Période',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: InkWell(
                              onTap: () => _selectDate(true),
                              child: InputDecorator(
                                decoration: const InputDecoration(
                                  labelText: 'Date début',
                                  border: OutlineInputBorder(),
                                ),
                                child: Text(DateFormat('dd/MM/yyyy').format(_startDate)),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: InkWell(
                              onTap: () => _selectDate(false),
                              child: InputDecorator(
                                decoration: const InputDecoration(
                                  labelText: 'Date fin',
                                  border: OutlineInputBorder(),
                                ),
                                child: Text(DateFormat('dd/MM/yyyy').format(_endDate)),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            
            const SizedBox(height: 16),
            
            // Options d'inclusion
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Options d\'inclusion',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 12),
                    SwitchListTile(
                      title: const Text('Inclure les consultations'),
                      value: _includeConsultations,
                      onChanged: (value) {
                        setState(() => _includeConsultations = value);
                      },
                    ),
                    SwitchListTile(
                      title: const Text('Inclure les allergies'),
                      value: _includeAllergies,
                      onChanged: (value) {
                        setState(() => _includeAllergies = value);
                      },
                    ),
                    SwitchListTile(
                      title: const Text('Inclure les traitements'),
                      value: _includeTreatments,
                      onChanged: (value) {
                        setState(() => _includeTreatments = value);
                      },
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Aperçu
            if (selectedPatient != null)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Aperçu du document',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 12),
                      ListTile(
                        leading: const Icon(Icons.person, color: Colors.blue),
                        title: Text(selectedPatient.fullName),
                        subtitle: Text('Code: ${selectedPatient.id}'),
                      ),
                      if (selectedPatient.birthDate != null)
                        ListTile(
                          leading: const Icon(Icons.cake, color: Colors.blue),
                          title: const Text('Date de naissance'),
                          subtitle: Text(selectedPatient.birthDate!),
                        ),
                      if (selectedPatient.bloodType != null)
                        ListTile(
                          leading: const Icon(Icons.water_drop, color: Colors.red),
                          title: const Text('Groupe sanguin'),
                          subtitle: Text(selectedPatient.bloodType!),
                        ),
                      const Divider(),
                      Text(
                        'Contenu inclus:',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        children: [
                          if (_includeConsultations)
                            Chip(
                              label: const Text('Consultations'),
                              backgroundColor: Colors.blue.shade100,
                            ),
                          if (_includeAllergies)
                            Chip(
                              label: const Text('Allergies'),
                              backgroundColor: Colors.red.shade100,
                            ),
                          if (_includeTreatments)
                            Chip(
                              label: const Text('Traitements'),
                              backgroundColor: Colors.green.shade100,
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            
            const SizedBox(height: 24),
            
            // Bouton d'export
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                onPressed: _isExporting ? null : _exportPDF,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                ),
                icon: _isExporting
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Icon(Icons.picture_as_pdf),
                label: const Text(
                  'GÉNÉRER ET EXPORTER LE PDF',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Informations
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
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  Text(
                    '• Le PDF est généré avec un filigrane de confidentialité\n'
                    '• Le document est signé électroniquement\n'
                    '• Conservez une copie sécurisée\n'
                    '• Valide pour présentation aux autorités',
                    style: TextStyle(fontSize: 12),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _selectDate(bool isStartDate) async {
    final selected = await showDatePicker(
      context: context,
      initialDate: isStartDate ? _startDate : _endDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    
    if (selected != null) {
      setState(() {
        if (isStartDate) {
          _startDate = selected;
        } else {
          _endDate = selected;
        }
      });
    }
  }

  Future<void> _exportPDF() async {
    if (_exportType == 'medical_record' && _selectedPatientId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veuillez sélectionner un patient'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isExporting = true);

    try {
      // Données de test (à remplacer par les vraies données)
      final testConsultations = [
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
      ];

      final testAllergies = [
        {'name': 'Pénicilline', 'severity': 'Sévère', 'since': '2015'},
        {'name': 'Aspirine', 'severity': 'Modérée', 'since': '2018'},
      ];

      final testTreatments = [
        {'name': 'Atorvastatine', 'dosage': '20mg', 'frequency': '1x/jour soir'},
        {'name': 'Métoprolol', 'dosage': '50mg', 'frequency': '2x/jour'},
      ];

      final patientProvider = Provider.of<PatientProvider>(context, listen: false);
      final selectedPatient = patientProvider.getPatientById(_selectedPatientId!);

      if (selectedPatient != null) {
        await PDFService.exportMedicalRecord(
          context: context,
          patientName: selectedPatient.fullName,
          patientId: selectedPatient.id,
          birthDate: selectedPatient.birthDate ?? 'Non spécifiée',
          bloodType: selectedPatient.bloodType ?? 'Non spécifié',
          consultations: _includeConsultations ? testConsultations : [],
          allergies: _includeAllergies ? testAllergies : [],
          treatments: _includeTreatments ? testTreatments : [],
        );
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('PDF généré avec succès'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => _isExporting = false);
    }
  }
}