import 'package:fireflutter/fireflutter.dart';
import 'package:flutter/material.dart';

void main() async {
  runApp(
    const MaterialApp(
      home: MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({
    super.key,
  });

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      FireFlutterService.instance.init(globalContext: () => context);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('FireFlutter Simplest App'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () => alert(
            context: context,
            title: 'Hello, there!',
            message: 'This is the simplest FireFlutter app.',
          ),
          child: const Text('Hello, FireFlutter!'),
        ),
      ),
    );
  }
}
