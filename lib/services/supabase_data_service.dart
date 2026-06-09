import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/app_user.dart';
import '../models/student.dart';
import '../models/attendance_record.dart';
import 'data_service.dart';

class SupabaseDataService implements DataService {
  SupabaseDataService(this.client);

  final SupabaseClient client;

  static const String _teacherPassword = 'teacher123';

  String _email(String input) => input.trim().toLowerCase();
  String _password(String input) => input.trim();
  String _studentLoginCode(String input) =>
      input.trim().toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '');
  String _studentEmail(String studentNumber) =>
      '${_studentLoginCode(studentNumber)}@student.bcc.edu';
  String _teacherName(String email) {
    final localPart = email.split('@').first;
    final words = localPart
        .split(RegExp(r'[^a-z0-9]+'))
        .where((word) => word.trim().isNotEmpty);
    final name = words
        .map((word) => '${word[0].toUpperCase()}${word.substring(1)}')
        .join(' ');
    return name.isEmpty ? 'BCC Teacher' : name;
  }

  Future<Map<String, dynamic>?> _findUserByEmail(String email) async {
    // Teacher accounts read directly from users. Generated student accounts
    // can be repaired from the students table when their user row is missing.
    final rows = await client
        .from('users')
        .select('id,email,password,full_name,role,student_number')
        .eq('email', email)
        .limit(1);

    final list = List<Map<String, dynamic>>.from(rows);
    if (list.isEmpty) return null;
    return list.first;
  }

  Future<Map<String, dynamic>?> _findStudentByLoginCode(
      String loginCode) async {
    final rows = await client
        .from('students')
        .select('student_number,full_name')
        .order('full_name', ascending: true);

    final students = List<Map<String, dynamic>>.from(rows);
    for (final student in students) {
      final studentNumber = (student['student_number'] ?? '').toString();
      if (_studentLoginCode(studentNumber) == loginCode) {
        return student;
      }
    }

    return null;
  }

  Future<AppUser?> _loginGeneratedStudent(
      String email, String password) async {
    if (!email.endsWith('@student.bcc.edu')) return null;

    final loginCode = email.replaceFirst('@student.bcc.edu', '');
    if (loginCode.isEmpty || password != loginCode) return null;

    final student = await _findStudentByLoginCode(loginCode);
    if (student == null) return null;

    final studentNumber = (student['student_number'] ?? '').toString();
    final fullName = (student['full_name'] ?? '').toString();
    final rows = await client
        .from('users')
        .upsert({
          'email': email,
          'password': loginCode,
          'full_name': fullName,
          'role': 'student',
          'student_number': studentNumber,
        }, onConflict: 'email')
        .select('id,email,full_name,role,student_number')
        .single();

    return AppUser.fromMap(Map<String, dynamic>.from(rows));
  }

  Future<AppUser?> _loginTeacher(String email, String password) async {
    if (email.endsWith('@student.bcc.edu') || password != _teacherPassword) {
      return null;
    }

    final rows = await client
        .from('users')
        .upsert({
          'email': email,
          'password': _teacherPassword,
          'full_name': _teacherName(email),
          'role': 'teacher',
          'student_number': null,
        }, onConflict: 'email')
        .select('id,email,full_name,role,student_number')
        .single();

    return AppUser.fromMap(Map<String, dynamic>.from(rows));
  }

  @override
  Future<AppUser?> login(String email, String password) async {
    final cleanEmail = _email(email);
    final cleanPassword = _password(password);

    final row = await _findUserByEmail(cleanEmail);
    if (row == null) {
      return await _loginGeneratedStudent(cleanEmail, cleanPassword) ??
          await _loginTeacher(cleanEmail, cleanPassword);
    }

    final savedPassword = (row['password'] ?? '').toString().trim();
    if (savedPassword != cleanPassword) {
      return await _loginGeneratedStudent(cleanEmail, cleanPassword) ??
          await _loginTeacher(cleanEmail, cleanPassword);
    }

    row.remove('password');
    return AppUser.fromMap(row);
  }

  @override
  Future<List<Student>> getStudents({String search = ''}) async {
    final rows = await client
        .from('students')
        .select('id,student_number,full_name,course,section')
        .order('full_name', ascending: true);

    final students =
        List<Map<String, dynamic>>.from(rows).map(Student.fromMap).toList();
    final q = search.trim().toLowerCase();
    if (q.isEmpty) return students;

    return students.where((s) {
      return s.studentNumber.toLowerCase().contains(q) ||
          s.fullName.toLowerCase().contains(q) ||
          s.course.toLowerCase().contains(q) ||
          s.section.toLowerCase().contains(q);
    }).toList();
  }

  @override
  Future<Student> addStudent({
    required String studentNumber,
    required String fullName,
    required String course,
    required String section,
  }) async {
    final rows = await client
        .from('students')
        .insert({
          'student_number': studentNumber.trim(),
          'full_name': fullName.trim(),
          'course': course.trim().toUpperCase(),
          'section': section.trim().toUpperCase(),
        })
        .select('id,student_number,full_name,course,section')
        .single();
    final student = Student.fromMap(Map<String, dynamic>.from(rows));
    final loginCode = _studentLoginCode(student.studentNumber);

    await client.from('users').upsert({
      'email': _studentEmail(student.studentNumber),
      'password': loginCode,
      'full_name': student.fullName,
      'role': 'student',
      'student_number': student.studentNumber,
    }, onConflict: 'email');

    return student;
  }

  @override
  Future<void> deleteStudent(String id) async {
    final rows = await client
        .from('students')
        .select('student_number')
        .eq('id', id)
        .limit(1);
    final students = List<Map<String, dynamic>>.from(rows);
    final studentNumber = students.isEmpty
        ? null
        : (students.first['student_number'] ?? '').toString();

    await client.from('students').delete().eq('id', id);

    if (studentNumber != null && studentNumber.isNotEmpty) {
      await client
          .from('users')
          .delete()
          .eq('email', _studentEmail(studentNumber));
    }
  }

  @override
  Future<void> markAttendance({
    required Student student,
    required String status,
    required String markedBy,
    String remarks = '',
  }) async {
    await client.from('attendance').insert({
      'student_id': student.id,
      'status': status,
      'remarks': remarks.trim(),
      'marked_by': markedBy.trim().isEmpty ? null : markedBy.trim(),
    });
  }

  @override
  Future<List<AttendanceRecord>> getAttendanceRecords(
      {String search = ''}) async {
    final rows = await client.from('attendance').select('''
      id,
      student_id,
      status,
      remarks,
      attendance_time,
      students(id, student_number, full_name, course, section)
    ''').order('attendance_time', ascending: false);

    final records = List<Map<String, dynamic>>.from(rows)
        .map(AttendanceRecord.fromMap)
        .toList();
    final q = search.trim().toLowerCase();
    if (q.isEmpty) return records;

    return records.where((r) {
      return r.studentNumber.toLowerCase().contains(q) ||
          r.studentName.toLowerCase().contains(q) ||
          r.status.toLowerCase().contains(q) ||
          r.course.toLowerCase().contains(q) ||
          r.section.toLowerCase().contains(q) ||
          r.remarks.toLowerCase().contains(q);
    }).toList();
  }

  @override
  Future<List<AttendanceRecord>> getStudentAttendanceRecords(
      String studentNumber) async {
    final cleanStudentNumber = studentNumber.trim();
    if (cleanStudentNumber.isEmpty) return [];

    final rows = await client.from('attendance').select('''
      id,
      student_id,
      status,
      remarks,
      attendance_time,
      students!inner(id, student_number, full_name, course, section)
    ''').eq('students.student_number', cleanStudentNumber).order(
          'attendance_time',
          ascending: false,
        );

    return List<Map<String, dynamic>>.from(rows)
        .map(AttendanceRecord.fromMap)
        .toList();
  }
}
