import 'package:flutter/material.dart';
import 'package:today_i_lift/features/repositories/routine_repository.dart';
import 'package:today_i_lift/features/services/analytics_service.dart';
import 'package:today_i_lift/shared/widgets/gradient_app_bar.dart';
import 'package:today_i_lift/shared/widgets/home_stats_cards.dart';
import 'package:today_i_lift/shared/widgets/last_workout_card.dart'
    show LastWorkoutCard;
import 'package:today_i_lift/shared/widgets/recent_prs.dart';
import 'package:today_i_lift/shared/widgets/routine_list.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _routineRepo = RoutineRepository();
  final _analyticsService = AnalyticsService();

  List<Map<String, dynamic>> _routines = [];
  int _weekStreak = 0;
  int _workoutsThisWeek = 0;
  Map<String, dynamic>? _lastWorkout;
  List<Map<String, dynamic>> _recentPRs = [];
  Map<String, DateTime> _lastPlayedPerRoutine = {};
  bool _statsLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAll();
  }

  Future<void> _loadAll() async {
    setState(() => _statsLoading = true);

    final results = await Future.wait([
      _routineRepo.getRoutines(),
      _analyticsService.getWeekStreak(),
      _analyticsService.getWorkoutsThisWeek(),
      _analyticsService.getLastWorkout(),
      _analyticsService.getRecentPRs(),
      _analyticsService.getLastPlayedPerRoutine(),
    ]);

    if (!mounted) return;
    setState(() {
      _routines = results[0] as List<Map<String, dynamic>>;
      _weekStreak = results[1] as int;
      _workoutsThisWeek = results[2] as int;
      _lastWorkout = results[3] as Map<String, dynamic>?;
      _recentPRs = results[4] as List<Map<String, dynamic>>;
      _lastPlayedPerRoutine = results[5] as Map<String, DateTime>;
      _statsLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: GradientAppBar(
        title: 'Today I Lift',
        showDate: true,
        bottomHeight: 120,
        bottomContent: HomeStatsCards(
          weekStreak: _weekStreak,
          workoutsThisWeek: _workoutsThisWeek,
          newPRs: _recentPRs.length,
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _loadAll,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 24),
              LastWorkoutCard(session: _lastWorkout, loading: _statsLoading),
              const SizedBox(height: 24),
              RecentPRs(records: _recentPRs),
              if (_recentPRs.isNotEmpty) const SizedBox(height: 24),
              RoutineList(
                routines: _routines,
                lastPlayedPerRoutine: _lastPlayedPerRoutine,
                onChanged: _loadAll,
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}
