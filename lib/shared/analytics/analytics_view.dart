import 'package:flutter/material.dart';
import 'package:today_i_lift/features/services/analytics_service.dart';
import 'package:today_i_lift/shared/analytics/widgets/muscle_radar_chart.dart';
import 'package:today_i_lift/shared/analytics/widgets/personal_records.dart';
import 'package:today_i_lift/shared/analytics/widgets/progress_graph.dart';
import 'package:today_i_lift/shared/analytics/widgets/streak_card.dart';

class AnalyticsView extends StatefulWidget {
  const AnalyticsView({super.key});

  @override
  State<AnalyticsView> createState() => _AnalyticsViewState();
}

class _AnalyticsViewState extends State<AnalyticsView> {
  final _service = AnalyticsService();

  int _weekStreak = 0;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final streak = await _service.getWeekStreak();
    if (!mounted) return;
    setState(() {
      _weekStreak = streak;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Center(child: CircularProgressIndicator());

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          StreakCard(weekStreak: _weekStreak),
          const SizedBox(height: 16),
          const ProgressGraph(),
          const SizedBox(height: 16),
          const MuscleRadarChart(),
          const SizedBox(height: 16),
          const PersonalRecords(),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
