import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'login_page.dart';
import '../../app//app.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    final supabase = Supabase.instance.client;

    return StreamBuilder<AuthState>(
      stream: supabase.auth.onAuthStateChange,
      builder: (context, snapshot) {
        // ระหว่างเช็คสถานะ
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final session = snapshot.data?.session;

        // ยังไม่ล็อกอิน → ไปหน้า Login
        if (session == null) {
          return const LoginPage();
        }

        // ล็อกอินแล้ว → ไปหน้า Home
        return const TodayILiftApp();
      },
    );
  }
}
