import 'package:supabase_flutter/supabase_flutter.dart';

class RoutineRepository {
  final _client = Supabase.instance.client;

  Future<List<Map<String, dynamic>>> getRoutines() async {
    final res = await _client.from('routines').select().order('created_at');

    return List<Map<String, dynamic>>.from(res);
  }

  Future<void> createRoutine(String name) async {
    final userId = _client.auth.currentUser!.id;

    await _client.from('routines').insert({'user_id': userId, 'name': name});
  }

  Future<void> deleteRoutine(String id) async {
    await _client.from('routines').delete().eq('id', id);
  }

  Future<String> createRoutineReturnId(String name, int icon, int color) async {
    final userId = _client.auth.currentUser!.id;

    final res = await _client
        .from('routines')
        .insert({'user_id': userId, 'name': name, 'icon': icon, 'color': color})
        .select()
        .single();

    return res['id'];
  }

  Future<void> updateRoutine(
    String id,
    String name,
    int? icon,
    int? color,
  ) async {
    await _client
        .from('routines')
        .update({
          'name': name,
          if (icon != null) 'icon': icon,
          if (color != null) 'color': color,
        })
        .eq('id', id);
  }
}
