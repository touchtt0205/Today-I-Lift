import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final supabase = Supabase.instance.client;

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final user = supabase.auth.currentUser;

    if (user == null) {
      return const Scaffold(
        body: Center(child: Text('No user')),
      );
    }

    final email = user.email ?? '-';
    final provider = user.appMetadata['provider'] ?? 'email';
    final avatarUrl = user.userMetadata?['avatar_url'];

    String loginType;
    switch (provider) {
      case 'google':
        loginType = 'Google';
        break;
      default:
        loginType = 'Email & Password';
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          IconButton(
            onPressed: () async => await supabase.auth.signOut(),
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // รูปโปรไฟล์
            avatarUrl != null
                ? CircleAvatar(
                    radius: 40,
                    backgroundImage: NetworkImage(avatarUrl),
                  )
                : const CircleAvatar(
                    radius: 40,
                    child: Icon(Icons.person, size: 40),
                  ),

            const SizedBox(height: 24),

            // Email
            const Text(
              'Email',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Text(email),

            const SizedBox(height: 16),

            // วิธีล็อกอิน
            const Text(
              'Login Method',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Text(loginType),

            const SizedBox(height: 24),

            // User ID
            const Text(
              'User ID',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Text(user.id),
          ],
        ),
      ),
    );
  }
}
