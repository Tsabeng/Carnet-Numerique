class Department {
  final int id;
  final String name;
  final String? description;
  final String? headDoctorId;
  
  const Department({
    required this.id,
    required this.name,
    this.description,
    this.headDoctorId,
  });
}