import 'package:flutter/material.dart';

void main() async {
  runApp(const FireFlutterExample());
}

class FireFlutterExample extends StatelessWidget {
  const FireFlutterExample({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
    );
  }
}
