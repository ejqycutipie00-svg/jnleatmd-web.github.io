import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/attendance_record.dart';
import '../services/app_data.dart';
import '../widgets/ui_helpers.dart';

class RecordsScreen extends StatefulWidget {
  const RecordsScreen({super.key, this.studentOnly = false});
  final bool studentOnly;

  @override
  State<RecordsScreen> createState() => _RecordsScreenState();
}

class _RecordsScreenState extends State<RecordsScreen> {
  final _search = TextEditingController();
  late Future<List<AttendanceRecord>> _future;

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

  Future<List<AttendanceRecord>> _load() async {
    if (widget.studentOnly) {
      final studentNumber = AppData.currentUser?.studentNumber ?? '';
      return AppData.requireService().getStudentAttendanceRecords(studentNumber);
    }
    return AppData.requireService().getAttendanceRecords(search: _search.text);
  }

  void _refresh() => setState(() => _future = _load());

  Color _statusColor(String status) {
    switch (status) {
      case 'Present':
        return const Color(0xFF16A34A);
      case 'Late':
        return const Color(0xFFD97706);
      case 'Absent':
        return const Color(0xFFDC2626);
      default:
        return const Color(0xFF2563EB);
    }
  }

  Widget _summaryCard(List<AttendanceRecord> records) {
    final total = records.length;
    final present = records.where((r) => r.status == 'Present').length;
    final late = records.where((r) => r.status == 'Late').length;
    final absent = records.where((r) => r.status == 'Absent').length;
    final latestStatus = records.isEmpty ? 'No records' : records.first.status;

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 54,
                height: 54,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF0F766E), Color(0xFF2563EB)],
                  ),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: const Icon(Icons.insights_rounded,
                    color: Colors.white, size: 30),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('My Attendance Status',
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.w900)),
                    const SizedBox(height: 4),
                    Text('Latest: $latestStatus',
                        style: TextStyle(
                            color: _statusColor(latestStatus),
                            fontWeight: FontWeight.w900)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              _StatPill(label: 'Total', value: '$total'),
              const SizedBox(width: 8),
              _StatPill(label: 'Present', value: '$present'),
              const SizedBox(width: 8),
              _StatPill(label: 'Late', value: '$late'),
              const SizedBox(width: 8),
              _StatPill(label: 'Absent', value: '$absent'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _studentHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 10),
      child: AppCard(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            const Icon(Icons.badge_rounded, color: Color(0xFF2563EB)),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                AppData.currentUser?.studentNumber ?? 'Student account',
                style:
                    const TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _searchField() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: TextField(
        controller: _search,
        onChanged: (_) => _refresh(),
        decoration: const InputDecoration(
          labelText: 'Search records',
          prefixIcon: Icon(Icons.search_rounded),
        ),
      ),
    );
  }

  Widget _recordCard(AttendanceRecord record, DateFormat dateFormat) {
    return AppCard(
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: _statusColor(record.status).withValues(alpha: .12),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Icon(Icons.verified_rounded,
                color: _statusColor(record.status)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  record.studentName.isEmpty ? 'Student' : record.studentName,
                  style: const TextStyle(
                      fontWeight: FontWeight.w900, fontSize: 16),
                ),
                const SizedBox(height: 4),
                Text(
                  '${record.studentNumber} - ${record.course} ${record.section}',
                  style: const TextStyle(
                      color: Colors.black54, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 6),
                Text(
                  dateFormat.format(record.dateTime.toLocal()),
                  style: const TextStyle(
                      color: Colors.black54, fontWeight: FontWeight.w700),
                ),
                if (record.remarks.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Text(record.remarks,
                      style: const TextStyle(fontWeight: FontWeight.w600)),
                ],
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
            decoration: BoxDecoration(
              color: _statusColor(record.status),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              record.status,
              style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                  fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('MMM d, yyyy - h:mm a');

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.studentOnly ? 'My Attendance' : 'Attendance Records',
          style: const TextStyle(fontWeight: FontWeight.w900),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            widget.studentOnly ? _studentHeader() : _searchField(),
            Expanded(
              child: FutureBuilder<List<AttendanceRecord>>(
                future: _future,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Text(
                          AppData.readableError(snapshot.error!),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    );
                  }

                  final records = snapshot.data ?? [];
                  if (records.isEmpty) {
                    if (widget.studentOnly) {
                      return ListView(
                        padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                        children: [
                          _summaryCard(records),
                          const SizedBox(height: 12),
                          const AppCard(
                            child: Text('No attendance records yet.',
                                style: TextStyle(fontWeight: FontWeight.w800)),
                          ),
                        ],
                      );
                    }
                    return const Center(
                      child: Text('No attendance records yet.',
                          style: TextStyle(fontWeight: FontWeight.w800)),
                    );
                  }

                  return ListView.separated(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                    itemBuilder: (context, index) {
                      if (widget.studentOnly && index == 0) {
                        return _summaryCard(records);
                      }

                      final recordIndex = widget.studentOnly ? index - 1 : index;
                      return _recordCard(records[recordIndex], dateFormat);
                    },
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemCount: records.length + (widget.studentOnly ? 1 : 0),
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

class _StatPill extends StatelessWidget {
  const _StatPill({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            Text(value,
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
            const SizedBox(height: 2),
            Text(label,
                style: const TextStyle(
                    color: Colors.black54,
                    fontSize: 11,
                    fontWeight: FontWeight.w800)),
          ],
        ),
      ),
    );
  }
}
