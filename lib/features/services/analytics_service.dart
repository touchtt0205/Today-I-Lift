import 'package:today_i_lift/features/repositories/analytics_repository.dart';

class AnalyticsService {
  final _repo = AnalyticsRepository();

  /// วันที่มี workout (ใช้ highlight ใน Calendar)
  Future<List<DateTime>> getWorkoutDates() {
    return _repo.fetchWorkoutDates();
  }

  /// Sessions ของวันที่เลือกใน Calendar
  Future<List<Map<String, dynamic>>> getSessionsByDate(DateTime date) {
    return _repo.fetchSessionsByDate(date);
  }

  Future<Map<String, Map<String, dynamic>>> getDailyData() {
    return _repo.fetchDailyData();
  }

  /// Streak ต่อสัปดาห์
  Future<int> getWeekStreak() {
    return _repo.fetchWeekStreak();
  }

  /// Graph data
  Future<List<Map<String, dynamic>>> getGraphData({
    required String metric,
    required String range,
  }) {
    return _repo.fetchGraphData(metric: metric, range: range);
  }

  /// Muscle Distribution
  Future<Map<String, int>> getMuscleDistribution({String range = 'all'}) {
    return _repo.fetchMuscleDistribution(range: range);
  }

  /// Personal Records
  Future<List<Map<String, dynamic>>> getPersonalRecords() {
    return _repo.fetchPersonalRecords();
  }
}
