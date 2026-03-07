import 'package:flutter/material.dart';
import 'package:today_i_lift/features/model/workoutexercise.dart';
import 'package:today_i_lift/features/repositories/workout_repository.dart';

class WorkoutService {
  final _repo = WorkoutRepository();

  // Future<List<WorkoutExercise>> getExercisesForWorkout(String routineId) async {
  //   // โหลด routine_items เสมอ
  //   final routineItems = await _repo.fetchRoutineExercises(routineId);
  //   final exercises = routineItems.map(WorkoutExercise.fromMap).toList();

  //   // เช็ค session ที่ completed ล่าสุด
  //   final lastCompleted = await _repo.fetchLastCompletedSession(routineId);
  //   if (lastCompleted == null) return exercises; // ไม่เคยเล่น → คืนค่าปกติ

  //   // ดึง previous sets
  //   final sets = await _repo.fetchWorkoutSets(lastCompleted['id']);
  //   if (sets.isEmpty) return exercises;

  //   // map previous เข้า exercise แต่ละตัวโดยจับคู่ด้วย exercise_id
  //   final previousMap = <String, Map<String, dynamic>>{};
  //   for (final s in sets) {
  //     previousMap[s['exercise_id']] = s;
  //   }

  //   return exercises.map((e) {
  //     final prev = previousMap[e.exerciseId];
  //     return WorkoutExercise(
  //       id: e.id,
  //       exerciseId: e.exerciseId,
  //       name: e.name,
  //       sets: e.sets,
  //       reps: e.reps,
  //       weight: e.weight,
  //       previousReps: prev?['reps'],
  //       previousWeight: (prev?['weight'] as num?)?.toDouble(),
  //     );
  //   }).toList();
  // }

  Future<List<WorkoutExercise>> getExercisesForWorkout(String routineId) async {
    final routineItems = await _repo.fetchRoutineExercises(routineId);

    final lastCompleted = await _repo.fetchLastCompletedSession(routineId);
    List<Map<String, dynamic>> previousSets = [];
    if (lastCompleted != null) {
      previousSets = await _repo.fetchWorkoutSets(lastCompleted['id']);
    }

    // เก็บทุก set แยกตาม exercise_id → set_number
    final previousMap = <String, List<Map<String, dynamic>>>{};
    for (final s in previousSets) {
      previousMap.putIfAbsent(s['exercise_id'], () => []).add(s);
    }
    for (final list in previousMap.values) {
      list.sort(
        (a, b) => (a['set_number'] as int).compareTo(b['set_number'] as int),
      );
    }

    return routineItems.map((item) {
      final exerciseId = item['exercise_id'] as String;
      final name = item['exercises']?['name'] ?? '';
      final prevSets = previousMap[exerciseId] ?? [];
      final templates = item['routine_set_templates'] as List? ?? [];

      final int setsCount;
      final int defaultReps;
      final double defaultWeight;

      if (templates.isNotEmpty) {
        setsCount = templates.length;
        defaultReps = templates.first['reps'] as int? ?? 10;
        defaultWeight = (templates.first['weight'] as num?)?.toDouble() ?? 0;
      } else {
        setsCount = item['sets'] as int? ?? 3;
        defaultReps = item['reps'] as int? ?? 10;
        defaultWeight = (item['weight'] as num?)?.toDouble() ?? 0;
      }

      return WorkoutExercise(
        id: item['id'] as String,
        exerciseId: exerciseId,
        name: name,
        sets: setsCount,
        reps: defaultReps,
        weight: defaultWeight,
        previousReps: prevSets.isNotEmpty ? prevSets.first['reps'] : null,
        previousWeight: prevSets.isNotEmpty
            ? (prevSets.first['weight'] as num?)?.toDouble()
            : null,
        setTemplates: templates
            .map(
              (t) => {
                'set_number': t['set_number'],
                'reps': t['reps'],
                'weight': (t['weight'] as num?)?.toDouble() ?? 0.0,
              },
            )
            .toList(),
        previousSets: prevSets
            .map(
              (s) => {
                'set_number': s['set_number'],
                'reps': s['reps'],
                'weight': (s['weight'] as num?)?.toDouble() ?? 0.0,
              },
            )
            .toList(),
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
