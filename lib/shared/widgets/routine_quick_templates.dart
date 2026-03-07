import 'package:flutter/material.dart';

class RoutineQuickTemplates extends StatelessWidget {
  final void Function(String type) onApply;

  const RoutineQuickTemplates({super.key, required this.onApply});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: _buildButton('💪 Push', const Color(0xFFEF4444), 'push')),
        const SizedBox(width: 8),
        Expanded(child: _buildButton('🔥 Pull', const Color(0xFFFF8551), 'pull')),
        const SizedBox(width: 8),
        Expanded(child: _buildButton('🦵 Legs', const Color(0xFFFBBF24), 'legs')),
      ],
    );
  }

  Widget _buildButton(String label, Color color, String type) {
    return GestureDetector(
      onTap: () => onApply(type),
      child: Container(
        height: 50,
        decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(12)),
        child: Center(
          child: Text(label,
              style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
        ),
      ),
    );
  }
}