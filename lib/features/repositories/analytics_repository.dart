import 'package:supabase_flutter/supabase_flutter.dart';

class AnalyticsRepository {
  final _supabase = Supabase.instance.client;
  String get _userId => _supabase.auth.currentUser!.id;

  // Calendar — วันที่มี session
  Future<List<DateTime>> fetchWorkoutDates() async {
    final data = await _supabase
        .from('workout_sessions')
        .select('started_at')
        .eq('user_id', _userId)
        .eq('status', 'completed')
        .order('started_at', ascending: false);

    return List<Map<String, dynamic>>.from(
      data,
    ).map((e) => DateTime.parse(e['started_at']).toLocal()).toList();
  }

  DateTime _getWeekStart(DateTime date) {
    final diff = date.weekday - DateTime.monday;
    return DateTime(date.year, date.month, date.day - diff);
  }

  // Session detail — กดวันใน Calendar
  Future<List<Map<String, dynamic>>> fetchSessionsByDate(DateTime date) async {
    final start = DateTime(date.year, date.month, date.day);
    final end = start.add(const Duration(days: 1));

    final data = await _supabase
        .from('workout_sessions')
        .select('*, routines(name , icon , color)')
        .eq('user_id', _userId)
        .eq('status', 'completed')
        .gte('started_at', start.toUtc().toIso8601String())
        .lt('started_at', end.toUtc().toIso8601String());

    return List<Map<String, dynamic>>.from(data);
  }

  Future<Map<String, Map<String, dynamic>>> fetchDailyData() async {
    final data = await _supabase
        .from('workout_sessions')
        .select('started_at, routines(name, color)')
        .eq('user_id', _userId)
        .eq('status', 'completed');

    final result = <String, Map<String, dynamic>>{};

    for (final row in List<Map<String, dynamic>>.from(data)) {
      final date = DateTime.parse(row['started_at']).toLocal();
      final key =
          '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

      result[key] = {
        'color': row['routines']?['color'],
        'name': row['routines']?['name'] ?? '',
      };
    }

    return result;
  }

  // Streak ต่อสัปดาห์
  Future<int> fetchWeekStreak() async {
    final data = await _supabase
        .from('workout_sessions')
        .select('started_at')
        .eq('user_id', _userId)
        .eq('status', 'completed')
        .order('started_at', ascending: false);

    final dates = List<Map<String, dynamic>>.from(
      data,
    ).map((e) => DateTime.parse(e['started_at']).toLocal()).toList();

    if (dates.isEmpty) return 0;

    // normalize เป็น week (ISO week = วันจันทร์)
    final weeks =
        dates
            .map((d) {
              final diff = d.weekday - 1;
              return DateTime(d.year, d.month, d.day - diff);
            })
            .toSet()
            .toList()
          ..sort((a, b) => b.compareTo(a));

    int streak = 0;
    DateTime expected = _getWeekStart(DateTime.now());

    for (final week in weeks) {
      if (week == expected ||
          week == expected.subtract(const Duration(days: 7))) {
        streak++;
        expected = week.subtract(const Duration(days: 7));
      } else {
        break;
      }
    }

    return streak;
  }

  // Graph data — duration / volume / reps ต่อสัปดาห์
  Future<List<Map<String, dynamic>>> fetchGraphData({
    required String metric,
    required String range,
  }) async {
    final now = DateTime.now();
    DateTime? from;

    switch (range) {
      case '1M':
        from = now.subtract(const Duration(days: 30));
        break;
      case '3M':
        from = now.subtract(const Duration(days: 90));
        break;
      case '6M':
        from = now.subtract(const Duration(days: 180));
        break;
      case '1Y':
        from = now.subtract(const Duration(days: 365));
        break;
      default:
        from = null;
    }

    // granularity ตาม range
    final groupBy = switch (range) {
      '1M' => 'day',
      '3M' || '6M' => 'week',
      _ => 'month',
    };

    if (metric == 'duration') {
      var query = _supabase
          .from('workout_sessions')
          .select('started_at, duration_seconds')
          .eq('user_id', _userId)
          .eq('status', 'completed');

      if (from != null) {
        query = query.gte('started_at', from.toUtc().toIso8601String());
      }

      final data = await query.order('started_at');
      final grouped = <String, double>{};

      for (final row in List<Map<String, dynamic>>.from(data)) {
        final date = DateTime.parse(row['started_at']).toLocal();
        final key = _getGroupKey(date, groupBy);
        final value = (((row['duration_seconds'] ?? 0) as num) / 60)
            .roundToDouble();
        grouped[key] = (grouped[key] ?? 0) + value;
      }

      return _toSortedList(grouped, groupBy);
    } else {
      var query = _supabase
          .from('workout_sets')
          .select(
            'weight, reps, completed_at, workout_sessions!inner(user_id, status, started_at)',
          )
          .eq('workout_sessions.user_id', _userId)
          .eq('workout_sessions.status', 'completed');

      if (from != null) {
        query = query.gte(
          'workout_sessions.started_at',
          from.toUtc().toIso8601String(),
        );
      }

      final data = await query.order('completed_at');
      final grouped = <String, double>{};

      for (final row in List<Map<String, dynamic>>.from(data)) {
        final date = DateTime.parse(row['completed_at']).toLocal();
        final key = _getGroupKey(date, groupBy);
        final weight = ((row['weight'] ?? 0) as num).toDouble();
        final reps = (row['reps'] ?? 0) as int;
        final value = metric == 'volume' ? weight * reps : reps.toDouble();
        grouped[key] = (grouped[key] ?? 0) + value;
      }

      return _toSortedList(grouped, groupBy);
    }
  }

  String _getGroupKey(DateTime date, String groupBy) {
    switch (groupBy) {
      case 'day':
        return DateTime(date.year, date.month, date.day).toIso8601String();
      case 'week':
        return _getWeekStart(date).toIso8601String();
      case 'month':
        return DateTime(date.year, date.month, 1).toIso8601String();
      default:
        return _getWeekStart(date).toIso8601String();
    }
  }

  List<Map<String, dynamic>> _toSortedList(
    Map<String, double> grouped,
    String groupBy,
  ) {
    return grouped.entries
        .map(
          (e) => {
            'date': DateTime.parse(e.key),
            'value': e.value,
            'groupBy': groupBy,
          },
        )
        .toList()
      ..sort(
        (a, b) => (a['date'] as DateTime).compareTo(b['date'] as DateTime),
      );
  }

  // Muscle Distribution
  Future<Map<String, int>> fetchMuscleDistribution({
    String range = 'all',
  }) async {
    DateTime? from;
    final now = DateTime.now();

    switch (range) {
      case '1M':
        from = now.subtract(const Duration(days: 30));
        break;
      case '3M':
        from = now.subtract(const Duration(days: 90));
        break;
      case '6M':
        from = now.subtract(const Duration(days: 180));
        break;
      case '1Y':
        from = now.subtract(const Duration(days: 365));
        break;
      default:
        from = null;
    }

    var query = _supabase
        .from('workout_sets')
        .select(
          'exercises(muscle_group), workout_sessions!inner(user_id, status, started_at)',
        )
        .eq('workout_sessions.user_id', _userId)
        .eq('workout_sessions.status', 'completed');

    if (from != null) {
      query = query.gte(
        'workout_sessions.started_at',
        from.toUtc().toIso8601String(),
      );
    }

    final data = await query;
    final result = <String, int>{};

    for (final row in List<Map<String, dynamic>>.from(data)) {
      final muscleGroup = row['exercises']?['muscle_group'] as String?;
      if (muscleGroup == null) continue;
      result[muscleGroup] = (result[muscleGroup] ?? 0) + 1;
    }

    return result;
  }

  // Personal Records — น้ำหนักสูงสุดต่อท่า
  Future<List<Map<String, dynamic>>> fetchPersonalRecords() async {
    final data = await _supabase
        .from('workout_sets')
        .select(
          'weight, reps, completed_at, exercises(name, muscle_group), workout_sessions!inner(user_id, status)',
        )
        .eq('workout_sessions.user_id', _userId)
        .eq('workout_sessions.status', 'completed')
        .order('weight', ascending: false);

    // เก็บแค่ PR ต่อ exercise (weight สูงสุด)
    final prMap = <String, Map<String, dynamic>>{};

    for (final row in List<Map<String, dynamic>>.from(data)) {
      final name = row['exercises']?['name'] as String?;
      if (name == null) continue;

      if (!prMap.containsKey(name)) {
        prMap[name] = {
          'name': name,
          'muscle_group': row['exercises']?['muscle_group'],
          'weight': row['weight'],
          'reps': row['reps'],
          'date': row['completed_at'],
        };
      }
    }

    final result = prMap.values.toList()
      ..sort((a, b) => (b['weight'] as num).compareTo(a['weight'] as num));

    return result;
  }
}
