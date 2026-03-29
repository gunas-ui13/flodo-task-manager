import 'package:flutter/material.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(const FlodoTaskApp());
}

class FlodoTaskApp extends StatelessWidget {
  const FlodoTaskApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flodo Tasks',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}