import 'package:flutter/material.dart';

class WorkoutSummaryScreen extends StatelessWidget {
  final int durationSeconds;

  const WorkoutSummaryScreen({super.key, required this.durationSeconds});

  String _formatDuration(int seconds) {
    final minutes = (seconds / 60).round(); // ปัดเป็นนาทีที่ใกล้สุด
    return '$minutes นาที';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Workout Summary'),
        centerTitle: true,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.check_circle, size: 96),
              const SizedBox(height: 24),
              const Text(
                'Workout Complete!',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              Text(
                'เวลารวม: ${_formatDuration(durationSeconds)}',
                style: const TextStyle(fontSize: 18),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.popUntil(context, (route) => route.isFirst);
                  },
                  child: const Text('Back to Home'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
