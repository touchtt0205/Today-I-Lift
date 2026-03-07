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

  // ใน AnalyticsRepository

  /// Last completed session
  // Future<Map<String, dynamic>?> fetchLastWorkout() async {
  //   final data = await _supabase
  //       .from('workout_sessions')
  //       .select('*, routines(name, icon, color)')
  //       .eq('user_id', _userId)
  //       .eq('status', 'completed')
  //       .order('finished_at', ascending: false)
  //       .limit(1)
  //       .maybeSingle();

  //   return data;
  // }

  // /// Recent PRs — ท่าที่ทำ PR ใหม่ใน 7 วันล่าสุด
  // Future<List<Map<String, dynamic>>> fetchRecentPRs() async {
  //   final since = DateTime.now()
  //       .subtract(const Duration(days: 7))
  //       .toUtc()
  //       .toIso8601String();

  //   // ดึง sets ทั้งหมดใน 7 วัน
  //   final recentSets = await _supabase
  //       .from('workout_sets')
  //       .select(
  //         'weight, reps, completed_at, exercises(name, muscle_group), workout_sessions!inner(user_id, status)',
  //       )
  //       .eq('workout_sessions.user_id', _userId)
  //       .eq('workout_sessions.status', 'completed')
  //       .gte('completed_at', since)
  //       .order('weight', ascending: false);

  //   // ดึง all-time PR ต่อท่า
  //   final allPRs = await fetchPersonalRecords();
  //   final prMap = {for (final pr in allPRs) pr['name']: pr['weight']};

  //   // กรองเฉพาะที่ weight เท่ากับ all-time PR (แปลว่าเพิ่งทำ PR)
  //   final result = <String, Map<String, dynamic>>{};

  //   for (final row in List<Map<String, dynamic>>.from(recentSets)) {
  //     final name = row['exercises']?['name'] as String?;
  //     if (name == null) continue;

  //     final weight = (row['weight'] as num).toDouble();
  //     final allTimePR = (prMap[name] as num?)?.toDouble();

  //     if (allTimePR != null &&
  //         weight >= allTimePR &&
  //         !result.containsKey(name)) {
  //       result[name] = {
  //         'name': name,
  //         'muscle_group': row['exercises']?['muscle_group'],
  //         'weight': weight,
  //         'reps': row['reps'],
  //         'date': row['completed_at'],
  //       };
  //     }
  //   }

  //   return result.values.toList();
  // }

  /// จำนวน session สัปดาห์นี้
  Future<int> fetchWorkoutsThisWeek() async {
    final weekStart = _getWeekStart(DateTime.now()).toUtc().toIso8601String();

    final data = await _supabase
        .from('workout_sessions')
        .select('id')
        .eq('user_id', _userId)
        .eq('status', 'completed')
        .gte('started_at', weekStart);

    return List<Map<String, dynamic>>.from(data).length;
  }

  /// Last workout + sets stats
  Future<Map<String, dynamic>?> fetchLastWorkout() async {
    final session = await _supabase
        .from('workout_sessions')
        .select('*, routines(name, icon, color)')
        .eq('user_id', _userId)
        .eq('status', 'completed')
        .order('finished_at', ascending: false)
        .limit(1)
        .maybeSingle();

    if (session == null) return null;

    // ดึง sets ของ session นั้น
    final sets = await _supabase
        .from('workout_sets')
        .select('weight, reps, exercise_id')
        .eq('session_id', session['id']);

    final setList = List<Map<String, dynamic>>.from(sets);
    final totalSets = setList.length;
    final totalExercises = setList.map((s) => s['exercise_id']).toSet().length;
    final totalVolume = setList.fold<double>(
      0,
      (sum, s) => sum + ((s['weight'] as num).toDouble() * (s['reps'] as int)),
    );

    return {
      ...session,
      'total_sets': totalSets,
      'total_exercises': totalExercises,
      'total_volume': totalVolume,
    };
  }

  Future<List<Map<String, dynamic>>> getRecentPRs() async {
    // ดึง session ล่าสุด
    final lastSession = await _supabase
        .from('workout_sessions')
        .select('id, started_at')
        .eq('user_id', _userId)
        .eq('status', 'completed')
        .order('started_at', ascending: false)
        .limit(1)
        .maybeSingle();

    if (lastSession == null) return [];

    // ดึง session ก่อนหน้า (อันที่ 2)
    final prevSession = await _supabase
        .from('workout_sessions')
        .select('id')
        .eq('user_id', _userId)
        .eq('status', 'completed')
        .lt('started_at', lastSession['started_at'])
        .order('started_at', ascending: false)
        .limit(1)
        .maybeSingle();

    // sets ของ session ล่าสุด
    final currentSets = await _supabase
        .from('workout_sets')
        .select('weight, reps, exercises(name, muscle_group)')
        .eq('session_id', lastSession['id']);

    // PR สูงสุดของ session ก่อนหน้า
    final prevPRMap = <String, double>{};
    if (prevSession != null) {
      final prevSets = await _supabase
          .from('workout_sets')
          .select('weight, exercises(name)')
          .eq('session_id', prevSession['id']);

      for (final row in List<Map<String, dynamic>>.from(prevSets)) {
        final name = row['exercises']?['name'] as String?;
        if (name == null) continue;
        final w = (row['weight'] as num).toDouble();
        if (!prevPRMap.containsKey(name) || w > prevPRMap[name]!) {
          prevPRMap[name] = w;
        }
      }
    }

    // max weight ของ session ล่าสุด ต่อท่า
    final currentMax = <String, Map<String, dynamic>>{};
    for (final row in List<Map<String, dynamic>>.from(currentSets)) {
      final name = row['exercises']?['name'] as String?;
      if (name == null) continue;
      final w = (row['weight'] as num).toDouble();
      if (!currentMax.containsKey(name) ||
          w > (currentMax[name]!['weight'] as num).toDouble()) {
        currentMax[name] = row;
      }
    }

    // เปรียบเทียบ
    final result = <Map<String, dynamic>>[];
    currentMax.forEach((name, row) {
      final weight = (row['weight'] as num).toDouble();
      final prevPR = prevPRMap[name] ?? 0.0;

      if (weight > prevPR) {
        result.add({
          'name': name,
          'muscle_group': row['exercises']?['muscle_group'],
          'weight': weight,
          'reps': row['reps'],
          'increase': prevPR == 0 ? weight : weight - prevPR,
          'date': lastSession['started_at'],
        });
      }
    });

    return result;
  }

  /// Last played date ต่อ routine
  Future<Map<String, DateTime>> fetchLastPlayedPerRoutine() async {
    final data = await _supabase
        .from('workout_sessions')
        .select('routine_id, started_at')
        .eq('user_id', _userId)
        .eq('status', 'completed')
        .order('started_at', ascending: false);

    final result = <String, DateTime>{};

    for (final row in List<Map<String, dynamic>>.from(data)) {
      final routineId = row['routine_id'] as String;
      if (!result.containsKey(routineId)) {
        result[routineId] = DateTime.parse(row['started_at']).toLocal();
      }
    }

    return result;
  }
}
