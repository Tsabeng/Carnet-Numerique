import 'package:flutter/material.dart';
import '../models/appointment.dart';

class AppointmentService extends ChangeNotifier {
  List<Appointment> _appointments = [];
  List<Appointment> get appointments => _appointments;

  AppointmentService() {
    _initializeAppointments();
  }

  void _initializeAppointments() {
    _appointments = [
      Appointment(
        id: 'APT001',
        patientId: 'PAT001',
        patientName: 'Jean Dupont',
        doctorId: 'DOC001',
        doctorName: 'Dr. Martin',
        dateTime: DateTime.now().add(const Duration(days: 1, hours: 10)),
        type: 'consultation',
        status: 'confirmed',
        reason: 'Contrôle annuel',
        createdAt: DateTime.now().subtract(const Duration(days: 7)),
      ),
      Appointment(
        id: 'APT002',
        patientId: 'PAT002',
        patientName: 'Marie Martin',
        doctorId: 'DOC001',
        doctorName: 'Dr. Martin',
        dateTime: DateTime.now().add(const Duration(days: 2, hours: 14)),
        type: 'suivi',
        status: 'scheduled',
        reason: 'Suivi traitement',
        createdAt: DateTime.now().subtract(const Duration(days: 3)),
      ),
      Appointment(
        id: 'APT003',
        patientId: 'PAT003',
        patientName: 'Pierre Durand',
        doctorId: 'DOC001',
        doctorName: 'Dr. Martin',
        dateTime: DateTime.now().add(const Duration(days: 3, hours: 16)),
        type: 'urgence',
        status: 'pending',
        reason: 'Douleurs thoraciques',
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
      ),
    ];
  }

  Future<void> addAppointment(Appointment appointment) async {
    await Future.delayed(const Duration(milliseconds: 500));
    _appointments.add(appointment);
    notifyListeners();
  }

  Future<void> updateAppointment(String id, Appointment updatedAppointment) async {
    await Future.delayed(const Duration(milliseconds: 500));
    final index = _appointments.indexWhere((apt) => apt.id == id);
    if (index != -1) {
      _appointments[index] = updatedAppointment;
      notifyListeners();
    }
  }

  Future<void> deleteAppointment(String id) async {
    await Future.delayed(const Duration(milliseconds: 500));
    _appointments.removeWhere((apt) => apt.id == id);
    notifyListeners();
  }

  List<Appointment> getAppointmentsByDoctorId(String doctorId) {
    return _appointments.where((apt) => apt.doctorId == doctorId).toList();
  }

  List<Appointment> getAppointmentsByPatientId(String patientId) {
    return _appointments.where((apt) => apt.patientId == patientId).toList();
  }

  List<Appointment> getTodayAppointments() {
    final today = DateTime.now();
    return _appointments.where((apt) {
      return apt.dateTime.year == today.year &&
             apt.dateTime.month == today.month &&
             apt.dateTime.day == today.day;
    }).toList();
  }

  List<Appointment> getUpcomingAppointments() {
    final now = DateTime.now();
    return _appointments.where((apt) => apt.dateTime.isAfter(now)).toList();
  }
}