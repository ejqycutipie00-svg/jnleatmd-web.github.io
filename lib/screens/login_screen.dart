import 'package:flutter/material.dart';

import '../models/app_user.dart';
import '../services/app_data.dart';
import '../widgets/ui_helpers.dart';
import 'student_home_screen.dart';
import 'teacher_home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _loading = false;
  bool _hidePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      showAppMessage(context, 'Enter email and password.', error: true);
      return;
    }

    setState(() => _loading = true);
    try {
      final AppUser? user =
          await AppData.requireService().login(email, password);

      if (!mounted) return;

      if (user == null) {
        showAppMessage(context, 'Invalid email or password.', error: true);
        return;
      }

      AppData.setCurrentUser(user);
      final page = user.isTeacher
          ? TeacherHomeScreen(user: user)
          : StudentHomeScreen(user: user);
      Navigator.of(context)
          .pushReplacement(MaterialPageRoute(builder: (_) => page));
    } catch (e) {
      showAppMessage(context, AppData.readableError(e), error: true);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final setupError = AppData.setupError;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 460),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 86,
                      height: 86,
                      decoration: BoxDecoration(
                        gradient: AppColors.primaryGradient,
                        borderRadius: BorderRadius.circular(18),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.blue.withValues(alpha: .26),
                            blurRadius: 24,
                            offset: const Offset(0, 14),
                          ),
                        ],
                      ),
                      child: const Icon(Icons.fact_check_rounded,
                          color: Colors.white, size: 42),
                    ),
                  ),
                  const SizedBox(height: 26),
                  const Center(
                    child: Text(
                      'Student Attendance\nMonitor',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 38,
                        height: .98,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0,
                      ),
                    ),
                  ),
                  const SizedBox(height: 28),
                  if (setupError != null) ...[
                    AppCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Row(
                            children: [
                              Icon(Icons.info_outline_rounded),
                              SizedBox(width: 10),
                              Text('Supabase Setup Required',
                                  style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w900)),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text(setupError,
                              style: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                  color: Colors.black87)),
                          const SizedBox(height: 10),
                          const Text(
                            'Run database/schema.sql in Supabase SQL Editor. '
                            'Then copy Project Settings > API > Project URL '
                            'and the anon public key into .env.',
                            style: TextStyle(
                                fontWeight: FontWeight.w700,
                                color: Colors.black54),
                          ),
                        ],
                      ),
                    ),
                  ] else ...[
                    AppCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          TextField(
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            decoration: const InputDecoration(
                              labelText: 'Email',
                              prefixIcon: Icon(Icons.email_rounded),
                            ),
                          ),
                          const SizedBox(height: 14),
                          TextField(
                            controller: _passwordController,
                            obscureText: _hidePassword,
                            decoration: InputDecoration(
                              labelText: 'Password',
                              prefixIcon: const Icon(Icons.lock_rounded),
                              suffixIcon: IconButton(
                                onPressed: () => setState(
                                    () => _hidePassword = !_hidePassword),
                                icon: Icon(_hidePassword
                                    ? Icons.visibility_rounded
                                    : Icons.visibility_off_rounded),
                              ),
                            ),
                          ),
                          const SizedBox(height: 18),
                          PrimaryButton(
                            label: 'Login',
                            icon: Icons.login_rounded,
                            isLoading: _loading,
                            onPressed: _login,
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
