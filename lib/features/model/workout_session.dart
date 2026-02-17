class WorkoutSession {
  final String id;
  final String routineId;
  final DateTime startedAt;
  final String status;

  WorkoutSession({
    required this.id,
    required this.routineId,
    required this.startedAt,
    required this.status,
  });

  factory WorkoutSession.fromMap(Map<String, dynamic> map) {
    return WorkoutSession(
      id: map['id'],
      routineId: map['routine_id'],
      startedAt: DateTime.parse(map['started_at']),
      status: map['status'],
    );
  }
}
