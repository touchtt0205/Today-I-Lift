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

    _startTime = widget.sessionStartedAt.toLocal();

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
    exercises = await _workoutService.getExercisesForWorkout(widget.workout.id);

    for (final e in exercises) {
      debugPrint(
        'Exercise: ${e.name} | weight: ${e.weight} | reps: ${e.reps} | prevW: ${e.previousWeight} | prevR: ${e.previousReps}',
      );
    }

    if (!mounted) return;

    setState(() => loading = false);
  }

  Future<void> _confirmCancel() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('ยกเลิก Workout?'),
        content: const Text('ข้อมูลที่บันทึกไปแล้วจะถูกลบทั้งหมด'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('ออกกำลังกายต่อ'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('ยกเลิก Workout'),
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
          _StatItem(
            "$_completedExercises/${exercises.length}",
            "EXERCISES",
          ),
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
          onSetCompleted: (setData, setNumber) async {
            final setId = await _workoutService.completeSet(
              sessionId: widget.sessionId,
              exerciseId: ex.exerciseId,
              setNumber: setNumber,
              reps: int.tryParse(setData.reps) ?? 0,
              weight: double.tryParse(setData.kg) ?? 0,
              restSeconds:
                  _restSecondsPerExercise[i] ?? 60,
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
