import 'package:flutter/material.dart';
import 'package:today_i_lift/features/model/workout.dart';
import 'package:today_i_lift/features/pages/active_workout_page.dart';
import 'package:today_i_lift/features/services/workout_service.dart';

class WorkoutModal extends StatefulWidget {
  const WorkoutModal({super.key});

  @override
  State<WorkoutModal> createState() => _WorkoutModalState();
}

class _WorkoutModalState extends State<WorkoutModal> {
  final _workoutService = WorkoutService();
  late Future<List<Workout>> _future;

  @override
  void initState() {
    super.initState();
    _future = _workoutService.getWorkouts();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFD1D1D1),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: FutureBuilder<List<Workout>>(
          future: _future,
          builder: (context, snapshot) {
            // loading
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const SizedBox(
                height: 150,
                child: Center(child: CircularProgressIndicator()),
              );
            }

            // error
            if (snapshot.hasError) {
              return const SizedBox(
                height: 150,
                child: Center(child: Text('โหลด workout ไม่สำเร็จ')),
              );
            }

            final workouts = snapshot.data!;

            return Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Start Workout',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const Text(
                  'Choose your workout type',
                  style: TextStyle(color: Colors.grey, fontSize: 16),
                ),
                const SizedBox(height: 20),

                ...workouts.map((w) => _item(w)),

                const SizedBox(height: 10),

                Center(
                  child: TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text(
                      'Cancel',
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _item(Workout w) {
    w.createdAt.toLocal();

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.black12),
      ),
      child: ListTile(
        leading: const Icon(Icons.fitness_center),
        title: Text(
          w.name,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text('${w.exerciseCount} exercises'),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: () async {
          final sessionId = await _workoutService.startWorkout(w.id);

          if (!mounted) return;

          Navigator.pop(context); // ปิด modal ก่อน

          await Future.delayed(const Duration(milliseconds: 200));

          if (!mounted) return;

          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) =>
                  ActiveWorkoutScreen(workout: w, sessionId: sessionId),
            ),
          );
        },
      ),
    );
  }
}
