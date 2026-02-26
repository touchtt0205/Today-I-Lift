class WorkoutExercise {
  final String id;
  final String exerciseId;
  final String name;
  final int sets;
  final int reps;
  final double weight;
  final int? previousReps;
  final double? previousWeight;

  WorkoutExercise({
    required this.id,
    required this.exerciseId,
    required this.name,
    required this.sets,
    required this.reps,
    required this.weight,
    this.previousReps,
    this.previousWeight,
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
