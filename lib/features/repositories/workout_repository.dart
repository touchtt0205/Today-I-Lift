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
        .select('*, exercises(name, muscle_group), routine_set_templates(*)')
        .eq('routine_id', routineId)
        .order('order_index');

    // sort set templates ตาม set_number
    final result = List<Map<String, dynamic>>.from(data);
    for (final item in result) {
      final templates = item['routine_set_templates'] as List? ?? [];
      templates.sort(
        (a, b) => (a['set_number'] as int).compareTo(b['set_number'] as int),
      );
    }

    return result;
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

    if (existing != null) return existing;

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
        .select('started_at, user_id')
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

    // อัพเดท PR
    await _updatePersonalRecords(sessionId, res['user_id']);

    return duration;
  }

  Future<void> _updatePersonalRecords(String sessionId, String userId) async {
    // ดึง max weight ต่อท่าใน session นี้
    final sets = await _supabase
        .from('workout_sets')
        .select('exercise_id, weight, reps')
        .eq('session_id', sessionId);

    // หา max weight ต่อท่า
    final maxPerExercise = <String, Map<String, dynamic>>{};
    for (final row in List<Map<String, dynamic>>.from(sets)) {
      final exId = row['exercise_id'] as String;
      final w = (row['weight'] as num).toDouble();
      if (!maxPerExercise.containsKey(exId) ||
          w > (maxPerExercise[exId]!['weight'] as num).toDouble()) {
        maxPerExercise[exId] = row;
      }
    }

    // เปรียบเทียบกับ PR เดิม และ upsert
    for (final entry in maxPerExercise.entries) {
      final exId = entry.key;
      final newWeight = (entry.value['weight'] as num).toDouble();
      final newReps = entry.value['reps'] as int;

      // ดึง PR เดิม
      final existing = await _supabase
          .from('personal_records')
          .select('weight')
          .eq('user_id', userId)
          .eq('exercise_id', exId)
          .maybeSingle();

      final prevWeight = existing != null
          ? (existing['weight'] as num).toDouble()
          : 0.0;

      // ถ้า PR ใหม่มากกว่า → upsert
      if (newWeight > prevWeight) {
        await _supabase.from('personal_records').upsert({
          'user_id': userId,
          'exercise_id': exId,
          'session_id': sessionId,
          'weight': newWeight,
          'reps': newReps,
          'previous_weight': prevWeight == 0 ? null : prevWeight,
          'increase': prevWeight == 0 ? newWeight : newWeight - prevWeight,
          'achieved_at': DateTime.now().toUtc().toIso8601String(),
        }, onConflict: 'user_id, exercise_id');
      }
    }
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
