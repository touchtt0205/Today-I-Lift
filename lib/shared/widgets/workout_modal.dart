import 'package:flutter/material.dart';
import 'package:today_i_lift/features/model/workout.dart';
import 'package:today_i_lift/features/pages/active_workout_page.dart';
import 'package:today_i_lift/features/services/workout_service.dart';
import 'package:today_i_lift/shared/widgets/routine_card.dart';
import 'package:today_i_lift/features/repositories/routine_repository.dart';
import 'package:today_i_lift/features/repositories/routine_item_repository.dart';

class WorkoutModal extends StatefulWidget {
  const WorkoutModal({super.key});

  @override
  State<WorkoutModal> createState() => _WorkoutModalState();
}

class _WorkoutModalState extends State<WorkoutModal> {
  final _workoutService = WorkoutService();
  final _routineRepo = RoutineRepository(); 
  final _itemRepo = RoutineItemRepository(); 

  late Future<List<Map<String, dynamic>>> _future; 

  @override
  void initState() {
    super.initState();
    _future = _routineRepo.getRoutines();
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
        child: FutureBuilder<List<Map<String, dynamic>>>(
          future: _future,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const SizedBox(
                height: 150,
                child: Center(child: CircularProgressIndicator()),
              );
            }

            if (snapshot.hasError) {
              return const SizedBox(
                height: 150,
                child: Center(child: Text('โหลด routine ไม่สำเร็จ')),
              );
            }

            final routines = snapshot.data!;

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

                ...routines.map((r) => _buildRoutineItem(r)),

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

  Widget _buildRoutineItem(Map<String, dynamic> routine) {
    return FutureBuilder(
      future: _itemRepo.getItems(routine['id']),
      builder: (context, snapshot) {
        final exerciseCount = snapshot.hasData
            ? (snapshot.data as List).length
            : 0;

        return RoutineCard(
          routine: routine, // ส่ง Map ทั้งก้อน
          exerciseCount: exerciseCount,
          onTap: () => _startWorkout(routine), //ส่ง routine Map
        );
      },
    );
  }

  Future<void> _startWorkout(Map<String, dynamic> routine) async {
    final session = await _workoutService.startOrResumeWorkout(routine['id']);

    if (!mounted) return;

    Navigator.pop(context);

    await Future.delayed(const Duration(milliseconds: 200));

    if (!mounted) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ActiveWorkoutScreen(
          workout: Workout(
            id: routine['id'],
            name: routine['name'] ?? '',
            exerciseCount: 0,
            createdAt: DateTime.now(),
          ),
          sessionId: session['id'],
          sessionStartedAt: DateTime.parse(session['started_at']),
        ),
      ),
    );
  }
}
