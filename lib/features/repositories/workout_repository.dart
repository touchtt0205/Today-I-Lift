import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class WorkoutRepository {
  final _supabase = Supabase.instance.client;

  Future<List<Map<String, dynamic>>> fetchWorkouts() async {
    final data = await _supabase
        .from('routines')
        .select('''
          *,
          routine_items(count)
        ''')
        .order('created_at');

    return List<Map<String, dynamic>>.from(data);
  }

  Future<List<Map<String, dynamic>>> fetchRoutineExercises(
    String routineId,
  ) async {
    final data = await _supabase
        .from('routine_items')
        .select('*, exercises(name , muscle_group)')
        .eq('routine_id', routineId)
        .order('order_index');

    return List<Map<String, dynamic>>.from(data);
  }

  Future<Map<String, dynamic>?> fetchLastCompletedSession(
    String routineId,
  ) async {
    return await _supabase
        .from('workout_sessions')
        .select()
        .eq('routine_id', routineId)
        .eq('status', 'completed') // เฉพาะที่จบแล้ว
        .order('finished_at', ascending: false)
        .limit(1)
        .maybeSingle();
  }

  Future<Map<String, dynamic>> startOrResumeWorkout(String routineId) async {
    final userId = _supabase.auth.currentUser!.id;

    final existing = await _supabase
        .from('workout_sessions')
        .select('id, started_at')
        .eq('user_id', userId)
        .eq('routine_id', routineId)
        .eq('status', 'active')
        .maybeSingle();

    if (existing != null) return existing; // resume → return id + started_at

    final res = await _supabase
        .from('workout_sessions')
        .insert({'user_id': userId, 'routine_id': routineId})
        .select('id, started_at')
        .single();

    return res;
  }

  Future<void> cancelSession(String sessionId) async {
    await _supabase
        .from('workout_sessions')
        .update({'status': 'cancelled'})
        .eq('id', sessionId);
  }

  Future<List<Map<String, dynamic>>> fetchWorkoutSets(String sessionId) async {
    final data = await _supabase
        .from('workout_sets')
        .select('*, exercises(name)')
        .eq('session_id', sessionId)
        .order('order_index');

    return List<Map<String, dynamic>>.from(data);
  }

  Future<int> finishWorkout(String sessionId) async {
    final res = await _supabase
        .from('workout_sessions')
        .select('started_at')
        .eq('id', sessionId)
        .single();

    final startedAt = DateTime.parse(res['started_at']);
    final finishedAt = DateTime.now().toUtc();
    final duration = finishedAt.difference(startedAt).inSeconds;

    await _supabase
        .from('workout_sessions')
        .update({
          'finished_at': finishedAt.toIso8601String(),
          'duration_seconds': duration,
          'status': 'completed',
        })
        .eq('id', sessionId);

    return duration;
  }

  // ================= SET =================

  /// INSERT
  Future<String> insertWorkoutSet({
    required String sessionId,
    required String exerciseId,
    required int setNumber,
    required int reps,
    required double weight,
    required int restSeconds,
  }) async {
    final res = await _supabase
        .from('workout_sets')
        .insert({
          'session_id': sessionId,
          'exercise_id': exerciseId,
          'set_number': setNumber,
          'reps': reps,
          'weight': weight,
          'rest_seconds': restSeconds,
          'completed_at': DateTime.now().toUtc().toIso8601String(),
        })
        .select()
        .single();

    return res['id'];
  }

  /// UPDATE
  Future<void> updateWorkoutSet({
    required String setId,
    required int reps,
    required double weight,
  }) async {
    await _supabase
        .from('workout_sets')
        .update({'reps': reps, 'weight': weight})
        .eq('id', setId);
  }

  /// DELETE
  Future<void> deleteWorkoutSet(String setId) async {
    await _supabase.from('workout_sets').delete().eq('id', setId);
  }

  /// PREVIOUS SET
  Future<Map<String, dynamic>?> getLastSet(String exerciseId) async {
    return await _supabase
        .from('workout_sets')
        .select()
        .eq('exercise_id', exerciseId)
        .order('completed_at', ascending: false)
        .limit(1)
        .maybeSingle();
  }
}
