import 'package:flutter/material.dart';

class RoutineAppearance {
  static const List<Color> colors = [
    Color(0xFFEF4444), // Red
    Color(0xFFFF8551), // Orange
    Color(0xFFFBBF24), // Yellow
    Color(0xFF22C55E), // Green
    Color(0xFF3B82F6), // Light Blue
    Color(0xFF2563EB), // Blue
    Color(0xFF9333EA), // Purple
    Color(0xFFEC4899), // Pink
    Color(0xFF6B7280), // Gray
  ];

  static const List<IconData> icons = [
    Icons.fitness_center,
    Icons.local_fire_department,
    Icons.sports_gymnastics,
    Icons.self_improvement,
    Icons.apps,
    Icons.flash_on,
    Icons.favorite,
    Icons.star,
  ];

  static Color getColor(int? colorValue, String routineName) {
    if (colorValue != null) {
      return Color(colorValue);
    }

    final index = routineName.hashCode.abs() % colors.length;
    return colors[index];
  }

  static IconData getIcon(int? iconCode, String routineName) {
    if (iconCode != null) {
      try {
        return icons.firstWhere((icon) => icon.codePoint == iconCode);
      } catch (e) {
        return icons[0];
      }
    }

    final index = (routineName.hashCode.abs() ~/ 10) % icons.length;
    return icons[index];
  }
}
