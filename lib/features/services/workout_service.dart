import 'package:flutter/material.dart';
import 'package:today_i_lift/features/model/workout.dart';
import 'package:today_i_lift/features/model/workoutexercise.dart';
import 'package:today_i_lift/features/repositories/workout_repository.dart';

class WorkoutService {
  final _repo = WorkoutRepository();

  Future<List<Workout>> getWorkouts() async {
    final data = await _repo.fetchWorkouts();
    return data.map(Workout.fromMap).toList();
  }

  Future<List<WorkoutExercise>> getExercisesForWorkout(String routineId) async {
    debugPrint('=== getExercisesForWorkout START ===');
    debugPrint('routineId: $routineId');

    final lastSession = await _repo.fetchLastSession(routineId);
    debugPrint('lastSession: $lastSession');

    // ❌ ยังไม่เคยเล่น
    if (lastSession == null) {
      debugPrint('STATUS: NEVER PLAYED → use routine_items');

      final routineItems = await _repo.fetchRoutineExercises(routineId);
      debugPrint('routineItems count: ${routineItems.length}');
      debugPrint('routineItems raw: $routineItems');

      final result = routineItems.map(WorkoutExercise.fromMap).toList();
      debugPrint('RETURN exercises count: ${result.length}');
      debugPrint('=== END (from routine_items) ===');

      return result;
    }

    // ✅ เคยเล่นแล้ว → ลองดึง workout_sets
    debugPrint('STATUS: HAS SESSION → sessionId: ${lastSession['id']}');

    final sets = await _repo.fetchWorkoutSets(lastSession['id']);
    debugPrint('workout_sets count: ${sets.length}');
    debugPrint('workout_sets raw: $sets');

    // 🔥 กันเคสมี session แต่ไม่มี sets
    if (sets.isEmpty) {
      debugPrint(
        'WARNING: session exists but no workout_sets → fallback to routine_items',
      );

      final routineItems = await _repo.fetchRoutineExercises(routineId);
      debugPrint('fallback routineItems count: ${routineItems.length}');

      final result = routineItems.map(WorkoutExercise.fromMap).toList();
      debugPrint('RETURN exercises count: ${result.length}');
      debugPrint('=== END (fallback routine_items) ===');

      return result;
    }

    // ✅ มี workout_sets จริง
    final result = sets.map((e) {
      return WorkoutExercise(
        id: e['id'],
        name: e['exercises']['name'],
        sets: e['sets'] ?? 0,
        reps: e['reps'] ?? 0,
        weight: (e['weight'] ?? 0).toDouble(),
        previousReps: e['reps'] ?? 0,
        previousWeight: (e['weight'] ?? 0).toDouble(),
      );
    }).toList();

    debugPrint('RETURN exercises count: ${result.length}');
    debugPrint('=== END (from workout_sets) ===');

    return result;
  }

  Future<String> startWorkout(String routineId) {
    return _repo.startWorkout(routineId);
  }

  Future<Map<String, dynamic>?> getActiveSession() {
    return _repo.getActiveSession();
  }

  Future<String> startOrResumeWorkout(String routineId) {
    return _repo.startOrResumeWorkout(routineId);
  }

  Future<int> finishWorkout(String sessionId) {
    return _repo.finishWorkout(sessionId);
  }

  // Future<void> completeSet({
  //   required String sessionId,
  //   required String exerciseId,
  //   required int setNumber,
  //   required int reps,
  //   required double weight,
  //   required int restSeconds,
  // }) async {
  //   await _repo.insertWorkoutSet(
  //     sessionId: sessionId,
  //     exerciseId: exerciseId,
  //     setNumber: setNumber,
  //     reps: reps,
  //     weight: weight,
  //     restSeconds: restSeconds,
  //   );
  // }

  // Future<Map<String, dynamic>?> getPreviousSet(String exerciseId) {
  //   return _repo.getLastSet(exerciseId);
  // }

  // Future<List<WorkoutExercise>> getInitialExercisesForSession(
  //   String routineId,
  // ) async {
  //   final data = await _repo.fetchInitialExercises(routineId);
  //   return data.map(WorkoutExercise.fromMap).toList();
  // }

  // ===== SET =====

  /// กดติ๊ก = complete set
  Future<String> completeSet({
    required String sessionId,
    required String exerciseId,
    required int setNumber,
    required int reps,
    required double weight,
    required int restSeconds,
  }) {
    return _repo.insertWorkoutSet(
      sessionId: sessionId,
      exerciseId: exerciseId,
      setNumber: setNumber,
      reps: reps,
      weight: weight,
      restSeconds: restSeconds,
    );
  }

  /// แก้ KG / REPS
  Future<void> editSet({
    required String setId,
    required int reps,
    required double weight,
  }) {
    return _repo.updateWorkoutSet(setId: setId, reps: reps, weight: weight);
  }

  /// ลบ set
  Future<void> removeSet(String setId) {
    return _repo.deleteWorkoutSet(setId);
  }

  /// previous
  Future<Map<String, dynamic>?> getPreviousSet(String exerciseId) {
    return _repo.getLastSet(exerciseId);
  }
}
