import 'package:flutter/material.dart';

class HomeStatsCards extends StatelessWidget {
  final int weekStreak;
  final int workoutsThisWeek;
  final int newPRs;

  const HomeStatsCards({
    super.key,
    required this.weekStreak,
    required this.workoutsThisWeek,
    required this.newPRs,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      child: Row(
        children: [
          _buildStatCard('🔥', 'Streak', '$weekStreak', 'weeks'),
          const SizedBox(width: 10),
          _buildStatCard('🎯', 'This Week', '$workoutsThisWeek', 'Routines'),
          const SizedBox(width: 10),
          _buildStatCard('🏆', 'New PRs', '$newPRs', ' '),
        ],
      ),
    );
  }

  Widget _buildStatCard(String emoji, String label, String value, String sub) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.2),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(emoji, style: const TextStyle(fontSize: 14)),
                const SizedBox(width: 4),
                Text(
                  label,
                  style: const TextStyle(fontSize: 14, color: Colors.white70),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            if (sub.isNotEmpty)
              Text(
                sub,
                style: const TextStyle(fontSize: 10, color: Colors.white70),
              ),
          ],
        ),
      ),
    );
  }
}
