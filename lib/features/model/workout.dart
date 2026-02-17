class Workout {
  final String id;
  final String name;
  final int exerciseCount;
  final DateTime createdAt;

  Workout({
    required this.id,
    required this.name,
    required this.exerciseCount,
    required this.createdAt,
  });

  factory Workout.fromMap(Map<String, dynamic> map) {
    return Workout(
      id: map['id'],
      name: map['name'],
      exerciseCount: (map['routine_items'] as List?)?.first['count'] ?? 0,
      createdAt: DateTime.parse(map['created_at']),
    );
  }
}
