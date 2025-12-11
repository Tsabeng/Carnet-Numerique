import 'package:intl/intl.dart';

class Appointment {
  final String id;
  final String patientId;
  final String patientName;
  final String doctorId;
  final String doctorName;
  final DateTime dateTime;
  final Duration duration;
  final String type; // consultation, suivi, urgence
  final String status; // scheduled, confirmed, cancelled, completed
  final String? notes;
  final String? reason;
  final DateTime createdAt;

  const Appointment({
    required this.id,
    required this.patientId,
    required this.patientName,
    required this.doctorId,
    required this.doctorName,
    required this.dateTime,
    this.duration = const Duration(hours: 1),
    this.type = 'consultation',
    this.status = 'scheduled',
    this.notes,
    this.reason,
    required this.createdAt,
  });

  String get formattedDate => DateFormat('dd/MM/yyyy').format(dateTime);
  String get formattedTime => DateFormat('HH:mm').format(dateTime);
  String get formattedDateTime => DateFormat('dd/MM/yyyy HH:mm').format(dateTime);

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'patientId': patientId,
      'patientName': patientName,
      'doctorId': doctorId,
      'doctorName': doctorName,
      'dateTime': dateTime.toIso8601String(),
      'duration': duration.inMinutes,
      'type': type,
      'status': status,
      'notes': notes,
      'reason': reason,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory Appointment.fromMap(Map<String, dynamic> map) {
    return Appointment(
      id: map['id'] ?? '',
      patientId: map['patientId'] ?? '',
      patientName: map['patientName'] ?? '',
      doctorId: map['doctorId'] ?? '',
      doctorName: map['doctorName'] ?? '',
      dateTime: DateTime.parse(map['dateTime'] ?? DateTime.now().toIso8601String()),
      duration: Duration(minutes: map['duration'] ?? 60),
      type: map['type'] ?? 'consultation',
      status: map['status'] ?? 'scheduled',
      notes: map['notes'],
      reason: map['reason'],
      createdAt: DateTime.parse(map['createdAt'] ?? DateTime.now().toIso8601String()),
    );
  }
}