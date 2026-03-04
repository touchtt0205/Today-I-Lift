import 'package:flutter/material.dart';
import 'package:today_i_lift/features/services/analytics_service.dart';
import 'package:today_i_lift/shared/analytics/analytics_view.dart'
    show AnalyticsView;
import 'package:today_i_lift/shared/widgets/gradient_app_bar.dart';
import 'package:today_i_lift/shared/widgets/heatmap_year_row.dart';
import 'package:today_i_lift/shared/widgets/month_view.dart';
import 'package:today_i_lift/shared/widgets/session_detail_card.dart';
import 'package:today_i_lift/shared/widgets/year_view.dart';

enum CalendarViewMode { month, year, multi }

class CalendarPage extends StatefulWidget {
  const CalendarPage({super.key});

  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage>
    with SingleTickerProviderStateMixin {
  final _service = AnalyticsService();

  late final TabController _tabController;

  CalendarViewMode _viewMode = CalendarViewMode.month;

  Set<DateTime> _workoutDates = {};
  Map<String, Map<String, dynamic>> _dailyData = {};

  DateTime _focusedMonth = DateTime.now();
  int _focusedYear = DateTime.now().year;

  DateTime? _selectedDate;
  List<Map<String, dynamic>> _selectedSessions = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    final dates = await _service.getWorkoutDates();
    final dailyData = await _service.getDailyData();

    if (!mounted) return;

    setState(() {
      _workoutDates = dates
          .map((d) => DateTime(d.year, d.month, d.day))
          .toSet();
      _dailyData = dailyData;
    });
  }

  Future<void> _onDayTapped(DateTime date) async {
    final normalized = DateTime(date.year, date.month, date.day);

    if (!_workoutDates.contains(normalized)) {
      setState(() {
        _selectedDate = null;
        _selectedSessions = [];
      });
      return;
    }

    final sessions = await _service.getSessionsByDate(date);

    if (!mounted) return;

    setState(() {
      _selectedDate = normalized;
      _selectedSessions = sessions;
    });
  }

  List<int> _getYears() {
    if (_dailyData.isEmpty) return [DateTime.now().year];
    return _dailyData.keys
        .map((k) => int.parse(k.split('-')[0]))
        .toSet()
        .toList()
      ..sort((a, b) => b.compareTo(a));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const GradientAppBar(
        title: 'Progress',
        subtitle: 'Track your journey',
        showDate: false,
      ),
      body: Column(
        children: [
          Container(
            color: Colors.white,
            child: TabBar(
              controller: _tabController,
              indicatorColor: const Color(0xFFFF7043),
              labelColor: const Color(0xFFFF7043),
              unselectedLabelColor: Colors.grey,
              labelStyle: const TextStyle(fontWeight: FontWeight.bold),
              tabs: const [
                Tab(text: 'Calendar'),
                Tab(text: 'Analytics'),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [_buildCalendarTab(), const AnalyticsView()],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCalendarTab() {
    return Column(
      children: [
        _buildViewToggle(),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                if (_viewMode == CalendarViewMode.month)
                  MonthView(
                    focusedMonth: _focusedMonth,
                    workoutDates: _workoutDates,
                    dailyData: _dailyData,
                    selectedDate: _selectedDate,
                    onDayTapped: _onDayTapped,
                    onMonthChanged: (m) => setState(() => _focusedMonth = m),
                  ),
                if (_viewMode == CalendarViewMode.year)
                  YearView(
                    focusedYear: _focusedYear,
                    workoutDates: _workoutDates,
                    dailyData: _dailyData,
                    onYearChanged: (y) => setState(() => _focusedYear = y),
                  ),
                if (_viewMode == CalendarViewMode.multi)
                  ..._getYears().map(
                    (y) => HeatmapYearRow(
                      year: y,
                      dailyData: _dailyData,
                      onDayTapped: _onDayTapped,
                    ),
                  ),
                if (_selectedDate != null)
                  SessionDetailCard(
                    date: _selectedDate!,
                    sessions: _selectedSessions,
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildViewToggle() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _toggleButton('Month', CalendarViewMode.month),
          const SizedBox(width: 8),
          _toggleButton('Year', CalendarViewMode.year),
          const SizedBox(width: 8),
          _toggleButton('All Time', CalendarViewMode.multi),
        ],
      ),
    );
  }

  Widget _toggleButton(String label, CalendarViewMode mode) {
    final selected = _viewMode == mode;
    return GestureDetector(
      onTap: () => setState(() => _viewMode = mode),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFFFF7043) : Colors.grey[100],
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? Colors.white : Colors.grey[600],
            fontWeight: FontWeight.bold,
            fontSize: 13,
          ),
        ),
      ),
    );
  }
}
