import 'package:flutter/material.dart';

import '../models/student.dart';
import '../services/app_data.dart';
import '../widgets/ui_helpers.dart';

class MarkAttendanceScreen extends StatefulWidget {
  const MarkAttendanceScreen({super.key});

  @override
  State<MarkAttendanceScreen> createState() => _MarkAttendanceScreenState();
}

class _MarkAttendanceScreenState extends State<MarkAttendanceScreen> {
  final _search = TextEditingController();
  final _remarks = TextEditingController();
  String _status = 'Present';
  Student? _selected;
  List<Student> _students = [];
  bool _loading = true;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _search.dispose();
    _remarks.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      _students =
          await AppData.requireService().getStudents(search: _search.text);
    } catch (e) {
      if (!mounted) return;
      showAppMessage(context, AppData.readableError(e), error: true);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _mark() async {
    final selected = _selected;
    if (selected == null) {
      showAppMessage(context, 'Select a student first.', error: true);
      return;
    }
    setState(() => _saving = true);
    try {
      await AppData.requireService().markAttendance(
        student: selected,
        status: _status,
        markedBy: AppData.currentUser?.id ?? '',
        remarks: _remarks.text,
      );
      if (!mounted) return;

      showAppMessage(context, 'Attendance marked: $_status');
      setState(() {
        _selected = null;
        _remarks.clear();
      });
    } catch (e) {
      if (!mounted) return;
      showAppMessage(context, AppData.readableError(e), error: true);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'Present':
        return const Color(0xFF16A34A);
      case 'Late':
        return AppColors.amber;
      case 'Absent':
        return AppColors.rose;
      default:
        return AppColors.blue;
    }
  }

  Widget _studentOption(Student student) {
    final selected = _selected?.id == student.id;

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: () => setState(() => _selected = student),
        child: AppCard(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Icon(
                selected
                    ? Icons.radio_button_checked_rounded
                    : Icons.radio_button_unchecked_rounded,
                color: selected ? AppColors.teal : AppColors.muted,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(student.fullName,
                        style: const TextStyle(
                            fontWeight: FontWeight.w900, fontSize: 16)),
                    Text(
                      '${student.studentNumber} - ${student.course} ${student.section}',
                      style: const TextStyle(
                          color: Colors.black54, fontWeight: FontWeight.w700),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final statuses = ['Present', 'Late', 'Absent', 'Excused'];

    return Scaffold(
      appBar: AppBar(
          title: const Text('Mark Attendance',
              style: TextStyle(fontWeight: FontWeight.w900))),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            TextField(
              controller: _search,
              onChanged: (_) => _load(),
              decoration: const InputDecoration(
                  labelText: 'Search student',
                  prefixIcon: Icon(Icons.search_rounded)),
            ),
            const SizedBox(height: 16),
            if (_loading)
              const Center(
                  child: Padding(
                      padding: EdgeInsets.all(32),
                      child: CircularProgressIndicator()))
            else if (_students.isEmpty)
              const AppCard(
                  child: Text('No students found.',
                      style: TextStyle(fontWeight: FontWeight.w800)))
            else
              ..._students.take(8).map(_studentOption),
            const SizedBox(height: 10),
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Attendance Status',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: statuses.map((status) {
                      final selected = _status == status;
                      return ChoiceChip(
                        label: Text(status,
                            style: TextStyle(
                                fontWeight: FontWeight.w900,
                                color:
                                    selected ? Colors.white : AppColors.ink)),
                        selected: selected,
                        selectedColor: _statusColor(status),
                        onSelected: (_) => setState(() => _status = status),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _remarks,
                    maxLines: 2,
                    decoration: const InputDecoration(
                        labelText: 'Remarks optional',
                        prefixIcon: Icon(Icons.notes_rounded)),
                  ),
                  const SizedBox(height: 18),
                  PrimaryButton(
                    label: 'Save Attendance',
                    icon: Icons.check_circle_rounded,
                    isLoading: _saving,
                    onPressed: _mark,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
