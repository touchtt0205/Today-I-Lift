import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:today_i_lift/features/services/analytics_service.dart';

class MuscleRadarChart extends StatefulWidget {
  const MuscleRadarChart({super.key});

  @override
  State<MuscleRadarChart> createState() => _MuscleRadarChartState();
}

class _MuscleRadarChartState extends State<MuscleRadarChart> {
  final _service = AnalyticsService();

  String _selectedRange = 'all';
  Map<String, int> _muscleData = {};
  bool _loading = true;

  // muscle groups ที่ fix ไว้ เพื่อให้ radar ครบทุกแกนเสมอ
  final List<String> _muscleGroups = [
    'Chest',
    'Back',
    'Legs',
    'Shoulders',
    'Arms',
    'Core',
  ];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _loading = true);
    final data = await _service.getMuscleDistribution(range: _selectedRange);
    if (!mounted) return;
    setState(() {
      _muscleData = data;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Muscle Distribution',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          _buildRangeToggle(),
          const SizedBox(height: 16),
          _loading
              ? const SizedBox(
                  height: 200,
                  child: Center(child: CircularProgressIndicator()),
                )
              : _muscleData.isEmpty
              ? SizedBox(
                  height: 200,
                  child: Center(
                    child: Text(
                      'No data',
                      style: TextStyle(color: Colors.grey[400]),
                    ),
                  ),
                )
              : _buildChart(),
        ],
      ),
    );
  }

  Widget _buildRangeToggle() {
    return Row(
      children: ['1M', '3M', '6M', '1Y', 'All'].map((r) {
        final key = r == 'All' ? 'all' : r;
        final selected = _selectedRange == key;
        return Padding(
          padding: const EdgeInsets.only(right: 6),
          child: GestureDetector(
            onTap: () {
              setState(() => _selectedRange = key);
              _loadData();
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: selected
                    ? const Color(0xFFFF7043).withOpacity(0.15)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                r,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: selected ? const Color(0xFFFF7043) : Colors.grey[500],
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildChart() {
    final total = _muscleData.values.fold(0, (a, b) => a + b);
    final maxValue = _muscleData.values.isEmpty
        ? 1.0
        : _muscleData.values.reduce((a, b) => a > b ? a : b).toDouble();

    return Row(
      children: [
        // Radar chart
        SizedBox(
          width: 200,
          height: 200,
          child: RadarChart(
            RadarChartData(
              radarShape: RadarShape.polygon,
              tickCount: 4,
              ticksTextStyle: const TextStyle(fontSize: 0),
              radarBorderData: const BorderSide(color: Colors.transparent),
              gridBorderData: BorderSide(color: Colors.grey[300]!, width: 1),
              tickBorderData: BorderSide(color: Colors.grey[200]!, width: 1),
              getTitle: (index, angle) {
                final name = _muscleGroups[index];
                final short = name.length > 5 ? name.substring(0, 5) : name;
                return RadarChartTitle(text: short, angle: angle);
              },
              titleTextStyle: TextStyle(
                fontSize: 10,
                color: Colors.grey[600],
                fontWeight: FontWeight.bold,
              ),
              titlePositionPercentageOffset: 0.15,
              dataSets: [
                RadarDataSet(
                  fillColor: const Color(0xFFFF7043).withOpacity(0.2),
                  borderColor: const Color(0xFFFF7043),
                  borderWidth: 2,
                  entryRadius: 3,
                  dataEntries: _muscleGroups.map((group) {
                    final value = (_muscleData[group] ?? 0).toDouble();
                    return RadarEntry(value: value);
                  }).toList(),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 8),
        // Legend
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: _muscleGroups.map((group) {
              final value = _muscleData[group] ?? 0;
              final pct = total > 0
                  ? '${(value / total * 100).toStringAsFixed(0)}%'
                  : '0%';

              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: value > 0
                            ? const Color(0xFFFF7043)
                            : Colors.grey[300],
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        group,
                        style: TextStyle(
                          fontSize: 12,
                          color: value > 0 ? Colors.black87 : Colors.grey[400],
                        ),
                      ),
                    ),
                    Text(
                      pct,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: value > 0
                            ? const Color(0xFFFF7043)
                            : Colors.grey[300],
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}
