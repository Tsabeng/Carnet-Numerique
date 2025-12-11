import 'package:intl/intl.dart';

class MedicalRecord {
  final String id;
  final String patientId;
  final int serviceId;
  final String visitType;
  final DateTime visitDate;
  final String symptoms;
  final String diagnosis;
  final String treatment;
  final String prescription;
  final String doctorName;
  final String doctorId;
  final String notes;
  final List<dynamic> testResults;
  final DateTime createdAt;

  const MedicalRecord({
    required this.id,
    required this.patientId,
    required this.serviceId,
    required this.visitType,
    required this.visitDate,
    required this.symptoms,
    required this.diagnosis,
    required this.treatment,
    required this.prescription,
    required this.doctorName,
    required this.doctorId,
    required this.notes,
    required this.testResults,
    required this.createdAt,
  });

  String get formattedDate {
    return DateFormat('dd/MM/yyyy HH:mm').format(visitDate);
  }

  String get formattedDateOnly {
    return DateFormat('dd/MM/yyyy').format(visitDate);
  }
}