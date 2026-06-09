import 'package:flutter/material.dart';

import '../models/app_user.dart';
import '../services/app_data.dart';
import '../widgets/ui_helpers.dart';
import 'add_student_screen.dart';
import 'login_screen.dart';
import 'mark_attendance_screen.dart';
import 'records_screen.dart';
import 'students_screen.dart';

class TeacherHomeScreen extends StatelessWidget {
  const TeacherHomeScreen({super.key, required this.user});
  final AppUser user;

  void _logout(BuildContext context) {
    AppData.logout();
    Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const LoginScreen()), (_) => false);
  }

  @override
  Widget build(BuildContext context) {
    final items = [
      _HomeItem('Add Students', 'Register new student records',
          Icons.person_add_alt_1_rounded, const AddStudentScreen()),
      _HomeItem('Student List', 'Search, view, and delete students',
          Icons.groups_rounded, const StudentsScreen()),
      _HomeItem('Mark Attendance', 'Record present, late, absent, or excused',
          Icons.fact_check_rounded, const MarkAttendanceScreen()),
      _HomeItem('Attendance Records', 'View all attendance history',
          Icons.list_alt_rounded, const RecordsScreen()),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Teacher Dashboard',
            style: TextStyle(fontWeight: FontWeight.w900)),
        actions: [
          IconButton(
              onPressed: () => _logout(context),
              icon: const Icon(Icons.logout_rounded)),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            AppCard(
              child: Row(
                children: [
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                        gradient: AppColors.primaryGradient,
                        borderRadius: BorderRadius.circular(14)),
                    child: const Icon(Icons.school_rounded,
                        color: Colors.white, size: 32),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Welcome, ${user.fullName}',
                            style: const TextStyle(
                                fontSize: 20, fontWeight: FontWeight.w900)),
                        const SizedBox(height: 6),
                        const Text('Teacher Account',
                            style: TextStyle(
                                color: Colors.black54,
                                fontWeight: FontWeight.w800)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: MediaQuery.of(context).size.width > 720 ? 2 : 1,
                mainAxisExtent: 132,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
              ),
              itemCount: items.length,
              itemBuilder: (context, index) {
                final item = items[index];
                final accentColors = [
                  AppColors.teal,
                  AppColors.blue,
                  AppColors.amber,
                  AppColors.rose,
                ];
                final accent = accentColors[index % accentColors.length];
                return InkWell(
                  borderRadius: BorderRadius.circular(8),
                  onTap: () => Navigator.of(context)
                      .push(MaterialPageRoute(builder: (_) => item.page)),
                  child: AppCard(
                    child: Row(
                      children: [
                        Container(
                          width: 58,
                          height: 58,
                          decoration: BoxDecoration(
                              color: accent.withValues(alpha: .12),
                              borderRadius: BorderRadius.circular(12)),
                          child: Icon(item.icon, color: accent, size: 30),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(item.title,
                                  style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w900)),
                              const SizedBox(height: 6),
                              Text(item.subtitle,
                                  style: const TextStyle(
                                      color: Colors.black54,
                                      fontWeight: FontWeight.w700)),
                            ],
                          ),
                        ),
                        const Icon(Icons.chevron_right_rounded),
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _HomeItem {
  final String title;
  final String subtitle;
  final IconData icon;
  final Widget page;
  const _HomeItem(this.title, this.subtitle, this.icon, this.page);
}
