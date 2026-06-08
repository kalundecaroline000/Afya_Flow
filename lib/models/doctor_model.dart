class Doctor {
  final String name;
  final String specialty;
  final bool isAvailable;

  Doctor({
    required this.name,
    required this.specialty,
    required this.isAvailable,
  });

  // Factory constructor to map incoming network JSON streams into clean Dart objects
  factory Doctor.fromJson(Map<String, dynamic> json) {
    return Doctor(
      name: json['name'] ?? 'Unknown Doctor',
      specialty: json['specialty'] ?? 'General Practitioner',
      isAvailable: json['isAvailable'] ?? false,
    );
  }
}