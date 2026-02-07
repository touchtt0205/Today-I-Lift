import 'package:flutter/material.dart';
import 'shared/widgets/stat_card.dart';
import 'shared/widgets/last_workout_card.dart';
import 'shared/widgets/routine_card.dart';
import 'routine_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const HomeContent(),
    const RoutineScreen(),
    const Center(child: Text('Start Page')),
    const Center(child: Text('Calendar Page')),
    const Center(child: Text('Profile Page')),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],

      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.deepPurple,
        unselectedItemColor: Colors.grey,
        showSelectedLabels: false,
        showUnselectedLabels: false,
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(
            icon: Icon(Icons.fitness_center),
            label: 'Lift',
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.play_circle_fill,
              size: 48,
              color: Colors.deepOrange,
            ),
            label: 'Start',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today),
            label: 'Calendar',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}

class HomeContent extends StatelessWidget {
  const HomeContent({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          _buildHeader(),
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // --- Section: Last Workout ---
                const Text(
                  'Last Workout',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                const LastWorkoutCard(),
                const SizedBox(height: 24),

                // --- Section: Recent PRs ---
                const Text(
                  'Recent PRs',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                _buildRecentPRsList(),
                const SizedBox(height: 24),

                // --- Section: My Routines ---
                const Text(
                  'My Routines',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                const RoutineCard(
                  title: 'Push Day',
                  subtitle: '5 exercises • 3 Days Ago',
                  icon: Icons.fitness_center,
                  iconColor: Colors.redAccent,
                ),
                const RoutineCard(
                  title: 'Pull Day',
                  subtitle: '5 exercises • 1 Days Ago',
                  icon: Icons.waves,
                  iconColor: Colors.orangeAccent,
                ),
                const RoutineCard(
                  title: 'Leg Day',
                  subtitle: '5 exercises • 1 Days Ago',
                  icon: Icons.directions_walk,
                  iconColor: Colors.amber,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      height: 280, // ปรับความสูงเล็กน้อย
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment(0.8, 1),
          colors: <Color>[Color(0xFFFF8551), Color(0xEEEF4444)],
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            top: 45,
            right: 16,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.3),
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: const Icon(Icons.nightlight_round, color: Colors.white),
                onPressed: () {},
              ),
            ),
          ),
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 0, 16, 20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Today I Lift',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Saturday, Jan 4, 2026',
                  style: TextStyle(color: Colors.white70, fontSize: 16),
                ),
                SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: StatCard(
                        icon: Icons.local_fire_department,
                        label: 'Streak',
                        value: '5 🔥',
                      ),
                    ),
                    SizedBox(width: 8),
                    Expanded(
                      child: StatCard(
                        icon: Icons.track_changes,
                        label: 'This Week',
                        value: '6',
                        subValue: 'workouts',
                      ),
                    ),
                    SizedBox(width: 8),
                    Expanded(
                      child: StatCard(
                        icon: Icons.emoji_events,
                        label: 'New PRs',
                        value: '5',
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentPRsList() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          _buildPRItem('Bench Press', '2 days ago', '65 Kg', '+5kg'),
          const Divider(height: 1, indent: 16, endIndent: 16),
          _buildPRItem('Squat', '2 days ago', '85 Kg', '+5kg'),
          const Divider(height: 1, indent: 16, endIndent: 16),
          _buildPRItem('Deadlift', '2 days ago', '105 Kg', '+5kg'),
        ],
      ),
    );
  }

  Widget _buildPRItem(String name, String date, String weight, String diff) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              Text(
                date,
                style: const TextStyle(color: Colors.grey, fontSize: 12),
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                weight,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Colors.deepOrange,
                ),
              ),
              Text(
                diff,
                style: const TextStyle(
                  color: Colors.green,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
