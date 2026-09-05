import 'package:flutter/material.dart';
import 'day3_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: Day3Screen(), // ← আপনার স্ক্রিন এখানে বসল
    );
  }
}