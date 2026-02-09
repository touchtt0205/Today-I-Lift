import 'package:flutter/material.dart';

class RoutineCard extends StatelessWidget {
  final Map<String, dynamic> routine;
  final int exerciseCount;
  final VoidCallback onTap;

  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const RoutineCard({
    super.key,
    required this.routine,
    required this.exerciseCount,
    required this.onTap,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final colors = [
      const Color(0xFFEF4444),
      const Color(0xFFFF8551),
      const Color(0xFFFBBF24),
      const Color(0xFF22C55E),
      const Color(0xFF3B82F6),
      const Color(0xFF2563EB),
      const Color(0xFF9333EA),
      const Color(0xFFEC4899),
      const Color(0xFF6B7280),
    ];
    final icons = [
      Icons.fitness_center,
      Icons.local_fire_department,
      Icons.sports_gymnastics,
      Icons.self_improvement,
      Icons.apps,
      Icons.flash_on,
      Icons.favorite,
      Icons.star,
    ];

    final routineName = routine['name'] ?? 'Routine';
    final colorIndex = routineName.hashCode.abs() % colors.length;
    final iconIndex = (routineName.hashCode.abs() ~/ 10) % icons.length;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: colors[colorIndex],
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icons[iconIndex], color: Colors.white, size: 28),
        ),
        title: Text(
          routineName,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          '$exerciseCount exercises',
          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
        ),
        onTap: onTap,

        trailing: (onEdit != null && onDelete != null)
            ? Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit, size: 20, color: Colors.grey),
                    onPressed: onEdit,
                    tooltip: 'Edit',
                  ),
                  IconButton(
                    icon: const Icon(
                      Icons.delete,
                      size: 20,
                      color: Colors.grey,
                    ),
                    onPressed: onDelete,
                    tooltip: 'Delete',
                  ),
                ],
              )
            : const Icon(Icons.chevron_right, color: Colors.grey),
      ),
    );
  }
}
