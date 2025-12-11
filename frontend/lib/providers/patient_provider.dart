import 'package:flutter/material.dart';
import '../models/patient.dart';

class PatientProvider extends ChangeNotifier {
  List<Patient> _patients = [];
  
  List<Patient> get patients => _patients;
  
  PatientProvider() {
    _initializeData();
  }
  
  void _initializeData() {
    _patients = [
      Patient(
        id: 'PAT001',
        fullName: 'Jean Dupont',
        birthDate: '15/05/1979',
        bloodType: 'O+',
        phoneNumber: '06 12 34 56 78',
        email: 'jean.dupont@email.com',
        address: '12 Rue de la Paix, Paris',
        emergencyContact: 'Marie Dupont - 06 98 76 54 32',
      ),
      Patient(
        id: 'PAT002',
        fullName: 'Marie Martin',
        birthDate: '22/08/1992',
        bloodType: 'A+',
        phoneNumber: '07 23 45 67 89',
        email: 'marie.martin@email.com',
        address: '45 Avenue des Champs, Lyon',
        emergencyContact: 'Pierre Martin - 07 89 67 45 23',
      ),
      Patient(
        id: 'PAT003',
        fullName: 'Pierre Durand',
        birthDate: '30/03/1966',
        bloodType: 'B+',
        phoneNumber: '06 34 56 78 90',
        email: 'pierre.durand@email.com',
        address: '78 Boulevard Saint-Germain, Marseille',
        emergencyContact: 'Sophie Durand - 06 90 78 56 34',
      ),
      Patient(
        id: 'PAT004',
        fullName: 'Sophie Laurent',
        birthDate: '18/11/1985',
        bloodType: 'AB+',
        phoneNumber: '07 45 67 89 01',
        email: 'sophie.laurent@email.com',
        address: '23 Rue du Commerce, Lille',
      ),
      Patient(
        id: 'PAT005',
        fullName: 'Thomas Petit',
        birthDate: '09/07/1972',
        bloodType: 'O-',
        phoneNumber: '06 56 78 90 12',
        email: 'thomas.petit@email.com',
        address: '56 Avenue de la République, Toulouse',
      ),
    ];
  }
  
  Patient? getPatientById(String id) {
    try {
      return _patients.firstWhere((patient) => patient.id == id);
    } catch (e) {
      return null;
    }
  }
  
  Future<void> addPatient(Patient patient) async {
    await Future.delayed(const Duration(seconds: 1));
    _patients.add(patient);
    notifyListeners();
  }
  
  Future<void> updatePatient(String id, Patient updatedPatient) async {
    await Future.delayed(const Duration(seconds: 1));
    final index = _patients.indexWhere((patient) => patient.id == id);
    if (index != -1) {
      _patients[index] = updatedPatient;
      notifyListeners();
    }
  }
  
  Future<void> deletePatient(String id) async {
    await Future.delayed(const Duration(seconds: 1));
    _patients.removeWhere((patient) => patient.id == id);
    notifyListeners();
  }
  
  List<Patient> searchPatients(String query) {
    if (query.isEmpty) return _patients;
    
    return _patients.where((patient) {
      return patient.fullName.toLowerCase().contains(query.toLowerCase()) ||
             patient.id.toLowerCase().contains(query.toLowerCase()) ||
             (patient.phoneNumber?.toLowerCase().contains(query.toLowerCase()) ?? false) ||
             (patient.email?.toLowerCase().contains(query.toLowerCase()) ?? false);
    }).toList();
  }
}