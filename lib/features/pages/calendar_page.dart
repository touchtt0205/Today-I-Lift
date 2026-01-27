import 'package:flutter/material.dart';
import 'package:today_i_lift/shared/widgets/gradient_app_bar.dart';

class CalendarPage extends StatelessWidget {
  const CalendarPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const GradientAppBar(
        title: 'Calendar',
        subtitle: 'Your workout schedule at a glance',
        showDate: false,
      ),
      body: const Center(
        child: Text(
          'Calendar Page',
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}
