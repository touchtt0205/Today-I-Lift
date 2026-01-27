import 'package:flutter/material.dart';
import 'package:today_i_lift/shared/widgets/gradient_app_bar.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const GradientAppBar(
        title: 'Today I Lift',
        showDate: true,
      ),
      body: const Center(child: Text('Home Page')),
    );
  }
}
