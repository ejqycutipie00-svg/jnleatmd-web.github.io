import '../models/app_user.dart';
import '../models/student.dart';
import '../models/attendance_record.dart';

abstract class DataService {
  Future<AppUser?> login(String email, String password);
  Future<List<Student>> getStudents({String search = ''});

  Future<Student> addStudent({
    required String studentNumber,
    required String fullName,
    required String course,
    required String section,
  });

  Future<void> deleteStudent(String id);

  Future<void> markAttendance({
    required Student student,
    required String status,
    required String markedBy,
    String remarks,
  });

  Future<List<AttendanceRecord>> getAttendanceRecords({String search = ''});
  Future<List<AttendanceRecord>> getStudentAttendanceRecords(
      String studentNumber);
}
