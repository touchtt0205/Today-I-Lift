import 'package:flutter/material.dart';

class BottomNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const BottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFE8EAF6),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(icon: Icons.home, index: 0),
              _buildNavItem(icon: Icons.fitness_center, index: 1),
              _buildNavItem(
                icon: Icons.play_circle_filled,
                index: 2,
                isLarge: true,
              ),
              _buildNavItem(icon: Icons.calendar_today, index: 3),
              _buildNavItem(icon: Icons.person, index: 4),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required int index,
    bool isLarge = false,
  }) {
    final bool isSelected = currentIndex == index;

    return GestureDetector(
      onTap: () => onTap(index),
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.all(8),
        child: Icon(
          icon,
          size: isLarge ? 56 : 28,
          color: index == 2
              ? const Color(0xFFFF7043) // ปุ่ม Play สีส้มตลอด
              : (isSelected
                    ? const Color(0xFFFF7043)
                    : Colors.grey.withOpacity(0.6)),
        ),
      ),
    );
  }
}
