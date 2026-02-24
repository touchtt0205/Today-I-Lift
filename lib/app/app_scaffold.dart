import 'package:flutter/material.dart';
import 'package:today_i_lift/shared/widgets/bottom_nav_bar.dart';
import 'package:today_i_lift/shared/widgets/workout_modal.dart';
import 'package:today_i_lift/features/pages/home_page.dart';
// import 'package:today_i_lift/features/pages/workout_page.dart';
// import 'package:today_i_lift/features/pages/play_page.dart';
import 'package:today_i_lift/features/pages/profile_page.dart';
import 'package:today_i_lift/features/pages/calendar_page.dart';
import 'package:today_i_lift/features/pages/routine_list_page.dart';

class AppScaffold extends StatefulWidget {
  const AppScaffold({super.key});

  @override
  State<AppScaffold> createState() => _AppScaffoldState();
}

class _AppScaffoldState extends State<AppScaffold> {
  int _currentIndex = 0;

  final List<Widget> _pages = const [
    HomePage(),
    RoutineListPage(),
    SizedBox(),
    CalendarPage(),
    ProfilePage(),
  ];

  void _showWorkoutModal() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => const WorkoutModal(),
    );
  }

  void _onTap(int index) {
    if (index == 2) {
      _showWorkoutModal();
      return; // ไม่ต้องเปลี่ยนหน้า
    }
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
