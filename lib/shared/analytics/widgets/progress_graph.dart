import 'dart:math' show pow, log, ln10;
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:today_i_lift/features/services/analytics_service.dart';

class ProgressGraph extends StatefulWidget {
  const ProgressGraph({super.key});

  @override
  State<ProgressGraph> createState() => _ProgressGraphState();
}

class _ProgressGraphState extends State<ProgressGraph> {
  final _service = AnalyticsService();

  String _selectedMetric = 'volume';
  String _selectedRange = '3M';
  List<Map<String, dynamic>> _graphData = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _loading = true);
    final data = await _service.getGraphData(
      metric: _selectedMetric,
      range: _selectedRange,
    );
    if (!mounted) return;
    setState(() {
      _graphData = data;
      _loading = false;
    });
  }

  String _formatYLabel(double v) {
    if (_selectedMetric == 'duration') return '${v.toInt()}m';
    if (_selectedMetric == 'volume') {
      if (v >= 1000) return '${(v / 1000).toStringAsFixed(1)}k';
      return v.toInt().toString();
    }
    return v.toInt().toString();
  }

  String _formatXLabel(DateTime date, int index) {
    switch (_selectedRange) {
      case '1M':
      case '3M':
      case '6M':
        return DateFormat('d/M').format(date);
      default:
        // 1Y, All → แสดงปีเมื่อเป็น Jan หรือ bar แรก
        if (index == 0 || date.month == 1) {
          return DateFormat('MMM\nyyyy').format(date); // "Jan\n2025"
        }
        return DateFormat('MMM').format(date);
    }
  }

  double _niceInterval(double maxValue) {
    if (maxValue <= 0) return 1;
    final raw = maxValue / 4;
    final magnitude = pow(10, (log(raw) / ln10).floor()).toDouble();
    final normalized = raw / magnitude;
    double nice;
    if (normalized <= 1)
      nice = 1;
    else if (normalized <= 2)
      nice = 2;
    else if (normalized <= 5)
      nice = 5;
    else
      nice = 10;
    return nice * magnitude;
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
            'Progress',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          _buildMetricToggle(),
          const SizedBox(height: 8),
          _buildRangeToggle(),
          const SizedBox(height: 16),
          SizedBox(
            height: 180,
            child: _loading ? _buildLoading() : _buildChart(),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricToggle() {
    return Row(
      children: ['duration', 'volume', 'reps'].map((m) {
        final selected = _selectedMetric == m;
        return Padding(
          padding: const EdgeInsets.only(right: 8),
          child: GestureDetector(
            onTap: () {
              setState(() => _selectedMetric = m);
              _loadData();
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
              decoration: BoxDecoration(
                color: selected ? const Color(0xFFFF7043) : Colors.grey[100],
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                m[0].toUpperCase() + m.substring(1),
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: selected ? Colors.white : Colors.grey[600],
                ),
              ),
            ),
          ),
        );
      }).toList(),
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

  Widget _buildLoading() {
    return const Center(child: CircularProgressIndicator());
  }

  Widget _buildChart() {
    if (_graphData.isEmpty) {
      return Center(
        child: Text('No data', style: TextStyle(color: Colors.grey[400])),
      );
    }

    final maxValue = _graphData
        .map((e) => (e['value'] as double?) ?? 0.0)
        .fold(0.0, (a, b) => a > b ? a : b);

    final interval = _niceInterval(maxValue);

    // bar width ตาม จำนวน data
    final barWidth = _graphData.length > 20 ? 5.0 : 8.0;

    return BarChart(
      BarChartData(
        groupsSpace: 4,
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: interval,
          getDrawingHorizontalLine: (v) =>
              FlLine(color: Colors.grey[200]!, strokeWidth: 1),
        ),
        borderData: FlBorderData(show: false),
        maxY: maxValue * 1.2,
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 44,
              interval: interval,
              getTitlesWidget: (v, _) {
                if (v == 0) return const SizedBox();
                return Text(
                  _formatYLabel(v),
                  style: TextStyle(fontSize: 9, color: Colors.grey[500]),
                );
              },
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 30,
              getTitlesWidget: (v, _) {
                final i = v.toInt();
                if (i < 0 || i >= _graphData.length) {
                  return const SizedBox();
                }

                // แสดงแค่ 5 label
                final step = (_graphData.length / 5).ceil();
                if (i % step != 0 && i != _graphData.length - 1) {
                  return const SizedBox();
                }

                final date = _graphData[i]['date'] as DateTime;
                return Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    _formatXLabel(date, i),
                    style: TextStyle(fontSize: 9, color: Colors.grey[500]),
                  ),
                );
              },
            ),
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
        ),
        barGroups: _graphData.asMap().entries.map((e) {
          final value = (e.value['value'] as double?) ?? 0.0;
          return BarChartGroupData(
            x: e.key,
            barRods: [
              BarChartRodData(
                toY: value,
                color: const Color(0xFFFF7043),
                width: barWidth,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(4),
                ),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }
}
