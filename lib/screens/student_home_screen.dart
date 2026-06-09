import 'package:flutter/material.dart';

import '../models/app_user.dart';
import '../services/app_data.dart';
import '../widgets/ui_helpers.dart';
import 'login_screen.dart';
import 'records_screen.dart';

class StudentHomeScreen extends StatelessWidget {
  const StudentHomeScreen({super.key, required this.user});
  final AppUser user;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Student Portal',
            style: TextStyle(fontWeight: FontWeight.w900)),
        actions: [
          IconButton(
            onPressed: () {
              AppData.logout();
              Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                  (_) => false);
            },
            icon: const Icon(Icons.logout_rounded),
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 64,
                        height: 64,
                        decoration: BoxDecoration(
                            gradient: AppColors.primaryGradient,
                            borderRadius: BorderRadius.circular(14)),
                        child: const Icon(Icons.person_rounded,
                            color: Colors.white, size: 34),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(user.fullName,
                                style: const TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.w900)),
                            const SizedBox(height: 6),
                            Text(user.email,
                                style: const TextStyle(
                                    color: Colors.black54,
                                    fontWeight: FontWeight.w700)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            InkWell(
              borderRadius: BorderRadius.circular(8),
              onTap: () => Navigator.of(context).push(MaterialPageRoute(
                  builder: (_) => const RecordsScreen(studentOnly: true))),
              child: const AppCard(
                child: Row(
                  children: [
                    Icon(Icons.list_alt_rounded,
                        size: 42, color: AppColors.blue),
                    SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('View Attendance Records',
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.w900)),
                          SizedBox(height: 6),
                          Text('Check attendance logs and status history',
                              style: TextStyle(
                                  color: Colors.black54,
                                  fontWeight: FontWeight.w700)),
                        ],
                      ),
                    ),
                    Icon(Icons.chevron_right_rounded),
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
