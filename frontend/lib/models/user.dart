class MedicalUser {
  final String id;
  final String fullName;
  final String email;
  final String role; // 'doctor', 'nurse', 'admin', 'patient'
  final String? specialty;
  final String? department;
  final DateTime createdAt;
  
  const MedicalUser({
    required this.id,
    required this.fullName,
    required this.email,
    required this.role,
    this.specialty,
    this.department,
    required this.createdAt,
  });
  
  factory MedicalUser.fromMap(Map<String, dynamic> map) {
    return MedicalUser(
      id: map['id'] ?? '',
      fullName: map['fullName'] ?? '',
      email: map['email'] ?? '',
      role: map['role'] ?? 'doctor',
      specialty: map['specialty'],
      department: map['department'],
      createdAt: DateTime.parse(map['createdAt'] ?? DateTime.now().toIso8601String()),
    );
  }
}