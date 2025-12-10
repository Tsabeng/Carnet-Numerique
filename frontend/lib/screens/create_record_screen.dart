import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/medical_record.dart';
import '../providers/medical_record_provider.dart';
import '../providers/patient_provider.dart';

class CreateRecordScreen extends StatefulWidget {
  final String? patientId;
  
  const CreateRecordScreen({super.key, this.patientId});
  
  @override
  State<CreateRecordScreen> createState() => _CreateRecordScreenState();
}

class _CreateRecordScreenState extends State<CreateRecordScreen> {
  final _formKey = GlobalKey<FormState>();
  
  // Champs du formulaire
  String _selectedPatientId = '';
  String _selectedServiceId = '';
  String _visitType = 'CONSULTATION';
  DateTime _visitDate = DateTime.now();
  TimeOfDay _visitTime = TimeOfDay.now();
  final _symptomsController = TextEditingController();
  final _diagnosisController = TextEditingController();
  final _treatmentController = TextEditingController();
  final _prescriptionController = TextEditingController();
  final _doctorNameController = TextEditingController();
  final _notesController = TextEditingController();
  
  // Tests médicaux
  final List<Map<String, dynamic>> _testResults = [];
  
  @override
  void initState() {
    super.initState();
    _selectedPatientId = widget.patientId ?? '';
    _doctorNameController.text = 'Dr. Martin';
    
    // Charger les services
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<MedicalRecordProvider>(context, listen: false).loadServices();
    });
  }
  
  @override
  Widget build(BuildContext context) {
    final recordProvider = Provider.of<MedicalRecordProvider>(context);
    final patientProvider = Provider.of<PatientProvider>(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nouveau Dossier Médical'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _submitForm,
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Sélection du patient
              const Text(
                'PATIENT',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 8),
              
              DropdownButtonFormField<String>(
                value: _selectedPatientId.isNotEmpty ? _selectedPatientId : null,
                decoration: const InputDecoration(
                  labelText: 'Sélectionner un patient',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person),
                ),
                items: patientProvider.patients.map((patient) {
                  return DropdownMenuItem(
                    value: patient.id,
                    child: Text(patient.fullName),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() => _selectedPatientId = value ?? '');
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez sélectionner un patient';
                  }
                  return null;
                },
              ),
              
              const SizedBox(height: 20),
              
              // Type de visite
              const Text(
                'TYPE DE VISITE',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 8),
              
              Wrap(
                spacing: 8,
                children: [
                  _buildVisitTypeChip('Consultation', 'CONSULTATION', Icons.medical_services),
                  _buildVisitTypeChip('Urgence', 'EMERGENCY', Icons.local_hospital),
                  _buildVisitTypeChip('Suivi', 'FOLLOW_UP', Icons.update),
                  _buildVisitTypeChip('Hospitalisation', 'HOSPITALIZATION', Icons.hotel),
                ],
              ),
              
              const SizedBox(height: 20),
              
              // Date et heure
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'DATE',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey,
                          ),
                        ),
                        const SizedBox(height: 8),
                        InkWell(
                          onTap: _selectDate,
                          child: InputDecorator(
                            decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                              prefixIcon: Icon(Icons.calendar_today),
                            ),
                            child: Text(
                              DateFormat('dd/MM/yyyy').format(_visitDate),
                              style: const TextStyle(fontSize: 16),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'HEURE',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey,
                          ),
                        ),
                        const SizedBox(height: 8),
                        InkWell(
                          onTap: _selectTime,
                          child: InputDecorator(
                            decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                              prefixIcon: Icon(Icons.access_time),
                            ),
                            child: Text(
                              _visitTime.format(context),
                              style: const TextStyle(fontSize: 16),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 20),
              
              // Service hospitalier
              const Text(
                'SERVICE',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 8),
              
              DropdownButtonFormField<String>(
                value: _selectedServiceId.isNotEmpty ? _selectedServiceId : null,
                decoration: const InputDecoration(
                  labelText: 'Sélectionner un service',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.local_hospital),
                ),
                items: recordProvider.services.map((service) {
                  return DropdownMenuItem(
                    value: service.id.toString(),
                    child: Text(service.name),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() => _selectedServiceId = value ?? '');
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez sélectionner un service';
                  }
                  return null;
                },
              ),
              
              const SizedBox(height: 20),
              
              // Nom du médecin
              TextFormField(
                controller: _doctorNameController,
                decoration: const InputDecoration(
                  labelText: 'Nom du médecin',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer le nom du médecin';
                  }
                  return null;
                },
              ),
              
              const SizedBox(height: 20),
              
              // Symptômes
              TextFormField(
                controller: _symptomsController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Symptômes',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.warning),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez décrire les symptômes';
                  }
                  return null;
                },
              ),
              
              const SizedBox(height: 20),
              
              // Diagnostic
              TextFormField(
                controller: _diagnosisController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Diagnostic',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.medical_services),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer le diagnostic';
                  }
                  return null;
                },
              ),
              
              const SizedBox(height: 20),
              
              // Traitement
              TextFormField(
                controller: _treatmentController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Traitement prescrit',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.medication),
                ),
              ),
              
              const SizedBox(height: 20),
              
              // Prescription
              TextFormField(
                controller: _prescriptionController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Prescription médicamenteuse',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.description),
                ),
              ),
              
              const SizedBox(height: 20),
              
              // Tests médicaux
              _buildTestResultsSection(),
              
              const SizedBox(height: 20),
              
              // Notes
              TextFormField(
                controller: _notesController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Notes supplémentaires',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.note),
                ),
              ),
              
              const SizedBox(height: 30),
              
              // Boutons d'action
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: const Text('ANNULER'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _submitForm,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: const Text('ENREGISTRER'),
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 50),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildVisitTypeChip(String label, String value, IconData icon) {
    return ChoiceChip(
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16),
          const SizedBox(width: 8),
          Text(label),
        ],
      ),
      selected: _visitType == value,
      onSelected: (selected) {
        setState(() => _visitType = value);
      },
    );
  }
  
  Widget _buildTestResultsSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'TESTS MÉDICAUX',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.add_circle),
                  onPressed: _addTestResult,
                ),
              ],
            ),
            
            if (_testResults.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 20),
                child: Center(
                  child: Text(
                    'Aucun test ajouté',
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
              ),
            
            ..._testResults.asMap().entries.map((entry) {
              final index = entry.key;
              final test = entry.value;
              return Card(
                margin: const EdgeInsets.only(bottom: 10),
                child: ListTile(
                  title: Text(test['name'] ?? ''),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Résultat: ${test['result']} ${test['unit'] ?? ''}'),
                      if (test['normalRange'] != null && test['normalRange'].isNotEmpty)
                        Text('Normale: ${test['normalRange']}'),
                    ],
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => _removeTestResult(index),
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
  
  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _visitDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    
    if (picked != null && picked != _visitDate) {
      setState(() => _visitDate = picked);
    }
  }
  
  Future<void> _selectTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _visitTime,
    );
    
    if (picked != null && picked != _visitTime) {
      setState(() => _visitTime = picked);
    }
  }
  
  void _addTestResult() {
    showDialog(
      context: context,
      builder: (context) {
        final testNameController = TextEditingController();
        final resultController = TextEditingController();
        final unitController = TextEditingController();
        final normalRangeController = TextEditingController();
        
        return AlertDialog(
          title: const Text('Nouveau Test Médical'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: testNameController,
                  decoration: const InputDecoration(
                    labelText: 'Nom du test',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: resultController,
                  decoration: const InputDecoration(
                    labelText: 'Résultat',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: unitController,
                  decoration: const InputDecoration(
                    labelText: 'Unité (mg/dL, mmol/L, etc.)',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: normalRangeController,
                  decoration: const InputDecoration(
                    labelText: 'Valeurs normales (ex: 70-110)',
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('ANNULER'),
            ),
            ElevatedButton(
              onPressed: () {
                if (testNameController.text.isNotEmpty && 
                    resultController.text.isNotEmpty) {
                  setState(() {
                    _testResults.add({
                      'name': testNameController.text,
                      'result': resultController.text,
                      'unit': unitController.text,
                      'normalRange': normalRangeController.text,
                    });
                  });
                  Navigator.pop(context);
                }
              },
              child: const Text('AJOUTER'),
            ),
          ],
        );
      },
    );
  }
  
  void _removeTestResult(int index) {
    setState(() {
      _testResults.removeAt(index);
    });
  }
  
  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      // Combiner date et heure
      final visitDateTime = DateTime(
        _visitDate.year,
        _visitDate.month,
        _visitDate.day,
        _visitTime.hour,
        _visitTime.minute,
      );
      
      try {
        final recordData = {
          'patient_id': _selectedPatientId,
          'service_id': int.parse(_selectedServiceId),
          'visit_type': _visitType,
          'visit_date': visitDateTime.toIso8601String(),
          'symptoms': _symptomsController.text,
          'diagnosis': _diagnosisController.text,
          'treatment': _treatmentController.text,
          'prescription': _prescriptionController.text,
          'doctor_name': _doctorNameController.text,
          'doctor_id': '1', // À remplacer par l'ID réel du médecin
          'notes': _notesController.text,
          'test_results': _testResults,
        };
        
        await Provider.of<MedicalRecordProvider>(context, listen: false)
            .createMedicalRecord(recordData);
        
        if (mounted) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Dossier médical créé avec succès'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
  
  @override
  void dispose() {
    _symptomsController.dispose();
    _diagnosisController.dispose();
    _treatmentController.dispose();
    _prescriptionController.dispose();
    _doctorNameController.dispose();
    _notesController.dispose();
    super.dispose();
  }
}