import 'package:flutter/material.dart';

import '../services/app_data.dart';
import '../widgets/ui_helpers.dart';

class AddStudentScreen extends StatefulWidget {
  const AddStudentScreen({super.key});

  @override
  State<AddStudentScreen> createState() => _AddStudentScreenState();
}

class _AddStudentScreenState extends State<AddStudentScreen> {
  final _formKey = GlobalKey<FormState>();
  final _number = TextEditingController();
  final _name = TextEditingController();
  final _course = TextEditingController();
  final _section = TextEditingController();
  bool _loading = false;

  @override
  void dispose() {
    _number.dispose();
    _name.dispose();
    _course.dispose();
    _section.dispose();
    super.dispose();
  }

  String? _required(String? value) =>
      value == null || value.trim().isEmpty ? 'Required field' : null;

  String _loginCode(String studentNumber) {
    return studentNumber
        .trim()
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9]'), '');
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    try {
      final student = await AppData.requireService().addStudent(
        studentNumber: _number.text,
        fullName: _name.text,
        course: _course.text,
        section: _section.text,
      );
      if (!mounted) return;

      final loginCode = _loginCode(student.studentNumber);
      showAppMessage(
        context,
        'Student saved. Login: $loginCode@student.bcc.edu / $loginCode',
      );
      _number.clear();
      _name.clear();
      _course.clear();
      _section.clear();
    } catch (e) {
      if (!mounted) return;
      showAppMessage(context, AppData.readableError(e), error: true);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: const Text('Add Student',
              style: TextStyle(fontWeight: FontWeight.w900))),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            AppCard(
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      controller: _number,
                      validator: _required,
                      decoration: const InputDecoration(
                          labelText: 'Student Number',
                          hintText: 'e.g. 024-1059',
                          prefixIcon: Icon(Icons.badge_rounded)),
                    ),
                    const SizedBox(height: 14),
                    TextFormField(
                      controller: _name,
                      validator: _required,
                      decoration: const InputDecoration(
                          labelText: 'Full Name',
                          prefixIcon: Icon(Icons.person_rounded)),
                    ),
                    const SizedBox(height: 14),
                    TextFormField(
                      controller: _course,
                      validator: _required,
                      textCapitalization: TextCapitalization.characters,
                      decoration: const InputDecoration(
                          labelText: 'Course',
                          hintText: 'BSIT',
                          prefixIcon: Icon(Icons.school_rounded)),
                    ),
                    const SizedBox(height: 14),
                    TextFormField(
                      controller: _section,
                      validator: _required,
                      textCapitalization: TextCapitalization.characters,
                      decoration: const InputDecoration(
                          labelText: 'Section',
                          hintText: '2G',
                          prefixIcon: Icon(Icons.class_rounded)),
                    ),
                    const SizedBox(height: 20),
                    PrimaryButton(
                        label: 'Save Student',
                        icon: Icons.save_rounded,
                        isLoading: _loading,
                        onPressed: _save),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
