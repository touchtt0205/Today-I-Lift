import 'package:flutter/material.dart';
import 'package:today_i_lift/shared/constants/routine_appearance.dart';

class LastWorkoutCard extends StatelessWidget {
  final Map<String, dynamic>? session;
  final bool loading;

  const LastWorkoutCard({
    super.key,
    required this.session,
    required this.loading,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Last Routine',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          loading
              ? const Center(child: CircularProgressIndicator())
              : session == null
              ? _buildEmpty()
              : _buildCard(session!),
        ],
      ),
    );
  }

  Widget _buildEmpty() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        'No routine yet\nStart your first routine!',
        textAlign: TextAlign.center,
        style: TextStyle(color: Colors.grey[500]),
      ),
    );
  }

  Widget _buildCard(Map<String, dynamic> session) {
    final routine = session['routines'];
    final routineName = routine?['name'] ?? 'Unknown';
    final color = RoutineAppearance.getColor(routine?['color'], routineName);
    final icon = RoutineAppearance.getIcon(routine?['icon'], routineName);

    final startedAt = DateTime.parse(session['started_at']).toLocal();
    final mins = (session['duration_seconds'] ?? 0) ~/ 60;
    final totalSets = session['total_sets'] ?? 0;
    final totalExercises = session['total_exercises'] ?? 0;
    final totalVolume = (session['total_volume'] ?? 0.0) as double;
    final volumeLabel = totalVolume.toInt().toString();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: Colors.white, size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      routineName,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      _formatTimeAgo(startedAt),
                      style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '$mins m',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                  Text(
                    'duration',
                    style: TextStyle(fontSize: 10, color: Colors.grey[500]),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(child: _buildStat('$totalExercises', 'exercises')),
              const SizedBox(width: 8),
              Expanded(child: _buildStat('$totalSets', 'sets')),
              const SizedBox(width: 8),
              Expanded(child: _buildStat(volumeLabel, 'volume')),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                gradient: LinearGradient(
                  colors: [color.withOpacity(0.8), color],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStat(String value, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 2),
          Text(label, style: TextStyle(fontSize: 11, color: Colors.grey[600])),
        ],
      ),
    );
  }

  String _formatTimeAgo(DateTime date) {
    final diff = DateTime.now().difference(date);
    if (diff.inDays == 0) return 'Today';
    if (diff.inDays == 1) return 'Yesterday';
    if (diff.inDays < 7) return '${diff.inDays} Days Ago';
    return '${(diff.inDays / 7).floor()} Weeks Ago';
  }
}
