import 'package:supabase_flutter/supabase_flutter.dart';

class RoutineItemRepository {
  final _client = Supabase.instance.client;

  Future<List<Map<String, dynamic>>> getItems(String routineId) async {
    final res = await _client
        .from('routine_items')
        .select('*, exercises(*), routine_set_templates(*)')
        .eq('routine_id', routineId)
        .order('order_index');

    return List<Map<String, dynamic>>.from(res);
  }

  Future<void> replaceItems(
    String routineId,
    List<Map<String, dynamic>> items,
  ) async {
    // ลบของเดิม (routine_set_templates cascade ลบตาม)
    await _client.from('routine_items').delete().eq('routine_id', routineId);

    if (items.isEmpty) return;

    for (final item in items) {
      final sets = item['sets'] as List? ?? [];

      // insert routine_item
      final inserted = await _client
          .from('routine_items')
          .insert({
            'routine_id': routineId,
            'exercise_id': item['exercise_id'],
            'sets': sets.length,
            'reps': sets.isNotEmpty ? sets.first['reps'] : 10,
            'weight': sets.isNotEmpty ? sets.first['weight'] : 0,
            'order_index': item['order_index'],
          })
          .select('id')
          .single();

      if (sets.isEmpty) continue;

      // insert set templates
      final templates = sets
          .asMap()
          .entries
          .map(
            (e) => {
              'routine_item_id': inserted['id'],
              'set_number': e.key + 1,
              'reps': e.value['reps'] ?? 10,
              'weight': e.value['weight'] ?? 0,
            },
          )
          .toList();

      await _client.from('routine_set_templates').insert(templates);
    }
  }
}
