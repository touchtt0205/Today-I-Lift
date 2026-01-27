import 'package:flutter/material.dart';
import '../shared/widgets/bottom_nav_bar.dart';

class AppScaffold extends StatefulWidget {
  const AppScaffold({super.key});

  @override
  State<AppScaffold> createState() => _AppScaffoldState();
}

class _AppScaffoldState extends State<AppScaffold> {
  int _currentIndex = 0;

  final List<Widget> _pages = const [
    Center(child: Text('Home Tab')),        // index 0 - Home
    Center(child: Text('Workout Tab')),     // index 1 - Workout
    Center(child: Text('Play Tab')),        // index 2 - Play (กลาง)
    Center(child: Text('Calendar Tab')),    // index 3 - Calendar
    Center(child: Text('Profile Tab')),     // index 4 - Profile
  ];

  void _onTap(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Today I Lift'),
      ),
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavBar(
        currentIndex: _currentIndex,
        onTap: _onTap,
      ),
    );
  }
}