import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:today_i_lift/shared/constants/routine_appearance.dart';

class MonthView extends StatelessWidget {
  final DateTime focusedMonth;
  final Set<DateTime> workoutDates;
  final Map<String, Map<String, dynamic>> dailyData;
  final DateTime? selectedDate;
  final Future<void> Function(DateTime) onDayTapped;
  final void Function(DateTime) onMonthChanged;

  const MonthView({
    super.key,
    required this.focusedMonth,
    required this.workoutDates,
    required this.dailyData,
    required this.selectedDate,
    required this.onDayTapped,
    required this.onMonthChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildHeader(),
          const SizedBox(height: 12),
          _buildWeekdayLabels(),
          const SizedBox(height: 8),
          _buildGrid(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          icon: const Icon(Icons.chevron_left),
          onPressed: () => onMonthChanged(
            DateTime(focusedMonth.year, focusedMonth.month - 1),
          ),
        ),
        Text(
          DateFormat('MMMM yyyy').format(focusedMonth),
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        IconButton(
          icon: const Icon(Icons.chevron_right),
          onPressed: () => onMonthChanged(
            DateTime(focusedMonth.year, focusedMonth.month + 1),
          ),
        ),
      ],
    );
  }

  Widget _buildWeekdayLabels() {
    const days = ['Mo', 'Tu', 'We', 'Th', 'Fr', 'Sa', 'Su'];
    return Row(
      children: days
          .map(
            (d) => Expanded(
              child: Center(
                child: Text(
                  d,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[500],
                  ),
                ),
              ),
            ),
          )
          .toList(),
    );
  }

  Widget _buildGrid() {
    final firstDay = DateTime(focusedMonth.year, focusedMonth.month, 1);
    final daysInMonth = DateTime(
      focusedMonth.year,
      focusedMonth.month + 1,
      0,
    ).day;
    final startOffset = (firstDay.weekday - 1) % 7;
    final today = DateTime.now();
    final todayNormalized = DateTime(today.year, today.month, today.day);

    final cells = <Widget>[];

    for (int i = 0; i < startOffset; i++) {
      cells.add(const SizedBox());
    }

    for (int day = 1; day <= daysInMonth; day++) {
      final date = DateTime(focusedMonth.year, focusedMonth.month, day);
      final hasWorkout = workoutDates.contains(date);
      final isSelected = selectedDate == date;
      final isToday = date == todayNormalized;

      // ดึงสีจาก routine
      final key =
          '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
      final data = dailyData[key];
      final routineColor = data != null
          ? RoutineAppearance.getColor(data['color'], data['name'])
          : const Color(0xFFFF7043);

      cells.add(
        GestureDetector(
          onTap: () => onDayTapped(date),
          child: Container(
            margin: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              color: isSelected
                  ? routineColor
                  : hasWorkout
                  ? routineColor.withOpacity(0.2)
                  : Colors.transparent,
              shape: BoxShape.circle,
              border: isToday
                  ? Border.all(color: routineColor, width: 1.5)
                  : null,
            ),
            child: Center(
              child: Text(
                '$day',
                style: TextStyle(
                  fontWeight: hasWorkout || isSelected
                      ? FontWeight.bold
                      : FontWeight.normal,
                  color: isSelected
                      ? Colors.white
                      : hasWorkout
                      ? routineColor
                      : Colors.black87,
                  fontSize: 14,
                ),
              ),
            ),
          ),
        ),
      );
    }

    return GridView.count(
      crossAxisCount: 7,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: cells,
    );
  }
}
