import 'package:flutter/material.dart';
import 'package:today_i_lift/shared/constants/routine_appearance.dart';

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
    final routineName = routine['name'] ?? 'Routine';
    final displayColor = RoutineAppearance.getColor(
      routine['color'],
      routineName,
    );
    final displayIcon = RoutineAppearance.getIcon(routine['icon'], routineName);

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
            color: displayColor,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(displayIcon, color: Colors.white, size: 28),
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
