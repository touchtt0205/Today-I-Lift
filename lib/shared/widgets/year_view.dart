import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:today_i_lift/shared/constants/routine_appearance.dart';

class YearView extends StatelessWidget {
  final int focusedYear;
  final Set<DateTime> workoutDates;
  final Map<String, Map<String, dynamic>> dailyData;
  final void Function(int) onYearChanged;

  const YearView({
    super.key,
    required this.focusedYear,
    required this.workoutDates,
    required this.dailyData,
    required this.onYearChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildHeader(),
        const SizedBox(height: 8),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            childAspectRatio: 0.85,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
          ),
          itemCount: 12,
          itemBuilder: (context, i) => _buildMiniMonth(i + 1),
        ),
      ],
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          icon: const Icon(Icons.chevron_left),
          onPressed: () => onYearChanged(focusedYear - 1),
        ),
        Text(
          '$focusedYear',
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        IconButton(
          icon: const Icon(Icons.chevron_right),
          onPressed: () => onYearChanged(focusedYear + 1),
        ),
      ],
    );
  }

  Widget _buildMiniMonth(int month) {
    final firstDay = DateTime(focusedYear, month, 1);
    final daysInMonth = DateTime(focusedYear, month + 1, 0).day;
    final startOffset = (firstDay.weekday - 1) % 7;

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(
            DateFormat('MMM').format(firstDay),
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
          ),
          const SizedBox(height: 4),
          Expanded(
            child: GridView.count(
              crossAxisCount: 7,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                ...List.generate(startOffset, (_) => const SizedBox()),
                ...List.generate(daysInMonth, (i) {
                  final date = DateTime(focusedYear, month, i + 1);
                  final hasWorkout = workoutDates.contains(date);

                  final key =
                      '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
                  final data = dailyData[key];
                  final routineColor = data != null
                      ? RoutineAppearance.getColor(data['color'], data['name'])
                      : const Color(0xFFFF7043);

                  return Container(
                    margin: const EdgeInsets.all(1),
                    decoration: BoxDecoration(
                      color: hasWorkout ? routineColor : Colors.grey[200],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  );
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
