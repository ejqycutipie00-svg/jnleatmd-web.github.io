import 'package:flutter/material.dart';

import '../models/student.dart';
import '../services/app_data.dart';
import '../widgets/ui_helpers.dart';

class StudentsScreen extends StatefulWidget {
  const StudentsScreen({super.key});

  @override
  State<StudentsScreen> createState() => _StudentsScreenState();
}

class _StudentsScreenState extends State<StudentsScreen> {
  final _search = TextEditingController();
  late Future<List<Student>> _future;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  Future<List<Student>> _load() async {
    return AppData.requireService().getStudents(search: _search.text);
  }

  void _refresh() => setState(() => _future = _load());

  String _loginCode(String studentNumber) {
    return studentNumber
        .trim()
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9]'), '');
  }

  String _loginEmail(String studentNumber) {
    return '${_loginCode(studentNumber)}@student.bcc.edu';
  }

  Future<void> _delete(Student student) async {
    final yes = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete Student?'),
        content: Text('Remove ${student.fullName}?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel')),
          FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Delete')),
        ],
      ),
    );
    if (!mounted) return;

    if (yes != true) return;
    try {
      await AppData.requireService().deleteStudent(student.id);
      if (!mounted) return;

      showAppMessage(context, 'Student deleted.');
      _refresh();
    } catch (e) {
      if (!mounted) return;
      showAppMessage(context, AppData.readableError(e), error: true);
    }
  }

  Widget _avatar(Student student) {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(12),
      ),
      alignment: Alignment.center,
      child: Text(
        student.fullName.isNotEmpty ? student.fullName[0].toUpperCase() : '?',
        style:
            const TextStyle(color: Colors.white, fontWeight: FontWeight.w900),
      ),
    );
  }

  Widget _studentCard(Student student) {
    final password = _loginCode(student.studentNumber);

    return AppCard(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          _avatar(student),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(student.fullName,
                    style: const TextStyle(
                        fontWeight: FontWeight.w900, fontSize: 16)),
                const SizedBox(height: 4),
                Text(
                  '${student.studentNumber} - ${student.course} ${student.section}',
                  style: const TextStyle(
                      color: Colors.black54, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 6),
                Text(
                  'Login: ${_loginEmail(student.studentNumber)} / $password',
                  style: const TextStyle(
                      color: AppColors.blue,
                      fontSize: 12,
                      fontWeight: FontWeight.w800),
                ),
              ],
            ),
          ),
          IconButton(
              onPressed: () => _delete(student),
              icon: const Icon(Icons.delete_outline_rounded)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: const Text('Students',
              style: TextStyle(fontWeight: FontWeight.w900))),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(20),
              child: TextField(
                controller: _search,
                onChanged: (_) => _refresh(),
                decoration: const InputDecoration(
                    labelText: 'Search student',
                    prefixIcon: Icon(Icons.search_rounded)),
              ),
            ),
            Expanded(
              child: FutureBuilder<List<Student>>(
                future: _future,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Text(AppData.readableError(snapshot.error!),
                            textAlign: TextAlign.center),
                      ),
                    );
                  }
                  final students = snapshot.data ?? [];
                  if (students.isEmpty) {
                    return const Center(
                      child: Text('No students found.',
                          style: TextStyle(fontWeight: FontWeight.w800)),
                    );
                  }
                  return ListView.separated(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                    itemBuilder: (context, index) =>
                        _studentCard(students[index]),
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemCount: students.length,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
