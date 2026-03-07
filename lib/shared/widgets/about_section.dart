import 'package:flutter/material.dart';

class AboutSection extends StatelessWidget {
  final String version;

  const AboutSection({super.key, required this.version});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'About',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: ListTile(
              leading: Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: const Color(0xFFFF7043).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.info_outline,
                  color: Color(0xFFFF7043),
                  size: 18,
                ),
              ),
              title: const Text(
                'App Version',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
              ),
              trailing: Text(
                version.isEmpty ? '...' : version,
                style: TextStyle(fontSize: 13, color: Colors.grey[500]),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
