import 'package:flutter/material.dart';

class RoutineAppearanceSection extends StatelessWidget {
  final String routineName;
  final int exerciseCount;
  final List<Color> colors;
  final List<IconData> icons;
  final int selectedColorIndex;
  final int selectedIconIndex;
  final ValueChanged<int> onColorChanged;
  final ValueChanged<int> onIconChanged;

  const RoutineAppearanceSection({
    super.key,
    required this.routineName,
    required this.exerciseCount,
    required this.colors,
    required this.icons,
    required this.selectedColorIndex,
    required this.selectedIconIndex,
    required this.onColorChanged,
    required this.onIconChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildPreview(),
        const SizedBox(height: 16),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Color :',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 8),
                  _buildColorPicker(),
                ],
              ),
            ),
            const SizedBox(width: 24),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Icon :',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 8),
                  _buildIconPicker(),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPreview() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: colors[selectedColorIndex],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icons[selectedIconIndex],
              color: Colors.white,
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  routineName.isEmpty ? 'Routine Name' : routineName,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '$exerciseCount exercises',
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
          Icon(Icons.chevron_right, color: Colors.grey[400]),
        ],
      ),
    );
  }

  Widget _buildColorPicker() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: colors.asMap().entries.map((entry) {
        final isSelected = selectedColorIndex == entry.key;
        return GestureDetector(
          onTap: () => onColorChanged(entry.key),
          child: Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: entry.value,
              shape: BoxShape.circle,
              border: isSelected
                  ? Border.all(color: Colors.white, width: 2)
                  : null,
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: entry.value.withOpacity(0.5),
                        blurRadius: 8,
                        spreadRadius: 1,
                      ),
                    ]
                  : null,
            ),
            child: isSelected
                ? const Icon(Icons.check, color: Colors.white, size: 20)
                : null,
          ),
        );
      }).toList(),
    );
  }

  Widget _buildIconPicker() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: icons.asMap().entries.map((entry) {
        final isSelected = selectedIconIndex == entry.key;
        return GestureDetector(
          onTap: () => onIconChanged(entry.key),
          child: Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: isSelected ? const Color(0xFFFF8551) : Colors.grey[200],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              entry.value,
              color: isSelected ? Colors.white : Colors.grey[600],
              size: 20,
            ),
          ),
        );
      }).toList(),
    );
  }
}
