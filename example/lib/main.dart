import 'package:fireflutter/fireflutter.dart';
import 'package:flutter/material.dart';

void main() async {
  runApp(
    MaterialApp(
      home: Builder(
        builder: (context) => ElevatedButton(
          onPressed: () => alert(
            context: context,
            title: 'Hello, there!',
            message: 'This is the simplest FireFlutter app.',
          ),
          child: const Text('Hello, FireFlutter!'),
        ),
      ),
    ),
  );
}
