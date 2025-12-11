import 'package:flutter/material.dart';
import '../models/medical_record.dart';

class MedicalRecordProvider extends ChangeNotifier {
  List<MedicalRecord> _records = [];
  List<Map<String, dynamic>> _services = [];
  
  List<MedicalRecord> get records => _records;
  List<Map<String, dynamic>> get services => _services;
  
  MedicalRecordProvider() {
    _initializeData();
  }
  
  void _initializeData() {
    // Services hospitaliers
    _services = [
      {'id': 1, 'name': 'Cardiologie'},
      {'id': 2, 'name': 'Médecine Générale'},
      {'id': 3, 'name': 'Chirurgie'},
      {'id': 4, 'name': 'Pédiatrie'},
      {'id': 5, 'name': 'Urgences'},
      {'id': 6, 'name': 'Radiologie'},
      {'id': 7, 'name': 'Laboratoire'},
    ];
    
    // Données fictives pour le développement
    _records = [
      MedicalRecord(
        id: 'REC001',
        patientId: 'PAT001',
        serviceId: 2,
        visitType: 'CONSULTATION',
        visitDate: DateTime.now().subtract(const Duration(days: 7)),
        symptoms: 'Fièvre, toux, fatigue',
        diagnosis: 'Infection respiratoire',
        treatment: 'Antibiotiques, repos',
        prescription: 'Amoxicilline 500mg 3x/jour pendant 7 jours',
        doctorName: 'Dr. Martin',
        doctorId: 'DOC001',
        notes: 'Patient doit revenir si fièvre persiste',
        testResults: [
          {'name': 'Température', 'result': '38.5', 'unit': '°C', 'normalRange': '36.5-37.5'},
          {'name': 'Pression artérielle', 'result': '120/80', 'unit': 'mmHg', 'normalRange': '110/70-140/90'},
        ],
        createdAt: DateTime.now().subtract(const Duration(days: 7)),
      ),
      MedicalRecord(
        id: 'REC002',
        patientId: 'PAT002',
        serviceId: 1,
        visitType: 'FOLLOW_UP',
        visitDate: DateTime.now().subtract(const Duration(days: 3)),
        symptoms: 'Douleur thoracique',
        diagnosis: 'Contrôle cardiaque',
        treatment: 'Électrocardiogramme, analyses sanguines',
        prescription: 'Aspirine 100mg/jour',
        doctorName: 'Dr. Martin',
        doctorId: 'DOC001',
        notes: 'Résultats ECG normaux',
        testResults: [
          {'name': 'ECG', 'result': 'Normal', 'normalRange': 'Normal'},
          {'name': 'Cholestérol', 'result': '1.8', 'unit': 'g/L', 'normalRange': '< 2.0'},
        ],
        createdAt: DateTime.now().subtract(const Duration(days: 3)),
      ),
    ];
  }
  
  Future<void> loadServices() async {
    // Déjà initialisé dans le constructeur
    notifyListeners();
  }
  
  Future<void> createMedicalRecord(Map<String, dynamic> data) async {
    await Future.delayed(const Duration(seconds: 1));
    
    final newRecord = MedicalRecord(
      id: 'REC${DateTime.now().millisecondsSinceEpoch}',
      patientId: data['patient_id'] ?? '',
      serviceId: data['service_id'] ?? 0,
      visitType: data['visit_type'] ?? 'CONSULTATION',
      visitDate: DateTime.parse(data['visit_date'] ?? DateTime.now().toIso8601String()),
      symptoms: data['symptoms'] ?? '',
      diagnosis: data['diagnosis'] ?? '',
      treatment: data['treatment'] ?? '',
      prescription: data['prescription'] ?? '',
      doctorName: data['doctor_name'] ?? '',
      doctorId: data['doctor_id'] ?? '',
      notes: data['notes'] ?? '',
      testResults: data['test_results'] ?? [],
      createdAt: DateTime.now(),
    );
    
    _records.add(newRecord);
    notifyListeners();
  }
  
  Future<void> updateMedicalRecord(String id, Map<String, dynamic> data) async {
    await Future.delayed(const Duration(seconds: 1));
    
    final index = _records.indexWhere((record) => record.id == id);
    if (index != -1) {
      final oldRecord = _records[index];
      final updatedRecord = MedicalRecord(
        id: oldRecord.id,
        patientId: data['patient_id'] ?? oldRecord.patientId,
        serviceId: data['service_id'] ?? oldRecord.serviceId,
        visitType: data['visit_type'] ?? oldRecord.visitType,
        visitDate: data['visit_date'] != null 
            ? DateTime.parse(data['visit_date']) 
            : oldRecord.visitDate,
        symptoms: data['symptoms'] ?? oldRecord.symptoms,
        diagnosis: data['diagnosis'] ?? oldRecord.diagnosis,
        treatment: data['treatment'] ?? oldRecord.treatment,
        prescription: data['prescription'] ?? oldRecord.prescription,
        doctorName: data['doctor_name'] ?? oldRecord.doctorName,
        doctorId: data['doctor_id'] ?? oldRecord.doctorId,
        notes: data['notes'] ?? oldRecord.notes,
        testResults: data['test_results'] ?? oldRecord.testResults,
        createdAt: oldRecord.createdAt,
      );
      
      _records[index] = updatedRecord;
      notifyListeners();
    }
  }
  
  Future<void> deleteMedicalRecord(String id) async {
    await Future.delayed(const Duration(seconds: 1));
    _records.removeWhere((record) => record.id == id);
    notifyListeners();
  }
  
  List<MedicalRecord> getRecordsByPatientId(String patientId) {
    return _records.where((record) => record.patientId == patientId).toList();
  }
  
  List<MedicalRecord> getRecordsByDoctorId(String doctorId) {
    return _records.where((record) => record.doctorId == doctorId).toList();
  }
  
  MedicalRecord? getRecordById(String id) {
    return _records.firstWhere((record) => record.id == id);
  }
}