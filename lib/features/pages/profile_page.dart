import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:today_i_lift/shared/widgets/about_section.dart';
import 'package:today_i_lift/shared/widgets/account_section.dart';
import 'package:today_i_lift/shared/widgets/profile_header.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String _version = '';

  @override
  void initState() {
    super.initState();
    _loadVersion();
  }

  Future<void> _loadVersion() async {
    final info = await PackageInfo.fromPlatform();
    if (!mounted) return;
    setState(() => _version = info.version);
  }

  String _getInitials(String name, String email) {
    if (name.isNotEmpty) {
      final parts = name.trim().split(' ');
      if (parts.length >= 2) {
        return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
      }
      return name[0].toUpperCase();
    }
    return email.isNotEmpty ? email[0].toUpperCase() : '?';
  }

  @override
  Widget build(BuildContext context) {
    final user = Supabase.instance.client.auth.currentUser;

    if (user == null) {
      return const Scaffold(body: Center(child: Text('No user logged in')));
    }

    final displayName = (user.userMetadata?['full_name'] as String? ?? '')
        .trim();
    final email = user.email ?? '';
    final avatarUrl = user.userMetadata?['avatar_url'] as String?;
    final initials = _getInitials(displayName, email);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: SingleChildScrollView(
        child: Column(
          children: [
            ProfileHeader(
              displayName: displayName,
              email: email,
              initials: initials,
              avatarUrl: avatarUrl,
            ),
            const SizedBox(height: 24),
            const AccountSection(),
            const SizedBox(height: 24),
            AboutSection(version: _version),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
