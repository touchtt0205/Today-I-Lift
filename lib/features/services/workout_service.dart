import 'package:flutter/material.dart';
import 'package:today_i_lift/features/model/workoutexercise.dart';
import 'package:today_i_lift/features/repositories/workout_repository.dart';

class WorkoutService {
  final _repo = WorkoutRepository();

  Future<List<WorkoutExercise>> getExercisesForWorkout(String routineId) async {
    // โหลด routine_items เสมอ
    final routineItems = await _repo.fetchRoutineExercises(routineId);
    final exercises = routineItems.map(WorkoutExercise.fromMap).toList();

    // เช็ค session ที่ completed ล่าสุด
    final lastCompleted = await _repo.fetchLastCompletedSession(routineId);
    if (lastCompleted == null) return exercises; // ไม่เคยเล่น → คืนค่าปกติ

    // ดึง previous sets
    final sets = await _repo.fetchWorkoutSets(lastCompleted['id']);
    if (sets.isEmpty) return exercises;

    // map previous เข้า exercise แต่ละตัวโดยจับคู่ด้วย exercise_id
    final previousMap = <String, Map<String, dynamic>>{};
    for (final s in sets) {
      previousMap[s['exercise_id']] = s;
    }

    return exercises.map((e) {
      final prev = previousMap[e.exerciseId];
      return WorkoutExercise(
        id: e.id,
        exerciseId: e.exerciseId,
        name: e.name,
        sets: e.sets,
        reps: e.reps,
        weight: e.weight,
        previousReps: prev?['reps'],
        previousWeight: (prev?['weight'] as num?)?.toDouble(),
      );
    }).toList();
  }

  Future<void> cancelWorkout(String sessionId) {
    return _repo.cancelSession(sessionId);
  }

  Future<Map<String, dynamic>> startOrResumeWorkout(String routineId) {
    return _repo.startOrResumeWorkout(routineId);
  }

  Future<int> finishWorkout(String sessionId) {
    return _repo.finishWorkout(sessionId);
  }

  //set

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
}
