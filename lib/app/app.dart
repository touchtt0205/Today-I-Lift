import 'package:flutter/material.dart';
import 'app_scaffold.dart';

class TodayILiftApp extends StatelessWidget {
  const TodayILiftApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Today I Lift',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const AppScaffold(),
    );
  }
}
