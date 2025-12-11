class Patient {
  final String id;
  final String fullName;
  final String? birthDate;
  final String? bloodType;
  final String? address;
  final String? phoneNumber;
  final String? email;
  final String? emergencyContact;

  const Patient({
    required this.id,
    required this.fullName,
    this.birthDate,
    this.bloodType,
    this.address,
    this.phoneNumber,
    this.email,
    this.emergencyContact,
  });

  factory Patient.fromMap(Map<String, dynamic> map) {
    return Patient(
      id: map['id'] ?? '',
      fullName: map['fullName'] ?? '',
      birthDate: map['birthDate'],
      bloodType: map['bloodType'],
      address: map['address'],
      phoneNumber: map['phoneNumber'],
      email: map['email'],
      emergencyContact: map['emergencyContact'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'fullName': fullName,
      'birthDate': birthDate,
      'bloodType': bloodType,
      'address': address,
      'phoneNumber': phoneNumber,
      'email': email,
      'emergencyContact': emergencyContact,
    };
  }
}