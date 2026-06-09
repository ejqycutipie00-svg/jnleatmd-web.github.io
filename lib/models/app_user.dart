class AppUser {
  final String id;
  final String email;
  final String fullName;
  final String role;
  final String? studentNumber;

  const AppUser({
    required this.id,
    required this.email,
    required this.fullName,
    required this.role,
    this.studentNumber,
  });

  bool get isTeacher => role.toLowerCase() == 'teacher';
  bool get isStudent => role.toLowerCase() == 'student';

  factory AppUser.fromMap(Map<String, dynamic> map) {
    return AppUser(
      id: map['id'].toString(),
      email: (map['email'] ?? '').toString(),
      fullName: (map['full_name'] ?? '').toString(),
      role: (map['role'] ?? 'student').toString(),
      studentNumber: map['student_number']?.toString(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'email': email,
      'full_name': fullName,
      'role': role,
      'student_number': studentNumber,
    };
  }
}
