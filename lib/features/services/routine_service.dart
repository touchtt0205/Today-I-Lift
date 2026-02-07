import '../repositories/routine_repository.dart';

class RoutineService {
  final _repo = RoutineRepository();

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
}
