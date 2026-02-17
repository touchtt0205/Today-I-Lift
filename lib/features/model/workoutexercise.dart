class WorkoutExercise {
  final String id;
  final String name;
  final int sets;
  final int reps;
  final double weight;
  // final int order;
  final int previousReps;
  final double previousWeight;

  WorkoutExercise({
    required this.id,
    required this.name,
    required this.sets,
    required this.reps,
    required this.weight,
    // required this.order,
    this.previousReps = 0,
    this.previousWeight = 0,
  });

  factory WorkoutExercise.fromMap(Map<String, dynamic> map) {
    return WorkoutExercise(
      id: map['id'],
      name: map['exercises']['name'],
      sets: map['sets'] ?? 0,
      reps: map['reps'] ?? 0,
      weight: (map['weight'] ?? 0).toDouble(),
      // order: map['order_index'] ?? 0,
    );
  }
}
