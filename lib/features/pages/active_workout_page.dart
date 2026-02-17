import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:today_i_lift/features/model/workout.dart';
import 'package:today_i_lift/features/model/workoutexercise.dart';
import 'package:today_i_lift/features/pages/workout_summary_page.dart';
import 'package:today_i_lift/features/services/workout_service.dart';
import 'package:today_i_lift/shared/widgets/gradient_app_bar.dart';
import 'package:today_i_lift/shared/widgets/exercise_card.dart';

class ActiveWorkoutScreen extends StatefulWidget {
  final Workout workout;
  final String sessionId;

  const ActiveWorkoutScreen({
    super.key,
    required this.workout,
    required this.sessionId,
  });

  @override
  State<ActiveWorkoutScreen> createState() => _ActiveWorkoutScreenState();
}

class _ActiveWorkoutScreenState extends State<ActiveWorkoutScreen> {
  final _workoutService = WorkoutService();

  List<WorkoutExercise> exercises = [];
  bool loading = true;
  int expandedIndex = 0;

  Duration elapsed = Duration.zero;
  late final DateTime _startTime;
  late final Ticker _ticker;

  @override
  void initState() {
    super.initState();

    _startTime = DateTime.now();

    _ticker = Ticker((_) {
      setState(() {
        elapsed = DateTime.now().difference(_startTime);
      });
    })..start();

    _loadExercises();
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  Future<void> _loadExercises() async {
    debugPrint('LOAD EXERCISES START');
    exercises = await _workoutService.getExercisesForWorkout(
      widget.workout.id,
    );

    for (final e in exercises) {
      debugPrint(
        'Exercise: ${e.name} | weight: ${e.weight} | reps: ${e.reps} | prevW: ${e.previousWeight} | prevR: ${e.previousReps}',
      );
    }

    setState(() => loading = false);
  }

  String get _timeLabel {
    final m = elapsed.inMinutes.toString().padLeft(2, '0');
    final s = (elapsed.inSeconds % 60).toString().padLeft(2, '0');
    return "$m:$s";
  }

  Future<void> _finishWorkout() async {
    final duration = await _workoutService.finishWorkout(widget.sessionId);

    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => WorkoutSummaryScreen(durationSeconds: duration),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE0E0E0),
      appBar: GradientAppBar(
        title: widget.workout.name,
        subtitle: 'In Progress',
        showDate: false,
        showCloseButton: true,
      ),
      body: Column(
        children: [
          _buildStatsSummary(),
          Expanded(child: _buildExerciseList()),
          _buildBottomButton(),
        ],
      ),
    );
  }

  Widget _buildStatsSummary() {
    final totalSets = exercises.fold<int>(0, (s, e) => s + e.sets);

    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _StatItem(_timeLabel, "TIME"),
          _StatItem("$totalSets", "SETS"),
          _StatItem("0/${exercises.length}", "EXERCISES"),
        ],
      ),
    );
  }

  Widget _buildExerciseList() {
    if (loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (exercises.isEmpty) {
      return const Center(child: Text('No exercises in this routine'));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: exercises.length,
      itemBuilder: (context, i) {
        final ex = exercises[i];

        final initialSets = List.generate(
          ex.sets,
          (_) => SetData(
            prev: ex.previousWeight != null
                ? "${ex.previousWeight} x ${ex.previousReps}"
                : "-",
            kg: ex.weight.toInt().toString(),
            reps: ex.reps.toString(),
          ),
        );

        return ExerciseCard(
          title: ex.name,
          exerciseNumber: i + 1,
          initialSets: initialSets,
          isExpanded: expandedIndex == i,
          onToggle: () {
            setState(() {
              expandedIndex = expandedIndex == i ? -1 : i;
            });
          },
        );
      },
    );
  }

  Widget _buildBottomButton() {
    return Container(
      padding: const EdgeInsets.all(20),
      color: Colors.white,
      child: SafeArea(
        child: GestureDetector(
          onTap: _finishWorkout,
          child: Container(
            width: double.infinity,
            height: 50,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              gradient: const LinearGradient(
                colors: [Color(0xFFFF8A5C), Color(0xFFF4511E)],
              ),
            ),
            child: const Center(
              child: Text(
                'Finish Workout',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String value;
  final String label;

  const _StatItem(this.value, this.label);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.orangeAccent,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            fontSize: 10,
            color: Colors.orangeAccent,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
