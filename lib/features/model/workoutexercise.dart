class WorkoutExercise {
  final String id;
  final String exerciseId;
  final String name;
  final int sets;
  final int reps;
  final double weight;
  final int? previousReps;
  final double? previousWeight;
  final List<Map<String, dynamic>> setTemplates;
  final List<Map<String, dynamic>> previousSets;

  WorkoutExercise({
    required this.id,
    required this.exerciseId,
    required this.name,
    required this.sets,
    required this.reps,
    required this.weight,
    this.previousReps,
    this.previousWeight,
    this.setTemplates = const [],
    this.previousSets = const [],
  });

  factory WorkoutExercise.fromMap(Map<String, dynamic> map) {
    return WorkoutExercise(
      id: map['id'],
      exerciseId: map['exercise_id'],
      name: map['exercises']['name'],
      sets: map['sets'] ?? 0,
      reps: map['reps'] ?? 0,
      weight: (map['weight'] ?? 0).toDouble(),
    );
  }
}
