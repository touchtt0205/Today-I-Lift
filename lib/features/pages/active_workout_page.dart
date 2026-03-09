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
  final DateTime sessionStartedAt;

  const ActiveWorkoutScreen({
    super.key,
    required this.workout,
    required this.sessionId,
    required this.sessionStartedAt,
  });

  @override
  State<ActiveWorkoutScreen> createState() => _ActiveWorkoutScreenState();
}

class _ActiveWorkoutScreenState extends State<ActiveWorkoutScreen> {
  final _workoutService = WorkoutService();
  final Map<int, int> _completedSetsPerExercise = {};
  final Map<int, int> _restSecondsPerExercise = {};

  int get _totalCompletedSets =>
      _completedSetsPerExercise.values.fold(0, (a, b) => a + b);

  int get _completedExercises => _completedSetsPerExercise.entries
      .where((e) => e.value >= exercises[e.key].sets)
      .length;

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
    ;

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
    exercises = await _workoutService.getExercisesForWorkout(widget.workout.id);
    if (!mounted) return;

    setState(() => loading = false);
  }

  Future<void> _confirmCancel() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: const [
            Icon(Icons.warning_amber_rounded, color: Colors.red),
            SizedBox(width: 8),
            Text('Cancel Workout'),
          ],
        ),
        content: const Text(
          'Your workout progress will be lost.\nAre you sure you want to cancel?',
          style: TextStyle(height: 1.4),
        ),
        actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            style: TextButton.styleFrom(foregroundColor: Colors.grey[700]),
            child: const Text(
              'Continue Workout',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text('Cancel Workout'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await _workoutService.cancelWorkout(widget.sessionId);
      if (!mounted) return;
      Navigator.of(context).pop();
    }
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
        builder: (_) => WorkoutSummaryScreen(
          durationSeconds: duration,
          totalSets: _totalCompletedSets,
          completedExercises: _completedExercises,
          totalExercises: exercises.length,
        ),
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
        onClose: _confirmCancel,
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
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _StatItem(_timeLabel, "TIME"),
          _StatItem("$_totalCompletedSets", "SETS"),
          _StatItem("$_completedExercises/${exercises.length}", "EXERCISES"),
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
          ex.setTemplates.isNotEmpty ? ex.setTemplates.length : ex.sets,
          (i) {
            final prevSet = ex.previousSets.length > i
                ? ex.previousSets[i]
                : null;
            final template = ex.setTemplates.length > i
                ? ex.setTemplates[i]
                : null;

            final kg = prevSet != null
                ? (prevSet['weight'] as double).toInt().toString()
                : template != null
                ? (template['weight'] as double).toInt().toString()
                : ex.weight.toInt().toString();

            final reps = prevSet != null
                ? prevSet['reps'].toString()
                : template != null
                ? template['reps'].toString()
                : ex.reps.toString();

            return SetData(
              prev: prevSet != null
                  ? "${prevSet['weight']} x ${prevSet['reps']}"
                  : "-",
              kg: kg,
              reps: reps,
            );
          },
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
          onSetCompleted: (setData, setNumber) async {
            final setId = await _workoutService.completeSet(
              sessionId: widget.sessionId,
              exerciseId: ex.exerciseId,
              setNumber: setNumber,
              reps: int.tryParse(setData.reps) ?? 0,
              weight: double.tryParse(setData.kg) ?? 0,
              restSeconds: _restSecondsPerExercise[i] ?? 60,
            );
            setData.setId = setId; // เก็บ id กลับมาใช้ตอน edit/delete
          },
          onSetEdited: (setData) async {
            if (setData.setId == null) return;
            await _workoutService.editSet(
              setId: setData.setId!,
              reps: int.tryParse(setData.reps) ?? 0,
              weight: double.tryParse(setData.kg) ?? 0,
            );
          },
          onSetDeleted: (setData) async {
            if (setData.setId == null) return;
            await _workoutService.removeSet(setData.setId!);
          },
          onSetsChanged: (completedSets) {
            setState(() {
              _completedSetsPerExercise[i] = completedSets;
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
