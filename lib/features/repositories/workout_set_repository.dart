import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:today_i_lift/features/model/workout_set.dart';

class WorkoutRepository {
  final SupabaseClient _supabase;

  WorkoutRepository(this._supabase);

  /// Get default routine items
  Future<List<Map<String, dynamic>>> getRoutineItems(String routineId) async {
    final res = await _supabase
        .from('routine_items')
        .select()
        .eq('routine_id', routineId)
        .order('order_index');

    return List<Map<String, dynamic>>.from(res);
  }

  /// Get latest workout sets (previous session)
  Future<List<WorkoutSet>> getLatestWorkoutSets(String routineId) async {
    final sessionRes = await _supabase
        .from('workout_sessions')
        .select('id')
        .eq('routine_id', routineId)
        .order('created_at', ascending: false)
        .limit(1)
        .maybeSingle();

    if (sessionRes == null) return [];

    final setsRes = await _supabase
        .from('workout_sets')
        .select()
        .eq('session_id', sessionRes['id']);

    return (setsRes as List).map((e) => WorkoutSet.fromMap(e)).toList();
  }

  /// Insert or update workout set
  Future<void> upsertWorkoutSet(WorkoutSet set, String sessionId) async {
    await _supabase.from('workout_sets').upsert({
      ...set.toMap(),
      'session_id': sessionId,
    });
  }

  /// Create new workout session
  Future<String> createSession(String routineId) async {
    final res = await _supabase
        .from('workout_sessions')
        .insert({'routine_id': routineId})
        .select('id')
        .single();

    return res['id'];
  }

  /// Finish session
  Future<void> finishSession(String sessionId) async {
    await _supabase
        .from('workout_sessions')
        .update({'finished_at': DateTime.now().toIso8601String()})
        .eq('id', sessionId);
  }
}
