class WorkoutSet {
  final String id;
  final String exerciseId;
  final int setNumber;
  final int reps;
  final double weight;
  final bool isCompleted;

  WorkoutSet({
    required this.id,
    required this.exerciseId,
    required this.setNumber,
    required this.reps,
    required this.weight,
    required this.isCompleted,
  });

  factory WorkoutSet.fromMap(Map<String, dynamic> map) {
    return WorkoutSet(
      id: map['id'],
      exerciseId: map['exercise_id'],
      setNumber: map['set_number'],
      reps: map['reps'],
      weight: (map['weight'] as num).toDouble(),
      isCompleted: map['is_completed'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'exercise_id': exerciseId,
      'set_number': setNumber,
      'reps': reps,
      'weight': weight,
      'is_completed': isCompleted,
    };
  }
}
