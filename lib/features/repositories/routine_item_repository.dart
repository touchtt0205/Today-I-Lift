import 'package:supabase_flutter/supabase_flutter.dart';

class RoutineItemRepository {
  final _client = Supabase.instance.client;

  Future<List<Map<String, dynamic>>> getItems(String routineId) async {
    final res = await _client
        .from('routine_items')
        .select('*, exercises(*)')
        .eq('routine_id', routineId)
        .order('order_index');

    return List<Map<String, dynamic>>.from(res);
  }

  Future<void> replaceItems(
    String routineId,
    List<Map<String, dynamic>> items,
  ) async {
    await _client.from('routine_items').delete().eq('routine_id', routineId);

    if (items.isEmpty) return;

    await _client.from('routine_items').insert(items);
  }
}
