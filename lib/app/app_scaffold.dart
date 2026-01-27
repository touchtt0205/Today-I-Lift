import 'package:flutter/material.dart';
import '../shared/widgets/bottom_nav_bar.dart';
import '../features/pages/home_page.dart';
import '../features/pages/workout_page.dart';
import '../features/pages/play_page.dart';
import '../features/pages/profile_page.dart';
import '../features/pages/calendar_page.dart';

class AppScaffold extends StatefulWidget {
  const AppScaffold({super.key});

  @override
  State<AppScaffold> createState() => _AppScaffoldState();
}

class _AppScaffoldState extends State<AppScaffold> {
  int _currentIndex = 0;

  final List<Widget> _pages = const [
    HomePage(), 
    WorkoutPage(),
    PlayPage(), 
    CalendarPage(),
    ProfilePage(),
  ];

  void _onTap(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavBar(
        currentIndex: _currentIndex,
        onTap: _onTap,
      ),
    );
  }
}
