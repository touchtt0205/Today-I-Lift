import 'package:today_i_lift/features/repositories/analytics_repository.dart';

class AnalyticsService {
  final _repo = AnalyticsRepository();

  Future<List<DateTime>> getWorkoutDates() {
    return _repo.fetchWorkoutDates();
  }

  Future<List<Map<String, dynamic>>> getSessionsByDate(DateTime date) {
    return _repo.fetchSessionsByDate(date);
  }

  Future<Map<String, Map<String, dynamic>>> getDailyData() {
    return _repo.fetchDailyData();
  }

  Future<int> getWeekStreak() {
    return _repo.fetchWeekStreak();
  }

  Future<List<Map<String, dynamic>>> getGraphData({
    required String metric,
    required String range,
  }) {
    return _repo.fetchGraphData(metric: metric, range: range);
  }

  Future<Map<String, int>> getMuscleDistribution({String range = 'all'}) {
    return _repo.fetchMuscleDistribution(range: range);
  }

  Future<List<Map<String, dynamic>>> getPersonalRecords() {
    return _repo.fetchPersonalRecords();
  }

  Future<Map<String, dynamic>?> getLastWorkout() {
    return _repo.fetchLastWorkout();
  }

  Future<List<Map<String, dynamic>>> getRecentPRs() {
    return _repo.getRecentPRs();
  }

  Future<int> getWorkoutsThisWeek() {
    return _repo.fetchWorkoutsThisWeek();
  }

  Future<Map<String, DateTime>> getLastPlayedPerRoutine() {
    return _repo.fetchLastPlayedPerRoutine();
  }
}
