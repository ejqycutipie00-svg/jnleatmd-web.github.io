class Student {
  final String id;
  final String studentNumber;
  final String fullName;
  final String course;
  final String section;

  const Student({
    required this.id,
    required this.studentNumber,
    required this.fullName,
    required this.course,
    required this.section,
  });

  factory Student.fromMap(Map<String, dynamic> map) {
    return Student(
      id: map['id'].toString(),
      studentNumber: (map['student_number'] ?? '').toString(),
      fullName: (map['full_name'] ?? '').toString(),
      course: (map['course'] ?? '').toString(),
      section: (map['section'] ?? '').toString(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'student_number': studentNumber,
      'full_name': fullName,
      'course': course,
      'section': section,
    };
  }
}
