import 'package:today_i_lift/features/repositories/routine_item_repository.dart';

import '../repositories/routine_repository.dart';

class RoutineService {
  final _repo = RoutineRepository();
  final _itemRepo = RoutineItemRepository();

  Future<List<Map<String, dynamic>>> getRoutines() {
    return _repo.getRoutines();
  }

  Future<void> createRoutine(String name) async {
    if (name.trim().isEmpty) {
      throw Exception('Routine name is empty');
    }

    await _repo.createRoutine(name.trim());
  }

  Future<void> deleteRoutine(String id) {
    return _repo.deleteRoutine(id);
  }

  Future<String> saveRoutine({
    required String name,
    required int icon,
    required int color,
    required List<Map<String, dynamic>> items,
    String? routineId, // null = create, non-null = update
  }) async {
    if (name.trim().isEmpty) throw Exception('Routine name is empty');

    final String id;

    if (routineId != null) {
      await _repo.updateRoutine(routineId, name.trim(), icon, color);
      id = routineId;
    } else {
      id = await _repo.createRoutineReturnId(name.trim(), icon, color);
    }

    // แปลง items ให้พร้อม insert
    final mapped = items.asMap().entries.map((e) {
      final sets = e.value['sets'] as List? ?? [];
      return {
        'exercise_id': e.value['exercise_id'],
        'order_index': e.key,
        'sets': sets,
      };
    }).toList();

    await _itemRepo.replaceItems(id, mapped);

    return id;
  }

  // ─── ITEMS ────────────────────────────────────────────────

  Future<List<Map<String, dynamic>>> getItems(String routineId) async {
    final res = await _itemRepo.getItems(routineId);

    // แปลง routine_set_templates → sets list
    return res.map((item) {
      final templates = item['routine_set_templates'] as List? ?? [];

      final sets = templates.isNotEmpty
          ? templates
                .map(
                  (t) => {
                    'reps': t['reps'] ?? 10,
                    'weight': (t['weight'] as num?)?.toDouble() ?? 0.0,
                  },
                )
                .toList()
          : List.generate(
              item['sets'] as int? ?? 3,
              (_) => {
                'reps': item['reps'] ?? 10,
                'weight': (item['weight'] as num?)?.toDouble() ?? 0.0,
              },
            );

      return {...item, 'sets': sets};
    }).toList();
  }

  // ─── TEMPLATE ─────────────────────────────────────────────

  Future<List<Map<String, dynamic>>> getTemplateExercises(String type) async {
    final all = await _repo.getAllExercises();

    final templateNames = switch (type) {
      'push' => [
        'Bench Press',
        'Incline Dumbbell Press',
        'Dumbbell Fly',
        'Barbell Overhead Press',
        'Lateral Raise',
        'Triceps Pushdown',
      ],
      'pull' => [
        'Deadlift',
        'Barbell Row',
        'Lat Pulldown',
        'Seated Cable Row',
        'Face Pull',
        'Barbell Curl',
        'Hammer Curl',
      ],
      'legs' => [
        'Barbell Squat',
        'Leg Press',
        'Romanian Deadlift',
        'Leg Extension',
        'Leg Curl',
        'Calf Raise',
      ],
      _ => <String>[],
    };

    return templateNames
        .map(
          (name) => all.firstWhere((e) => e['name'] == name, orElse: () => {}),
        )
        .where((e) => e.isNotEmpty)
        .toList();
  }
}
