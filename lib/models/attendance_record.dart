class AttendanceRecord {
  final String id;
  final String studentId;
  final String studentNumber;
  final String studentName;
  final String course;
  final String section;
  final String status;
  final DateTime dateTime;
  final String remarks;

  const AttendanceRecord({
    required this.id,
    required this.studentId,
    required this.studentNumber,
    required this.studentName,
    required this.course,
    required this.section,
    required this.status,
    required this.dateTime,
    this.remarks = '',
  });

  factory AttendanceRecord.fromMap(Map<String, dynamic> map) {
    final student = map['students'] is Map ? Map<String, dynamic>.from(map['students']) : <String, dynamic>{};
    final rawTime = map['attendance_time'] ?? map['created_at'] ?? DateTime.now().toIso8601String();
    return AttendanceRecord(
      id: map['id'].toString(),
      studentId: (map['student_id'] ?? student['id'] ?? '').toString(),
      studentNumber: (student['student_number'] ?? map['student_number'] ?? '').toString(),
      studentName: (student['full_name'] ?? map['student_name'] ?? '').toString(),
      course: (student['course'] ?? map['course'] ?? '').toString(),
      section: (student['section'] ?? map['section'] ?? '').toString(),
      status: (map['status'] ?? 'Present').toString(),
      dateTime: DateTime.tryParse(rawTime.toString()) ?? DateTime.now(),
      remarks: (map['remarks'] ?? '').toString(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'student_id': studentId,
      'student_number': studentNumber,
      'student_name': studentName,
      'course': course,
      'section': section,
      'status': status,
      'attendance_time': dateTime.toIso8601String(),
      'remarks': remarks,
    };
  }
}
