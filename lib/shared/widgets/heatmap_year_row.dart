import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:today_i_lift/shared/constants/routine_appearance.dart';

class HeatmapYearRow extends StatelessWidget {
  final int year;
  final Map<String, Map<String, dynamic>> dailyData;
  final Future<void> Function(DateTime) onDayTapped;

  const HeatmapYearRow({
    super.key,
    required this.year,
    required this.dailyData,
    required this.onDayTapped,
  });

  @override
  Widget build(BuildContext context) {
    final firstDay = DateTime(year, 1, 1);
    final lastDay = DateTime(year, 12, 31);
    final totalDays = lastDay.difference(firstDay).inDays + 1;
    final startOffset = (firstDay.weekday - 1) % 7;

    // จัดกลุ่มเป็นสัปดาห์
    final weeks = <List<DateTime?>>[];
    List<DateTime?> currentWeek = List.filled(7, null);

    for (int i = 0; i < totalDays + startOffset; i++) {
      final weekIndex = i % 7;
      if (i < startOffset) {
        currentWeek[weekIndex] = null;
      } else {
        currentWeek[weekIndex] = firstDay.add(Duration(days: i - startOffset));
      }
      if (weekIndex == 6) {
        weeks.add(currentWeek);
        currentWeek = List.filled(7, null);
      }
    }
    if (currentWeek.any((d) => d != null)) weeks.add(currentWeek);

    // หา position ของแต่ละเดือน
    final monthLabels = <int, String>{};
    for (int m = 1; m <= 12; m++) {
      final firstOfMonth = DateTime(year, m, 1);
      final dayIndex = firstOfMonth.difference(firstDay).inDays + startOffset;
      final weekPos = dayIndex ~/ 7;
      monthLabels[weekPos] = DateFormat('MMM').format(firstOfMonth);
    }

    const cellSize = 11.0;
    const cellMargin = 1.5;
    const dayLabelWidth = 24.0;

    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$year',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 6),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Day labels
              Column(
                children: [
                  SizedBox(height: cellSize + cellMargin * 2 + 4),
                  ...['Mo', 'Tu', 'We', 'Th', 'Fr', 'Sa', 'Su'].map(
                    (d) => SizedBox(
                      height: cellSize + cellMargin * 2,
                      width: dayLabelWidth,
                      child: Text(
                        d,
                        style: TextStyle(fontSize: 8, color: Colors.grey[500]),
                      ),
                    ),
                  ),
                ],
              ),
              // Grid
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Month labels
                      SizedBox(
                        height: cellSize + cellMargin * 2 + 4,
                        child: Row(
                          children: List.generate(weeks.length, (wi) {
                            return SizedBox(
                              width: cellSize + cellMargin * 2,
                              child: monthLabels.containsKey(wi)
                                  ? OverflowBox(
                                      // เพิ่ม OverflowBox
                                      maxWidth: 28, // ให้ยืดออกได้ถึง 28px
                                      alignment: Alignment.centerLeft,
                                      child: Text(
                                        monthLabels[wi]!,
                                        style: TextStyle(
                                          fontSize: 8,
                                          color: Colors.grey[600],
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    )
                                  : null,
                            );
                          }),
                        ),
                      ),
                      // Week columns
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: List.generate(weeks.length, (wi) {
                          return Column(
                            children: List.generate(7, (di) {
                              final date = weeks[wi][di];
                              if (date == null) {
                                return SizedBox(
                                  width: cellSize + cellMargin * 2,
                                  height: cellSize + cellMargin * 2,
                                );
                              }

                              final key =
                                  '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
                              final data = dailyData[key];

                              Color cellColor = Colors.grey[200]!;
                              if (data != null) {
                                cellColor = RoutineAppearance.getColor(
                                  data['color'],
                                  data['name'],
                                );
                              }

                              return GestureDetector(
                                onTap: () => onDayTapped(date),
                                child: Container(
                                  width: cellSize,
                                  height: cellSize,
                                  margin: EdgeInsets.all(cellMargin),
                                  decoration: BoxDecoration(
                                    color: cellColor,
                                    borderRadius: BorderRadius.circular(2),
                                  ),
                                ),
                              );
                            }),
                          );
                        }),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
