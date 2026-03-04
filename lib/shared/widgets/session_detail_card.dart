import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:today_i_lift/shared/constants/routine_appearance.dart';

class SessionDetailCard extends StatelessWidget {
  final DateTime date;
  final List<Map<String, dynamic>> sessions;

  const SessionDetailCard({
    super.key,
    required this.date,
    required this.sessions,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            DateFormat('EEEE, MMM d').format(date),
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          ...sessions.map((session) => _buildSessionItem(session)),
        ],
      ),
    );
  }

  Widget _buildSessionItem(Map<String, dynamic> session) {
    final routine = session['routines'];
    final routineName = routine?['name'] ?? 'Unknown';
    final color = RoutineAppearance.getColor(routine?['color'], routineName);
    final icon = RoutineAppearance.getIcon(routine?['icon'], routineName);
    final duration = session['duration_seconds'] ?? 0;
    final mins = duration ~/ 60;
    final secs = duration % 60;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: Colors.white, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  routineName,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  '${mins}m ${secs}s',
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
